# Main working directory

### Provisioning
Create file terraform.tfvars with variables and appropriate values according to your account:

```
owner = "john-snow"
key_pair = "workshop-keypair"
region = "eu-west-1"
network = "10.0.0.0/26"
subnet_bits = 2
```

And then execute:

```
terraform init
terraform plan
terraform apply
```
