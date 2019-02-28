# Topic-3: Templating & remote state

**1.** Amend your **terraform.tfvars** file in *working-dir* and add the following variables:

```bash
 db_name = "wordpress_db"
 db_user = "admin"
 db_password = "adminpwd"
```

Note that db_password should be at least 8 char length. 


**DO NOT** commit your terraform.tfvars file to version control as it contains db_password value which is a sensitive data.

**2.** Copy all .tf and .sh files from directory topic-3 to your working-dir as shown below and in *backend.tf* file specify bucket name
that you've created in the *topic-0*.

```bash
 cp ../topic-3/*.tf ./
 cp ../topic-3/*.sh ./
```

**3.** Examine what has changed in which files and commit changes to your forked repository.

```bash
 git status
 git diff <path_to_file>
 git commit -am "Topic 3 files and changes"
```

**4.** Since we've changed our terraform state backend from local to s3, this requires reinitialization. Execute *terraform init*. 
You'll be prompted with question if you want to copy state from "local" to "s3". Enter "yes". 

```bash
 terraform init
```

<details><summary>Click here to expand for more details</summary>
<p>

```
 $ terraform init

Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. An existing non-empty state already exists in
  the new backend. The two states have been saved to temporary files that will be
  removed after responding to this query.
  
  Previous (type "local"): /var/folders/pf/3rmfygm55m54skdnln5hpvq00000gn/T/terraform734438438/1-local.tfstate
  New      (type "s3"): /var/folders/pf/3rmfygm55m54skdnln5hpvq00000gn/T/terraform734438438/2-s3.tfstate
  
  Do you want to overwrite the state in the new backend with the previous state?
  Enter "yes" to copy and "no" to start with the existing state in the newly
  configured "s3" backend.

  Enter a value: yes


Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 1.54"
* provider.template: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
</p>
</details>
</br>

**5.** Create terraform plan and examine the output. 

 - How many resources are going to be created? Changed? Destroyed? 
 - Can you identify which resource/attribute change causes the re-provisioning of the resource? 
 
```bash
 terraform plan
```

<details><summary>Click here to expand for more details</summary>
<p>

```hcl-terraform
terraform plan
 
 ...
  [ Some output removed ]
 ...
 
  ipv6_cidr_block_association_id:                                                           <computed>
       map_public_ip_on_launch:                                                                  "false"
       owner_id:                                                                                 <computed>
       tags.%:                                                                                   "1"
       tags.Name:                                                                                "private-db-john-snow-default-1"
       vpc_id:                                                                                   "vpc-0379a7d432dcd362e"
 
 
 Plan: 9 to add, 0 to change, 3 to destroy.
 
 ------------------------------------------------------------------------
 
 Note: You didn't specify an "-out" parameter to save this plan, so Terraform
 can't guarantee that exactly these actions will be performed if
 "terraform apply" is subsequently run.

```
</p>
</details>
</br>

**6.** Apply the terraform plan.

```bash
 terraform apply -auto-approve
```

<details><summary>Click here to expand for more details</summary>
<p>

```hcl-terraform
aws_launch_configuration.as_conf: Destroying... (ID: arya-stark-lc-default)
aws_security_group.rds: Creating...
  arn:                    "" => "<computed>"

 ...
  [ Some output removed ]
 ...
 
aws_launch_configuration.as_conf.deposed: Destroying... (ID: john-snow-lc-default)
aws_launch_configuration.as_conf.deposed: Destruction complete after 0s

Apply complete! Resources: 9 added, 0 changed, 3 destroyed.

Outputs:

alb_dns_name = arya-stark-alb-default-1946164951.eu-central-1.elb.amazonaws.com
alb_id = arn:aws:elasticloadbalancing:eu-central-1:437278685207:loadbalancer/app/arya-stark-alb-default/6c3fee0674b25616
db_endpoint = arya-stark-default.cbxsw293mz36.eu-central-1.rds.amazonaws.com
db_port = 3306
vpc_id = vpc-0dc49a0686a231015

```
</p>
</details>
</br>

**7.** Copy and paste application load balancer dns URL **alb_dns_name** from the outputs section to your browser and you should 
see WordPress welcome page with the **"owner"** value reference at the top similar as in the below screenshot. 

![WordPressHomepage](https://github.com/AmazingStuffPro/iac-workshop/blob/master/_docs/wp_homepage.png?raw=true)

This concludes our workshop, congratulations for making this far! Be aware that we've covered only the terraform basics
and IaC with terraform is capable of much more than that. 