## CoreAI configuration
# loaded by entrypoint.sh as /coreai_config.sh
# ... after setting the variables from the command line: will override with the values set here
#
# To use your custom version, duplicate the file and mount it in the container: -v /path/to/your/config.sh:/coreai_config.sh
#
# Can be used to set the other command line variables
# Set using: export VARIABLE=value

## Environment variables loaded when passing environment variables from user to user
# Ignore list: variables to ignore when loading environment variables from user to user
export ENV_IGNORELIST="HOME PWD USER SHLVL TERM OLDPWD SHELL _ SUDO_COMMAND HOSTNAME LOGNAME MAIL SUDO_GID SUDO_UID SUDO_USER ENV_IGNORELIST ENV_OBFUSCATE_PART"
# Obfuscate part: part of the key to obfuscate when loading environment variables from user to user, ex: HF_TOKEN, ...
export ENV_OBFUSCATE_PART="TOKEN API KEY"

##### Command line variables
# Uncomment and set as preferred, see README.md for more details

## User and group id
#export WANTED_UID=1000
#export WANTED_GID=1000
# DO NOT use `id -u` or `id -g` to set the values, use the actual values -- the script is started by coreaitoo with 1025/1025

## Verbose mode
# uncomment is enough to enable
#export CoreAI_VERBOSE="yes"

##### NVIDIA specific adds
#export NVIDIA_VISIBLE_DEVICES=all
#export NVIDIA_DRIVER_CAPABILITIES=all
#export NVCC_APPEND_FLAGS='-allow-unsupported-compiler'

##### User settings
# If adding content to be obfuscated, add it to ENV_OBFUSCATE_PART
#export HF_TOKEN=""
#export OPENAI_API_KEY=""

# Do not use an exit code, this is loaded by source
