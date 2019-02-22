# iac-workshop

## Getting started

This workshop is separated into several topics that cover various aspects of infrastructure as code with terraform aspects. Each topic relevant terraform configuration code is placed into a separate directory. Main directory where the participant would perform terraform runs is **"working-dir"**. This is where contents from each topic directory should be copy/pasted as progressing through the workshop.

![IaC workshop architecture](https://github.com/AmazingStuffPro/iac-workshop/blob/master/_docs/architecture.png?raw=true)

### Prerequisites

You need to have:
 - This repo forked to your account
 - Terraform in your path, AWS account and credentials set in order to provision target infra.
   - Create a separate aws profile in your *~/.aws/credentials* file if this is not your default credentials:
   ```bash
    cat ~/.aws/credentials   
    [iac-workshop-account]
    aws_access_key_id = ******************
    aws_secret_access_key = *************************************
   ```   
   
   - Set environment variable for your new aws profile:
   ```bash
    export AWS_PROFILE=iac-workshop-account 
   ```

Then follow the instructions in each topic.
