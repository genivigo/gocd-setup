# Go.cd agent install in Docker
# NAME: genivi/go-agent
#
# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# For design comments and rant, see server version instead.

# Baseimage:  Credits: https://github.com/phusion/baseimage-docker/
#FROM phusion/baseimage:18.04-1.0.0
FROM ubuntu:18.04

LABEL maintainer "Gunnar Andersson <gandersson@genivi.org>"

ENV GO_SERVER="go.genivi.org"

# Location of yocto cache for downloads/sstate inside container
ENV YOCTO_CACHE=/var/cache/yocto

# Standard fix of TZDATA first because otherwise it tries user-interactive
# questions during installation.
RUN apt-get update
ADD tzdata.sh /tmp/tzdata.sh
RUN /tmp/tzdata.sh

# Need git to fetch the provisioning script, the rest is done by the script
# Clean as much as possible before committing keeps the docker image size down.
RUN apt-get install -y git sudo qemu-system-x86 uml-utilities cron

# Standard package list from https://source.android.com/setup/build/initializing#setting-up-a-linux-build-environment
RUN apt-get install -y git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig

# Renesas required additions, according to documentation
RUN apt-get install -y python-wand python-crypto liblz4-tool

# Other stuff I found missing in container base image, and/or convenience tools
RUN apt-get install -y rsync libncurses5-dev wget m4 bc vim-tiny \
    apt-get clean ;\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* || true

# Touching a dummy file forces cache invalidation so
# that git-clone is re-run.  Useful during development
#ADD dummy /tmp/dummy

# Fetch script git repo
RUN git clone http://github.com/genivigo/gocd-setup.git -b lava_agent /root/gocd-setup 2>&1 && ls /root/gocd-setup

# Run the actual provisioning script -
RUN cd /root/gocd-setup && ./go-agent-setup.sh

# Not sure why this isn't being run on first install..  Anyway let's try
# running it explicitly from here.  If the script is there it should work,
# if not the docker build will fail, which is good so we know.
ENV DEBIAN_FRONTEND=noninteractive
RUN /etc/cron.hourly/go-agent-config-cronjob

# Clean up
RUN apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* || true

# Fix go-agent settings
RUN sed -ie 's/DAEMON=Y/DAEMON=N/' /etc/default/go-agent ;\
    sed -ie "s!GO_SERVER.*!GO_SERVER_URL=https://${GO_SERVER}:443/go!" /etc/default/go-agent ;\
    sed -ie 's/export GO_SERVER$/export GO_SERVER_URL/' /etc/default/go-agent

# Add service script for "runit" i.e the init/pid 1 used by phusion/baseimage
# and other needed dirs
RUN mkdir -p /etc/service/go-agent "$YOCTO_CACHE"
ADD go-agent.runit.sh /etc/service/go-agent/run

RUN usermod -a -G kvm go

# Install keys & credentials
RUN mkdir -p /var/go/.ssh ;\
    chown go:go /var/go/.ssh ;\
    chmod 700 /var/go/.ssh

# cip_lava_lab_cred should be a file containing user and token for
# a user that is allowed to submit jobs on the lava server:
#CIP_LAVA_LAB_USER=<something>
#CIP_LAVA_LAB_TOKEN=<something>

# TODO LAGG TILLBAKS DETTA
#ADD cip_lava_lab_cred /var/go/cip_lava_lab_cred
#RUN chown go /var/go/cip_lava_lab_cred

#ADD id_rsa /var/go/.ssh/id_rsa
#ADD id_rsa.pub /var/go/.ssh/id_rsa.pub
#RUN chown -R go /var/go/.ssh/* ;\
#    chmod 400 /var/go/.ssh/id_rsa* ;\
#    chmod 400 /var/go/cip_lava_lab_cred

# Accept host key
#RUN su go -c "echo quit | sftp -i /var/go/.ssh/id_rsa -o StrictHostKeyChecking=no go_artifact_upload@docs.projects.genivi.org" || true

# Use baseimage-docker's init system as default command
#CMD ["/sbin/my_init"]

