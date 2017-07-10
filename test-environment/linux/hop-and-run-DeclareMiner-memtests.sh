#!/bin/bash

# 
# This script automatically launches Declare Miner v. 2.0 in its four versions, saved in the v1..v4 subdirectories.
# Date: 2017/07/05
# Author: Claudio Di Ciccio
# 

#### Directories
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${BASE_DIR}

TEST_BASE_DIR="$BASE_DIR"
LIBS_DIR="$BASE_DIR/lib"
MESSAGE_DIR="$BASE_DIR/log"
ETC_DIR="$BASE_DIR/etc"
LOGGING_SUBDIR="logging"
OUTPUT_SUBDIR="output"
PRINT_CSV_LIST_OF_EVENT_LOGS_COMMAND_FILE="$BASE_DIR/print-csv-list-of-log-paths-for-testing.sh"

#### System files
#### --------------------------------
MAIN_CLASS_NAME="MultiBetterMiner"
# Load all libraries (JAR files in $LIBS_DIR)
LIBS_SCSV=""
for file in `find $LIBS_DIR -type f -name "*.jar"`; do LIBS_SCSV="$LIBS_SCSV:$file"; done

#### Message and config files
#### --------------------------------
MSG_FILE='tests-status-update.log'
DEBUG_DUMP='debug_dump.txt'
CONFIG_FILE='test-config.properties'
CONFIG_FILE_SKELETON="config.properties.skeleton"

#### Enumerated parameter values
#### --------------------------------
ALPHAS=(
  '100' # 0: vacuity detection enabled
  '0' # 100: vacuity detection disabled
)
DO_WRITE_MEM_CMDS=(
  "memory_check=false"
  "memory_check=true"
)

#### General set-up
#### --------------------------------
DO_CLEAN_PREVIOUS_OUTPUTS=1
VERSIONS=(
  "v1"
#  "v2"
  "v3"
  "v4"
)
RAM_MAX="16g"

################################################################
#### START OF: Config-file setup
#!!! Edit these to have effect !!!
################################################################
#EVENT_LOG_FILE_PATHS_CSV=`bash ${PRINT_CSV_LIST_OF_EVENT_LOGS_COMMAND_FILE} 1 1` # All synthetic logs, all benchmarks
EVENT_LOG_FILE_PATHS_CSV=`bash ${PRINT_CSV_LIST_OF_EVENT_LOGS_COMMAND_FILE} 1 0` # All synthetic logs, no benchmarks
#EVENT_LOG_FILE_PATHS_CSV=`bash ${PRINT_CSV_LIST_OF_EVENT_LOGS_COMMAND_FILE} 0 1` # no synthetic logs, all benchmarks
MIN_SUPPORTS_CSV="80,90,100"
ALPHAS_CSV="0,100"
MEM_PATH="./${OUTPUT_SUBDIR}/mem.csv"
DO_WRITE_MEM=${DO_WRITE_MEM_CMDS[1]}
ITER_NUM=1
NUMBER_OF_THREADS=4 # Affects only v3 and v4
DO_USE_HIERARCHY_FILTER="false" # Affects only v2 and v4
################################################################
#### END OF: Config-file setup
#!!! Edit those to have effect !!!
################################################################

#### Execution
#### --------------------------------

echo "[`date`] ######## New tests starting. If running on shell, press Ctrl+C to stop"

echo "[`date`] ######## New tests starting with (${VERSIONS[@]})"                             >> "${MESSAGE_DIR}/${MSG_FILE}"

for VERSION in "${VERSIONS[@]}"
do
  test_dir="${TEST_BASE_DIR}/${VERSION}"
  jar_name="DeclareMiner-$VERSION.jar"
  command="java -Xmx${RAM_MAX} -XX:+UseConcMarkSweepGC -cp ${jar_name}$LIBS_SCSV ${MAIN_CLASS_NAME} ${test_dir}/${CONFIG_FILE}" 

  # https://stackoverflow.com/questions/407279/fill-placeholders-in-file-in-single-pass#answer-924539
  echo "$(eval "echo \"$(cat ${ETC_DIR}/${CONFIG_FILE_SKELETON})\"")" > "${test_dir}/${CONFIG_FILE}"

  cd "${test_dir}"
  echo "################################################################"                     >> "${MESSAGE_DIR}/${MSG_FILE}"
  echo "[`date -R`] Moved to ${PWD}"                                                          >> "${MESSAGE_DIR}/${MSG_FILE}"
  if [ "$DO_CLEAN_PREVIOUS_OUTPUTS" = 1 ]
  then
    rm -f "${test_dir}/${LOGGING_SUBDIR}"/*.*
    rm -f "${test_dir}/${OUTPUT_SUBDIR}"/*.*
  fi
  echo "[`date -R`] Starting tests with $VERSION..."                                          >> "${MESSAGE_DIR}/${MSG_FILE}"
  echo "[`date -R`] Executing:  ${command}  &>  ${test_dir}/$LOGGING_SUBDIR/$DEBUG_DUMP"      >> "${MESSAGE_DIR}/${MSG_FILE}"
  eval "${command}" &> "${test_dir}/$LOGGING_SUBDIR/$DEBUG_DUMP"
  echo
  echo "[`date -R`] All tests executed with ${VERSION}"                                       >> "${MESSAGE_DIR}/${MSG_FILE}"
  cd "${TEST_BASE_DIR}"
  echo "################################################################"                     >> "${MESSAGE_DIR}/${MSG_FILE}"
done

echo "[`date`] ######## All tests done"                                                       >> "${MESSAGE_DIR}/${MSG_FILE}"
echo "[`date`] Waiting for some KILL command to stop this execution"                          >> "${MESSAGE_DIR}/${MSG_FILE}"

sleep 14d
exit 0
