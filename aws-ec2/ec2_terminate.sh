#!/bin/bash

# Load environment variables
source ./env_vars.sh

INSTANCES_ID=$(
   aws ec2 describe-instances \
      --filters "Name=tag:Name,Values=${INSTANCE_NAME}" \
      --query "Reservations[].Instances[].InstanceId" \
      --output text \
      --no-cli-pager
)

# ---------------------------------------------
terminate_ec2() {
   info header "Terminate EC2 instance"

   info "Terminating...\n"
   for instance_id in $INSTANCES_ID; do
      echo "Terminating instance: ${instance_id}"
      aws ec2 terminate-instances \
         --instance-ids ${instance_id} \
         --no-cli-pager
   done
   info "Complete!\n"
}

remove_key_pair() {
   info header "Remove key pair"

   info "Removing..."
   aws ec2 delete-key-pair \
      --key-name ${KEY_PAIR_NAME} \
      --no-cli-pager
   info "Complete!\n"
}

remove_security_group() {
   info header "Remove security group"

   info "Removing..."
   aws ec2 delete-security-group \
      --group-name ${SECURITY_GROUP_NAME} \
      --no-cli-pager
   info "Complete!\n"
}

# ---------------------------------------------
# main
terminate_ec2
remove_key_pair
remove_security_group
