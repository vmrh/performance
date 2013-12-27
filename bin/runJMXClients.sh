#!/bin/bash

# Get process PID
RUNJMX_PID=$$

# Check base dir name
BASE_DIR=`dirname "$0"`

# Initialize parameters and functions
. ${BASE_DIR}/functions.sh

# Initialize number of client to 1
NumberOfClients=1

# Check parameters
while getopts f:p:r:t:d:c:J:o: o
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
		J)
			EXTRA_ARGS=" ${EXTRA_ARGS} -J$OPTARG"
			;;
		o)
			OUTPUT_TREND="$OPTARG"
			;;
        \?)    
			echo 1>&2 Usage: $0 -f \<JMX_FILE\> -p \<PROPERTIES_FILE\> [-r \<REMOTE_HOST\> -t \<TPS\> -d \<TestDuration\> -c \<NumberOfClients\> -J\<ExtraArguments\> -o \<OutputTrendName\>]
            exit 1
			;;
		:)
      		echo 1>&2 "Option -$OPTARG requires an argument."
      		exit 2
      		;;
	esac
done

# Start clients
count=1
while [ $count -le $NumberOfClients ]
do
	# Running client count
	echo 1>&2 "Starting client: $count "

	# Run client
	${BASE_DIR}/runJMX.sh $* -l $count &

	# Sleep 1 second not have any problem with files generated
	sleep 1
	
	count=`expr $count + 1`
done


# everything was correct
exit 0