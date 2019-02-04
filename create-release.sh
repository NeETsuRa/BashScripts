#!/bin/bash

##
## Tool for creating, exporting and tagging builds.
##
##  Manual build:
##      yarn install
##      pod install
##      curl http://localhost:8081/index.ios.bundle -o main.jsbundle
##      xcodebuild CODE_SIGNING_REQUIRED="YES" CODE_SIGN_IDENTITY="iPhone Distribution: BAWAG P.S.K. Bank für Arbeit und Wirtschaft und Österreichische Postsparkasse Akti" PROVISIONING_PROFILE="3531ded1-4204-4906-a872-6f8a5e98dcc4" -sdk iphoneos -workspace "../BawagEasyBank.xcworkspace" -scheme "BAWAG_PSK_Debug_Gtt" clean archive -archivePath /Users/nejc.ravnjak/Documents/bawag-ios/bawag-ios/build/BAWAG_PSK.xcarchive/
##      xcodebuild -exportArchive -archivePath /Users/nejc.ravnjak/Documents/bawag-ios/bawag-ios/build/BAWAG_PSK.xcarchive/   -exportOptionsPlist uat-exportOptions.plist -exportPath $PWD/build
##

TARGET_VERSION="$1"
BUILD_DEVICE="$2" #TABLET or PHONE
BUILD_RELEASE="$3" #UAT or PROD

function validateDevice(){
  if [[("$1" != "PHONE") && ("$1" != "TABLET")]]; then
    printf "No valid Device found taking PHONE"
    BUILD_DEVICE="PHONE"
  fi
}
validateDevice ${BUILD_DEVICE}

PROGNAME="$(basename $0)"
TARGET_BUILD_NO="$(date -u +%y%m%d%H%M)"  # the current date/time in UTC
PROJECT_DIR="$(git rev-parse --show-toplevel)"
source "${PROJECT_DIR}/assets/bin/config.sh"

BUILD_BASE_DIR="${PROJECT_DIR}/${BUILD_BASE_DIR_FOLDER}"
BUILD_OUT_DIR="${BUILD_BASE_DIR}/build/${TARGET_BUILD_NO}"
ARCHIVE_DIR="${BUILD_OUT_DIR}/${PROJECT}_${BUILD_DEVICE}.xcarchive/"

#Default Signing
PROVISIONING_PROFILE_NAME="${PROVISIONING_PROFILE_NAME_DEV_PHONE}"
CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY_DEV}"
PRODUCT_BUNDLE_IDENTIFIER="${PRODUCT_BUNDLE_IDENTIFIER_PHONE_UAT}"
DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM_DEV_PHONE}"
SCHEME=${SCHEME_UAT_PHONE}

