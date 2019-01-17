# TBC

### Provisioning

**1.** Firsly, we need to destroy currently provisioned infrastructure:

```bash
 $ terraform plan -destroy
 $ terraform destroy
```

**2.** In order to make refactoring process simple, let's remove currently existing files from the **working-dir** by
executing command below. The only directory that should still be available is **.terraform**.

```bash
 $ rm ./*.tf && rm ./*.sh
 $ ls -al 
  total 0
  drwxr-xr-x   3 Ignas  staff   96 Jan 15 21:55 .
  drwxr-xr-x  13 Ignas  staff  416 Jan 10 15:36 ..
  drwxr-xr-x   4 Ignas  staff  128 Jan 10 15:51 .terraform
```

**3.** Copy all file structure recursively from directory topic-4 to your working-dir:

```bash
 $ cp -aR ../topic-4/* ./
```

**4.** Each component (directory and resources defined in that directory) will have to be provisioned in a following order:
1. vpc
2. database
3. compute


But before that we'll need update backend configuration where the terraform state of your infrastructure will be stored.

Let's start with the **vpc** configuration. 

**4.1.** In *vpc* directory update **backend.tf** file with your bucket and key values. Pay close attention to the **key**
value where path to terraform state file is specified. Also, *bucket* and *region* values should be the same as defined
in your *terraform.tfvars* file.

```hcl-terraform
terraform {
  backend "s3" {
    bucket = "john-snow-state-437278685207"
    key    = "workshop/vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}
```

**4.2.** Since we already have the provider plugins downloaded on disk from previous topics, we can reference them during 
initialization. This way we won't need to download same plugins each time we'll be initializing terraform in separate directories. 

```bash
 $ cd vpc
 $ terraform init -plugin-dir=../.terraform/plugins/darwin_amd64/
```

Depending on your OS and architecture, the path above might be slightly different.

**4.3.** 
To provision resources perform terraform plan and apply:

```bash
terraform plan -out tfplan -var-file=../../terraform.tfvars
terraform apply "tfplan"
```

**5.** Repeat 4.1., 4.2., 4.3. steps for directories *database* and *compute* with appropriate values changed accordingly.

**6.** If everything has been configured correctly, after provisioning *compute* layer you should should get similar output 
as shown below. 

```hcl-terraform
  target_tracking_configuration.0.predefined_metric_specification.0.predefined_metric_type: "" => "ASGAverageCPUUtilization"
  target_tracking_configuration.0.target_value:                                             "" => "40"
aws_autoscaling_policy.bat: Creation complete after 1s (ID: john-snow-default-asg-policy)

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = john-snow-alb-default-1174222442.eu-central-1.elb.amazonaws.com
alb_id = arn:aws:elasticloadbalancing:eu-central-1:749030158231:loadbalancer/app/john-snow-alb-default/3f626b7310531282

```

**7.** In your browser open your application load balancer dns URL "alb_dns_name" from the outputs section and you should 
see WordPres welcome page.
