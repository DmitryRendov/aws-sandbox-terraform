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
