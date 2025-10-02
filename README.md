# Terraform #

## Pre-requisites

1. Install dependencies (e.g. Ubintu 22)
```bash
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y git make jq tar unzip wget python3 python3-pip
```

2. Make sure that you're using Python3.9+
```
python3 --version
```

3. Install Go by following the official guide https://golang.org/doc/install

a. Download the Go

```wget https://go.dev/dl/go1.25.1.linux-amd64.tar.gz```

b. Unpack the package

```sudo rm -rf ~/go && tar -C ~/ -xzf go1.25.1.linux-amd64.tar.gz```

c. Update env variables

```
mkdir ~/.go
echo 'export GOPATH="$HOME/.go"' >> ~/.bashrc
echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.bashrc
```

d. Reload the config

```source ~/.bashrc```

e. Verify that you've installed Go right

```go version```

5. Install tfenv from the source

```
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
```

Reload the config

```bash
source ~/.bashrc
```


## Setup Terraform and dependencies

```bash
make setup
```

### What does `make setup` do?

The `setup` target in the Makefile installs and configures several development dependencies:

- **pre-commit**: Installs the `pre-commit` Python package globally (if not already installed) and runs `pre-commit install` to set up Git hooks for automated code checks.
- **terraform-config-inspect**: Installs the latest version of HashiCorp's `terraform-config-inspect` tool using Go. This tool is used to inspect Terraform modules and configurations programmatically.
- **terraform-docs**: Installs version 0.15.0 of `terraform-docs` using Go, which generates documentation from Terraform modules.
- **Python requirements**: Installs all Python packages listed in `lib/requirements.txt` using pip3.

If any required tool is missing, the setup will attempt to install it or prompt you with instructions.

**Note:** Ensure your Go environment (`GOPATH` and `PATH`) is correctly set up so that installed Go binaries are available in your shell.

## AWS Credentials configuration

### Install AWS CLI v2
Taken from https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
```
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
$ aws --version
```

### Configure your AWS credentials via AWS CLI or manually like that:

Now it’s time to configure your AWS credentials via AWS CLI or manually like that:

- Put your AWS access and secret keys given for Bastion account into the file ~/.aws/credentials like:
```
[bastion]
aws_access_key_id = AKIAXJ...<REDO>
aws_secret_access_key = xX9WO...<REDO>
```

- Configure profile in the file ~/.aws/config with the content like:
```
[default]
region = us-east-1
output = json
cli_timestamp_format = iso8601

[profile bastion]
mfa_serial = arn:aws:iam::500976330694:mfa/<your MFA device Identifier>

[profile sts]
terraform_sts_expiration = 1654554457
```
where **500976330694** is your bastion account ID and do not forget to configure your MFA Virtual device.

## Running

We use `make` to wrap Terraform commands and include extra functionality.

#### Example commands
```
make plan                                         #default workspace
make plan-prod                                    #prod workspace
make plan-prod TERRAFORM_EXEC_ROLE=dmitry_rendov  #prod workspace using the joe johnson role
make apply-prod ARGS='-target=module.default'     #apply in prod and target one module
```

#### Example set role before commands
```bash
aws-bastion.sh login
export TERRAFORM_EXEC_ROLE=dmitry_rendov
make plan-prod
make apply-prod
```

## Layout ##

### AWS Sandbox
This is where the AWS Sandbox infrastructure live.

### audit|bastion|production ###
Configuration for each respective account, there is only one account per directory

### <account>/global
Configuration for resources which are global in AWS, shared across multiple roles and required for each new account.

Examples:
* Global IAM role
* ACM Certificates
* Cloudtrail and AWS Config Setup

### <account>/roles
A role is a distinct functionality which requires typically requires it's own separate IAM role.

Examples:
* aws-config
* atlantis
* ecs

### **global-variables.tf.json ###
Shared variables across all Terraform code

### **account-variables.tf.json ###
Shared variables across an account

