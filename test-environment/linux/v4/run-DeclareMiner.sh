#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

JAR_NAME="DeclareMiner-v4.jar"
MAIN_CLASS_NAME="MultiBetterMiner"
LIBS_DIR="$BASE_DIR/../lib"

CONFIG_FILE="$BASE_DIR/config.properties"

# Load all libraries (JAR files in $LIBS_DIR)
LIBS=""
for file in `find $LIBS_DIR -type f -name "*.jar"`
 do
  LIBS="$LIBS:$file";
 done

echo "Launching DeclareMiner, version V4..."

cd "$BASE_DIR"
java -Xmx16g -XX:+UseConcMarkSweepGC -cp "${JAR_NAME}$LIBS" "${MAIN_CLASS_NAME}" "${CONFIG_FILE}"

exit 0
