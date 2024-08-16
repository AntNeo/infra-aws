## Set AWS Credentials
Set environment variables before issuing terraform commands:
```bash
export export AWS_ACCESS_KEY_ID="<your_aws_access_key_id>"
export AWS_SECRET_ACCESS_KEY="<your_aws_secret_access_key>"
```

## Create S3(Already Done)
You can skip this step as it should only be performed once.

The tfstates backend S3 buckets needs to be created in advanced before any resource can be created. To do this, change directory to `shared/state/s3-backend` and run terraform commands:
```bash
terraform init
terraform apply
```

## Create Shared Resources
There are 2 environments namely `prod` and `uat`, by which the listed resources are shared:
- ALB
- ECR
- Jenkins

To create ALB, change directory to `shared/foundation/alb` and run:
```bash
terraform init # only for the first time you run terraform for this resource
terraform apply
```

To create ECR, change directory to `shared/foundation/ecr` and run:
```bash
terraform init # only for the first time you run terraform for this resource
terraform apply
```

To create Jenkins, change directory to `shared/foundation/` and run:
```bash
terraform init # only for the first time you run terraform for this resource
terraform apply
```
Jenkins login user is as follow:
```bash
username: antoneo
```
password can be retrieved by issuing command under directory `shared/foundation/jenkins`:
```bash
terraform output -raw jenkins_admin_password
```

## Create UAT Resources
To create `uat` dedicated resources, change directory to `uat` and run:
```bash
terraform init # only for the first time you run terraform for this resource
terraform apply -target=uatvpc
terraform apply
```

## Create Prod Resources
To create `prod` dedicated resources, change directory to `prod` and run:
```bash
terraform init # only for the first time you run terraform for this resource
terraform apply -target=prodvpc
terraform apply
```