### **tf** and **terraform.sh** ###

Terraform wrapper scripts (symlinked).

### **lib/** ###

Shared Makefiles, scripts, plugins, providers, configurations


## Modules ##

Modules are in `/modules`, roughly divided into two categories: `base` and `site`

`base` modules are modules that are used by other modules, or modules that are copied from the Internet. These are modules that we could conceivably release as open source.
`site` modules are modules that have AWS Sandbox specific configuration, and are unlikely to be ever released to the public. They very likely are a composition of other modules.

### Module versioniong ###

Each module has one or more versions. When creating a new version, simply copy the code to the next version directory, and make a PR with changes. It is best to make one commit to add the new version with no code changes, and subsequent commits to make changes, so it is easier for code reviewers to see just the differences in a module.

Breaking changes that require a new version:

* New required variables
* Changes to default behavior that require the caller to make changes to the way they use the module, the resources it creates, or their understanding of the universe.

Non-breaking changes that do not require a new version:

* Adding outputs (usually)
* Use your best judgement

## Using the AWS Console with multiple roles

When asked to change your account password, please log out again after setting the password. Log in with a fresh session using the new password and current MFA token. This should ensure you have sufficient access to assume the correct roles as usual. The AWS console supports the ability to assume different roles directly within the console interface. Each day you want to work in the AWS console, you will log into the Bastion account with your chosen credentials when running the bootstrap script. After logging into the Bastion account and entering your MFA token, you will be taken to the console home page. From the home page, you now have permission to assume the different roles granted to you. [The document](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html) shows you how to manually enter different roles to make them available in the console to switch to. For your convenience, we also link directly to the different available roles so you can add them to your browser easily. They are linked next to the role's name below and with the text 'Console Switch Role.'

### Switch accounts/roles
You can switch between the AWS accounts using the roles, automatically created for you in every account. The process to assume these new roles is the same as the process above except the role name will now be standartized such as firstName_lastName (i.e. dmitry_rendov). Here is an example URL to assume a role in the

Production account:
* https://signin.aws.amazon.com/switchrole?account=091599657285&roleName=dmitry_rendov&displayName=Prod

To use these new roles in the CLI run the following commands but replace the account id and name with the correct values:
```
aws --profile prod-dmitry_rendov configure set role_arn arn:aws:iam::091599657285:role/dmitry_rendov
aws --profile prod-dmitry_rendov configure set region us-east-1
aws --profile prod-dmitry_rendov configure set source_profile sts
```

Each user's permissions are defined in the terraform repo (either in bastion/global/global/users.tf).

By default, a user has Administrator Access to the Dev account and Read Only Access to other accounts unless specified otherwise. Each user also can manage their password and MFA device in the Dev account.

### Switching roles in the AWS web console
Click on your name in the top right of the AWS console, and choose Switch Role

![Switch AWS Role](aws_profile_switch.jpg?raw=true "Switch AWS Role")


On the next page, enter the appropriate account number, such as 091599657285 in the case of the Prod account.
The role will be your firstNameLastName (i.e. dmitry_rendov). The alias is whatever helps you remember which environment you are entering. The list of prior roles in Role History is stored in a cookie, which periodically disappears. To avoid this frustration, see below for a helpful browser extension to greatly simplify role switching (and let you see more than 5 prior roles)

### Logging in to AWS Web Console access
The main entry point to AWS Console access is logging in via Bastion account https://500976330694.signin.aws.amazon.com/console. This is the bastion account that contains all your IAM user. After logging in you can assume roles, as described above, depending on what you need to do.

Since our policies require MFA periodically, you will need to (at least once per day), ensure you get a new STS token. Our helpful wrapper script will do this for you
```aws-login.sh login```
#You will be prompted to enter your MFA token
Once you have gotten a new daily token, you will be able to use the CLI to do your job. The AWS CLI supports multiple ways of telling it what profile to use when executing commands.
