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

## Create Prod Resources
To create `prod` dedicated resources, change directory to `prod` and run:
```bash
terraform init # only for the first time you run terraform for this resource
terraform apply -target=prodvpc
terraform apply
```