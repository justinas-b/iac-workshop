# Topic-1: Inputs & Outputs

**1.** In the directory **"working-dir"** create file terraform.tfvars with variables and appropriate values according to your account. 
For state bucket use the same bucket name that you've created in the topic-0.

```
owner = "john-snow"
region = "eu-central-1"
network = "10.0.0.0/25"
subnet_bits = 3
```

**2.** Copy all .tf and .sh files from directory topic-1 to your working-dir:
```bash
 $ cd working-dir
 $ cp ../topic-1/*.tf ./
```

**3.** Examine the contents of the copied files and commit them to your forked repository.

```bash
 $ git status
 $ git diff
 $ git commit -am "Topic 1 files"
```

**4.** Execute *terraform init*. This command initializes various local settings, downloads required provider plugins, etc. 
Note: in order to reduce space consumption and bandwidth usage already downloaded provider plugins could be referenced.

```bash
 $ terraform init
```

<details><summary>Click here to expand for more details</summary>
<p>

```
 $ terraform init

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 1.54"

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

**5.** Create a terraform plan by executing:

```bash
 $ terraform plan
```

Examine the produced output. 
 
 - How many resources are planned to be created? 
 - Can you reference the resource attribute values in the plan to what is in the code? 

<details><summary>Click here to expand for more details</summary>
<p>


```
 $ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_eip.nat[0]
      id:                               <computed>
      allocation_id:                    <computed>
      association_id:                   <computed>
      domain:                           <computed>
      instance:                         <computed>

...
[ Some output removed ]
...
       main_route_table_id:              <computed>
       owner_id:                         <computed>
       tags.%:                           "1"
       tags.Name:                        "arya-stark-default"
 
 
 Plan: 20 to add, 0 to change, 0 to destroy.
 
 ------------------------------------------------------------------------
 
 Note: You didn't specify an "-out" parameter to save this plan, so Terraform
 can't guarantee that exactly these actions will be performed if
 "terraform apply" is subsequently run.

```

</p>
</details>
</br>

**6.** Apply terraform plan by executing:

```bash
 $ terraform apply
```

Examine the produced output. 
 - How many and what outputs do you see? 

<details><summary>Click here to expand for more details</summary>
<p>

```
 $ terraform apply

...
[ Some output removed ]
...

Plan: 20 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

...
[ Some output removed ]
...

  route_table_id:             "" => "rtb-09941142fc5deb2a5"
  state:                      "" => "<computed>"
aws_route.private[1]: Creation complete after 1s (ID: r-rtb-09941142fc5deb2a51080289494)
aws_route.private[0]: Creation complete after 1s (ID: r-rtb-006af3b96b178f37a1080289494)

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

vpc_id = vpc-0dc49a0686a231015

```
</p>
</details>
</br>