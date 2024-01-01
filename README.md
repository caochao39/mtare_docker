# M-TARE Quick Start 

## Install Dependencies
Install terminal multiplexers
```
sudo apt install tmux tmuxp
```
Optional: use a customized tmux config file
```
cp <folder containing this repository>/.tmux.conf ~/
```

## Pull the Docker Image
For a tutorial on using Docker, please refer to [here](https://github.com/jizhang-cmu/docker_setup_instructions).
```
docker pull caochao/mtare-open-source:latest
```

## Prepare the Ethernet Interface
Make sure the ethernet interface on your computer is up. For example, ```ifconfig``` should list something like ```enp0s31f6```, ```eno1```, etc as one of the network interfaces.

If you are running this demo on a single computer, you can connect one end of an Ethernet cable to your computer's Ethernet port, and attach the other end to a second computer. In this setup, it's not necessary for the two computers to be able to ping each other. The key requirement is that the Ethernet interface on the target computer is active and operational (listed by ```ifconfig```).

## Run M-TARE
Run M-TARE with three robots to explore a tunnel environment
```
./run_mtare_3_robots.sh
```
Three ```Rviz``` windows should pop up and show the exploration process.

### Explore Other Environments
To run the exploration in other environments, change ```SCENARIO: tunnel``` in ```launch_robots.yml``` accordingly.