if [[ $# -lt 4 ]]; then
  DO_COMMIT_AND_TAG="NO"
else
  DO_COMMIT_AND_TAG="$4"
fi

SIGN_GIT_TAG=false

BOLD_WHITE='\033[1;37m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
BLUE='\033[0;34m'
BOLD_BLUE='\033[1;34m'
COLOR_RESET='\033[0m'


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

function wait_for_yarn_start() {
  tell "waiting for yarn start"
  until $(curl --output /dev/null --silent --head --fail "${JS_BUNDLE_URL}"); do
    printf '.'
    sleep 1
  done
}

function update_js_bundle() {
  tell "Checking JS bundle for updates" header
  local jsbundle="main.jsbundle"
  cd "${PROJECT_DIR}" || exit 1
  yarn start >/dev/null &
  wait_for_yarn_start
  local hash_before="$(shasum "$jsbundle")"
  curl --silent -o main.jsbundle "${JS_BUNDLE_URL}"
  curl_exit=$?
  kill -15 $!  # kill last background process = kill yarn
  if [[ $? -eq 0 ]]; then
    tell "yarn start shut down"
  else
    tell "failed to shut down yarn start" error
    exit 1
  fi
  if [[ $curl_exit -ne 0 ]]; then
    tell "updating main.jsbundle failed" error
    exit 1
  fi
  local hash_after="$(shasum "$jsbundle")"
  if [[ "$hash_before" = "$hash_after" ]]; then
    tell "$jsbundle up-to-date"
  else
    tell "$jsbundle updated -- make sure to review and commit the changes (before tagging) if this is a release!"
  fi
}

function set_target_version() {
  tell "Setting target version" header
  cd "${PROJECT_DIR}" || exit 1
  local version="${TARGET_VERSION}"
  local build_no="${TARGET_BUILD_NO}"

  local version_key="CFBundleShortVersionString"
  local build_no_key="CFBundleVersion"
  if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
    local file="${VERSION_P_LIST_PHONE}"
  else
    local file="${VERSION_P_LIST_TABLET}"
  fi

  local cur_version="$(plutil -extract "$version_key" xml1 "$file" -o - | sed -n -E '/<string>/s=^<string>(.+)</string>$=\1=p')"
  local cur_build_no="$(plutil -extract "$build_no_key" xml1 "$file" -o - | sed -n -E '/<string>/s=^<string>(.+)</string>$=\1=p')"
  if [[ -z "${version}" ]]; then
    tell "keeping current release version: ${cur_version} (build ${cur_build_no})"
  else
    tell "new release version: ${version} (build ${build_no})"
    plutil -replace "$version_key" -string "$version" "$file"
    # the build number is also only set in case this is a release build:
    plutil -replace "$build_no_key" -string "$build_no" "$file"
  fi
}

function install_deps() {
  tell "Installing dependencies" header
  cd "${PROJECT_DIR}" || exit 1
  #yarn install >/dev/null || exit 1  # use --silent when it's available, see https://github.com/yarnpkg/yarn/issues/788
  pod install --silent || exit 1
}

function build_archive() {
  tell "Building product archive" header
  if [[ "${BUILD_RELEASE}" = "PROD" ]]; then
    if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
      SCHEME="${SCHEME_PROD_PHONE}"
      PROVISIONING_PROFILE_NAME="${PROVISIONING_PROFILE_NAME_PROD_PHONE}"
      DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM_PROD_PHONE}"
      PRODUCT_BUNDLE_IDENTIFIER="${PRODUCT_BUNDLE_IDENTIFIER_PHONE_PROD}"
      else
      SCHEME="${SCHEME_PROD_TABLET}"
      PROVISIONING_PROFILE_NAME="${PROVISIONING_PROFILE_NAME_PROD_TABLET}"
      DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM_PROD_TABLET}"
      PRODUCT_BUNDLE_IDENTIFIER="${PRODUCT_BUNDLE_IDENTIFIER_TABLET_PROD}"
    fi
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY_PROD}"
  else
    if [[ "${BUILD_DEVICE}" = "PHONE" ]]; then
      SCHEME="${SCHEME_UAT_PHONE}"
      PROVISIONING_PROFILE_NAME="${PROVISIONING_PROFILE_NAME_DEV_PHONE}"
      DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM_DEV_PHONE}"
      PRODUCT_BUNDLE_IDENTIFIER="${PRODUCT_BUNDLE_IDENTIFIER_PHONE_UAT}"
    else
      SCHEME="${SCHEME_UAT_TABLET}"
      PROVISIONING_PROFILE_NAME="${PROVISIONING_PROFILE_NAME_DEV_TABLET}"
      DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM_DEV_TABLET}"
      PRODUCT_BUNDLE_IDENTIFIER="${PRODUCT_BUNDLE_IDENTIFIER_TABLET_UAT}"
    fi
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY_DEV}"
  fi
  tell "Build Archive with parameters:\n SCHEME: ${SCHEME} \n PROVISIONING_PROFILE_NAME: ${PROVISIONING_PROFILE_NAME} \n DEVELOPMENT_TEAM: ${DEVELOPMENT_TEAM} \n PRODUCT_BUNDLE_IDENTIFIER: ${PRODUCT_BUNDLE_IDENTIFIER} \n CODE_SIGN_IDENTITY: ${CODE_SIGN_IDENTITY}"
  
  set_product_bundle_identifier

  mkdir -p "${ARCHIVE_DIR}" && cd "${BUILD_BASE_DIR}" || exit 1
  xcodebuild \
    -quiet \
    CODE_SIGNING_REQUIRED="YES" \
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    PROVISIONING_PROFILE_SPECIFIER="${DEVELOPMENT_TEAM}/${PROVISIONING_PROFILE_NAME}" \
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
    -sdk iphoneos \
    -workspace "${PROJECT_DIR}/BawagEasyBank.xcworkspace" \
    -scheme "${SCHEME}" \
    -archivePath "${ARCHIVE_DIR}" \
    -destination generic/platform=iOS \
    clean archive \
  || { tell "xcodebuild archive: failed" error; exit 1; }
  tell "Build Successful!"
}

