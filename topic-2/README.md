# Topic-2: Bootstrapping

**1.** Copy all .tf and .sh files from directory topic-2 to your working-dir.
```bash
 cp ../topic-2/*.tf ./
 cp ../topic-2/*.sh ./
```

**2.** Examine what has changed in which files and commit changes to your forked repository.

```bash
 git status
 git diff <path_to_file>
 git commit -am "Topic 2 files and changes"
```

**3.** Execute terraform plan. Since we've added a new provider, you'll get an error similar as below. 

```bash
 terraform plan
```

<details><summary>Click here to expand for more details</summary>
<p>

```
 $ terraform plan
Plugin reinitialization required. Please run "terraform init".
Reason: Could not satisfy plugin requirements.

Plugins are external binaries that Terraform uses to access and manipulate
resources. The configuration provided requires plugins which can't be located,
don't satisfy the version constraints, or are otherwise incompatible.

1 error(s) occurred:

* provider.template: no suitable version installed
  version requirements: "(any version)"
  versions installed: none

Terraform automatically discovers provider requirements from your
configuration, including providers used in child modules. To see the
requirements and constraints from each module, run "terraform providers".


Error: error satisfying plugin requirements

```
</p>
</details>
</br>

**4.** As you can see, it's complaining about missing *template* provider. You need to execute *terraform init* each time you 
add new providers or change backend (more on that later). It's safe to run *terraform init* multiple times.

```bash
 terraform init
```

<details><summary>Click here to expand for more details</summary>
<p>

```
$ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "template" (1.0.0)...

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


**5.** Execute terraform plan, examine what changes are going to be made and then apply.

```bash
 terraform plan
 terraform apply -auto-approve
```

<details><summary>Click here to expand for more details</summary>
<p>

```
...
[ Some output removed ]
...
  
+ aws_security_group_rule.ssh_access
         id:                                                                                       <computed>
         cidr_blocks.#:                                                                            "1"
         cidr_blocks.0:                                                                            "0.0.0.0/0"
         description:                                                                              "Allow SSH access"
         from_port:                                                                                "22"
         protocol:                                                                                 "tcp"
         security_group_id:                                                                        "${aws_security_group.asg.id}"
         self:                                                                                     "false"
         source_security_group_id:                                                                 <computed>
         to_port:                                                                                  "22"
         type:                                                                                     "ingress"
   
   
   Plan: 14 to add, 0 to change, 0 to destroy.
   
   ------------------------------------------------------------------------
   
   Note: You didn't specify an "-out" parameter to save this plan, so Terraform
   can't guarantee that exactly these actions will be performed if
   "terraform apply" is subsequently run.
   
 $ terraform apply
 
 ...
 [ Some output removed ]
 ...
 
 Do you want to perform these actions?
   Terraform will perform the actions described above.
   Only 'yes' will be accepted to approve.
 
   Enter a value: yes
 
 aws_security_group.asg: Creating...
   arn:                    "" => "<computed>"
   description:            "" => "Allow user SSH and ALB traffic"
   egress.#:               "" => "<computed>"
   ingress.#:              "" => "<computed>"

...
[ Some output removed ]
...

 port:                              "" => "80"
  protocol:                          "" => "HTTP"
  ssl_policy:                        "" => "<computed>"
aws_lb_listener.front_end: Creation complete after 1s (ID: arn:aws:elasticloadbalancing:eu-central...ault/bd11de57716f17a0/ba506136c9dc282b)

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = arya-stark-alb-default-278267658.eu-central-1.elb.amazonaws.com
alb_id = arn:aws:elasticloadbalancing:eu-central-1:437278685207:loadbalancer/app/arya-stark-alb-default/bd11de57716f17a0
vpc_id = vpc-0faf9cf26d5246000

```
</p>
</details>
</br>

**6.** In your browser open the provisioned application load balancer URL that was specified in **ald_dns_name** output value above. 

You'll see Wordpress initial setup page to for database connection. However, currently we don't have a database to connect to. 
We'll resolve this in the next lesson/topic :)


