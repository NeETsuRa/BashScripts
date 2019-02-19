#!/bin/bash

# Default values
PACKAGE="at.com.xxx" #--> package can be found in the Manifest of the Application
ACTIVITIE_NAME="at.com.xxx.activities.Splash" #--> Activity Name can be found in the Manifest of the Application
PROJECT_ROOT="/Users/android" #--> The Root folder of the Project
PHONE_FOLDER="Phone" #--> Folder holding the build.gradle for Phone
TABLET_FOLDER="Tablet" #--> Folder holding the build.gradle for Tablet

#Build Tasks:
UAT_PHONE="assembleDebug" #--> gradle task for buildning the UAT Phone Release
UAT_TABLET="assembleDebug" #--> gradle task for buildning the UAT Tablet Release
PROD_PHONE="assembleRelease" #--> gradle task for buildning the PROD Phone Release
PROD_TABLET="assembleRelease" #--> gradle task for buildning the PROD Tablet Release

PHONE_BUILD_OUT_DIR="/Users/Phone/build/outputs/apk" #--> The DIR where the Phone APK is stored (needet only for the Information log)
TABLET_BUILD_OUT_DIR="/Users/Tablet/build/outputs/apk" #--> The DIR where the Tablet APK is stored (needet only for the Information log)

GIT_HUB_USER="mail@mai..com" #--> the GIT User for Release Taging
GIT_HUB_RELEASE_LINK="https://api.github.com/repos/android/releases" #--> the GIT URL for Release Taging

# Functions Used And some Usefull ones
#
# List all Devices
#   adb devices -l
# Install APK to a Device
#   adb -s DEVICE install -r APK
# Screen Record
#   adb -s DEVICE shell screenrecord --bit-rate 6000000 --time-limit 600 --verbose /sdcard/demo.mp4
# Get the a File from Device
#   adb pull /sdcard/demo.mp4
# Start The Application
#   adb -s "Device" shell am start -n "Package/Application Name" -S #-D
# Check Logcat
#   adb logcat *:LOG_LVL
# * List all Feautures of the Device
#   adb shell pm list features
# * List all libraries of the Device
#   adb shell pm list libraries
# Screenshot
#   adb -s $DEV shell screencap /sdcard/screen.png
# Build:
#   sh gradlew ":Phone:assembleUat2Debug"
#

# Text Preferences
BOLD_WHITE='\033[1;37m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
BLUE='\033[0;34m'
BOLD_BLUE='\033[1;34m'
COLOR_RESET='\033[0m'

REPOSITORY=""
PROGNAME="$(basename $0)"
ROOT=$(pwd)

#******************************************************************************
#* Print Function 
#* INTERN CALL: tell "Text" [Option] --> Option = "", "header", "error"
#* EXTERN CALL: /
#******************************************************************************
function tell() {
  if [[ "$2" = "header" ]]; then
    text_color="$BOLD_BLUE"
  elif [[ "$2" = "error" ]]; then
    text_color="$BOLD_RED"
  else
    text_color="$COLOR_RESET"
  fi
  prefix="${BOLD_WHITE}${PROGNAME}: ${COLOR_RESET}"
  if [[ "$2" = "error" ]]; then
    msg="${prefix}${text_color}ERROR: ${1}${COLOR_RESET}\n"
    >&2 printf "$msg"
  else
    msg="${prefix}${text_color}${1}${COLOR_RESET}\n"
    printf "$msg"
  fi
}

#******************************************************************************
#* Install Function
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh [INSTALL] [APK_PATH]
#* Description: The function is installing the application from URL on the specified Device
#******************************************************************************
function installApplikation() {
  tell "$ROOT\n" header
  adb devices -l
  read -p 'Device to be installet to: ' DEV
  install "$DEV" "$1"
}

#******************************************************************************
#* Install Function (Intern)
#* INTERN CALL: install "$DEV" "$APK_URL"
#* EXTERN CALL: /
#* Description: The function is installing the application from URL on the specified Device
#******************************************************************************
function install() {
  adb -s $1 install -r "$2"
}

#******************************************************************************
#* Recording Funktion 
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh [SCREEN_RECORD] [FILE_NAME]
#* Description: Function starts Recording the Specified Device screen and saves the Recording in the Device
#******************************************************************************
function record() {
  tell "$ROOT\n" header
  adb devices -l
  read -p 'Device to be recordet: ' DEV
  adb -s $DEV shell screenrecord --bit-rate 6000000 --time-limit 180 --verbose /sdcard/"$1".mp4
}

