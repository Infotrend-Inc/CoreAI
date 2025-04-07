#!/bin/bash

set -e

error_exit() {
  echo -n "!! ERROR: "
  echo $*
  echo "!! Exiting script (ID: $$)"
  exit 1
}

ok_exit() {
  verb_echo $*
  verb_echo "++ Exiting script (ID: $$)"
  exit 0
}

# everyone can read our files by default
umask 0022

# Write a world-writeable file (preferably inside /tmp -- ie within the container)
write_worldtmpfile() {
  tmpfile=$1
  if [ -z "${tmpfile}" ]; then error_exit "write_worldfile: missing argument"; fi
  if [ -f $tmpfile ]; then sudo rm -f $tmpfile; fi
  echo -n $2 > ${tmpfile}
  sudo chmod 777 ${tmpfile}
}

# Set verbose mode
if [ ! -z "${CoreAI_VERBOSE+x}" ]; then write_worldtmpfile /tmp/.CoreAI-VERBOSE "yes"; fi

verb_echo() {
  if [ -f /tmp/.CoreAI-VERBOSE ]; then
    echo $*
  fi
}

save_env() {
  tosave=$1
  verb_echo "-- Saving environment variables to $tosave"
  env | sort > "$tosave"
}

load_env() {
  tocheck=$1
  overwrite_if_different=$2
  ignorelist="HOME PWD USER SHLVL TERM OLDPWD SHELL _ SUDO_COMMAND HOSTNAME LOGNAME MAIL SUDO_GID SUDO_UID SUDO_USER"
  if [ -f "$tocheck" ]; then
    verb_echo "-- Loading environment variables from $tocheck (overwrite existing: $overwrite_if_different) (ignorelist: $ignorelist)"
    while IFS='=' read -r key value; do
      doit=false
      # checking if the key is in the ignorelist
      for i in $ignorelist; do
        if [ "A$key" = "A$i" ]; then doit=ignore; break; fi
      done
      if [ "A$doit" = "Aignore" ]; then continue; fi

      if [ -z "${!key}" ]; then
        verb_echo "  ++ Setting environment variable $key [$value]"
        doit=true
      elif [ "$overwrite_if_different" = true ]; then
        if [ "${!key}" != "$value" ]; then
          verb_echo "  @@ Overwriting environment variable $key [${!key}] -> [$value]"
          doit=true
        else
          verb_echo "  == Environment variable $key [$value] already set and value is unchanged"
        fi
      fi
      if [ "$doit" = true ]; then
        export "$key=$value"
      fi
    done < "$tocheck"
  fi
}


whoami=`whoami`
script_dir=$(dirname $0)
script_name=$(basename $0)
verb_echo ""; verb_echo ""
verb_echo "======================================"
verb_echo "=================== Starting script (ID: $$)"
verb_echo "== Running ${script_name} in ${script_dir} as ${whoami}"
script_fullname=$0
verb_echo "  - script_fullname: ${script_fullname}"
verb_echo "======================================"

# Get user and group id
if [ -f /tmp/.CoreAI-WANTED_UID ]; then WANTED_UID=$(cat /tmp/.CoreAI-WANTED_UID); fi
if [ -f /tmp/.CoreAI-WANTED_GID ]; then WANTED_GID=$(cat /tmp/.CoreAI-WANTED_GID); fi
WANTED_UID=${WANTED_UID:-1024}
WANTED_GID=${WANTED_GID:-1024}
if [ ! -f /tmp/.CoreAI-WANTED_UID ]; then write_worldtmpfile /tmp/.CoreAI-WANTED_UID ${WANTED_UID}; fi
if [ ! -f /tmp/.CoreAI-WANTED_GID ]; then write_worldtmpfile /tmp/.CoreAI-WANTED_GID ${WANTED_GID}; fi

# Grab command line arguments and placing them in /coreai_run.sh
if [ ! -z "$*" ]; then write_worldtmpfile /tmp/CoreAI-run.sh "$*"; fi

# Check user id and group id
new_gid=`id -g`
new_uid=`id -u`
verb_echo "== user ($whoami)"
verb_echo "  uid: $new_uid / WANTED_UID: $WANTED_UID"
verb_echo "  gid: $new_gid / WANTED_GID: $WANTED_GID"

# coreaitoo is a specfiic user not existing by default on ubuntu, we can check its whomai
if [ "A${whoami}" == "Acoreaitoo" ]; then 
  verb_echo "-- Running as coreaitoo, will switch coreai to the desired UID/GID"
  # The script is started as coreaitoo -- UID/GID 1025/1025

  # We are altering the UID/GID of the coreai user to the desired ones and restarting as coreai
  # using usermod for the already create coreai user, knowing it is not already in use
  # per usermod manual: "You must make certain that the named user is not executing any processes when this command is being executed"
  if [ "A$WANTED_UID" != "A1024" ]; then
    sudo groupmod -o -g ${WANTED_GID} coreai || error_exit "Failed to set GID of coreai user"
  fi
  if [ "A$WANTED_GID" != "A1024" ]; then
    sudo usermod -o -u ${WANTED_UID} coreai || error_exit "Failed to set UID of coreai user"
  fi
  sudo chown -R ${WANTED_UID}:${WANTED_GID} /home/coreai || error_exit "Failed to set owner of /home/coreai"

  # save the current environment
  save_env /tmp/.CoreAItoo-env

  # restart the script as coreai set with the correct UID/GID this time
  verb_echo "-- Restarting as coreai user with UID ${WANTED_UID} GID ${WANTED_GID}"
  sudo su coreai $script_fullname || error_exit "subscript failed"
  ok_exit "Clean exit"
fi

# If we are here, the script is started as another user than coreaitoo
# because the whoami value for the coreai user can be any existing user, we can not check against it
# instead we check if the UID/GID are the expected ones
if [ "$WANTED_GID" != "$new_gid" ]; then error_exit "coreai MUST be running as UID ${WANTED_UID} GID ${WANTED_GID}, current UID ${new_uid} GID ${new_gid}"; fi
if [ "$WANTED_UID" != "$new_uid" ]; then error_exit "coreai MUST be running as UID ${WANTED_UID} GID ${WANTED_GID}, current UID ${new_uid} GID ${new_gid}"; fi

# We are therefore running as coreai
verb_echo ""; verb_echo "== Running as coreai"

# Load environment variables one by one if they do not exist from /tmp/.CoreAItoo-env
it=/tmp/.CoreAItoo-env
if [ ! -f $it ]; then error_exit "Failed to load environment variables from $it"; fi
verb_echo "-- Loading not already set environment variables from $it"
load_env $it true

########## 'coreai' specific section below
if [ -f /tmp/CoreAI-run.sh ]; then
  sudo chmod +x /tmp/CoreAI-run.sh || error_exit "Failed to make /tmp/CoreAI-run.sh executable"
  /tmp/CoreAI-run.sh
else
  /bin/bash
fi

exit 0
