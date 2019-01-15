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
 $ rm ./*
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

**4.1.** In vpc directory update **backend.tf** file with your bucket and key values. Pay close attention to the **key**
value where path to terraform state file is specified. 

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

**5.1.**