#!/bin/bash

# Load environment variables
source .env

NETWORK=${NETWORK:-ansible-net}
NUMBER_OF_NODE=${NUMBER_OF_NODE:-2}
INVENTORY="./ansible/inventories/hosts.ini"
CONTROLLER_PATH_TO_PLAYBOOK="/etc/ansible/playbooks/playbook.yml"
CONTROLLER_PATH_TO_INVNETORY="/etc/ansible/inventories/hosts.ini"

# Function to print messages in pretty format
info() {
   if [ "$1" = "header" ]; then
      tput bold       # Sets the text to bold
      tput setaf 7    # Sets the text color to white (ANSI color code 7)
      tput setab 2    # Sets the background color to green (ANSI color code 2)
      printf "\n$2\n" # Prints the message passed as an argument to the function
      tput sgr0       # Resets text attributes (color, boldness, etc.) to default
      tput el
   else
      tput bold    # Sets the text to bold
      tput setaf 2 # Sets the text color to green (ANSI color code 2)
      printf "$1"  # Prints the message passed as an argument to the function without new line
      tput sgr0    # Resets text attributes (color, boldness, etc.) to default
      tput el
   fi
}

# Function to split string
split_string() {
   local input_string="$1"    # Input string
   local delimiter="$2"       # Delimiter character or string
   local -n output_array="$3" # Output array variable (passed by reference)

   IFS="$delimiter" read -r -a output_array <<<"$input_string"
}

# Remove old containers
info header "Remove old containers"
info "Removing..."
echo
docker rm -f ansible-controller
for ((node_id = 1; node_id <= $NUMBER_OF_NODE; node_id++)); do
   docker rm -f ubuntu-node-${node_id}
done
info "Complete!"

# Create network
info header "Create network '${NETWORK}'"
info "Creating..."
docker network create --driver=bridge ${NETWORK}
info "Complete!"

# Create Ansible container
info header "Create Ansible controller container"
info "Creating..."
docker build -t ansible-controller:v1 -f ./dockerfile/Dockerfile-ansible-machine .
docker run -itd \
   --name ansible-controller \
   --network ${NETWORK} \
   --volume ./ansible/:/etc/ansible/ \
   ansible-controller:v1
rsa_pub=$(docker exec -it ansible-controller sh -c 'cat ~/.ssh/id_rsa.pub')
info "Complete!"

# Create Node container
info header "Create Node container"
info "Building image..."
docker build -t ubuntu-node:18.04 -f ./dockerfile/Dockerfile-remote-machine .
info "Complete!"

for ((node_id = 1; node_id <= $NUMBER_OF_NODE; node_id++)); do
   info "Creating (ubuntu-node-${node_id})... "

   docker run -itd \
      --name=ubuntu-node-${node_id} \
      --network=${NETWORK} \
      --hostname=ubuntu-node-${node_id} \
      ubuntu-node:18.04

   docker exec -it ubuntu-node-${node_id} sh -c "mkdir -p /root/.ssh && echo '${rsa_pub}' > /root/.ssh/authorized_keys"

   info "Complete!"

done
info "Complete!"

# Get IP address of containers
info header "Get IP address of containers"
info "Getting..."
delimiter=";"
ipv4=$(docker network inspect --format="{{range .Containers}}{{.Name}}:{{.IPv4Address}}{{\"$delimiter\"}}{{end}}" $NETWORK)
split_string "$ipv4" "$delimiter" ipv4_array
info "Complete!"

# Generate inventory content
info header "Generate inventory content"
info "Generating..."
inventory_controller_group="[controller]"
inventory_node_group="[node]"

for element in "${ipv4_array[@]}"; do
   split_string "$element" ":" machine_props
   split_string "${machine_props[1]}" "/" ip

   machine_name=${machine_props[0]}
   machine_ip=${ip[0]}

   if [ ${machine_name[0]} == "ansible-controller" ]; then
      # generate inventory for controller
      inventory_controller_group+="\n${machine_name} ansible_host=${machine_ip}"
   else
      # generate inventory for node
      inventory_node_group+="\n${machine_name} ansible_host=${machine_ip}"

      # check connection from Controller to Nodes
      info "Checking connection from Controller to ${machine_name}..."
      printf "exit\n" | docker exec -i ansible-controller sh -c "ssh -o 'StrictHostKeyChecking=no' root@${machine_ip}"
      info "Complete!"
   fi
done
info "Complete!"

# Write inventory file
info header "Write inventory file"
info "Writing..."
inventory="${inventory_controller_group}\n\n${inventory_node_group}"
echo -e $inventory >$INVENTORY
info "Complete!"

# Check Inventory file
info header "List all hosts Inventory file"
info "Listing..."
docker exec -it ansible-controller sh -c "ansible-inventory -i $CONTROLLER_PATH_TO_INVNETORY --list"
info "Complete!"

# Check connection from Controller to node (client)
info header "Test playbook"
info "Playing..."
docker exec -it ansible-controller sh -c "ansible-playbook -i $CONTROLLER_PATH_TO_INVNETORY $CONTROLLER_PATH_TO_PLAYBOOK"
info "Complete!"
