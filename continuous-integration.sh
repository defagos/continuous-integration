#!/bin/bash

# Constants
VERSION_NBR=1.0
SCRIPT_NAME=`basename $0`
EXECUTION_DIR=`pwd`

param_clean_first=false
param_exit_on_failure=false

# User manual
usage() {
    echo ""
    echo "Script for iOS continuous integration, meant to be called from a Jenkins job. Simply"
    echo "run the script from a directory containing a .xcodeproj to have all configurations"
    echo "for all targets built. Users will be notified in case of build failure, and will"
    echo "receive a mail with a log excerpt, as well as links to the full compilation logs."
    echo "Optional parameters let you select only some project (if only one project exists"
    echo "in the directory where the script is run, this parameter can be omitted, otherwise"
    echo "it is mandatory) or some specific targets (if you do not need to build all of them)"
    echo ""
    echo "To be used, this script requires two environment variables to be set:"
    echo "  CODE_SIGN_IDENTITY: The identity to use for code signing (he name of the keychain "
    echo "                      certificate to use"
    echo "  PROVISIONING_PROFILE: The identifier of the provisioning profile to use"
    echo ""
    echo "Usage: $SCRIPT_NAME [-p project] [-t target] [-c] [-e] [-v] [-h]"
    echo ""
    echo "Options:"
    echo "   -c:                    Perform a clean before each build"
    echo "   -e:                    Exit on failure"
    echo "   -h:                    Display this documentation"
    echo "   -p:                    If several projects are available, use the -p parameter to"
    echo "                          select the one to build"
    echo "   -t:                    Comma-separated list of the targets to build"
    echo "   -v:                    Print the script version number"
    echo ""
}

# Processing command-line parameters
while getopts cehp:t:v OPT; do
    case "$OPT" in
        c)
            param_clean_first=true
            ;;
        e)
            param_exit_on_failure=true
            ;;
        h)
            usage
            exit 0
            ;;
        p) 
            param_project_name="$OPTARG"
            ;;
        t) 
            param_target_names="$OPTARG"
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

# Check that the required tools are available
which xcodeproj-info > /dev/null
if [ "$?" -ne "0" ]; then
    echo "[ERROR] The xcodeproj-info tool (bundled with this script) must be available in your path"
    echo ""
    exit 1
fi

# Check we are being run by Jenkins. Basic: Just test one Jenkins environment variable. Should suffice, though
if [ -z "$BUILD_ID" ]; then
    echo "[ERROR] This script must be run from a Jenkins job"
    exit 1
fi

# Check that exactly one .xcodeproj exists in the current directory
if [ -z "$param_project_name" ]; then
    xcodeproj_list=`ls -1 | grep ".xcodeproj"`
    
    # Not found
    if [ "$?" -ne "0" ]; then
        echo "[ERROR] No Xcode project found in the current directory"
        echo ""
        exit 1
    fi
    
    # Several projects found
    if [ `echo "$xcodeproj_list" | wc -l` -ne "1" ]; then
        echo "[ERROR] Several Xcode projects found in the current directory; use the -p option for disambiguation"
        echo ""
        exit 1
    fi
    
    # Extract the project name, stripping off the .xcodeproj
    project_name=`echo "$xcodeproj_list" | sed 's/.xcodeproj//g'`
# Else check that the project specified exists
else
    if [ ! -d "$EXECUTION_DIR/$param_project_name.xcodeproj" ]; then
        echo "[ERROR] The project $param_project_name does not exist"
        echo ""
        exit 1
    fi
    
    project_name="$param_project_name"
fi

# Create a symbolic link from the workspace (which we can access using a URL) and the builds directory. This is where we will store our build logs
# (this way, we can save them for each build number, and the files get deleted when a build is removed). If we had stored logs in the workspace 
# directly, we would have lost them when the workspace is cleaned up). 
buildlogs_dir="$WORKSPACE/buildlogs"
if [ ! -e "$buildlogs_dir" ]; then
    ln -s "$WORKSPACE/../builds/" "$buildlogs_dir" &> /dev/null
fi
build_dir="$buildlogs_dir/$BUILD_NUMBER"

