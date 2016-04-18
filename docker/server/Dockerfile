# Go.cd server install in Docker
#
# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# This seemingly does about the same as github/gocd/gocd-docker(*) but 
# nowadays the script does a whole lot more.
#
# Most of all I think it is ~bad~ to hide provisioning inside Dockerfiles.
# The steps should be reusable in other environments too.  If you want to
# do the installation on bare metal, or in Vagrant, or whatever - then a
# bourne shell script(s) is more reusable.
#
# ...and Docker syntax is freaking bizarre too :) </rant>
#
# But Docker has its charm.  There are some special settings for this
# go-cd and yes, those additions could have been layered on top of for
# example the gocd/gocd-docker Docker image.  That would be quite nice.
# But see above :)
#
# Anyway, phusion baseimage seem to get it right with respect to an actual
# good base container, so let's start there.

# Baseimage:  Credits: https://github.com/phusion/baseimage-docker/
FROM phusion/baseimage:0.9.18

# Need git to fetch the provisioning script, the rest is done by the script
# Clean as much as possible before committing keeps the docker image size  down.
RUN apt-get update ;\
    apt-get install -y git ;\
    apt-get clean ;\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Touching a dummy file forces cache invalidation so
# that git-clone is re-run.  Useful during development
#ADD dummy /tmp/dummy

# Fetch script git repo
RUN git clone http://github.com/genivigo/gocd-setup.git /tmp/gocd-setup 2>&1 && ls /home/xuser/gocd-setup

# Run the actual provisioning script -
RUN cd /tmp/gocd-setup && ./go-server-setup.sh

# Clean up
RUN apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 8153 8154

# Add service script for "runit" i.e the init/pid 1 used by phusion/baseimage
RUN sed -ie "s/DAEMON=Y/DAEMON=N/" /etc/default/go-server
RUN mkdir /etc/service/go-server
ADD go-server.runit.sh /etc/service/go-server/run

# Use baseimage-docker's init system as default command
CMD ["/sbin/my_init"]
