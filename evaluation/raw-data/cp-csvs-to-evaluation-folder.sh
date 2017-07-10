#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST_DIR="$BASE_DIR/../data"
TEST_EXEC_DIRS=(
  "v1"
  "v2"
  "v3"
  "v4"
)

# Change this line according to the preferred synlog_timing_file name
SYN_LOG_TIMING_FILE="synlog_performance.csv"
# Change this line according to the synlog_timing_file name
BENCHMARK_TIMING_FILE="benchmark_performance.csv"
# Change this line according to the memory consumption file name
# SYN_LOG_MEM_USAGE_FILE="synlog_memory_usage.csv"
# Change this line according to the memory consumption file name
BENCHMARK_MEM_USAGE_FILE="benchmark_memory_usage.csv"
SYN_LOG_APRIORI_TIMING_FILE="syn_apriori_performance.csv"
# BENCHMARK_APRIORI_TIMING_FILE="benchmark_apriori_performance.csv"

for test_dir in "${TEST_EXEC_DIRS[@]}"
do
  output_dir="$BASE_DIR/$test_dir"

  synlog_timing_file="$output_dir/$SYN_LOG_TIMING_FILE"

  if [ -f "${synlog_timing_file}" ]
  then 
    synlog_timing_copied_file="$DEST_DIR/$test_dir-$SYN_LOG_TIMING_FILE"
    echo "Copying ${synlog_timing_file} into ${synlog_timing_copied_file}"
    cp ${synlog_timing_file} ${synlog_timing_copied_file}
  else
    echo "No event logs processing time performance file"
  fi

  synlog_apriori_timing_file="$output_dir/$SYN_LOG_APRIORI_TIMING_FILE"

  if [ -f "${synlog_apriori_timing_file}" ]
  then 
    synlog_apriori_timing_copied_file="$DEST_DIR/$test_dir-$SYN_LOG_APRIORI_TIMING_FILE"
    echo "Copying ${synlog_apriori_timing_file} into ${synlog_apriori_timing_copied_file}"
    cp ${synlog_apriori_timing_file} ${synlog_apriori_timing_copied_file}
  else
    echo "No event logs apriori processing time file"
  fi

  benchmark_timing_file="$output_dir/$BENCHMARK_TIMING_FILE"

  if [ -f "${benchmark_timing_file}" ]
  then
    benchmark_timing_copied_file="$DEST_DIR/$test_dir-$BENCHMARK_TIMING_FILE"
    echo "Copying ${benchmark_timing_file} into ${benchmark_timing_copied_file}"
    cp ${benchmark_timing_file} ${benchmark_timing_copied_file}
  else
    echo "No benchmark processing time performance file"
  fi

  benchmark_mem_usage_file="$output_dir/$BENCHMARK_MEM_USAGE_FILE"

  if [ -f "${benchmark_mem_usage_file}" ]
  then
    benchmark_mem_usage_copied_file="$DEST_DIR/$test_dir-$BENCHMARK_MEM_USAGE_FILE"
    echo "Copying ${benchmark_mem_usage_file} into ${benchmark_mem_usage_copied_file}"
    cp "${benchmark_mem_usage_file}" "${benchmark_mem_usage_copied_file}"
  else
    echo "No benchmark processing memory usage file"
  fi

done

echo "Done."

exit 0
