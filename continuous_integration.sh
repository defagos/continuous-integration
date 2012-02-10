#!/bin/bash

# Constants
VERSION_NBR=1.0
SCRIPT_NAME=`basename $0`

# User manual
usage() {
    echo ""
    echo "Script for iOS continuous integration, meant to be called from a Jenkins job. Simply"
    echo "run the script from a directory containing a .xcodeproj to have all configurations"
    echo "for all targets built. Users will be notified in case of build failure, and will"
    echo "receive a mail with a log excerpt, as well as links to the full compilation logs."
    echo ""
    echo "To be used, this script requires two environment variables to be set:"
    echo "  CODE_SIGN_IDENTITY: The identity to use for code signing (he name of the keychain "
    echo "                      certificate to use"
    echo "  PROVISIONING_PROFILE: The identifier of the provisioning profile to use"
    echo ""
    echo "Usage: $SCRIPT_NAME [-v] [-h] [-p project]"
    echo ""
    echo "Options:"
    echo "   -h:                    Display this documentation"
    echo "   -v:                    Print the script version number"
    echo ""
}

# Processing command-line parameters
while getopts hp:v OPT; do
    case "$OPT" in
        h)
            usage
            exit 0
            ;;
        p) 
            param_project_name="$OPTARG"
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

# Check required environment variables
if [ -z "$CODE_SIGN_IDENTITY" ]; then
    echo "[ERROR] The CODE_SIGN_IDENTITY environment variable must be set to the code signing identity to use"
    echo ""
    exit 1
fi

if [ -z "$PROVISIONING_PROFILE" ]; then
    echo "[ERROR] The PROVISIONING_PROFILE environment variable must be set to the identififer of the provisioning profile to use"
    echo ""
    exit 1
fi

# Project name (optional, used for disambiguation)
if [ -z "$param_project_name" ]; then
    project_parameter=""
else
    project_parameter="-p $param_project_name"
fi

# Check we are being run by Jenkins. Basic: Just test one Jenkins environment variable. Should suffice, though
if [ -z "$BUILD_ID" ]; then
    echo "[ERROR] This script must be run from a Jenkins job"
    exit 1
fi

echo ""
echo "**************************************************************************************************************************************************"
echo "Continuous integration for $JOB_NAME, build $BUILD_NUMBER ($BUILD_ID)"
echo "**************************************************************************************************************************************************"
echo ""

# Create a symbolic link from the workspace (which we can access using a URL) and the builds directory. This is where we will store our build logs
# (this way, we can save them for each build number, and the files get deleted when a build is removed). If we had stored logs in the workspace 
# directly, we would have lost them when the workspace is cleaned up). 
buildlogs_dir="$WORKSPACE/buildlogs"
if [ ! -e "$buildlogs_dir" ]; then
    ln -s "$WORKSPACE/../builds/" "$buildlogs_dir"
fi
build_dir="$buildlogs_dir/$BUILD_NUMBER"

# Build all targets
OLD_IFS="$IFS"
IFS=$'\n'
targets_arr=(`xcodeproj-info list-targets`)
for target in ${targets_arr[@]}
do
    # Retrieve the list of configurations to build, and which SDK must be used
    configuration_data=`xcodeproj-info -t "$target" list-configurations`
    for configuration_data in ${configuration_data[@]}
    do
        # Extract build settings
        configuration_name=`echo "$configuration_data" | cut -d " " -f 1`
        configuration_sdk=`echo "$configuration_data" | cut -d " " -f 2`
        
        # Derive simulator SDK name
        configuration_simulator_sdk=`echo "$configuration_sdk" | sed -E 's/iphoneos/iphonesimulator/g'`
        
        # Build the simulator binaries (performs a static analysis. Not signed)
        echo "Building simulator binaries for configuration $configuration_name with SDK $configuration_simulator_sdk..."
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------"
        echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_${configuration_name}_${configuration_simulator_sdk}.log"
        log_file_path="$build_dir/build_${configuration_name}_${configuration_simulator_sdk}.log"
        xcodebuild clean build -configuration "$configuration_name" -sdk "$configuration_simulator_sdk" RUN_CLANG_STATIC_ANALYZER="true" \
            &> "$log_file_path"
        if [ $? -ne "0" ]; then
            echo "[STATUS] Build failed (log excerpt follows)"
            echo ""
            tail -n 20 "$log_file_path"
            exit 1  
        fi
        echo "[STATUS] Build succeeded"
        echo ""
        
        # Build the device binaries (signed)
        echo "Building device binaries for configuration $configuration_name with SDK $configuration_sdk..."
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------"
        echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_${configuration_name}_${configuration_sdk}.log"
        log_file_path="$build_dir/build_${configuration_name}_${configuration_sdk}.log"
        xcodebuild clean build -configuration "$configuration_name" -sdk "$configuration_sdk" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
            PROVISIONING_PROFILE="$PROVISIONING_PROFILE" &> "$log_file_path"
        if [ $? -ne "0" ]; then
            echo "[STATUS] Build failed (log excerpt follows)"
            echo ""
            tail -n 20 "$log_file_path"
            exit 1  
        fi
        echo "[STATUS] Build succeeded"
        echo ""
    done
done
IFS="$OLD_IFS"

# TODO: Create ipa
# See http://stackoverflow.com/questions/2664885/xcode-build-and-archive-from-command-line
# /usr/bin/xcrun -sdk iphoneos PackageApplication -v "${RELEASE_BUILDDIR}/${APPLICATION_NAME}.app" -o "${BUILD_HISTORY_DIR}/${APPLICATION_NAME}.ipa" --sign "${DEVELOPER_NAME}" --embed "${PROVISONING_PROFILE}"

echo "[STATUS] End of continuous integration"