# Find all configurations to consider
if [ ! -z "$param_target_names" ]; then
    # Tokenize input parameter (set the delimiter as temporary IFS)
    IFS=$',' read -ra param_target_name_arr <<< "$param_target_names"
    
    # Collect all configurations defined for each target
    for param_target_name in "${param_target_name_arr[@]}"; do
        # Use \n to delimit array elements, not simply the default whitespaces (since lines most probably contain whitespaces; we do not want
        # to break in the middle of them)
        IFS=$'\n' configurations_arr+=(`xcodeproj-info -p "$project_name" -t "$param_target_name" list-configurations`)
        if [ "$?" -ne "0" ]; then
            echo "[ERROR] The target $param_target_name does not exist"
            echo ""
            exit 1
        fi
    done
else
    # See comment above
    IFS=$'\n' configurations_arr=(`xcodeproj-info -p "$project_name" list-configurations`)
fi

echo ""
echo "**************************************************************************************************************************************************"
echo "Continuous integration for $JOB_NAME, build $BUILD_NUMBER ($BUILD_ID)"
echo "**************************************************************************************************************************************************"
echo ""
echo "[STATUS] Start date: "`date`
echo ""

build_successful=true

# Build all configurations for all targets to consider
for configuration in "${configurations_arr[@]}"; do
    # Extract build settings
    target_name=`echo "$configuration" | cut -f 1`
    configuration_name=`echo "$configuration" | cut -f 2`
    configuration_sdk=`echo "$configuration" | cut -f 3`
    
    # Derive simulator SDK name
    configuration_simulator_sdk=`echo "$configuration_sdk" | sed -E 's/iphoneos/iphonesimulator/g'`
    
    # Build the simulator binaries (performs a static analysis. Not signed)
    echo "Building simulator binaries for target $target_name and configuration $configuration_name with SDK $configuration_simulator_sdk..."
    echo "--------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_${configuration_name}_${configuration_simulator_sdk}.log"
    echo ""
    log_file_path="$build_dir/build_${configuration_name}_${configuration_simulator_sdk}.log"
    if $param_clean_first; then
        xcodebuild clean build -project "$project_name.xcodeproj" -target "$target_name" -configuration "$configuration_name"
    fi
    xcodebuild build -project "$project_name.xcodeproj" -target "$target_name" -configuration "$configuration_name" -sdk "$configuration_simulator_sdk" \
        RUN_CLANG_STATIC_ANALYZER="true" &> "$log_file_path"
    if [ "$?" -ne "0" ]; then
        echo "[STATUS] Build failed (log excerpt follows)"
        echo ""
        tail -n 20 "$log_file_path"
        if $param_exit_on_failure; then
            exit 1
        fi
        build_successful=false
    else
        echo "[STATUS] Build succeeded"
        echo ""
    fi
    echo ""
    
    # Build the device binaries (signed)
    echo "Building device binaries for target $target_name and configuration $configuration_name with SDK $configuration_sdk..."
    echo "--------------------------------------------------------------------------------------------------------------------------------------------------"
    echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_${configuration_name}_${configuration_sdk}.log"
    echo ""
    log_file_path="$build_dir/build_${configuration_name}_${configuration_sdk}.log"
    if $param_clean_first; then
        xcodebuild clean -project "$project_name.xcodeproj" -target "$target_name" -configuration "$configuration_name"
    fi
    xcodebuild clean build -project "$project_name.xcodeproj" -target "$target_name" -configuration "$configuration_name" -sdk "$configuration_sdk" \
        CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" PROVISIONING_PROFILE="$PROVISIONING_PROFILE" &> "$log_file_path"            
    if [ "$?" -ne "0" ]; then
        echo "[STATUS] Build failed (log excerpt follows)"
        echo ""
        tail -n 20 "$log_file_path"
        if $param_exit_on_failure; then
            exit 1
        fi
        build_successful=false
    else
        echo "[STATUS] Build succeeded"
        echo ""
    fi
    echo ""
done

echo "[STATUS] Finish date: "`date`
echo ""

# If a build failure was encountered (but did not stop the building process), exit with an error
if $build_successful; then
    echo "[STATUS] End of continuous integration; no build errors were encountered"
    echo ""
else 
    echo "[STATUS] End of continuous integration; a build error was encountered"
    echo ""
    exit 1
fi
