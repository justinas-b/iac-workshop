# TBC

**1.** Copy all .tf and .sh files from directory topic-3 to your working-dir:

```bash
cp ../topic-3/*.tf ./
cp ../topic-3/*.sh ./

```

**2.** Examine what has changed in which files and commit changes to your forked repository.

```bash
 $ git status
 $ git diff <path_to_file>
 $ git commit -am "Topic 3 files and changes"
```

**3.** Since we've changed our terraform state backend from local to s3, this requires reinitialization. Execute *terraform init*. 
You'll be prompted with question if you want to copy state from "local" to "s3". Enter "yes". 

```bash
 $ terraform init
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

**4.** Create terraform plan and examine the output. 

 - How many resources are going to be created? Changed? Destroyed? 
 - Can you identify which resource/attribute change causes the re-provisioning of the resource? 
 
 ```bash
 $ terraform plan
```

<details><summary>Click here to expand for more details</summary>
<p>

```hcl-terraform
 $ terraform plan
 
 ...
  [ Some output removed ]
 ...
 
 Plan: 7 to add, 1 to change, 1 to destroy.
 
 ------------------------------------------------------------------------
 
 Note: You didn't specify an "-out" parameter to save this plan, so Terraform
 can't guarantee that exactly these actions will be performed if
 "terraform apply" is subsequently run.
 

```
</p>
</details>
</br>

**5.** Apply the terraform plan.

```bash
 $ terraform apply
```

<details><summary>Click here to expand for more details</summary>
<p>

```hcl-terraform
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_launch_configuration.as_conf: Destroying... (ID: arya-stark-lc-default)
aws_security_group.rds: Creating...
  arn:                    "" => "<computed>"

 ...
  [ Some output removed ]
 ...
 
aws_db_instance.default: Creation complete after 4m3s (ID: arya-stark-default)
data.template_file.init: Refreshing state...

Error: Error applying plan:

1 error(s) occurred:

* aws_launch_configuration.as_conf (destroy): 1 error(s) occurred:

* aws_launch_configuration.as_conf: ResourceInUse: Cannot delete launch configuration arya-stark-lc-default because it is attached to AutoScalingGroup arya-stark-asg-default
        status code: 400, request id: 3ed49642-141c-11e9-a5e8-47e4b055fdc9

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.

 
```
</p>
</details>
</br>

**6.** Oooops! Terraform failed to update launch configuration since it is attached to an autoscaling group. 
Let's take an easy approach and taint the autoscaling group. Tainting will indicate terraform to destroy and 
reprovision this resource during next terraform run. 

Taint the autoscaling group resource, create a plan and examine the output.

 - How many resources will be created/destroyed? Why?
 - Can you identify the tainted resource? 

```bash
 $ terraform state list | grep asg
aws_autoscaling_group.asg
aws_security_group.asg
 $ terraform taint aws_autoscaling_group.asg
The resource aws_autoscaling_group.asg in the module root has been marked as tainted!
 $ terraform plan

 ...
  [ Some output removed ]
 ...
 

Plan: 2 to add, 0 to change, 2 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

**7.** Apply the terraform plan and examine the outputs.

```bash
 $ terraform apply
```

<details><summary>Click here to expand for more details</summary>
<p>


```hcl-terraform
 ...
  [ Some output removed ]
 ...
 
  wait_for_capacity_timeout:      "" => "10m"
aws_autoscaling_group.asg: Still creating... (10s elapsed)
aws_autoscaling_group.asg: Still creating... (20s elapsed)
aws_autoscaling_group.asg: Still creating... (30s elapsed)
aws_autoscaling_group.asg: Still creating... (40s elapsed)
aws_autoscaling_group.asg: Creation complete after 45s (ID: arya-stark-asg-default)

Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

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

**8.** In your browser open your application load balancer dns URL "alb_dns_name" from the outputs section and you should 
see WordPres welcome page.