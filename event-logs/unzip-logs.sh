#!/bin/bash

#
# To unzip the "synthetic.zip" file contents into the "synthetic" directory.
# Author: Claudio Di Ciccio
# Version: 2017-07-07
#

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

unzip "$BASE_DIR/synthetic.zip" -d "$BASE_DIR/synthetic"

exit 0
