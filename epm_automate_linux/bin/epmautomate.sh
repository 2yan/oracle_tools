#!/bin/sh
returnValue=0

utility_dir=`dirname "${0}"` 

current_dir=`pwd`
cd "${utility_dir}"
temp_pwd=`pwd`
cd "${current_dir}"

if [ ! -d "${JAVA_HOME}" ]; then
    	echo "ERROR: JAVA_HOME is not set. Please set the JAVA_HOME and try again"
	exit $returnValue 
fi
	
if [ $# -eq 0 ];then
	echo "EPM Automate Version 18.11.63"
	echo "Welcome to EPM Automate.Type epmautomate help and press <Enter> for help."
	exit 6
fi

lib_path="${temp_pwd}/../lib"

cd "${current_dir}"

class_path="${lib_path}/commons-cli-1.1.jar:${lib_path}/commons-codec-1.4.jar:${lib_path}/commons-dbcp-1.4.0.jar:${lib_path}/commons-discovery-0.4.jar:${lib_path}/commons-httpclient-3.1.jar:${lib_path}/commons-io-1.4.jar:${lib_path}/commons-logging-1.1.jar:${lib_path}/commons-validator-1.3.1.jar:${lib_path}/json.jar:${lib_path}/commons-compress-1.5.jar:${lib_path}/epmautomate.jar:${lib_path}/epmctlclient.jar:${lib_path}/opencsv-1.8.jar"

JAVA_OPTS="-Xms128m -Xmx1024m -DEXE_PATH=${lib_path}"

"${JAVA_HOME}/bin/java" $JAVA_OPTS -cp "${class_path}" com.hyperion.epmctl.client.processor.EPMCTLProcessor "$@"
returnValue=$?

if [ $returnValue -eq 99 ];then
	cd "${temp_pwd}/.."
	chmod +x upgrade.sh
	./upgrade.sh
	exit 0
fi

exit $returnValue
