#!/bin/bash

# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# ---------------------------------------------------------------------------
# SETTINGS
# ---------------------------------------------------------------------------
VERSION=21.1.0-12439
GO_HOME_DIR=/var/go
CRONSCRIPTS=/etc/cron.hourly

# Normalize directory - make sure we start in "this" directory
D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

fail() { echo "Something went wrong - check script" 1>&2 ; echo msg: "$@" 1>&2 ; exit 1 ; }


# MAIN SCRIPT STARTING -- agent

# ---------------------------------------------------------------------------
# Install Java, git and stuff.  N.B.: Java version is coded into helper script.
# ---------------------------------------------------------------------------
./install-prerequisites.sh
./install-lava-testing.sh

# ---------------------------------------------------------------------------
# Setting up directories
# ---------------------------------------------------------------------------

echo Copying default conf to /etc/default/go-agent
sudo cp go-agent.conf /etc/default/go-agent

# ---------------------------------------------------------------------------
# Install useful packages for agent (needed for yocto build etc.)
# ---------------------------------------------------------------------------
./install_common_build_dependencies.sh
sudo install -m 755 ./go-agent-config-cronjob $CRONSCRIPTS/ || fail "Copying agent config cronscript"
sudo install -m 755 ./rc.local /etc

echo Go-agent is installed - NOTE: It will contact the go server
echo at the defined address: GO_SERVER_URL is set to:
fgrep GO_SERVER_URL= /etc/default/go-agent

echo "Try starting the agent with"
echo "sudo service go-agent start"
echo "otherwise with:"
echo 'sudo -u go /etc/init.d/go-agent start'
