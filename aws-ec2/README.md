<h1 align="center">
  <img src="./assets/ec2-generator-logo.png" alt="icon" width="200"></img>
  <br>
  <b>AWS EC2 Generator</b>
</h1>

<p align="center">Automatically create EC2 machine with AWS CLI</p>

<!-- Badges -->
<p align="center">
  <a href="https://github.com/QuanBlue/aws-ec2-generator/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/QuanBlue/aws-ec2-generator" alt="contributors" />
  </a>
  <a href="">
    <img src="https://img.shields.io/github/last-commit/QuanBlue/aws-ec2-generator" alt="last update" />
  </a>
  <a href="https://github.com/QuanBlue/aws-ec2-generator/network/members">
    <img src="https://img.shields.io/github/forks/QuanBlue/aws-ec2-generator" alt="forks" />
  </a>
  <a href="https://github.com/QuanBlue/aws-ec2-generator/stargazers">
    <img src="https://img.shields.io/github/stars/QuanBlue/aws-ec2-generator" alt="stars" />
  </a>
  <a href="https://github.com/QuanBlue/aws-ec2-generator/issues/">
    <img src="https://img.shields.io/github/issues/QuanBlue/aws-ec2-generator" alt="open issues" />
  </a>
  <a href="https://github.com/QuanBlue/aws-ec2-generator/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/QuanBlue/aws-ec2-generator.svg" alt="license" />
  </a>
</p>

<p align="center">
  <b>
    <a href="https://github.com/QuanBlue/aws-ec2-generator">Documentation</a> •
    <a href="https://github.com/QuanBlue/aws-ec2-generator/issues/">Report Bug</a> •
    <a href="https://github.com/QuanBlue/aws-ec2-generator/issues/">Request Feature</a>
  </b>
</p>
<br/>
<details open>
<summary><b>Table of Contents</b></summary>

- [Getting Started](#toolbox-getting-started)
  - [Prerequisites](#pushpin-prerequisites)
  - [Environment Variables](#key-environment-variables)
  - [Run locally](#rocket-run-locally)
- [Usage](#mechanical_arm-usage)
- [Useful AWS CLI commands](#keyboard-useful-aws-cli-commands)
- [Roadmap](#world_map-roadmap)
- [Contributors](#busts_in_silhouette-contributors)
- [Credits](#sparkles-credits)
- [License](#scroll-license)
</details>

# :toolbox: Getting Started

## :pushpin: Prerequisites

Before proceeding with the installation and usage of this project, ensure that you have the following prerequisites in place:

- **Network Connectivity:** Docker requires network connectivity to download images, communicate with containers, and access external resources.
- **AWS account:** To use AWS services, you need to have an AWS account. Create an account [here](https://aws.amazon.com/free).
- **AWS CLI:** To control AWS services, you need to install AWS CLI. Install [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

## :key: Environment Variables

To run this project, you need to add the following environment variables to your `.env` file in `./`:

**App configs (`.env`):**

- `AWS_ACCESS_KEY_ID`\*: Unique identifier for AWS authentication.
- `AWS_SECRET_ACCESS_KEY`\*: Confidential key for securely signing AWS API requests.
  > Get access key id and secret at [here](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)
- `AWS_REGION`: AWS server location for services (default: ap-southeast-1)
  > List [AWS available region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions)
- `AMI_ID`: Identifier for AMD processors (default: ami-0df7a207adb9748c7)
  > - Find AMI_ID at [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html)
  > - Make sure that `AMI_ID` running it in the `AWS_REGION` that you want to deploy to.
- `INSTANCE_NAME`: Unique identifier for virtual servers. (default: quanblue)
- `INSTANCE_TYPE`: AWS server configuration specification. (default: t2.micro)
  > List [AWS available instance type](https://aws.amazon.com/ec2/instance-types/)
- `KEY_PAIR_NAME`: name of key pair (default: quanblue_key_pair)
- `SECURITY_GROUP_NAME`: name of security group (default: quanblue_sg)

Example:

```sh
# .env

AWS_ACCESS_KEY_ID=[your access key]
AWS_SECRET_ACCESS_KEY=[your secret key]
AWS_REGION=ap-southeast-1

AMI_ID=ami-0df7a207adb9748c7

INSTANCE_NAME=quanblue
INSTANCE_TYPE=t2.micro
KEY_PAIR_NAME=quanblue_key_pair
SECURITY_GROUP_NAME=quanblue_sg
```

> **Note:**
>
> - Which environment variables **not have default value**, you need to add it to `.env` file.
> - You can also check out the file `.env.example` to see all required environment variables.
> - If you want to use this example environment, you need to rename it to **.env**.

## :rocket: Run locally

To **automatically create EC2 instance**, run the following commands:

```sh
bash ./ec2_deploy.sh
```

To **automatically terminate EC2 instance, remove key pair, sec group,...**, run the following commands:

```sh
bash ./ec2_terminate.sh
```

# :mechanical_arm: Usage

In this Project I use AWS CLI to interact with EC2 instance, Within 3 main script file:

- `ec2_deploy.sh`: Automatically create EC2 instance
- `ec2_terminate.sh`: Automatically terminate EC2 instance and remove key pair, sec group,...
- `env_vars.sh`: Environment variables and common functions

> **Note:** In each script file, i have a comment to explain what it does.

# :keyboard: Useful AWS CLI commands

Connect EC2 instance via SSH

```sh
ssh -i <key-pair>.pem ec2-user@<ec2-public-ip>
```

Control EC2 instance

```sh
# Create instance
aws ec2 run-instances --image-id <ami-id> --instance-type <type> --key-name <my-key-pair> --security-group-ids <security-group-id>

# Terminate instance
aws ec2 terminate-instances --instance-ids <instance-id>
```

Control key pair

```sh
# Create key pair
aws ec2 create-key-pair --key-name <my-key-pair> --query 'KeyMaterial' --output text > <my-key-pair>.pem

# Remove key pair
aws ec2 delete-key-pair --key-name <my-key-pair>

# Get key pair information
aws ec2 describe-key-pairs
```

Control security group

```sh
# Create security group
aws ec2 create-security-group --group-name <security-group-name> --description <group-description>

# Add inbound rule
aws ec2 authorize-security-group-ingress --group-id <security-group-id> --protocol tcp --port 22 --cidr

# Remove inbound rule
aws ec2 revoke-security-group-ingress --group-id <security-group-id> --protocol tcp --port 22 --cidr

# Remove security group
aws ec2 delete-security-group --group-id <security-group-id>

# Get security group information
aws ec2 describe-security-groups --group-ids <security-group-id>
```

# :world_map: Roadmap

- [x] Automatically create EC2 instance
- [x] Automatically terminate EC2 instance and remove key pair, sec group,...

# :busts_in_silhouette: Contributors

<a href="https://github.com/QuanBlue/Linux-Bootstrap/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=QuanBlue/Linux-Bootstrap" />
</a>

Contributions are always welcome!

# :sparkles: Credits

- [AWS CLI](https://aws.amazon.com/cli/)
- Emojis are taken from [here](https://github.com/arvida/emoji-cheat-sheet.com)

# :scroll: License

Distributed under the MIT License. See <a href="../LICENSE">`LICENSE`</a> for more information.

---

> Bento [@quanblue](https://bento.me/quanblue) &nbsp;&middot;&nbsp;
> GitHub [@QuanBlue](https://github.com/QuanBlue) &nbsp;&middot;&nbsp; Gmail quannguyenthanh558@gmail.com
