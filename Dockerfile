FROM ubuntu

RUN apt-get update

RUN apt-get -y install sudo nano

# Adds test sudo user "docker" with password "docker"
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Puts the script inside the test user's home
COPY --chown=770 ubuntu.sh /home/docker/

USER docker
