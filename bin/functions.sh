#!/bin/bash

BASE_PORT=4444
JMX_FILE="ARCProxy-WS-CSV.jmx"
PROPERTIES_FILE="arcproxy_newtest.properties"
REMOTE_HOST=""
NUMBER_OF_SLAVES=1
reports="${BASE_DIR}/../reports"
csv="${BASE_DIR}/../csv"
logs="${BASE_DIR}/../logs"
XSL="${BASE_DIR}/xsl"
# Get timestamp
timestamp=`date "+%Y%m%d%H%M%S"`
TMP="tmp_${timestamp}"

# Time to wait before test has to be finished
WAITING_TIME_TO_SLEEP=60

# Function to get JMETER_DIR
getjmeterdir ()
{
	jmeter="/opt/ss/develenv/platform/jakarta-jmeter-2.6"

	# Check if JMeter is installed
	if [ -z ${JMETER_DIR} ]; then
        	# Just check if jmeter directory exists
        	if [ ! -d "$jmeter" ]; then
                	# Show an error and exit
                	echo 1>&2 "You need to specify JMETER_DIR or install JMeter on this directory"
                	exit 1
        	else
                	JMETER_DIR="$jmeter"
        	fi
	fi

	# Check if JMeter directory exists
	if [ ! -d $JMETER_DIR ]; then
        	# Show an error and exit
        	echo 1>&2 "You need to install JMeter before"
        	exit 2
	fi
}

getbasename ()
{
	if [ $# -ne 1 ]; then
		echo 1>&2 "You need to specify file"
		exit 1
	fi

	# Get base name
	FILE_NAME=`basename $1 | cut -f1 -d '.'`

	# Check if it is empty
	if [ -z $FILE_NAME ]; then
		echo 1>&2 "Could not get base file name from: $1"
                exit 1
	fi
}

getnumberofelements ()
{
	if [ $# -ne 1 ]; then
		echo 1>&2 "You need to specify a string"
		exit 1
	fi

	IFS=,
	# Split by comma
	arr=( $1)

	# Get number of elements
	NUMBER_OF_ELEMENTS=${#arr[*]}

	echo 1>&2 "Number of elements: ${NUMBER_OF_ELEMENTS}"
}

getsleeptime ()
{
	if [ $# -ne 2 ]; then
		echo 1>&2 "You need to specify properties file, number of slaves and optional tps and duration"
		exit 1
	fi

	FILE_WITH_SLEEP_TIME=$1
	SLAVES=$2
	
	# Load file
	. ${FILE_WITH_SLEEP_TIME} > /dev/null 2>&1
	
	# Check if we have tps or duration from command line
	if [ -n "$TPS_COMMAND_LINE" ]; then
		TPS=$TPS_COMMAND_LINE
	fi

	if [ -n "$TestDuration_COMMAND_LINE" ]; then
		TestDuration=$TestDuration_COMMAND_LINE
	fi

	# Get properties to know time to sleep:
	echo 1>&2 " "
	echo 1>&2 "CONFIGURATION"
	echo 1>&2 "	Transaction per second: ${TPS}"
	echo 1>&2 "	Multiplier to calculate number of threads: ${MultiplierNumberOfThreads}"		
	echo 1>&2 "	Number of slaves: ${SLAVES}"
	echo 1>&2 "	Time between threads creation: ${TimeBetweenThreadsCreation}"
	echo 1>&2 "	Duration time for testing: ${TestDuration}"
	echo 1>&2 " "
	
	ThreadCreationTime=$(echo "scale=2; ${TPS}*${MultiplierNumberOfThreads}*${TimeBetweenThreadsCreation}/${NUMBER_OF_SLAVES};" | bc) 
	
	SleepTime=$(echo "scale=2; ${TestDuration}+${ThreadCreationTime}+${WAITING_TIME_TO_SLEEP};" | bc) 
	
	echo 1>&2 "Sleep time (duration of tests plus threds creation time plus waiting to stop): ${SleepTime}"
}

generateListIP()
{
  for i in {1..254};
  do
      for j in {1..254};
      do echo 10.0.$i.$j";" >> ./ip.csv;
      done;
  done

}

generateOutputTrendFile ()
{
	echo "Output trend file to write: ${OUTPUT_TREND}"
	if [ -n $OUTPUT_TREND ]; then
		OUTPUT_TREND_FILE_NAME="../reports/${OUTPUT_TREND}_${NumberOfClient}-Performance-Trend.jtl"
		echo "Copying $JTL_FILE to trend file: ${OUTPUT_TREND_FILE_NAME}"
		cp ${JTL_FILE} ${OUTPUT_TREND_FILE_NAME}	
	fi
}

runJmeterAndGenerateReports ()
{
	# Run jmeter
	command="${JMETER_DIR}/bin/jmeter.sh -n -Jjmeter.save.saveservice.output_format=xml -j ${JLOG_FILE} -l ${JTL_FILE} -t ${JMX_FILE} -JBASE_DIR=${BASE_DIR} -JFILE_NAME=${FILE_NAME} -JNUMBER_OF_SLAVES=${NUMBER_OF_SLAVES} ${REMOTE_HOST} ${EXTRA_ARGS} -p ${PROPERTIES_FILE}"
	echo 1>&2 "Running in background:"
	echo 1>&2 "	${command}"
	${command}
	
	#echo 1>&2 "Trying to stop JMX process: ${RUNJMX_PID}"
	kill -9 ${RUNJMX_PID}
	
	# Generate trend file
	generateOutputTrendFile
}
