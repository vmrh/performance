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

# Get base name for jtl
getbasename $JTL_FILE
JTL_BASE_NAME=${FILE_NAME}
TMP_FILE_NAME=${TMP}/${JTL_BASE_NAME}_tmp
CSV_FILE_NAME=${TMP}/${JTL_BASE_NAME}_csv
THREAD_NAMES_FILE_NAME=${TMP}/${JTL_BASE_NAME}_thread_names
RESULT_FILE_NAME=${JTL_FILE}_statistics

if [  ! -d "$TMP" ]; then
	mkdir $TMP
fi

STARTURL="/2/oauth/authorize"
NUMBEROFREQUESTPERLOOP=5

#					TIME				LATENCY (first response) 	TIMESTAMP					URL									THREAD-NAME						BYTES
#^<httpSample t=\"\([0-9][0-9]*\)\" lt=\"\([0-9][0-9]*\)\" ts=\"\([0-9][0-9]*\)\" s=\"true\" lb=\"\(..*\)\" rc=\"200\" rm=\"OK\" tn=\"\(..*\)\" dt=\"text\" by=\"\([0-9][0-9]*\)\"\/\{0,1\}>$
# Only get correct responses
egrep "^<httpSample t=\"[0-9][0-9]*\" lt=\"[0-9][0-9]*\" ts=\"[0-9][0-9]*\" s=\"true\" lb=\"..*\" rc=\"20[01]\" rm=\"..*\" tn=\"..*\" dt=\"text\" by=\"[0-9][0-9]*\"/{0,1}>$"  ${JTL_FILE} > $TMP_FILE_NAME

# Just generate a new SV file with
#TIMESTAMP;THREAD NAME;URL;TIME
sed 's/^<httpSample t=\"\([0-9][0-9]*\)\" lt=\"\([0-9][0-9]*\)\" ts=\"\([0-9][0-9]*\)\" s=\"true\" lb=\"\(..*\)\" rc=\"20[01]\" rm=\"..*\" tn=\"\(..*\)\" dt=\"text\" by=\"\([0-9][0-9]*\)\"\/\{0,1\}>$/\3;\5;\4;\1/' ${TMP_FILE_NAME} > ${CSV_FILE_NAME}

# Remove temporarilly directory
rm ${TMP_FILE_NAME}

# Get name of threads
cut -d ";" -f 2 ${CSV_FILE_NAME} | sort | uniq > ${THREAD_NAMES_FILE_NAME}

# For all threads generate a report
while read line
do 
	# Check that line is not empty
	if [ -n "${line}" ]; then
		# Calculate time for threads
		echo "Calculating statistic for: ${line}, at ${CSV_FILE_NAME}"
		SON_PID=`${BASE_DIR}/calcThread.sh ${CSV_FILE_NAME} "${line}" ` &
	fi
done < ${THREAD_NAMES_FILE_NAME}

# Wait for jobs to finish
for job in `jobs -p | sort -n`
do
	#echo "Waiting for $job"
    wait $job
done

# Calculate max, min and average for all threads
# First min, sort min file and get first line
if [ -f ${CSV_FILE_NAME}_min ]; then
	MINTIME=`sort -n < ${CSV_FILE_NAME}_min | head -1 | cut -d " " -f1`
else
	MINTIME=NO_VALUE
fi
# Sort max time file reverse and get first line
if [ -f ${CSV_FILE_NAME}_max ]; then
	MAXTIME=`sort -nr < ${CSV_FILE_NAME}_max | head -1 | cut -d " " -f1`
else
	MAXTIME=NO_VALUE
fi

echo "Min value is: ${MINTIME}"
echo "Max value is: ${MAXTIME}"

if [ -f ${CSV_FILE_NAME}_avrg ]; then
	AVRGCOUNT=0
	AVRGTIME=0

	while read line
	do 
		# Check that line is not empty
		if [ -n $line ]; then
			# Add average
			AVRGTIME=$((${AVRGTIME}+$line));
			AVRGCOUNT=$(($AVRGCOUNT+1));				
		fi
	done < ${CSV_FILE_NAME}_avrg

	AVRGTIME=`expr ${AVRGTIME} / ${AVRGCOUNT}`
else
	AVRGTIME=NO_VALUE
fi


# Echo results
echo "Average value is: ${AVRGTIME}"			

# Print to a file
echo "Avrg (ms)	Min (ms)	Max(ms)" > $RESULT_FILE_NAME
echo "${AVRGTIME}	${MINTIME}	${MAXTIME}" >> $RESULT_FILE_NAME

# Remove files
#rm ${TMP}/${JTL_BASE_NAME}_*

