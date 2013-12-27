#!/bin/bash

# Script created to split payment file 

# Check base dir name
BASE_DIR=`dirname "$0"`

# Initialize parameters and functions
. ${BASE_DIR}/../functions.sh

# Check if we have at least one parameter
if [ $# -ne 1 ]; then
	echo 1>&2 Usage: $0 \<JTL_FILE\>
	exit 1
fi

# Get JTL file
JTL_FILE=$1

# Check JTL file size
JTL_SIZE=`ls -la $JTL_FILE | awk '{ print $5}'`

if [ ${JTL_SIZE} -lt 500000000 ]; then
	# Generate report
	${BASE_DIR}/generateHTMLReport.sh ${JTL_FILE}
	exit 0
fi

# Get base name for jtl
getbasename $JTL_FILE
JTL_BASE_NAME=${FILE_NAME}

# Generate different files for each of calls

call[1]="/2/oauth/authorize"
call[2]="/sandbox-2/api/login.do"
call[3]="/sandbox-2/oauth/confirm-access"
call[4]="/2/oauth/access-token"
call[5]="/1/payment/acr:Authorization/transactions/amount"
call[6]="/discovery/operator"
call[7]="/products/wac-"

for i in "${call[@]}"
do
	# Check if string exist in file
	COUNT=`grep "$i" ${JTL_FILE} | wc -l`

	if [ $COUNT -gt 0 ]; then

		# Create a new file
		getbasename $i
		CALL_NAME=${FILE_NAME}
		SPLIT_FILE=${JTL_FILE}_${CALL_NAME}

		# Add head to file
		cat < ${XSL}/jtl_head > ${SPLIT_FILE}_tmp

		# Get calls from file
		grep "$i" ${JTL_FILE} >> ${SPLIT_FILE}_tmp

		# add bottom to file
		cat < ${XSL}/jtl_bottom >> ${SPLIT_FILE}_tmp


		# Replace httpSample end
        sed 's/\(by=\"[0-9][0-9]*\"\)>/\1\/>/' ${SPLIT_FILE}_tmp > ${SPLIT_FILE}

		# Remove tmp file
		rm ${SPLIT_FILE}_tmp
	
		echo " Created: $SPLIT_FILE"

		# Generate report
		./generateHTMLReport.sh ${SPLIT_FILE}
	fi
done



