#!/bin/bash

# TODO: Document this script (most notably that it is meant to be used with Jenkins)

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

