#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io xmlstarlet jq
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker ubuntu

# wait for master up
sleep 120
until curl -s -f ${jenkins_url}/whoAmI/api/json; do
  echo waiting for jenkins-up
  sleep 5
done

# Node create
CURL_CREDENTIALS="${username}:${password}"
COOKIEJAR="$(mktemp)"
CRUMB_ISSUER_URL="${jenkins_url}/crumbIssuer/api/json"
echo "Making crumb request to: $CRUMB_ISSUER_URL"
CRUMB_JSON=$(curl -u "$CURL_CREDENTIALS" --cookie-jar "$COOKIEJAR" $CRUMB_ISSUER_URL)
CRUMB_FIELD=$(echo "$CRUMB_JSON" | jq --raw-output '.crumbRequestField')
CRUMB=$(echo "$CRUMB_JSON" | jq --raw-output '.crumb')
CRUMB_HEADER="$CRUMB_FIELD:$CRUMB"

NODE_REQUEST_JSON=$(
  cat <<EOF
{
  "name": "${agent_name}",
  "nodeDescription": "agent create automatically",
  "numExecutors": "1",
  "remoteFS": "/home/jenkins/agent",
  "labelString": "",
  "mode": "NORMAL",
  "": ["hudson.slaves.JNLPLauncher", "hudson.slaves.RetentionStrategy\$Always"],
  "launcher": {
    "stapler-class": "hudson.slaves.JNLPLauncher",
    "\$class": "hudson.slaves.JNLPLauncher",
    "workDirSettings": {
      "disabled": false,
      "workDirPath": "",
      "internalDir": "remoting",
      "failIfWorkDirIsMissing": false
    }
  },
  "retentionStrategy": {
    "stapler-class": "hudson.slaves.RetentionStrategy\$Always",
    "\$class": "hudson.slaves.RetentionStrategy\$Always"
  },
  "nodeProperties": { "stapler-class-bag": "true" },
  "type": "hudson.slaves.DumbSlave",
  "$CRUMB_FIELD": "$CRUMB"
}
EOF
)

NODE_CREATE_URL="${jenkins_url}/computer/doCreateItem?name=${agent_name}&type=hudson.slaves.DumbSlave"
RESPONSE_STATUS=$(curl -L -s -o /dev/null -w "%%{http_code}" -u "$CURL_CREDENTIALS" --cookie "$COOKIEJAR" -H "Content-Type:application/x-www-form-urlencoded" -H "$CRUMB_HEADER" -X POST -d "json=$NODE_REQUEST_JSON" $NODE_CREATE_URL)

if [[ $RESPONSE_STATUS == "200" ]]; then
  echo "SUCCESS"
elif [[ $RESPONSE_STATUS == "400" ]]; then
  echo "Response status: [400], continuing"
else
  echo "ERROR: Failed to create node. Response code: [$RESPONSE_STATUS]"
  exit 1
fi

AGENT_JNLP_URL="${jenkins_url}/computer/${agent_name}/slave-agent.jnlp"
SECRET=$(curl -L -s -u "$CURL_CREDENTIALS" -H "$CRUMB_HEADER" -X GET $AGENT_JNLP_URL | xmlstarlet sel -t -v "//jnlp/application-desc/argument[1]")

echo "Secret: $SECRET"
echo $SECRET | tr -d '\n' >jenkins-agent-secret.txt

# run agent

sudo docker run -d --name jenkins-agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker --user root --init jenkins/inbound-agent -url ${jenkins_url} -workDir=/home/jenkins/agent -secret $SECRET -name ${agent_name}
