# iac-workshop

## Getting started

This workshop is separated into several topics that cover various aspects of infrastructure as code with terraform aspects. Each topic relevant terraform configuration code is placed into a separate directory. Main directory where the participant would perform terraform runs is **"working-dir"**. This is where contents from each topic directory should be copy/pasted as progressing through the workshop.

![IaC workshop architecture](https://github.com/AmazingStuffPro/iac-workshop/blob/master/_docs/architecture.png?raw=true)

### Prerequisites
 - You need to have terraform in your path, AWS account and credentials set in order to provision target infra.
 - This repo forked to your account

### Provisioning
In the directory **"working-dir"** create file terraform.tfvars with variables and appropriate values according to your account:

```
owner = "john-snow"
key_pair = "frankfurt-ignas"
region = "eu-central-1"
network = "10.0.0.0/25"
subnet_bits = 3
db_name = "wordpress_db"
db_user = "admin"
db_password = "adminpwd"
```
Note that db_password should be at least 8 char length. 
**DO NOT** commit your terraform.tfvars file to version control as it contains db_password value which is a sensitive data.

Then follow the instructions in each topic.
