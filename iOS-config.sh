#DEVELOPMENT BUILD PARAMETERS:
CODE_SIGN_IDENTITY_DEV=""
#PHONE:
PROVISIONING_PROFILE_NAME_DEV_PHONE=""
PRODUCT_BUNDLE_IDENTIFIER_PHONE_UAT=""
SCHEME_UAT_PHONE=""
DEVELOPMENT_TEAM_DEV_PHONE=""
#TABLET:
PROVISIONING_PROFILE_NAME_DEV_TABLET=""
PRODUCT_BUNDLE_IDENTIFIER_TABLET_UAT=""
SCHEME_UAT_TABLET=""
DEVELOPMENT_TEAM_DEV_TABLET=""

#########################################################
#RELEASE BUILD PARAMETERS:
CODE_SIGN_IDENTITY_PROD=""
#PHONE:
PROVISIONING_PROFILE_NAME_PROD_PHONE=""
PRODUCT_BUNDLE_IDENTIFIER_PHONE_PROD=""
SCHEME_PROD_PHONE=""
DEVELOPMENT_TEAM_PROD_PHONE=""
#TABLET:
PROVISIONING_PROFILE_NAME_PROD_TABLET=""
PRODUCT_BUNDLE_IDENTIFIER_TABLET_PROD=""
SCHEME_PROD_TABLET=""
DEVELOPMENT_TEAM_PROD_TABLET=""

#########################################################
#OTHER PARAMETERS
EXPORT_OPTIONS=""
VERSION_P_LIST_PHONE=""
VERSION_P_LIST_TABLET=""
JS_BUNDLE_URL=""
BUILD_BASE_DIR_FOLDER=""
PROJECT=""
GIT_HUB_USER=""
GIT_HUB_RELEASE_LINK=""
#########################################################
#Where to find the Fields:
#PRODUCT_BUNDLE_IDENTIFIER = found in xCode under the Project. Example: "at.easybank.mobileBanking.internal"
#EXPORT_OPTIONS = name of the export options files. Example: "exportOptions.plist"
#CODE_SIGN_IDENTITY = Common name field in KeyChain under the used Certificate. Example: "iPhone Distribution: easybank AG"
#SCHEME = Scheme name used (found in xCode next to Run button). Example: "easybank_debug_gtt"
#PROVISIONING_PROFILE_NAME = Provisioning profile Name found when click i next to provisioning Profile, drag icon to text editor and search for the field Name. Example: "Bawag PSK In House Distribution Wildcard Profile"
#DEVELOPMENT_TEAM = Development Team  found when click i next to provisioning Profile, drag icon to text editor and search for the field TeamIdentifier. Example: "DAFJMFE92V"
#VERSION_P_LIST_PHONE = Path to the Info.plist. Example: "Easybank/Easybank/Easybank-Info.plist"
#VERSION_P_LIST_TABLET = Path to the Tablet Info.plist. Example: "Easybank/Easybank/easybank HD-Info.plist"
#JS_BUNDLE_URL = URL of the yarn JS_BUNDLE. Example: "http://localhost:8081/index.ios.bundle"
#BUILD_BASE_DIR_FOLDER = Name of the Project Files inside of the Root Folders. Example: "Easybank"
#PROJECT = Project name found in the BUILD_BASE_DIR_FOLDER (the file with the ending .xcodeproj Example: "Easybank"
#GIT_HUB_USER = GIT HUB User. Example: "nejc.ravnjak@accenture.com"
#GIT_HUB_RELEASE_LINK = Link to the Releases on HIT HUB. Example: "https://api.github.com/repos/LeDominik/easybank-ios/releases"
