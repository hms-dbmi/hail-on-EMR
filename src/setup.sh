#!/bin/sh -x

logger_debug() {
	MSG=$1
	echo "`date` DEBUG ${MSG}"
}

logger_error() {
	MSG=$1
	echo "`date` ERROR ${MSG}"
}

logger_debug "Clean up previous virtualenv"
rm -fR bin include lib lib64 local pip-selfcheck.json

logger_debug "Creating local Python environment"
python3 -m venv .

logger_debug "Activating local Python environment"
source bin/activate

logger_debug "Installing required libraries"
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
logger_debug "Status and Context check of hail environment"

export HAIL_HOME=`pwd`
./hail_submit.sh src/scripts/context.py
