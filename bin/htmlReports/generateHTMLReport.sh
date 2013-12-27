#!/bin/bash

# Check base dir name
BASE_DIR=`dirname "$0"`

# Initialize parameters and functions
. ${BASE_DIR}/../functions.sh

# Check if we have at least one parameter
if [ $# -eq 1 ]; then
        JTL_FILE=$1
fi

# Call getjmeterdir
getjmeterdir

# Delete calls
sed "/lb=\"http/d" $JTL_FILE > "${JTL_FILE}_Without_Redirections"

# Get JTL_FILE name
HTML_FILE="${JTL_FILE}_Without_Redirections.html"

# Change jtl to analize
JTL_FILE="${JTL_FILE}_Without_Redirections"

# Echo options
echo 1>&2 ""
echo 1>&2 " Generate HTML Report Options:"
echo 1>&2 "     JTL_FILE=${JTL_FILE}"
echo 1>&2 "     HTML_FILE=${HTML_FILE}"

# Run java to generate report
java ${JVM_ARGS} -classpath "${JMETER_DIR}/lib/xalan-2.7.1.jar:${JMETER_DIR}/lib/serializer-2.7.1.jar" org.apache.xalan.xslt.Process -IN "${JTL_FILE}" -XSL "${BASE_DIR}/xsl/jmeter-results-report_21.xsl" -OUT "${HTML_FILE}"

# Echo result
if [ "$?" -eq "0" ]; then
	echo 1>&2 ""
	echo 1>&2 " Generated HTML Report: ${HTML_FILE}"
fi

