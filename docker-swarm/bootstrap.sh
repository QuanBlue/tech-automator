################################## INSTRUCTIONS ##################################
# 2. Installed Docker engine                                                          #
# 3. Run using $ . bootstrap.sh                                                  #
##################################################################################

# Load environment variables
source .env

MANAGER=manager
NUMBER_OF_WORKERS=${NUMBER_OF_WORKERS:-2}
VISUALIZER_PORT=${VISUALIZER_PORT:-8080}

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

# Function to trim leading and trailing spaces
trim() {
   local var=$1
   var="${var#"${var%%[![:space:]]*}"}" # Trim leading spaces
   var="${var%"${var##*[![:space:]]}"}" # Trim trailing spaces
   echo -n "$var"                       # Print the trimmed value
}

# remove containers
info header "Remove containers"
info "Remove: "
docker rm -f $MANAGER
for ((i = 1; i <= $NUMBER_OF_WORKERS; i++)); do
   info "Remove: "
   docker rm -f worker${i}
done

# Pull image
info header "Pull image docker:dind"
info "Pulling..."
docker pull docker:dind
info "Complete!"

# Create containers
info header "Create containers"
info "Create (${MANAGER}): "
docker run -d --privileged --hostname=${MANAGER} --name=${MANAGER} docker:dind

for ((worker_id = 1; worker_id <= $NUMBER_OF_WORKERS; worker_id++)); do
   info "Create (worker${i}): "
   docker run -d --privileged --hostname=worker${worker_id} --name=worker${worker_id} docker:dind
done

# Wait for Docker-in-Docker container to start
info header "Wait for Docker-in-Docker container to start"
info "Watting..."
sleep 5
info "Complete!"
echo ""

# Init Swarm
info header "Create Swarm"
info "Init Swarm: "
docker exec -it $MANAGER docker swarm init

# Create service Visualizer
info header "Create Visualizer service"
info "Installing..."
docker exec -it $MANAGER docker service create \
   --name=visualizer \
   --publish=${VISUALIZER_PORT}:8080/tcp \
   --constraint=node.role==manager \
   --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
   dockersamples/visualizer
info "Complete!"

# Get worker join-token
JOIN_TOKEN=$(trim $(docker exec -it $MANAGER docker swarm join-token -q worker))

# Get the Swarm Manager node IP address and port
MANAGER_HOST_PORT=$(trim $(docker exec -it $MANAGER docker node inspect self --format '{{.ManagerStatus.Addr}}'))

# Join worker nodes to the Swarm
info header "Join worker nodes to the Swarm"
for ((worker_id = 1; worker_id <= $NUMBER_OF_WORKERS; worker_id++)); do
   info "Joining worker${worker_id} to the Swarm... "
   docker exec -it worker$worker_id docker swarm join --token $JOIN_TOKEN $MANAGER_HOST_PORT
done
