#!/usr/bin/env bash

disp_usage() {
  # display script usage
  echo "Usage: stop.sh <robot_id>"
  echo "  - <robot_id> (Optional): The robot with robot_id to stop"
}

if [ "$#" -gt 1 ]; then
  disp_usage
  exit 22  
fi

stop_all=1
robot_id=0
if [ "$#" -eq 1 ]; then
  # check robot id is in range
  stop_all=0
  robot_id=$1
fi

# If stop all
if [ "$stop_all" -eq 1 ]; then
  echo "Stopping all robots"
  # kill all tmux sessions
  tmux list-sessions | grep -oP 'launch_robot\d+' | while read -r session; do
    echo "Stopping tmux session: $session"
    # Manually stop the development environment and TARE
    dev_env_window=DEV_ENV
    dev_env_pane_num=$(tmux list-panes -t "$session:$dev_env_window" | wc -l)
    for pane_id in $(seq 0 $(($dev_env_pane_num - 1))); do \
      tmux send-keys -t $session:$dev_env_window.$pane_id C-c Enter ; done

    tare_window=TARE
    tare_pane_num=$(tmux list-panes -t "$session:$tare_window" | wc -l)
    for pane_id in $(seq 0 $(($tare_pane_num - 1))); do \
      tmux send-keys -t $session:$tare_window.$pane_id C-c Enter ; done    
    
    sleep 3s  
    tmux kill-session -t $session 
  done

  # kill all docker containers
  echo "stopping and removing docker containers"
  docker ps -aq --filter "name=robot*" | grep -q . && docker stop $(docker ps -aq --filter name="robot*") && docker rm $(docker ps -aq --filter name="robot*")
else
  # only kill the tmux session and docker with the specified robot_id
  echo "Stopping robot $robot_id"
  session=launch_robot${robot_id}
  tmux has-session -t $session 2>/dev/null
  if [ $? == 0 ]; then
    echo "Stopping tmux session: $session"
    # Manually stop the development environment and TARE
    dev_env_window=DEV_ENV
    dev_env_pane_num=$(tmux list-panes -t "$session:$dev_env_window" | wc -l)
    for pane_id in $(seq 0 $(($dev_env_pane_num - 1))); do \
      tmux send-keys -t $session:$dev_env_window.$pane_id C-c Enter ; done

    tare_window=TARE
    tare_pane_num=$(tmux list-panes -t "$session:$tare_window" | wc -l)
    for pane_id in $(seq 0 $(($tare_pane_num - 1))); do \
      tmux send-keys -t $session:$tare_window.$pane_id C-c Enter ; done    

    sleep 3s  
    tmux kill-session -t $session 
  else
    echo "No tmux sessions"
  fi

  # kill all docker containers
  echo "stopping and removing docker container"
  docker ps -aq --filter "name=robot$robot_id" | grep -q . && docker stop $(docker ps -aq --filter name="robot$robot_id") && docker rm $(docker ps -aq --filter name="robot$robot_id")
fi

# Remove the network
echo "Removing my-macvlan-net"
docker network rm my-macvlan-net