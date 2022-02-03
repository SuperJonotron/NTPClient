#!/bin/bash

# Setup script will be in charge of running all associated scripts and commands
# to fully prepare the Docker image.  This is intended help keep the Dockerfile
# cleaner and easier to read as well as remove a lot of issues with dynamic
# enviornemnt variables that are hard to manage when trying to work from the 
# Docker build context.

#Download and install arduino-cli to /bin
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

#Initialize arduino-cli
arduino-cli config init 

#Resolve the installed locations for arduino-cli
DATA_PATH=$(arduino-cli config dump | grep "data:" | awk '{print $2}')
USER_PATH=$(arduino-cli config dump | grep "user:" | awk '{print $2}')

#Replace file "/root/.arduino15/arduino-cli.yaml" created from init
#with the esp8266 board defined in additional_urls
cp /arduino/arduino-cli/arduino-cli.yaml $DATA_PATH

#Update arduino-cli with the new config file
RUN arduino-cli core update-index

#Install the esp8266 board
arduino-cli core install esp8266:esp8266

#Create a folder for the libraries
mkdir -p $USER_PATH/libraries

#Dynamically create the correct arduiono global variables
#for the esp8266 board regardless of what cli and board
#version were installed during build time
BOARD="esp8266"
BOARD_VERSION=$(arduino-cli core list | grep $BOARD | awk '{print $2}')
BOARD_PATH="$DATA_PATH/packages/$BOARD/hardware/$BOARD/$BOARD_VERSION"
TOOL_PATH="$BOARD_PATH/tools/espota.py"

#Replace the platform.txt for the esp8266 to fix pre-compiled library usage
cp /arduino/arduino-cli/$BOARD/platform.txt $BOARD_PATH

echo BOARD="\""$BOARD"\"">> /etc/environment 
echo DATA_PATH="\""$DATA_PATH"\"">> /etc/environment 
echo USER_PATH="\""$USER_PATH"\"">> /etc/environment 
echo BOARD_VERSION="\""$BOARD_VERSION"\"">> /etc/environment 
echo BOARD_PATH="\""$BOARD_PATH"\"">> /etc/environment 
echo TOOL_PATH="\""$TOOL_PATH"\"">> /etc/environment 