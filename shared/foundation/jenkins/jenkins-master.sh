#!/bin/bash
set -x
set -e
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker ubuntu

# Pull and run Jenkins Docker image
sudo mkdir /var/jenkins_home && sudo chown ubuntu:ubuntu /var/jenkins_home
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home --restart=always --name jenkins jenkins/jenkins:lts

# wait master up
sleep 30

# Output Jenkins initial admin password
INITIAL_PASSWORD=$(sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
echo $INITIAL_PASSWORD

# download jenkins-cli.jar
sudo docker exec jenkins curl -s http://localhost:8080/jenkins/jnlpJars/jenkins-cli.jar -o /var/jenkins_home/jenkins-cli.jar
if [ $? -ne 0 ]; then
    echo "Failed to download jenkins-cli.jar"
    exit 1
fi
echo "====================================================================="
# create a new admin user
sudo docker exec -i jenkins sh -c "echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"${jenkins_admin}\", \"${jenkins_password}\")' | java -jar /var/jenkins_home/jenkins-cli.jar -auth admin:$INITIAL_PASSWORD -s http://localhost:8080/ groovy ="

# # install instance-identity plugins for agent register
sudo docker exec -i jenkins sh -c "jenkins-plugin-cli --plugins instance-identity aws-credentials docker-workflow"

# # restart jenkins for plugin reload
sudo docker restart jenkins
