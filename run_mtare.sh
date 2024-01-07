#!/usr/bin/env bash

disp_usage() {
  # display script usage
  echo "Usage: run_mtare.sh <envrionment> <comms_range> <robot_num> <robot_id>"
  echo "  - <envrionment>: The environment to explore: tunnel, garage, campus, indoor, forest"
  echo "  - <comms_range>: Communication range in meters, two robots further than this range cannot communicate"
  echo "  - <robot_num>: Total number of robots"
  echo "  - <robot_id>: Robot id, ranging from 0 to robot_num - 1"
  echo "  - <network_interface>: Name of the network interface to use, e.g. eth0"
}

if [ "$#" -ne 5 ] || [ "$1" != "tunnel" ] && [ "$1" != "garage" ] && [ "$1" != "forest" ] && [ "$1" != "indoor" ] && [ "$1" != "campus" ]; then
  disp_usage
  exit 22  
# comms_range should be greater than zero
elif [ "$2" -le 0 ]; then
  disp_usage
  exit 22
# check total robot number is in range [1, 20]
elif [ "$3" -le 0 ] || [ "$3" -ge 21 ]; then
  disp_usage
  exit 22
# check robot id is in range
elif [ "$4" -lt 0 ] || [ "$4" -ge "$3" ]; then
  disp_usage
  exit 22
fi

export ENVIRONMENT=$1
export COMMS_RANGE=$2
export ROBOT_NUM=$3
export ROBOT_ID=$4
export NETWORK_INTERFACE=$5
export CONTAINER_NAME="robot${ROBOT_ID}"
export CONTAINER_IP="10.0.2.${ROBOT_ID}"

echo "Running with " 
echo ">>> environment: " $ENVIRONMENT
echo ">>> communication range: " $COMMS_RANGE
echo ">>> total robot number: " $ROBOT_NUM
echo ">>> robot id: " $ROBOT_ID
echo ">>> using network interface: " $NETWORK_INTERFACE
echo ">>> setting container name: " $CONTAINER_NAME
echo ">>> setting container ip: " $CONTAINER_IP

# generate a string such that the first character is 1 if COMMS_RANGE is less than 1000, otherwise 0
# the second character is 0 for "tunnel", 1 for "garage", 2 for "campus", 3 for "indoor" and 4 for "forst". 
# The third and forth character is the $ROBOT_NUM. 
# The rest characters are the $COMMS_RANGE
# e.g. 100230 means the environment is "tunnel", the total robot number is 2, the communication range is 30 meters

# First character
if [ "$COMMS_RANGE" -lt 1000 ]; then
    first_char="1"
else
    first_char="0"
fi

# Second character
case "$ENVIRONMENT" in
    "tunnel")
        second_char="0"
        ;;
    "garage")
        second_char="1"
        ;;
    "campus")
        second_char="2"
        ;;
    "indoor")
        second_char="3"
        ;;
    "forest")
        second_char="4"
        ;;
    *)
        echo "Unknown environment"
        exit 1
        ;;
esac

# Third and fourth characters (ensuring two digits for ROBOT_NUM)
printf -v robot_num "%02d" $ROBOT_NUM

# Construct the final string
export TEST_ID="${first_char}${second_char}${robot_num}${COMMS_RANGE}"
echo ">>> setting test id: $TEST_ID"

# Check if Nvidia GPU is available
# Check if the NVIDIA driver is installed
docker_compose_filename="docker-compose-launch-robot.yml"
if ! command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA driver not detected."
    docker_compose_filename="docker-compose-launch-robot-cpu.yml"
fi

export DOCKER_COMPOSE_FILE=$docker_compose_filename
echo ">>> using docker compose file: $DOCKER_COMPOSE_FILE"

# Rename tmux session and docker compose service
tmux_session_name="launch_robot${ROBOT_ID}"
docker_compose_service_name="robot${ROBOT_ID}"
sed -i "s/^session_name:.*/session_name: $tmux_session_name/" "launch_robot.yml"
sed -i "s/robot.*:/$docker_compose_service_name:/" "$docker_compose_filename"

tmuxp load launch_robot.yml