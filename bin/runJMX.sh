#!/bin/bash

# Get process PID
RUNJMX_PID=$$

# Check base dir name
BASE_DIR=`dirname "$0"`

# Initialize parameters and functions
. ${BASE_DIR}/functions.sh

# Initialize number of client to 1
NumberOfClient=1

# Check parameters
while getopts f:p:r:t:d:c:l:J:o: o
do      
	case "$o" in
    	f)      
			JMX_FILE="$OPTARG"
			;;
        p)      
			PROPERTIES_FILE="$OPTARG"
			;;
        r)      
			REMOTE_HOST="$OPTARG"
			;;
		t)
			TPS_COMMAND_LINE="$OPTARG"
			EXTRA_ARGS=" ${EXTRA_ARGS} -JTPS=${TPS_COMMAND_LINE} "
			;;
		d)
			TestDuration_COMMAND_LINE="$OPTARG"
			EXTRA_ARGS=" ${EXTRA_ARGS} -JTestDuration=${TestDuration_COMMAND_LINE} "			
			;;
		c)
			NumberOfClients="$OPTARG"
			;;			
		l)
			NumberOfClient="$OPTARG"
			;;
		J)
			EXTRA_ARGS=" ${EXTRA_ARGS} -J$OPTARG"
			;;
		o)
			OUTPUT_TREND="$OPTARG"
			;;
        \?)    
			echo 1>&2 Usage: $0 -f \<JMX_FILE\> -p \<PROPERTIES_FILE\> -r \<REMOTE_HOST\> -t \<TPS\> -d \<TestDuration\> -c \<NumberOfClients\> -l \<NumberOfClient\> -J\<ExtraArguments\> -o \<OutputTrendName\>
               		exit 1
			;;
		:)
      		echo 1>&2 "Option -$OPTARG requires an argument."
      		exit 2
      		;;
	esac
done

EXTRA_ARGS=" ${EXTRA_ARGS} ${ExtraArguments} "

# Check number of slaves
if [ -z $REMOTE_HOST ]; then
    REMOTE_HOST=""
	NUMBER_OF_SLAVES=1
else
	# Get number of elements
	getnumberofelements ${REMOTE_HOST}
	NUMBER_OF_SLAVES=${NUMBER_OF_ELEMENTS}

    REMOTE_HOST="-r -Jremote_hosts=${REMOTE_HOST}"
fi

# Echo options
echo 1>&2 "Options:"
echo 1>&2 "     JMX_FILE=${JMX_FILE}"
echo 1>&2 "     PROPERTIES_FILE=${PROPERTIES_FILE}"
echo 1>&2 "     REMOTE_HOST=${REMOTE_HOST}"
echo 1>&2 "     NUMBER_OF_SLAVES=${NUMBER_OF_SLAVES}"
echo 1>&2 "     TPS=${TPS_COMMAND_LINE}"
echo 1>&2 "     TestDuration=${TestDuration_COMMAND_LINE}"
echo 1>&2 "     NumberOfClients=${NumberOfClients}"

# Call getjmeterdir
getjmeterdir

# Get base name for properties
getbasename $PROPERTIES_FILE
PROPERTIES_BASE_NAME=${FILE_NAME}

# Get base name of JMX file
getbasename $JMX_FILE
JMX_BASE_NAME=${FILE_NAME}

# Get timestamp
timestamp=`date "+%Y%m%d%H%M%S"`

# Get machine name
HOSTNAME=`hostname`


# Generate FILE_NAME
FILE_NAME="${JMX_BASE_NAME}_${PROPERTIES_BASE_NAME}_${HOSTNAME}_${timestamp}"

# Get total tests duration
getsleeptime ${PROPERTIES_FILE} ${NUMBER_OF_SLAVES}

JTL_FILE="${reports}/${FILE_NAME}.jtl"
JLOG_FILE="${logs}/${FILE_NAME}.log" 

# Check if reports directory exists
if [ -d $reports ]; then
	# Delete old reports
	rm -f ${JTL_FILE}
	rm -f ${JLOG_FILE}
	echo 1>&2 "Old reports deleted"
fi

if [ -d $csv ]; then
        # Delete old CSV reports
        rm -f ${csv}/${FILE_NAME}*.*
        echo 1>&2 "Old reports deleted"
fi

export JVM_ARGS="-XX:+UseParallelGC -Xms128m -Xmx256m"

# Calculate port with client number
PORT=`expr $NumberOfClient + $BASE_PORT`

# Be sure nothing is running on this port
${BASE_DIR}/stopJMX.sh $PORT
sleep 5

# Call JMeter and generate reports
runJmeterAndGenerateReports &

# Sleep thread
echo 1>&2 "Sleeping thread: ${SleepTime}"
sleep ${SleepTime}

# Try to shutdown
${BASE_DIR}/shutdownJMX.sh $PORT

# Sleep one minute
sleep 60

# Force stop
${BASE_DIR}/stopJMX.sh $PORT

# everything was correct
exit 0
