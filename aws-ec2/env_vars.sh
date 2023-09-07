# Load environment variables
source .env

declare -A AWS_CONFIG=(
   [region]=${AWS_REGION:-"ap-southeast-1"}
   [output]="table"
)

declare -A AWS_CREDENTIALS=(
   [aws_access_key_id]=${AWS_ACCESS_KEY_ID}
   [aws_secret_access_key]=${AWS_SECRET_ACCESS_KEY}
)

export AMI_ID=${AMI_ID:-"ami-0df7a207adb9748c7"}
export INSTANCE_NAME=${INSTANCE_NAME:-"quanblue"}
export INSTANCE_TYPE=${INSTANCE_TYPE:-"t2.micro"}
export KEY_PAIR_NAME=${KEY_PAIR_NAME:-"quanblue_key_pair"}
export SECURITY_GROUP_NAME=${SECURITY_GROUP_NAME:-"quanblue_sg"}
export AWS_CONFIG
export AWS_CREDENTIALS

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
