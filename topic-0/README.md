# Topic-0: Terraform intro

**1.** If you are not already, with terminal **change directory to *topic-0***. 

```bash
 cd ./topic-0
```

In the **bucket.tf** file there is **aws_s3_bucket** resource block. Change bucket name to something unique. 
In order to maintain uniqueness an example naming convention has been proposed. 
Change bucket name accordingly.

**2.** Execute *terraform init*. This command initializes various local settings, downloads required provider plugins, etc.
You need to execute *terraform init* each time you add new providers or change backend (more on that later). 
It's safe to run *terraform init* multiple times.

```bash
 terraform init
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

**3.** Create a terraform plan by executing:

```bash
 terraform plan
```

Examine the produced output. 
 
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

  + aws_s3_bucket.b
      id:                          <computed>
      acceleration_status:         <computed>
      acl:                         "private"
      arn:                         <computed>
      bucket:                      "johnn-snow-state-437278685207"
      bucket_domain_name:          <computed>
      bucket_regional_domain_name: <computed>
      force_destroy:               "false"
      hosted_zone_id:              <computed>
      region:                      <computed>
      request_payer:               <computed>
      versioning.#:                "1"
      versioning.0.enabled:        "true"
      versioning.0.mfa_delete:     "false"
      website_domain:              <computed>
      website_endpoint:            <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

 ------------------------------------------------------------------------
 
 Note: You didn't specify an "-out" parameter to save this plan, so Terraform
 can't guarantee that exactly these actions will be performed if
 "terraform apply" is subsequently run.

```

</p>
</details>
</br>

**4.** Apply terraform plan by executing command below. Enter 'yes' when prompted.

```bash
 terraform apply
```

Examine the produced output. 

<details><summary>Click here to expand for more details</summary>
<p>

```
 $ terraform apply
aws_s3_bucket.b: Creating...
  acceleration_status:         "" => "<computed>"
  acl:                         "" => "private"
  arn:                         "" => "<computed>"
  bucket:                      "" => "johnn-snow-state-437278685207"
  bucket_domain_name:          "" => "<computed>"
  bucket_regional_domain_name: "" => "<computed>"
  force_destroy:               "" => "false"
  hosted_zone_id:              "" => "<computed>"
  region:                      "" => "<computed>"
  request_payer:               "" => "<computed>"
  versioning.#:                "" => "1"
  versioning.0.enabled:        "" => "true"
  versioning.0.mfa_delete:     "" => "false"
  website_domain:              "" => "<computed>"
  website_endpoint:            "" => "<computed>"
aws_s3_bucket.b: Creation complete after 3s (ID: johnn-snow-state-437278685207)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```
</p>
</details>
</br>

**5.** You should see additional file *terraform.tfstate* created in your directory. 
State file maps the resources defined in *.tf files with the actual resources in the cloud service provider, in our case AWS. 

```bash
ls -al
total 32
drwxr-xr-x   7 Ignas  staff   224 Jan 20 12:17 .
drwxr-xr-x  16 Ignas  staff   512 Jan 20 12:04 ..
drwxr-xr-x   4 Ignas  staff   128 Jan 20 12:06 .terraform
-rw-r--r--   1 Ignas  staff   173 Jan 20 12:16 bucket.tf
-rw-r--r--   1 Ignas  staff  2087 Jan 20 12:17 terraform.tfstate
```

**DO NOT** modify state file manually. It's a lot safer to use built in commands. For example, you can execute the following
commands to list and examine particular resource:

```bash
terraform state list
aws_s3_bucket.state_bucket

terraform state show aws_s3_bucket.state_bucket
id                                     = johnn-snow-state-437278685207
acceleration_status                    = 
acl                                    = private
arn                                    = arn:aws:s3:::johnn-snow-state-437278685207
bucket                                 = johnn-snow-state-437278685207
bucket_domain_name                     = johnn-snow-state-437278685207.s3.amazonaws.com
bucket_regional_domain_name            = johnn-snow-state-437278685207.s3.eu-central-1.amazonaws.com
cors_rule.#                            = 0
force_destroy                          = false
hosted_zone_id                         = Z21DNDUVLTQW6Q
lifecycle_rule.#                       = 0
logging.#                              = 0
region                                 = eu-central-1
replication_configuration.#            = 0
request_payer                          = BucketOwner
server_side_encryption_configuration.# = 0
tags.%                                 = 0
versioning.#                           = 1
versioning.0.enabled                   = true
versioning.0.mfa_delete                = false
website.#                              = 0
```

**6.** You can log in to the AWS console and open S3 dashboard. You should see your new S3 bucket that you've just created using terraform.
Open your bucket, go to **Properties** tab, scroll down and add a new tag. You can add whatever key/value pair you want. Hit save.

**7.** Go back to your terminal, and create terraform plan. As you can see from the plan terraform is going to remove the tag
since it hasn't been defined in terraform configuration (we've added it manually in step 6.). 


<details><summary>Click here to expand for more details</summary>
<p>

```bash
terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_s3_bucket.state_bucket: Refreshing state... (ID: johnn-snow-state-437278685207)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ aws_s3_bucket.state_bucket
      tags.%:       "1" => "0"
      tags.testing: "tf" => ""


Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```
</p>
</details>
</br>


**8.** Apply terraform plan by executing *terraform apply* in order to restore your resources (only single S3 bucket in this case)
to the desired configuration.


<details><summary>Click here to expand for more details</summary>
<p>

```bash
terraform apply
aws_s3_bucket.state_bucket: Refreshing state... (ID: johnn-snow-state-437278685207)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ aws_s3_bucket.state_bucket
      tags.%:       "1" => "0"
      tags.testing: "tf" => ""


Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.state_bucket: Modifying... (ID: johnn-snow-state-437278685207)
  tags.%:       "1" => "0"
  tags.testing: "tf" => ""
aws_s3_bucket.state_bucket: Modifications complete after 2s (ID: johnn-snow-state-437278685207)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

```
</p>
</details>
</br>

Let's leave the bucket as is for now, we'll need it later.



