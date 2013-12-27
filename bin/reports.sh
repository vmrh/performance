#!/bin/bash

# Check base dir name
BASE_DIR=`dirname "$0"`

# Load funcions
. ${BASE_DIR}/functions.sh

# Function used to genate tar.gz
generateTarGz ()
{
	if [ $# -ne 2 ]; then
		echo 1>&2 "You need to specify tar.gz name and files to be included"
		exit 1
	fi

	FILE_NAME=$1
	FILES=$2
	
	DIR_NAME=`dirname "$FILES"`
    BASE_NAME=`basename "$FILES"`
	
	# Check if file exists
	count=`find ${DIR_NAME} -name ${BASE_NAME} | wc -l`

	if [ "$count" -gt "0" ]; then
		# Compress all reports on a file
		tar -cvzf "${FILE_NAME}.tar.gz" ${FILES}

		# Check if everythings goes ok
		if [ "$?" -ne "0" ]; then
			# Show an error and exit
	        echo  1>&2 "Could not generate tarball: ${FILE_NAME} including: ${FILES}"
    	    exit 1
		fi

		# Remove files
		rm -f ${FILES}
	else
		echo  1>&2 "There is no files like: ${BASE_NAME}, at: ${DIR_NAME}, to generate tarball"
	fi
	
}

# Get timestamp
TIMESTAMP=`date "+%Y%m%d%H%M%S"`

# Check if we have a parameter with environment
if [ $# -eq 1 ]
then
        ENVIRONMENT=$1
        TIMESTAMP=_${TIMESTAMP}
fi

# Get machine name
HOSTNAME=`hostname`

# Generate report name
REPORT_NAME="reports_${HOSTNAME}_${ENVIRONMENT}${TIMESTAMP}"

# Generate tar.gz with JTL files
generateTarGz "${REPORT_NAME}_jtl" "${reports}/*${ENVIRONMENT}*.jtl"
generateTarGz "${REPORT_NAME}_log" "${logs}/*${ENVIRONMENT}*.log"
generateTarGz "${REPORT_NAME}_html" "${reports}/*${ENVIRONMENT}*.html"

exit 0