#******************************************************************************
#* Recording fatch Funktion 
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh [GET_RRECORD_FILE] [FILE_NAME]
#* Description: Function gets the Recordet file specified by the Name from the Mobile Phone
#******************************************************************************
function fetchRecordFile() {
  tell "$ROOT\n" header
  adb devices -l
  read -p 'Device to fetch the Record: ' DEV
  adb -s $DEV pull /sdcard/"$1".mp4
}

#******************************************************************************
#* Application start Funktion 
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh [RUN]
#* Description: Function runs the specified Application on the Device
#******************************************************************************
function startApplication() {
  tell "$ROOT\n" header
  adb devices -l
  read -p "Device to fetch the Record: " DEV
  read -p "Activity Package (Default $PACKAGE): " SET_PACKAGE
  if [[("$SET_PACKAGE" == "")]] 
    then
      tell "Will use \"$PACKAGE\" \n" error
    else
      PACKAGE="$SET_PACKAGE"
  fi
  read -p "Activity Name (Default $ACTIVITIE_NAME): : " SET_ACTIVITIE_NAME
  if [[("$SET_ACTIVITIE_NAME" == "")]] 
    then
      tell "Will use \"$ACTIVITIE_NAME\" \n" error
    else
      ACTIVITIE_NAME="$SET_ACTIVITIE_NAME"
  fi
  startApplicationWithParameters "$PACKAGE/$ACTIVITIE_NAME" "$DEV"
}

#******************************************************************************
#* Application start Function (intern)
#* INTERN CALL: startApplicationWithParameters "$StartString" "$DEV" --> Start string is a combo of Package and Application name. DEV is the Device Identifier
#* EXTERN CALL: /
#* Description: The Function starts the specified Application on the specified Devide
#******************************************************************************
function startApplicationWithParameters() {
  adb -s $2 shell am start -n "$1" -S #-D
}

#******************************************************************************
#* Install and Run Funktion 
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh [INSTALL_RUN] [APK_PATH]
#* Description: The Function installs the APK file on the specified Device and runns the APK on the device
#******************************************************************************
function installAndRun() {
  tell "$ROOT\n" header
  adb devices -l
  read -p 'Device to be installet to: ' DEV
  PACKAGE=$(aapt dump badging "$1" | awk '/package/{gsub("name=|'"'"'","");  print $2}')
  read -p "Activity Name (Default $ACTIVITIE_NAME): : " SET_ACTIVITIE_NAME
  if [[("$SET_ACTIVITIE_NAME" == "")]] 
    then
      tell "Will use \"$ACTIVITIE_NAME\" \n" error
    else
      ACTIVITIE_NAME="$SET_ACTIVITIE_NAME"
  fi
  install "$DEV" "$1"
  startApplicationWithParameters "$PACKAGE/$ACTIVITIE_NAME" "$DEV"
}

#******************************************************************************
#* Logcat Funktion 
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh [START_LOGCAT] [LOG_LVL]
#* Description: Function starts printing the Logcat of the specified Device. The LVL of the Logcat can be specified in the Parameter
#******************************************************************************
function logcat() {
  tell "$ROOT\n" header
  adb devices -l
  read -p 'Device to be installet to: ' DEV
  adb -s $DEV logcat *:"$1"
}

#******************************************************************************
#* Screenshot Funktion 
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh [SCREENSHOT]
#* Description: The Function is making a Screenshot of the specified Device and saves the screen shot in same location as the location of the Script
#******************************************************************************
function screenshot() {
  tell "$ROOT\n" header
  adb devices -l
  read -p 'Device to be installet to: ' DEV
  DATE="$(date -u +%y%m%d%H%M)"
  adb -s $DEV shell screencap "/sdcard/"$DATE"_screen.png"
  adb -s $DEV pull "/sdcard/"$DATE"_screen.png"
}

