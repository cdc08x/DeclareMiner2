#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_EXEC_DIRS=(
  "v1"
  "v2"
  "v3"
  "v4"
)
RAW_DATA_DIR=${BASE_DIR}

RAW_DATA_TIMING_FILE="performance.csv"
RAW_DATA_MEMORY_FILE="mem.csv"
RAW_APRIORI_TIMING_FILE="apriori.csv"

# Change this line according to the preferred synlogfile name
SYN_LOG_TIMING_FILE="synlog_performance.csv"
# Change this line according to the synlogfile name
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
  old_timing_file="$output_dir/$RAW_DATA_TIMING_FILE"
  old_memory_file="$output_dir/$RAW_DATA_MEMORY_FILE"
  old_apriori_timing_file="$output_dir/$RAW_APRIORI_TIMING_FILE"
  syn_log_timing_file="$output_dir/$SYN_LOG_TIMING_FILE"
  syn_log_apriori_timing_file="$output_dir/$SYN_LOG_APRIORI_TIMING_FILE"
  benchmark_timing_file="$output_dir/$BENCHMARK_TIMING_FILE"
#  syn_log_mem_usage_file="$output_dir/$SYN_LOG_MEM_USAGE_FILE"
  benchmark_mem_usage_file="$output_dir/$BENCHMARK_MEM_USAGE_FILE"
#  benchmark_apriori_timing_file="$output_dir/$APRIORI_TIMING_FILE"

  echo "Extracting timing data about synthetic logs processing from ${test_dir}..."

  if [ -z "`grep -e 'alpha_' "${old_timing_file}"`" ]
  then
    echo "No lines about synthetic event logs processing from ${test_dir}"
  else
    echo "Creating event logs processing performance file: ${syn_log_timing_file}"
#   Keep only those lines that refer to "alpha*" files
    grep -e 'alpha_' "${old_timing_file}" > "${syn_log_timing_file}"

#   Translate file names into log specs
    sed -i -e 's/alpha_\([0-9]*\)_minlen_\([0-9]*\)_maxlen_\([0-9]*\)_size_\([0-9]*\)\.mxml/\0;\1;\2;\3;\4/g' "${syn_log_timing_file}"
    # sed -i -e "s/^/$test_dir;/g" "${syn_log_timing_file}" # This one got outdated: New files bear at the first column the version of the software
#   Clean the file from spaces and other unpleasant symbols
    sed -i -e 's/\([;,]\) /\1/g' -e 's/[][]//g' "${syn_log_timing_file}"
#   Remove trailing zeroes
    sed -i -e 's/\(\.0$\)\|\(\.0;\)//g' "${syn_log_timing_file}"

    # Create the new header
    header=`echo "'version';'constraints';'alpha';'support';'mode';'file';'alphabet';'minlen';'maxlen';'logsize';'time'"`
    # Remove the old header and replace it with the new one
    tail -n +2 "${syn_log_timing_file}" > "${syn_log_timing_file}.aux"
    echo "$header" | cat - "${syn_log_timing_file}.aux" > "${syn_log_timing_file}"
    rm "${syn_log_timing_file}".aux
  fi

  echo "Extracting apriori timing data about synthetic logs processing from ${test_dir}..."

  if [ -z "`grep -e 'alpha_' "${old_apriori_timing_file}"`" ]
  then
    echo "No lines about apriori synthetic event logs processing from ${test_dir}"
  else
    echo "Creating event logs apriori processing performance file: ${syn_log_apriori_timing_file}"
#   Keep only those lines that refer to "alpha*" files

    grep -e 'alpha_' "${old_apriori_timing_file}" > "${syn_log_apriori_timing_file}"

#   Translate file names into log specs
    sed -i -e 's/alpha_\([0-9]*\)_minlen_\([0-9]*\)_maxlen_\([0-9]*\)_size_\([0-9]*\)\.mxml/\0;\1;\2;\3;\4/g' "${syn_log_apriori_timing_file}"
    # sed -i -e "s/^/$test_dir;/g" "${syn_log_timing_file}" # This one got outdated: New files bear at the first column the version of the software
