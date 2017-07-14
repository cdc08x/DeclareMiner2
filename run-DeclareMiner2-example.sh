#!/bin/bash

# 
# This script launches Declare Miner v. 2.0
# Date: 2017/07/07
# Author: Claudio Di Ciccio
# 

################################
#### Configuration
################################

JAR_FILE="jars/DeclareMiner-v1.jar"
CONFIG_FILE="config.properties.example"

#### Maximum memory allocation
#### --------------------------------
RAM_MAX="16g"

################################
#### System settings
################################

#### Directories
#### --------------------------------
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#### System files
#### --------------------------------
MAIN_CLASS_NAME="MultiBetterMiner"
# Load all libraries (JAR files in $LIBS_DIR)
LIBS_SCSV=""
for file in `find $LIBS_DIR -type f -name "*.jar"`; do LIBS_SCSV="$LIBS_SCSV:$file"; done

################################
#### Run!
################################
cd ${BASE_DIR}

java -Xmx${RAM_MAX} -XX:+UseConcMarkSweepGC -cp "$JAR_FILE:$LIBS_SCSV" "${MAIN_CLASS_NAME}" "${CONFIG_FILE}"

exit 0

