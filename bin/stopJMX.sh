#!/bin/bash

# Check base dir name
BASE_DIR=`dirname "$0"`

# Initialize parameters and functions
. ${BASE_DIR}/functions.sh

# Call getjmeterdir
getjmeterdir

# Check if there are arguments
if [ $# -gt 0 ]; then
	# Check if argument is a number
	for item in "$@"
	do
		if [[ "$item" =~ ^[0-9]+$ ]] ; then
			# Call shutdown
			${JMETER_DIR}/bin/stoptest.sh $item 
		fi
	done
else
	# Call shutdown
	${JMETER_DIR}/bin/stoptest.sh
fi

