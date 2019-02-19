
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

