#!/bin/bash

# Constants
VERSION_NBR=1.0
EXECUTION_DIR=`pwd`
SCRIPT_NAME=`basename $0`
SCRIPT_FILE_DIR=`dirname $0`
SCRIPT_FILE_DIR=`cd $SCRIPT_FILE_DIR; pwd`

# Set dummy Jenkins parameters
export BUILD_ID=Test_build_id
export BUILD_NUMBER=Test_build_number
export JOB_NAME=Test_job_name

export WORKSPACE="$SCRIPT_FILE_DIR/jenkins_dummy_job/workspace"

# User manual
usage() {
    echo ""
    echo "Use this script to test continuous-integration.sh during development, without"
    echo "requiring a Jenkins environment."
    echo ""
    echo "A series of tests is run when this script is invoked. You can manually select a"
    echo "test by providing its id using the -t option."
    echo ""
    echo "Usage: $SCRIPT_NAME [-t test_id] [-h] [-v]"
    echo ""
    echo "Options:"
    echo "   -h:                    Display this documentation"
    echo "   -t:                    The id of the test to run"
    echo "   -v:                    Print the script version number"
    echo ""
}

# Processing command-line parameters
while getopts ht:v OPT; do
    case "$OPT" in
        h)
            usage
            exit 0
            ;;
        t) 
            param_test_id="$OPTARG"
            ;;
        v)
            echo "$SCRIPT_NAME version $VERSION_NBR"
            exit 0
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done

# Create log directory, as Jenkins would do
output_dir="$SCRIPT_FILE_DIR/jenkins_dummy_job/builds/$BUILD_NUMBER"
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

# Run the test(s). If no -t parameter, run them all
pushd "$WORKSPACE" > /dev/null

# All targets
if [ -z "$param_test_id" ] || [ "$param_test_id" -eq "0" ]; then
    "$SCRIPT_FILE_DIR/../continuous-integration.sh"
fi

# Only one target
if [ -z "$param_test_id" ] || [ "$param_test_id" -eq "1" ]; then
    "$SCRIPT_FILE_DIR/../continuous-integration.sh" -t "Second target"
fi

# Only one target. Clean first
if [ -z "$param_test_id" ] || [ "$param_test_id" -eq "2" ]; then
    "$SCRIPT_FILE_DIR/../continuous-integration.sh" -c -t "Second target"
fi

# Only one target, failure
if [ -z "$param_test_id" ] || [ "$param_test_id" -eq "3" ]; then
    "$SCRIPT_FILE_DIR/../continuous-integration.sh" -t "Bundle"
fi

# Only one target. Exit on failure
if [ -z "$param_test_id" ] || [ "$param_test_id" -eq "4" ]; then
    "$SCRIPT_FILE_DIR/../continuous-integration.sh" -e -t "Bundle"
fi

# Two targets
if [ -z "$param_test_id" ] || [ "$param_test_id" -eq "5" ]; then
    "$SCRIPT_FILE_DIR/../continuous-integration.sh" -t "Test Application,Bundle"
fi

# Missing target
if [ -z "$param_test_id" ] || [ "$param_test_id" -eq "6" ]; then
    "$SCRIPT_FILE_DIR/../continuous-integration.sh" -t "Missing target"
fi

popd > /dev/null
