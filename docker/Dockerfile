FROM ubuntu:20.04
#Update before we do anything else
RUN apt-get update

#Get the CA certificates so we can validate packages
RUN apt-get install ca-certificates -y --no-install-recommends

#Uncomment this to install packages for debugging during development
RUN apt-get install iputils-ping net-tools -y --no-install-recommends

# Install all required packages
#   - curl -> used to retrieve arduino packages
#	- git -> used to retrieve arduino libraries
#	- python3 -> required to use arduino-cli
#	- dos2unix -> Used to fix window line endings for bash files
RUN apt-get install curl git python3 dos2unix -y --no-install-recommends

#Create necessary directories
RUN mkdir -p /arduino/arduino-cli
RUN mkdir -p /arduino/bin
RUN mkdir -p /sketch/out

#Move over all the required files for arduino-cli
COPY arduino-cli /arduino/arduino-cli

#Move over all the executable files
COPY bin/ /arduino/bin

#Make sure scripts are executable
RUN chmod +x /arduino/bin/*

# When developing in windows, files tend get
# corrupted so we'll correct for this every time to be safe
RUN find arduino/bin/ -type f -print0 | xargs -0 dos2unix
RUN find arduino/arduino-cli/ -type f -print0 | xargs -0 dos2unix
RUN find arduino/arduino-cli/esp8266 -type f -print0 | xargs -0 dos2unix

# Setup arduino-cli and the environment for compiling sketches
RUN arduino/bin/setup.sh

WORKDIR /arduino/bin



# NodeMCU 1.0 (ESP-12E Module) 
# https://github.com/esp8266/Arduino/blob/master/boards.txt

#nodemcuv2.menu.FlashSize.4M1M.build.spiffs_start=0x300000
#nodemcuv2.menu.FlashSize.4M1M.build.spiffs_end=0x3FB000

#0x3FB000 - 0x300000 = 0xFB000

#cd /root/.arduino15/packages/esp8266/tools/mkspiffs/2.5.0-4-b40a506/
#./mkspiffs --size 0xFB000 --page 256 --block 8192 -d 5 --create /data /data/spiffs.bin
