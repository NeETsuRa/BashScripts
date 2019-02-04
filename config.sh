#DEVELOPMENT BUILD PARAMETERS:
CODE_SIGN_IDENTITY_DEV="iPhone Distribution: easybank AG"
#PHONE:
PROVISIONING_PROFILE_NAME_DEV_PHONE="Easybank eBanking App Internal"
PRODUCT_BUNDLE_IDENTIFIER_PHONE_UAT="at.easybank.mobileBanking.internal"
SCHEME_UAT_PHONE="easybank_debug_gtt"
DEVELOPMENT_TEAM_DEV_PHONE="DAFJMFE92V"
#TABLET:
PROVISIONING_PROFILE_NAME_DEV_TABLET="Easybank Tablet"
PRODUCT_BUNDLE_IDENTIFIER_TABLET_UAT="at.easybank.mobileBankingTablet.internal"
SCHEME_UAT_TABLET="easybank_HD_debug_gtt"
DEVELOPMENT_TEAM_DEV_TABLET="DAFJMFE92V"

#########################################################
#RELEASE BUILD PARAMETERS:
CODE_SIGN_IDENTITY_PROD="iPhone Distribution: easybank AG"
#PHONE:
PROVISIONING_PROFILE_NAME_PROD_PHONE="Easy Phone New"
PRODUCT_BUNDLE_IDENTIFIER_PHONE_PROD="at.easybank.mobileBanking"
SCHEME_PROD_PHONE="easybank_release_live"
DEVELOPMENT_TEAM_PROD_PHONE="7283Y763QK"
#TABLET:
PROVISIONING_PROFILE_NAME_PROD_TABLET="easybank Tablet"
PRODUCT_BUNDLE_IDENTIFIER_TABLET_PROD="at.easybank.mobileBankingTablet"
SCHEME_PROD_TABLET="easybank_HD_release_live"
DEVELOPMENT_TEAM_PROD_TABLET="7283Y763QK"

#########################################################
#OTHER PARAMETERS
EXPORT_OPTIONS="exportOptions.plist"
VERSION_P_LIST_PHONE="Easybank/Easybank/Easybank-Info.plist"
VERSION_P_LIST_TABLET="Easybank/Easybank/easybank HD-Info.plist"
JS_BUNDLE_URL="http://localhost:8081/index.ios.bundle"
BUILD_BASE_DIR_FOLDER="Easybank"
PROJECT="Easybank"
GIT_HUB_USER="nejc.ravnjak@accenture.com"
GIT_HUB_RELEASE_LINK="https://api.github.com/repos/LeDominik/easybank-ios/releases"
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
