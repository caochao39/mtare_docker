FROM caochao/ubuntu20_ros1_ros2:latest

# Add a user
RUN useradd -m docker-user

# Add the user to sudoers
RUN usermod -aG sudo docker-user

# Optinal: use sudo without a password prompt
RUN echo 'docker-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the user
USER docker-user

# Source ROS1
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Setup work directory
RUN mkdir -p /home/docker-user/mtare

CMD ["bash"]