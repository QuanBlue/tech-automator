#!/bin/bash

# Load environment variables
source ./env_vars.sh

# ---------------------------------------------
prequisites() {
   info header "Prequisites"

   info "Granting write permission to the script itself..."
   chmod a+w "$0"
   info "Complete!\n"

   info "Store previous aws configuaration..."
   if [ -d "~/.aws/" ]; then
      if [ -f "~/.aws/config" ]; then
         mv ~/.aws/config ~/.aws/config.bak
      fi
      if [ -f "~/.aws/credentials" ]; then
         mv ~/.aws/credentials ~/.aws/credentials.bak
      fi
   else
      mkdir -p ~/.aws
   fi
   info "Complete!\n"

   info "Resetting setting folder..."
   if [ -d "./setting/" ]; then
      # If the folder exists, remove its contents (all files and subdirectories)
      rm -rf ./setting/*
   else
      # If the folder doesn't exist, create it
      mkdir ./setting/
   fi
   info "Complete!\n"

}

# ---------------------------------------------
aws_setup() {
   info header "AWS setup"

   # Generate AWS configuration file
   info "Generating configuration..."
   aws_config="[default]\n"
   for config_field in ${!AWS_CONFIG[@]}; do
      aws_config+="${config_field} = ${AWS_CONFIG[${config_field}]}\n"
   done
   echo -e "$aws_config" >~/.aws/config
   info "Complete!\n"

   # Generate AWS credentials file
   info "Generating credentials..."
   aws_credentials="[default]\n"
   for config_field in ${!AWS_CREDENTIALS[@]}; do
      aws_credentials+="${config_field} = ${AWS_CREDENTIALS[${config_field}]}\n"
   done
   echo -e "$aws_credentials" >~/.aws/credentials
   info "Complete!"
}

# ---------------------------------------------
create_ec2_machine() {
   info header "Create EC2 machine"

   info "Generating key pair..."
   aws ec2 create-key-pair \
      --key-name ${KEY_PAIR_NAME} \
      --query "KeyMaterial" \
      --output text >setting/${KEY_PAIR_NAME}.pem
   chmod 0400 setting/${KEY_PAIR_NAME}.pem
   info "Complete!\n"

   info "Creating security group..."
   aws ec2 create-security-group \
      --group-name ${SECURITY_GROUP_NAME} \
      --description "Security group for Quanblue" \
      --no-cli-pager
   info "Complete!\n"

   info "Adding rule for security group..."
   aws ec2 authorize-security-group-ingress \
      --group-name ${SECURITY_GROUP_NAME} \
      --protocol tcp \
      --port 0-65535 \
      --cidr 0.0.0.0/0 \
      --no-cli-pager
   info "Complete!\n"

   info "Creating EC2 instance...\n"
   aws ec2 run-instances \
      --image-id ${AMI_ID} \
      --instance-type ${INSTANCE_TYPE} \
      --key-name ${KEY_PAIR_NAME} \
      --security-groups ${SECURITY_GROUP_NAME} \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]" \
      --no-cli-pager
   info "Complete!\n"
}

get_instance_ip() {
   info header "Get instance IP"
   public_ip=$(
      aws ec2 describe-instances \
         --filters "Name=tag:Name,Values=${INSTANCE_NAME}" \
         --query 'Reservations[*].Instances[*].PublicIpAddress' \
         --output text \
         --no-cli-pager
   )
   info "Public IP address of "${INSTANCE_NAME}" is: ${public_ip}"
}

# ---------------------------------------------
# main
prequisites
aws_setup
create_ec2_machine
get_instance_ip
