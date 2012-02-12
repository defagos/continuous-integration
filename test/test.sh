#!/bin/bash

# Run this script to test continuous_integration.sh without Jenkins environment.

SCRIPT_FILE_DIR=`dirname $0`
SCRIPT_FILE_DIR=`cd $SCRIPT_FILE_DIR; pwd`

# Set dummy Jenkins parameters
export BUILD_ID=Test_build_id
export BUILD_NUMBER=Test_build_number
export JOB_NAME=Test_job_name

export WORKSPACE="$SCRIPT_FILE_DIR/jenkins_dummy_job/workspace"

# Create log directory, as Jenkins would do
output_dir="$SCRIPT_FILE_DIR/jenkins_dummy_job/builds/$BUILD_NUMBER"
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

pushd "$WORKSPACE" > /dev/null
"$SCRIPT_FILE_DIR/../continuous_integration.sh"
popd > /dev/null