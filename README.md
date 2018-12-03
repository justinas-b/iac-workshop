# iac-workshop

## Getting started

### Prerequisites
You need to have terraform in your path, AWS account and credentials set in order to provision target infra.  

### Provisioning
In the root directory create file terraform.tfvars with variables and appropriate values according to your account:

```
owner = "john-snow"
key_pair = "workshop-keypair"
```

And then execute:

```
terraform init
terraform plan
terraform apply
```