#******************************************************************************
#* BUILD Command Function 
#* INTERN CALL: /
#* EXTERN CALL: Andro.sh BUILD [VER] [DEVICE] [RELEASE] [COMMIT_AND_TAG (Default NO)]
#*            Where: 
#*                VER - the Version number of the Application (String no space)
#*                DEVICE - TABLET or PHONE
#*                RELEASE - UAT or PROD - for what release the Application should be build
#*                COMMIT_AND_TAG - YES - should a TAG be created and all changes commited
#*
#* Description: The function is provided the User for Building the APK file
#******************************************************************************
function build() {
  tell "$ROOT\n" header
  TARGET_VERSION="$1"
  BUILD_DEVICE="$2" #TABLET or PHONE
  BUILD_RELEASE="$3" #UAT or PROD
  TARGET_BUILD_NO="$(date -u +%y%m%d%H%M)"  # the current date/time in UTC
  BUILD_OUT_DIR="DIR"
  DO_COMMIT_AND_TAG="$4"

  tell "Start Build With Parameters:\n Version: ${TARGET_VERSION} \n Device: ${BUILD_DEVICE} \n Release: ${BUILD_RELEASE} \n Commit and Tag: ${DO_COMMIT_AND_TAG} "
  set_target_version
  build_apk
  if [[ "${DO_COMMIT_AND_TAG}" = "YES" ]]; then
    commit_changes
    tag_release
  fi

  if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
    BUILD_OUT_DIR="$PHONE_BUILD_OUT_DIR"
    else
    BUILD_OUT_DIR="$TABLET_BUILD_OUT_DIR"
  fi
  tell "All done. Find the exported apk file in ${BUILD_OUT_DIR}"
}

#******************************************************************************
#* Target and Build number Update Function 
#* INTERN CALL: set_target_version
#* EXTERN CALL: /
#* Description: The Function is setting the Target and Build number in the build.gradle file
#******************************************************************************
function set_target_version() {
  tell "Setting target version" header
  local version="${TARGET_VERSION}"
  local build_no="${TARGET_BUILD_NO}"
  local version_key="versionName"
  local build_no_key="versionCode"
  if [[ "${PHONE_FOLDER}" = "" ]]; then
    local file="$PROJECT_ROOT/build.gradle"
  else
    if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
      local file="$PROJECT_ROOT/$PHONE_FOLDER/build.gradle"
    else
      local file="$PROJECT_ROOT/$TABLET_FOLDER/build.gradle"
    fi
  fi
  tell "new release version: ${version} (build ${build_no})"
  sed -i '' "s/.*$version_key.*/        $version_key \"$version\"/g" "$file"
  sed -i '' "s/.*$build_no_key.*/        $build_no_key $build_no/g" "$file"
}

#******************************************************************************
#* APK Build function 
#* INTERN CALL: build_apk
#* EXTERN CALL: /
#* Description: Function is running the gradle Task for building the APK file
#******************************************************************************
function build_apk() {
  tell "Building APK" header
  cd "$PROJECT_ROOT/"
  FOLDER="$PHONE_FOLDER"
  RELEASE_TASK="$UAT"
  if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
    FOLDER="$PHONE_FOLDER"
    if [[ "${BUILD_RELEASE}" = "UAT" ]]; then
      RELEASE_TASK="$UAT_PHONE"
    else
      RELEASE_TASK="$PROD_PHONE"
    fi
  else
    FOLDER="$TABLET_FOLDER"
    if [[ "${BUILD_RELEASE}" = "UAT" ]]; then
      RELEASE_TASK="$UAT_TABLET"
    else
      RELEASE_TASK="$PROD_TABLET"
    fi
  fi
  
  if [[ "$FOLDER" = "" ]]; then
    sh gradlew ":$RELEASE_TASK"
  else
    sh gradlew ":$FOLDER:$RELEASE_TASK"
  fi
  
  cd "$ROOT"
}

#******************************************************************************
#* Git Hub Commit Function 
#* INTERN CALL: commit_changes
#* EXTERN CALL: /
#* Description: The Function is adding and  commiting the changes (No Push)
#******************************************************************************
function commit_changes() {
  cd "${PROJECT_ROOT}" || exit 1
  if [[ -z "${TARGET_VERSION}" ]]; then
    return
  fi
  tell "Let's commit the changes we've done so far" header
  git add -p \
    && git commit -m "Bump version to ${TARGET_VERSION} build ${TARGET_BUILD_NO}" \
    || exit 1
}

