#!/bin/bash

set -x
set -e

# Update the package lists and install Docker
sudo yum update -y
sudo yum install -y docker

# Start and enable the Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add the user to the docker group
sudo usermod -aG docker ec2-user

# Create a directory for Jenkins data and set appropriate permissions
sudo mkdir /var/jenkins_home
sudo chown ec2-user:ec2-user /var/jenkins_home

# Run the Jenkins Docker image
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home --restart=always --name jenkins jenkins/jenkins:lts

# Wait for Jenkins to start up
sleep 30

# Output the initial admin password
INITIAL_PASSWORD=$(sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
echo $INITIAL_PASSWORD

# Download jenkins-cli.jar
sudo docker exec jenkins curl -u admin:$INITIAL_PASSWORD -s http://localhost:8080/jnlpJars/jenkins-cli.jar -o /var/jenkins_home/jenkins-cli.jar
if [ $? -ne 0 ]; then
    echo "Failed to download jenkins-cli.jar"
    exit 1
fi

echo "====================================================================="

# Create a new admin user (make sure to set jenkins_admin and jenkins_password environment variables)
sudo docker exec -i jenkins sh -c "echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"${jenkins_admin}\", \"${jenkins_password}\")' | java -jar /var/jenkins_home/jenkins-cli.jar -auth admin:$INITIAL_PASSWORD -s http://localhost:8080/ groovy ="

# Install instance-identity plugins for agent register
sudo docker exec -i jenkins sh -c "java -jar /var/jenkins_home/jenkins-cli.jar -s http://localhost:8080/ install-plugin instance-identity aws-credentials docker-workflow --restart no"

# Restart Jenkins for plugin reload
sudo docker restart jenkins
