#!/bin/bash

# Check user
#whoami | grep "jmeter" 

# Check if everythings goes ok
if [ "$?" -ne "0" ]; then
        # Show an error and exit
        echo  1>&2 "Could not install you need to use JMeter user on your machine"
        exit 1
fi

# Check Java installed
java -version 2>&1 | grep "1.7"

if [ "$?" -ne "0" ]; then
        # Show an error and exit
        echo  1>&2 "You need Java 1.7 in order to install JMeter load balance test"
        exit 2
fi


# Get JMeter binaries from web
curl -O http://mirror.catn.com/pub/apache/jmeter/binaries/apache-jmeter-2.10.tgz

# Check if everythings goes ok
if [ "$?" -ne "0" ]; then
	# Show an error and exit
	echo  1>&2 "Could not download JMeter"
	exit 3
fi

# Unzip file
tar -xvzf apache-jmeter-2.10.tgz

# Remove tgz
rm apache-jmeter-2.10.tgz


# Copy libraries to lib extension
#cp lib/* apache-jmeter-2.9.tgz/lib/ext/





