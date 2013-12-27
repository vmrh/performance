#!/bin/bash

# Get JDK
wget http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.rpm -O jdk-7u45-linux-x64.rpm

# Check if everythings went right
if [ "$?" -ne "0" ]; then
        echo 1>&2 "There is a problem downloading Java"
        exit 2
fi

# Install on machine
rpm –ivh jdk-7u45-linux-x64.rpm

# Check if everythings went right
if [ "$?" -ne "0" ]; then
	echo 1>&2 "There is a problem installing Java"
	exit 2
fi

# Check Java installed
java -version 2>&1 | grep "1.7"

if [ "$?" -ne "0" ]; then
        # Show an error and exit
        echo  1>&2 "You need Java 1.7 in order to install JMeter load balance test"
        exit 2
fi
