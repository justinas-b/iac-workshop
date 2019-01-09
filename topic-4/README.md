# TBC

### Provisioning

Create file terraform.tfvars with the below variables. Change owner, db_password values according to yourself.
```
owner = "john-snow"
key_pair = "frankfurt-ignas"
region = "eu-central-1"
network = "10.0.0.0/25"
subnet_bits = 3
db_name = "wordpress_db"
db_user = "admin"
db_password = "********"
```

Note that db_password should be at least 8 char length. 
Don't commit your terraform.tfvars file to version control as it contains db_password value it is a sensitive data.

Resources in each directory needs to be provisioned in a following order:
1. vpc
2. database
3. compute


To provision resources, cd to each of the directory and perform terraform plan and apply:

```bash
cd vpc
terraform plan -out tfplan -var-file=../terraform.tfvars
terraform apply "tfplan"
```
