#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST_DIR="/home/claudio/University/Pubs/Declarative/declare-veloci-miner/evaluation/raw-data"
TEST_EXEC_DIRS=(
  "v1"
#  "v2"
  "v3"
  "v4"
)
OUTPUT_SUB_DIR='output'

SUBDIR_STORAGE_NAME="older-than-`date +"%Y%m%d-%H%M%S"`"

for test_dir in "${TEST_EXEC_DIRS[@]}"
do
  echo "Moving files from $test_dir"
  echo

  if [ -z "$(find ${DEST_DIR}/$test_dir -maxdepth 1 -type f)" ]
  then
    echo "No files to store in ${DEST_DIR}/$test_dir"
  else
    mkdir "${DEST_DIR}/$test_dir/$SUBDIR_STORAGE_NAME/"
    echo "Copying contents of ${DEST_DIR}/$test_dir into ${DEST_DIR}/$test_dir/$SUBDIR_STORAGE_NAME"
    cp "${DEST_DIR}/$test_dir/"*.* "${DEST_DIR}/$test_dir/$SUBDIR_STORAGE_NAME/"
  fi


  output_dir="$BASE_DIR/$test_dir/$OUTPUT_SUB_DIR"
  if [ -z "$(find ${output_dir} -maxdepth 1 -type f)" ]
  then
    echo "No files to copy from ${output_dir}"
  else
    echo "Copying contents of ${output_dir} into ${DEST_DIR}/$test_dir/"
    cp "${output_dir}/"*.* "${DEST_DIR}/$test_dir/"
  fi

  echo
done

echo "Done."

exit 0
