## Synopsis

Wrapper for running performance tests using JMeter allowing:
- Easy installation,
- Running multiple client on the same machine,
- Parameterized runs,
- Generating reports easily,

## Motivation

Uses this wrapper to distribute performance FW into multiple servers in order to run performance tests in parallel.

## Content

This project contains all scripts to install and run Performance Test using JMeter, and generate HTML reports:

- bin -- scripts to run and stop test,
- install -- scripts to install jmeter user, java and JMeter on local machine and scripts to install performance test tarball on a remote server,
- jmx -- JMX files for running performance tests with JMeter,
- logs -- directory where JMeter execution logs are going to be stored,
- properties -- configuration files for testing,
- reports -- directory where JMeter execution JTL are going to be stored, and HTML generated reports,
- scenarios -- scripts to run different test scenarios,
- statistics --scripts to generate html report from JTL files using Perl,

## Installation

What needs to be installed:

- Java 7 [java]
- JMeter 2.10 [jmeter]

[java]: https://www.java.com
[jmeter]: http://jmeter.apache.org/

## Setting up

There are two scripts in order to install prerequisites, that only need an internet connection to install software:

1. Install Java 7, if you are using a Linux x64 machine you can use following command:

	# Go to install scripts directory
	cd install
	# Modify permissions 
	chmod 744 install_java.sh
	# Install Java
	./install_java.sh

2. Create a new user/group, called `jmeter`, to run tests:

	# Go to install scripts directory
	cd install
	# Modify permissions 
	chmod 744 install_user.sh
	# Create jmeter group and jmeter/welc0me user you have to use root user for Linux
	./install_user.sh

3. Copy jmeter content to jmeter user home

	cp -R * /home/jmeter
	chown -R /home/jmeter/*

4. Change user to jmeter and do not use root any more

	su - jmeter

5. Change scripts permissions, in order to run it:

	chmod 744 *.sh

6. Install JMeter just running following script

	./install_jmeter.sh

	It installs jmeter at /home/jmeter/apache-jmeter-2.10

Remember that if you install JMeter on another directory you need to export JMETER_DIR property, for example:

	export JMETER_DIR=/home/jmeter/apache-jmeter-2.10

## Running Tests 

1. You only need to run following script:

	./bin/runJMXClients.sh -f \<JMX_FILE\> -p \<PROPERTIES_FILE\> [-r \<REMOTE_HOST\> -t \<TPS\> -d \<TestDuration\> -c \<NumberOfClients\>]

Parameters:
		
- JMX_FILE -- File containing test plan to run, you can find these files at jmx directory
- PROPERTIES_FILE -- File containing variables to run test, end point, request distribution, TPS, etc...
- REMOTE_HOST -- If you want to run in master-slave mode, you need to run slaves in the same subnet only install jmeter and run jmeter-server at slaves, and specify IP or slave name separated by commas.
- TPS -- Number of TPS you want to run (it is used to calculate number of threads, just multiplying by MultiplierNumberOfThreads)
- TestDuration -- Number of secons you want to run test
- NumberOfClients -- Number of clients you want to run in parallel

Examples:
	
	./bin/runJMXClients.sh -f jmx/DEFINITION.jmx -p properties/ENVIRONMENT.properties

It generates a log file at logs directory and a JTL file with all information at reports directory:
	
- jtl file -- Containing test requests and responses
- log file -- Variables used to run it and errors
	
This script run test, and force stop at a given time

2. To stop test you can:

2.1. stopJMX.sh $PORT -- Stop is immediate - threads are killed 
2.2. shutdownJMX.sh $PORT -- Stop  gradually - threads exit at next opportunity
	
If you do no specify anything port used is 4445, default one.

## Configuring Tests

1. General-Default configuration "functions.sh":

- JMX_FILE -- Default JMX_FILE to run, by default DEFINITION.jmx
- PROPERTIES_FILE -- Default configuration file to run jmeter test, by default ENVIRONMENT.properties
- REMOTE_HOST -- String containing remote hosts, by default is empty (running at same machine)
- NUMBER_OF_SLAVES -- Number of slaves to run test, by default 1, not master-slave mode
- reports -- Directory for reports, by default "reports"

2. Test configuration *.properties

- Request parameters -- Parameters to send at request, for example context to use
- Data configuration -- Different CSV files containing information to run test, better generate before this files
- HTTPSampler -- Http configuration, including protocol, IP and port to use
- Number of transactions -- Total amount of TPS that we want to generate, depends on service tested. Loop configuration number of times to run script
- General configuration -- Other parameters, like duration of tests,
- Sleep configuration -- Every time you run loop, you can configure a sleep time in order not to stress system tested
	
## Generation of reports

There are three ways to generate reports:

1. Using Java:

	bin/htmlReports/split.sh <JTL_FILE>
	
It uses xsl files to do the transformation. And generate a file with complete information for every URL.
	
2. Using shell scripting:

	bin/htmlReports/calc.sh <JTL_FILE>
	
Generate statistics for complete payment, spliting files into different files by thread name, and calculating reponse time for complete payment (5 calls with authorization)
	
3. Using perl:
	
	statistics/workflow_jtl <JTL_FILE> <NUMBER_OF_REQUEST>
	
Generate a file with complete information for payment process, with max, min, average, mean and percentiles, where number of request is the request we need to do a payment.
	
	statistics/jtl2html <JTL_FILE>
	
Generate a complete html summary with numbers of request, success, max, min average, etc, same name as jtl file terminated by html.

## Contributing workflow

Here’s how we suggest you go about proposing a change to this project:

1. [Fork this project][fork] to your account.
2. [Create a branch][branch] for the change you intend to make.
3. Make your changes to your fork.
4. [Send a pull request][pr] from your fork’s branch to our `master` branch.

Using the web-based interface to make changes is fine too, and will help you
by automatically forking the project and prompting to send a pull request too.

[fork]: http://help.github.com/forking/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository
[pr]: http://help.github.com/pull-requests/

## License

[MIT](./LICENSE).
