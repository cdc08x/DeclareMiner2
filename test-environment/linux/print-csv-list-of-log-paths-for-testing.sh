#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -lt 2 ]; then
  echo "Usage: $0 [All synth logs? Then pass '1' here] [All benchmarks? Then pass '1' here]"
  exit
fi

PATH_FROM_HERE_TO_LOGS="../../../../logs"
PATH_FROM_RUNNING_JAR_TO_LOGS="../$PATH_FROM_HERE_TO_LOGS"
SYNTHETIC_LOGS_SUBDIR="synthetic"
BENCMARK_LOGS_SUBDIR="bpi_challenges-selected"

# '################################################################'
# "Copy and paste the following print out after the "
# '    log_file_path='
# "directive in the 'test-config.properties' files"
# '################################################################'
#

cd "$PATH_FROM_HERE_TO_LOGS"

csv_synth=""
if [ $1 == '1' ]
then
  for file in ${SYNTHETIC_LOGS_SUBDIR}/*.mxml; do csv_synth="$csv_synth,$PATH_FROM_RUNNING_JAR_TO_LOGS/$SYNTHETIC_LOGS_SUBDIR/`basename "$file"`"; done
  csv_synth=${csv_synth:1} # Remove trailing comma
fi

csv_benchmark=""
if [ $2 == '1' ]
then
  for file in ${BENCMARK_LOGS_SUBDIR}/*.*;  do csv_benchmark="$csv_benchmark,$PATH_FROM_RUNNING_JAR_TO_LOGS/$BENCMARK_LOGS_SUBDIR/`basename "$file"`"; done
  if [ "$csv_synth" == "" ]
  then
    csv_benchmark=${csv_benchmark:1} # Remove trailing comma
  fi
fi

echo "${csv_synth}${csv_benchmark}"

exit 0
