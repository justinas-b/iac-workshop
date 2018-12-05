# iac-workshop

## Getting started

This workshop is separated into several topics that cover various aspects of infrastructure as code with terraform aspects. Each topic relevant terraform configuration code is placed into a separate directory. Main directory where the participant would perform terraform runs is **"working-dir"**. This is where contents from each topic directory should be copy/pasted as progressing through the workshop.

![IaC workshop architecture](https://github.com/AmazingStuffPro/iac-workshop/blob/master/_docs/architecture.png?raw=true)

### Prerequisites
You need to have terraform in your path, AWS account and credentials set in order to provision target infra.

### Provisioning
In the directory **"working-dir"** create file terraform.tfvars with variables and appropriate values according to your account:

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
And you'll get similar output as shown below:
```
...

aws_lb_listener.front_end: Creation complete after 10s (ID: arn:aws:elasticloadbalancing:eu-central...ault/04f6e3fd44656f37/cffd81baa98f9f33)

Apply complete! Resources: 33 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = john-snow-alb-default-208374325.eu-central-1.elb.amazonaws.com
alb_id = arn:aws:elasticloadbalancing:eu-central-1:437278685207:loadbalancer/app/john-snow-alb-default/032ef4304fe2db3f
```
