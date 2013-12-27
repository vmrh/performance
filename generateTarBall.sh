#!/bin/bash

# Check base dir name
BASE_DIR=`dirname "$0"`

timestamp=`date "+%Y%m%d%H%M%S"`

TARBALL_NAME="performance_${timestamp}.tar.gz"

# Remove previous version it exists
if [ -f "${TARBALL_NAME}" ]; then
	rm -f "${TARBALL_NAME}"
fi

# Generate tarball
tar -cvzf ${TARBALL_NAME}  ${BASE_DIR}/README.txt ${BASE_DIR}/bin/*.sh ${BASE_DIR}/bin/*.sql ${BASE_DIR}/bin/*.jar ${BASE_DIR}/bin/*.bsh ${BASE_DIR}/bin/htmlReports/*.sh ${BASE_DIR}/bin/htmlReports/xsl/* ${BASE_DIR}/install/*.sh ${BASE_DIR}/install/*.pem ${BASE_DIR}/install/lib/*.jar ${BASE_DIR}/jmx/*.jmx ${BASE_DIR}/jmx/UI/*.jmx ${BASE_DIR}/logs/.donotdelete ${BASE_DIR}/properties/*.properties ${BASE_DIR}/properties/*.csv ${BASE_DIR}/scenarios/*.sh ${BASE_DIR}/statistics/*

# Check if everythings goes ok
if [ "$?" -eq "0" ]; then
	# Show an error and exit
	echo  1>&2 "Generated tarball: ${TARBALL_NAME}"
    exit 0
fi