#   Clean the file from spaces and other unpleasant symbols
    sed -i -e 's/\([;,]\) /\1/g' -e 's/[][]//g' "${syn_log_apriori_timing_file}"
#   Remove trailing zeroes
    sed -i -e 's/\(\.0$\)\|\(\.0;\)//g' "${syn_log_apriori_timing_file}"

    # Create the new header
    header=`echo "'version';'constraints';'alpha';'support';'mode';'file';'alphabet';'minlen';'maxlen';'logsize';'time'"`
    # Remove the old header and replace it with the new one
    cp "${syn_log_apriori_timing_file}" "${syn_log_apriori_timing_file}.aux"
    echo "$header" | cat - "${syn_log_apriori_timing_file}.aux" > "${syn_log_apriori_timing_file}"
    rm "${syn_log_apriori_timing_file}".aux
  fi

  echo "Extracting timing data about benchmark logs processing from ${old_timing_file}..."

  cp "${old_timing_file}" "${benchmark_timing_file}.aux"
# Filter out those lines that refer to "alpha*" files
  sed -i -e '/alpha_/d' "${benchmark_timing_file}.aux"

  if [ -z "`tail -n +2 "${benchmark_timing_file}.aux"`" ]
  then
    echo "No lines about benchmark event logs processing from ${test_dir}"
  else
    echo "Creating event logs apriori processing performance file: ${benchmark_timing_file}"

    cp "${benchmark_timing_file}.aux" "${benchmark_timing_file}"
    # sed -i -e "s/^/$test_dir;/g" "${benchmark_timing_file}" # This one got outdated: New files bear at the first column the version of the software
#   Clean the file from spaces and other unpleasant symbols
    sed -i -e 's/\([;,]\) /\1/g' -e 's/[][]//g' "${benchmark_timing_file}"
#   Remove trailing zeroes
    sed -i -e 's/\(\.0$\)\|\(\.0;\)//g' "${benchmark_timing_file}"

    # Create the new header
    header=`echo "'version';'constraints';'alpha';'support';'mode';'file';'time'"`
    # Remove the old header and replace it with the new one
    tail -n +2 "${benchmark_timing_file}" > "${benchmark_timing_file}.aux"
    echo "$header" | cat - "${benchmark_timing_file}.aux" > "${benchmark_timing_file}"
  fi
  rm "${benchmark_timing_file}".aux

  echo "Extracting memory usage data about benchmark logs processing from ${old_memory_file}..."

  if [ -f "$old_memory_file" ]
  then
    echo "Creating event logs processing memory usage file: ${benchmark_mem_usage_file}"

    cp "${old_memory_file}" "${benchmark_mem_usage_file}.aux"
#   Filter out those lines that refer to "alpha*" files
    sed -i -e '/alpha_/d' "${benchmark_mem_usage_file}.aux"
    if [ -z "`tail -n +2 "${benchmark_mem_usage_file}.aux"`" ]
    then
      echo "No lines about benchmark event logs processing from ${test_dir}"
    else
      cp "${old_memory_file}" "${benchmark_mem_usage_file}"
      # sed -i -e "s/^/$test_dir;/g" "${benchmark_mem_usage_file}" # This one got outdated: New files bear at the first column the version of the software
#     Clean the file from spaces and other unpleasant symbols
      sed -i -e 's/\([;,]\) /\1/g' -e 's/[][]//g' "${benchmark_mem_usage_file}"
#     Remove trailing zeroes
      sed -i -e 's/\(\.0$\)\|\(\.0;\)//g' "${benchmark_mem_usage_file}"

      # Create the new header
      header=`echo "'version';'constraints';'alpha';'support';'mode';'file';'memorymin';'memorymax';'memoryavg'"`
      echo "$header" | cat - "${benchmark_mem_usage_file}.aux" > "${benchmark_mem_usage_file}"
    fi
    rm "${benchmark_mem_usage_file}".aux
  else
    echo "No input data about memory usage available."
  fi

done

echo "Done."
