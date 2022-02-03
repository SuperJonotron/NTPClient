#!/bin/bash

LIBRARY="NTPClient"
EXAMPLE="NTPClient"

#Loads the global variable set at build time
source /etc/environment

#Add some messaging to help confirm everything is working
echo "BOARD: $BOARD"
echo "BOARD_VERSION: $BOARD_VERSION"
echo "BOARD_PATH: $BOARD_PATH/"
echo "TOOL_PATH: $TOOL_PATH"

#Download all external libraries from git that don't have direct arduino library support
LIBRARIES=$USER_PATH/libraries
# git clone https://github.com/SuperJonotron/arduino-tm1637 $LIBRARIES/arduino-tm1637
# git clone https://github.com/SuperJonotron/Time $LIBRARIES/Time
# git clone https://github.com/SuperJonotron/Timezone $LIBRARIES/Timezone
# git clone https://github.com/SuperJonotron/RTClib $LIBRARIES/RTClib

# #Download all available libraries from the arduino library manager
# arduino-cli lib install "ArduinoJson"
# arduino-cli lib install "rBase64"

cp -r /sketch $LIBRARIES/$LIBRARY
echo "$LIBRARIES/$LIBRARY"

# #Extract OTA python tool and store to mounted location
# mkdir -p /sketch/out/tools
# cp $BOARD_PATH/tools/espota.py /sketch/out/tools/espota.py

# Compile the Example library
cd $LIBRARIES/$LIBRARY/examples/$EXAMPLE
#-e Export binaries
#--output-dir Location to output all the compiled files
#--fqbn Fully qualified board name to compile against
arduino-cli compile -e --output-dir /sketch/out/build --fqbn esp8266:esp8266:nodemcuv2