#******************************************************************************
#* Git Hub Taging Function 
#* INTERN CALL: tag_release
#* EXTERN CALL: /
#* Description: The function is creating a TAG on Git Hub
#******************************************************************************
function tag_release() {
  cd "${PROJECT_ROOT}" || exit 1
  if [[ -z "${TARGET_VERSION}" ]]; then
    return
  fi
  local version="${TARGET_VERSION}"
  local build_no="${TARGET_BUILD_NO}"
  tell "Let's create a release tag for our "${BUILD_RELEASE}" release" header

  local tag_flag="-a"
  if [[ "$SIGN_GIT_TAG" = "true" ]]; then
    tag_flag="-s"
  fi

  # template for the tag message:
  local template_file
  template_file="$(mktemp -t $PROGNAME)" || exit 1
  trap "rm -f ${template_file}" EXIT
  cat <<EOF >$template_file
$release_type Release $version build $build_no

-
EOF

  editor="${EDITOR:-$(git config core.editor)}"
  editor="${editor:-open}"
  eval $editor "$template_file" || exit 1

  # only create tag if template file has contents:
  local pre_release
  if [[ -z "$(cat "$template_file" | sed -E 's/\s//g')" ]]; then
    tell "Empty tag message -> skipping tag creation"
  else
    if [[ "${BUILD_RELEASE}" = "PROD" ]]; then
      if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
          local version="${TARGET_VERSION}-Phone"
        else
          local version="${TARGET_VERSION}-Tablet"
      fi
      pre_release="false"
    else
      if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
        local version="${TARGET_VERSION}-Phone"
      else
        local version="${TARGET_VERSION}-Tablet"
      fi
      pre_release="true"
    fi
    git tag "$tag_flag" -F "$template_file" "$version" || exit 1
    git push origin "$version"
    local body=$(echo $(<$template_file))
    gitHubTag "$version" "$body" "$pre_release"
  fi

  # cleanup done in trap
}

#******************************************************************************
#* Git Hub Tag Promotion Function. 
#* INTERN CALL: gitHubTag "$version" "$body" "$pre_release"
#* EXTERN CALL: /
#* Description: The function is Promoting the Git Hub TAG to a PreRelease or a Release
#******************************************************************************
function gitHubTag(){
    tell "seting the tag to Release or Pre-Release" header
    curl -v -XPOST -H "Content-type: application/json" -u "$GIT_HUB_USER" -d '{  "tag_name": "'"$1"'",  "name": "'"$1"'",  "body": "'"$2"'",  "draft": false,  "prerelease": '"$3"' }' $GIT_HUB_RELEASE_LINK
}


#******************************************************************************
#* Main Function 
#* INTERN CALL: /
#* EXTERN CALL: GIT.sh [COMAND]
#******************************************************************************
if [ $# -lt 1 ]
  then
    printf "\n HELP:"
    printf "\n Run the script with next command:"
    printf "\n    GIT.sh [COMAND]"
    printf "\n"
    printf "\n Where for COMAND: "
    printf "\n INSTALL [APK_PATH]              --> Install an APK to a Device" 
    printf "\n SCREEN_RECORD [FILE_NAME]       --> Starts a Screen Record"
    printf "\n GET_RRECORD_FILE [FILE_NAME]    --> Downloads the Screen Record with Name FILE_NAME"  
    printf "\n RUN                             --> Start Activitie specifiedwith Package and Activity Name"
    printf "\n INSTALL_RUN [APK_PATH]          --> Installs the APK and runs it"
    printf "\n START_LOGCAT [LOG_LVL]          --> Start Logcat witl Log LVL (Select LVL from following: Log max V->D->I->W->E->F->S Log minimum)"
    printf "\n SCREENSHOT                      --> Make a screen Shot of a Device"
    printf "\n"
    printf "\n"
    printf "\n BUILD [VER] [DEVICE] [RELEASE] [TAG&COMMIT] --> Builds an Android APK File"
    printf "\n          sh Andro.sh BUILD [VER] [DEVICE] [RELEASE] [COMMIT_AND_TAG (Default NO)]"
    printf "\n            Where: "
    printf "\n                VER - the Version number of the Application"
    printf "\n                DEVICE - TABLET or PHONE"
    printf "\n                RELEASE - UAT or PROD - for what release the Application should be build"
    printf "\n                COMMIT_AND_TAG - YES - should a TAG be created and all changes commited"
    printf "\n"
    printf "\n             Example: "
    printf "\n                sh Andro.sh 6.4.0-Alpha.1 PHONE UAT"
    printf "\n                sh Andro.sh 6.4.0 TABLET PROD YES"
    printf "\n"
    printf "\n"
  else
    case $1 in
      INSTALL)
        tell "Install:" header
        installApplikation "$2"
        ;;
      SCREEN_RECORD)
        tell "Record:" header
        record "$2"
        ;;
      GET_RRECORD_FILE)
        tell "Fetch:" header
        fetchRecordFile "$2"
        ;;
      RUN)
        tell "Run:" header
        startApplication
        ;;
      INSTALL_RUN)
        tell "Install and Run:" header
        installAndRun "$2"
        ;;
      START_LOGCAT)
        tell "Show Logcat:" header
        logcat "$2"
        ;;
      SCREENSHOT)
        tell "Make Screen Shot:" header
        screenshot
        ;;
      BUILD)
        tell "Android Build APK: " header
        build $2 $3 $4 $5
        ;;
      *)
        tell "Command Not Found \n" error
        sh GIT.sh
        ;;
    esac
fi