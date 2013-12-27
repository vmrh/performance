#!/bin/sh

# Check base dir name
BASE_DIR=`dirname "$0"`

function usageHelp ()
{
	echo 1>&2 "Usage: $0 -s <server> -d directory"
	echo 1>&2 "Parameters:"
	echo 1>&2 "	-u <user>: user to connect to remote server"
	echo 1>&2 "	-s <server>: server to connect to"
	echo 1>&2 "	-d <directory>: directory used in order to copy temporarily files"
	echo 1>&2 "Example:"
	echo 1>&2 "	$0 -s apibuild -d /home/jmeter/test  -- "
}


# check if there are parameters
if [ $# -gt 2 ]; then
    
	while getopts u:s:d: o
	do	case "$o" in
		u)	user="$OPTARG";;
		s)	server="$OPTARG";;
		d)	remoteDirectory="$OPTARG";;
		[?]) usageHelp;exit 1;;
		esac
	done
else
	# At least we need server and remote directory in order to install
	usageHelp $*
	exit 2
fi

# Check user, server and directory
if [ -z ${user} ]; then 
	# Show error and exit
	echo 1<&2 "User is mandatory: please include \"-u <user>\" as a parameter"
	usageHelp $*
	exit 3
fi

if [ -z ${server} ]; then 
	# Show error and exit
	echo 1<&2 "Server is mandatory: please include \"-s <server>\" as a parameter"
	usageHelp $*
	exit 4
fi

if [ -z ${remoteDirectory} ]; then 
	# Show error and exit
	echo 1<&2 "Remote directory is mandatory: please include \"-d <directory>\" as a parameter"
	usageHelp $*
	exit 5
fi

# Check if remote directory exists
ssh ${user}@${server} "ls ${remoteDirectory} > /dev/null 2>&1"

# Check that everything goes ok
if [ "$?" -eq "0" ]; then
	# Directory exists just mv information
	timestamp=`date "+%Y%m%d%H%M%S"`
	ssh ${user}@${server} "mv ${remoteDirectory} ${remoteDirectory}_${timestamp}"
	
	echo 1<&2 "Directory: ${remoteDirectory} moved to ${remoteDirectory}_${timestamp}, in order not to get old files"
fi

# Create token directory
ssh ${user}@${server} "mkdir ${remoteDirectory}"

# Check that everything goes ok
if [ "$?" -ne "0" ]; then
	echo 1<&2 "Directory: ${remoteDirectory} could not be created, please check it"
	exit 7
fi

echo 1<&2 "Directory: ${remoteDirectory} created"

# Copy files to remote server
scp performance*.tar.gz ${user}@${server}:${remoteDirectory}/

# Check that everything goes ok
if [ "$?" -ne "0" ]; then
	echo 1<&2 "Error trying to copy performance*.tar.gz"
	exit 8
fi

echo 1<&2 "${remoteDirectory}/performance*.tar.gz copied"

# Extract files
ssh ${user}@${server} "cd ${remoteDirectory}; tar -xzf performance*.tar.gz"

# Check that everything goes ok
if [ "$?" -ne "0" ]; then
	echo 1<&2 "Error trying to extract ${remoteDirectory}/performance*.tar.gz"
	exit 9
fi

echo 1<&2 "${remoteDirectory}/performance*.tar.gz extracted"

