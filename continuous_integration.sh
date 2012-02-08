#!/bin/bash

# TODO: Extract SDKROOT from .pbxproj. Use it with xcodebuild (currently, the latest SDK is used)
# TODO: Extract .xcodeproj files. Use it to build all projects and to create separate build logs for each of them
# TODO: Document this script (most notably that it is meant to be used with Jenkins)

echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------------------------"
echo "Continuous integration for $JOB_NAME, build $BUILD_NUMBER ($BUILD_ID)"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------"
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

# Simulator debug build
echo "Building simulator Debug binaries..."
echo "------------------------------------"
echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_simulator_debug.log"
xcodebuild clean build -configuration "Debug" -sdk iphonesimulator RUN_CLANG_STATIC_ANALYZER="true" &> "$build_dir/build_simulator_debug.log"
if [ $? -ne "0" ]; then
    echo "[STATUS] Build failed"
    echo ""
    exit 1  
fi
echo "[STATUS] Build succeeded"
echo ""

# Simulator release build
echo "Building simulator Release binaries..."
echo "--------------------------------------"
echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_simulator_release.log"
xcodebuild clean build -configuration "Release" -sdk iphonesimulator RUN_CLANG_STATIC_ANALYZER="true" &> "$build_dir/build_simulator_release.log"
if [ $? -ne "0" ]; then
    echo "[STATUS] Build failed"
    echo ""
    exit 1  
fi
echo "[STATUS] Build succeeded"
echo ""

# Device debug build
echo "Building device Debug binaries..."
echo "---------------------------------"
echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_device_debug.log"
xcodebuild clean build -configuration "Debug" -sdk iphoneos CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" PROVISIONING_PROFILE="$PROVISIONING_PROFILE" &> "$build_dir/build_device_debug.log"
if [ $? -ne "0" ]; then
    echo "[STATUS] Build failed"
    echo ""
    exit 1  
fi
echo "[STATUS] Build succeeded"
echo ""

# Device release build
echo "Building device Release binaries..."
echo "-----------------------------------"
echo "The full log is available under ${JOB_URL}ws/buildlogs/$BUILD_NUMBER/build_device_release.log"
xcodebuild clean build -configuration "Release" -sdk iphoneos CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" PROVISIONING_PROFILE="$PROVISIONING_PROFILE" &> "$build_dir/build_device_release.log"
if [ $? -ne "0" ]; then
    echo "[STATUS] Build failed"
    echo ""
    exit 1  
fi
echo "[STATUS] Build succeeded"
echo ""

# TODO: Create ipa
# See http://stackoverflow.com/questions/2664885/xcode-build-and-archive-from-command-line
# /usr/bin/xcrun -sdk iphoneos PackageApplication -v "${RELEASE_BUILDDIR}/${APPLICATION_NAME}.app" -o "${BUILD_HISTORY_DIR}/${APPLICATION_NAME}.ipa" --sign "${DEVELOPER_NAME}" --embed "${PROVISONING_PROFILE}"

echo "[STATUS] End of continuous integration"