function update_exportOptionsPlist() {
  tell "Update exportOptionsPlist " header
  tell "set provisioningProfiles <key>  to: ${PRODUCT_BUNDLE_IDENTIFIER}, <value> to ${PROVISIONING_PROFILE_NAME}"
  /usr/libexec/PlistBuddy -c "delete :provisioningProfiles dict" "${BUILD_BASE_DIR}/${EXPORT_OPTIONS}"
  /usr/libexec/PlistBuddy -c "add :provisioningProfiles:${PRODUCT_BUNDLE_IDENTIFIER} string ${PROVISIONING_PROFILE_NAME}" "${BUILD_BASE_DIR}/${EXPORT_OPTIONS}"
  if [[ "${BUILD_RELEASE}" = "PROD" ]]; then
    tell "set method <key>  to: app-store"
    /usr/libexec/PlistBuddy -c "set :method app-store" "${BUILD_BASE_DIR}/${EXPORT_OPTIONS}"
  else
    tell "set method <key>  to: enterprise"
    /usr/libexec/PlistBuddy -c "set :method enterprise" "${BUILD_BASE_DIR}/${EXPORT_OPTIONS}"
  fi
  tell "set teamID <key>  to: ${DEVELOPMENT_TEAM}"
  /usr/libexec/PlistBuddy -c "set :teamID ${DEVELOPMENT_TEAM}" "${BUILD_BASE_DIR}/${EXPORT_OPTIONS}"
}

function set_product_bundle_identifier() {
  tell "set PRODUCT_BUNDLE_IDENTIFIER to: ${PRODUCT_BUNDLE_IDENTIFIER}" header
  sed -i '' "s/.*PRODUCT_BUNDLE_IDENTIFIER.*/        PRODUCT_BUNDLE_IDENTIFIER = ${PRODUCT_BUNDLE_IDENTIFIER};/g" "${BUILD_BASE_DIR}/${PROJECT}.xcodeproj/project.pbxproj"
}

function export_archive_ipa() {
  update_exportOptionsPlist

  tell "Exporting product archive to .ipa file with export options ${EXPORT_OPTIONS}" header
  mkdir -p "${ARCHIVE_DIR}" && cd "${BUILD_BASE_DIR}" || exit 1
  xcodebuild \
    -quiet \
    -exportArchive \
    -archivePath "${ARCHIVE_DIR}" \
    -exportPath "${BUILD_OUT_DIR}" \
    -exportOptionsPlist "${BUILD_BASE_DIR}/${EXPORT_OPTIONS}" \
  || { tell "xcodebuild exportArchive: failed" error; exit 1; }
  tell "Export Successful!"
}

function commit_changes() {
  cd "${PROJECT_DIR}" || exit 1
  if [[ -z "${TARGET_VERSION}" ]]; then
    return
  fi
  tell "Let's commit the changes we've done so far" header
  git add -p \
    && git commit -m "Bump version to ${TARGET_VERSION} build ${TARGET_BUILD_NO}" \
    || exit 1
}

function tag_release() {
  cd "${PROJECT_DIR}" || exit 1
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

function gitHubTag(){
    tell "seting the tag to Release or Pre-Release" header
    curl -v -XPOST -H "Content-type: application/json" -u "$GIT_HUB_USER" -d '{  "tag_name": "'"$1"'",  "name": "'"$1"'",  "body": "'"$2"'",  "draft": false,  "prerelease": '"$3"' }' $GIT_HUB_RELEASE_LINK
}

function main() {
  tell "Start Build With Parameters:\n Version: ${TARGET_VERSION} \n Device: ${BUILD_DEVICE} \n Release: ${BUILD_RELEASE} \n Commit and Tag: ${DO_COMMIT_AND_TAG} "
  install_deps
  set_target_version
  #update_js_bundle
  build_archive
  export_archive_ipa
  if [[ "${DO_COMMIT_AND_TAG}" = "YES" ]]; then
    commit_changes
    tag_release
  fi
  tell "All done. Find the exported .ipa file in ${BUILD_OUT_DIR}"
}

if [ $# -lt 3 ]
  then
    printf "\n HELP:"
    printf "\n Run the script with next command:"
    printf "\n    sh create-release.sh [VER] [DEVICE] [RELEASE] [COMMIT_AND_TAG (Default NO)]"
    printf "\n"
    printf "\n Where: "
    printf "\n VER - the Version number of the Application"
    printf "\n DEVICE - TABLET or PHONE"
    printf "\n RELEASE - UAT or PROD - for what release the Application should be build"
    printf "\n COMMIT_AND_TAG - YES - should a TAG be created and all changes commited"
    printf "\n"
    printf "\n INFO:"
    printf "\n   - By All releases the correct Provisioning Profile has to be set in in XCode"
    printf "\n"
    printf "\n Example: "
    printf "\n    sh bin/create-release.sh 6.4.0-Alpha.1 PHONE UAT"
    printf "\n    sh bin/create-release.sh 6.4.0 TABLET PROD YES"
    printf "\n"
    printf "\n"
  else
    main
fi
