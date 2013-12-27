#!/bin/bash

# Script created to split payment file 

# Check base dir name
BASE_DIR=`dirname "$0"`

# Initialize parameters and functions
. ${BASE_DIR}/../functions.sh

# Check if we have two parameters, name of thread and CSV file
if [ $# -ne 2 ]; then
	echo 1>&2 "Incorrect number of arguments: $#"
	echo 1>&2 "Call: $*"
	echo 1>&2 Usage: $0 \<CSV_FILE\> \<THREAD_NAME\>
	exit 1
fi

# Get arguments
CSV_FILE_NAME=$1
THREAD=$2

STARTURL="/2/oauth/authorize"
NUMBEROFREQUESTPERLOOP=5

# Check if string exist in file
COUNT=`grep ";${THREAD};" ${CSV_FILE_NAME} | wc -l`
	
#echo "File: ${CSV_FILE_NAME}, contains: ${COUNT}, thread: ${THREAD}"

if [ $COUNT -gt 0 ]; then
				
	# Thread name
	THREAD_NAME=`echo "${THREAD}" | cut -d " " -f 2`
		
	#echo "Thread ${THREAD_NAME}, with $COUNT entries "
		
	# Create a new file only with threads entries from CSV
	THREAD_FILE_NAME=${CSV_FILE_NAME}_${THREAD_NAME}		
	grep ";${THREAD};" ${CSV_FILE_NAME} > ${THREAD_FILE_NAME}
		
	# Create a file to maintain total time for each complete transaction
	THREAD_TOTALTIME_FILE_NAME=${THREAD_FILE_NAME}_time	
	if [ -f $THREAD_TOTALTIME_FILE_NAME ]; then
		rm $THREAD_TOTALTIME_FILE_NAME
	fi
	
	# Read each line of THREAD_FILE_NAME to calculate time of transactions
	LOOPTIME=0
	REQUESTNUMBER=0
	TOTALTIMEOFLOOPS=0
	
	# Read all lines
	while read line
	do 
		# Get url and time			
		URL=`echo "$line" | cut -d ";" -f 3`
		TIME=`echo "$line" | cut -d ";" -f 4`
		TIMESTAMP=`echo "$line" | cut -d ";" -f 1`
			
		# Check if it is first call
		if [ "${URL}" = "${STARTURL}" ]; then
			LOOPTIME=$TIME;
			REQUESTNUMBER=1			
		else
			LOOPTIME=$(($LOOPTIME+$TIME));
			REQUESTNUMBER=$(($REQUESTNUMBER+1));
				
			# Check if it is last request
			if [ $REQUESTNUMBER -eq "5" ]; then
				echo "${LOOPTIME} ${TIMESTAMP} ${URL}" >> $THREAD_TOTALTIME_FILE_NAME
				TOTALTIMEOFLOOPS=$((${TOTALTIMEOFLOOPS}+$LOOPTIME));
			fi
		fi
	done < ${THREAD_FILE_NAME}
		
	
	# Sort file as numbers, first greatest one
	sort -nr < $THREAD_TOTALTIME_FILE_NAME > ${THREAD_TOTALTIME_FILE_NAME}_sort
	
	LOOPCOUNT=`wc -l < ${THREAD_TOTALTIME_FILE_NAME}_sort`
	
	# Check if there is any loop
	if [ "$LOOPCOUNT" -gt "0" ]; then
		# Get max, min and average
		MAXTIME=`head -1 ${THREAD_TOTALTIME_FILE_NAME}_sort`
		MINTIME=`tail -1 ${THREAD_TOTALTIME_FILE_NAME}_sort`
		AVRGTIME=`expr ${TOTALTIMEOFLOOPS} / ${LOOPCOUNT}`
		
		# Echo results for loop
		echo "Min value for $THREAD is: ${MINTIME}"
		echo "Max value for $THREAD is: ${MAXTIME}"
		echo "Average value for $THREAD is: ${AVRGTIME}"
		
		# Save numbers to file
		echo "$MAXTIME" >> ${CSV_FILE_NAME}_max
		echo "$MINTIME" >> ${CSV_FILE_NAME}_min
		echo "$AVRGTIME" >> ${CSV_FILE_NAME}_avrg
	fi
fi