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
Jenkins login credentials are as follow:
```
username: antoneo
password: an2mW_x0mcE9E7lL
```

## Create UAT Resources
To create UAT dedicated resources, change directory to `uat` and run:
```bash
terraform init # only for the first time you run terraform for this resource
terraform apply
```