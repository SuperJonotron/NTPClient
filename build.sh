#!/bin/bash

function usage {
    echo ""
    echo "usage: build.sh [-b|-c|-doc|-h]"
    echo "  -b Build the image only. Will override other parameters expected behavior."
    echo "  -c Compile the binaries".
    echo "  -doc Generate the code documentation using doxygen."
    echo "  -h Shows the usage help."
    echo "  If no arguemnts are supplied the default behavior is to"
    echo "  build the image, compile binaries and generate documentation"
}

ARG="${1:-unset}"

#Default options
COMPILE="./compile.sh"
GEN_DOC="./genDoc.sh"
BUILD=true

#Check all arguments to assign build values
for i in $*; do
	case $ARG in
	    "-h") 
	        #Help requested.
	        usage 
	        exit 1
	        ;;
	esac
done

while getopts ":c:b:doc:" opt; do
	case $opt in
		c)
			if [ "$OPTARG" == "n" ] || [ "$OPTARG" == "N" ];then
				COMPILE=""
			fi
			;;
		b)
			if [ "$OPTARG" == "n" ] || [ "$OPTARG" == "N" ];then
				BUILD=false
			fi
			;;
		doc)
			if [ "$OPTARG" == "n" ] || [ "$OPTARG" == "N" ];then
				GEN_DOC=""
			fi
			;;

	esac
done

if [ "$BUILD" = true ]; then
	echo "Building image for ntpclient-builder..."
	docker build -f docker/Dockerfile -t ntpclient-builder .
fi

if ! ( [ -z $COMPILE ] && [ -z $GEN_DOC ] );then
	#Create an output directory for the binaries
	mkdir -p "$PWD/out/"
	
	docker run -it \
			   --name ntpclient \
			   --rm \
			   -v "$PWD"/src:/sketch/src \
			   -v "$PWD"/examples:/sketch/examples \
			   -v "$PWD"/out:/sketch/out \
			   -v "$PWD"/library.properties:/sketch/library.properties \
			   ntpclient-builder $COMPILE

fi