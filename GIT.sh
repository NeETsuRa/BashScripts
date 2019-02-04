#!/bin/bash

# For usage of the Script following Parameters has to be set:
# Parameter:
# Repos (Mandatory) - By change edit Function setRepo and the HELP (can delete or add more if needet):
BAWAG_IOS_REPO="bawag-ios"
BAWAG_ANDROID_REPO="bawag-android"
EASYBANK_IOS_REPO="easybank-ios"
EASYBANK_ANDROID_REPO="easybank-android"

REPO_LIST=("$BAWAG_IOS_REPO" "$EASYBANK_IOS_REPO" "$BAWAG_ANDROID_REPO" "$EASYBANK_ANDROID_REPO")
REPO_CLONE_LIST=("BAWAG_IOS" "EASYBANK_IOS" "BAWAG_ANDROID" "EASYBANK_ANDROID")

# GIT URL (Optional - only if need to clone) - By change edit Function setURLRepo and the HELP (can delete or add more if needet):
BAWAG_IOS_URL="https://github.com/LeDominik/bawag-ios.git"
BAWAG_ANDROID_URL="https://github.com/LeDominik/bawag-android.git"
EASYBANK_IOS_URL="https://github.com/LeDominik/easybank-ios.git"
EASYBANK_ANDROID_URL="https://github.com/LeDominik/easybank-android.git"

#
# Functions Used and some usefull Functions:
#   Basic git Functions:
#     git checkout .                  --> MASTER_UPDATE_ALL
#     git checkout master             --> MASTER_UPDATE_ALL
#     git pull                        --> MASTER_UPDATE_ALL, UPDATE_ALL
#     git lfs clone URL
#
#   Tree - git commit graph:
#     git log --graph --decorate --pretty=oneline --abbrev-commit --all  --> TREE_ALL, TREE REPO
#
#   Delete GIT Tag:                   --> DELETE_TAG REPO TAG
#     git tag -d 6.4.0-Phone
#     git push origin :refs/tags/6.4.0-Phone
#
#   GIT Tag:                          --> CREATE_TAG REPO TAG \"MSG\"
#     git tag -a TAG_NAME -m "TAG TEXT"
#     git push --tags
#
#   Branching:                        --> BRANCH REPO BRANCH_NAME, BRANCH_AND_COMMIT REPO BRANCH_NAME
#     git checkout -b BRANCH
#     git push -u origin BRANCH
#
#   Commit changes:
#     git commit -a --amend 
#     git rebase -i @~2
#
#   Revert all commits:
#     git reset --soft HEAD~
#     git reset --soft HEAD~1  

# Text Preferences
BOLD_WHITE='\033[1;37m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
BLUE='\033[0;34m'
BOLD_BLUE='\033[1;34m'
COLOR_RESET='\033[0m'

REPOSITORY=""
ROOT=$(pwd)

function setRepo() {
  case $1 in
    BAWAG_IOS)
      REPOSITORY="$BAWAG_IOS_REPO"
      break
      ;;
    EASYBANK_IOS)
      REPOSITORY="$EASYBANK_IOS_REPO"
      break
      ;;
    BAWAG_ANDROID)
      REPOSITORY="$BAWAG_ANDROID_REPO"
      break
      ;;
    EASYBANK_ANDROID)
      REPOSITORY="$EASYBANK_ANDROID_REPO"
      break
      ;;
  esac
}

function setURLRepo() {
  case $1 in
    BAWAG_IOS)
      REPOSITORY="$BAWAG_IOS_URL"
      ;;
    EASYBANK_IOS)
      REPOSITORY="$EASYBANK_IOS_URL"
      ;;
    BAWAG_ANDROID)
      REPOSITORY="$BAWAG_ANDROID_URL"
      ;;
    EASYBANK_ANDROID)
      REPOSITORY="$EASYBANK_ANDROID_URL"
      ;;
  esac
}

function updateAll() {
  printf "\n"
  printf "$ROOT\n"
  for repo in "${REPO_LIST[@]}"; do
    echo "$BOLD_WHITE ${repo}: $COLOR_RESET"
    cd "${repo}" 
    git pull
    cd "$ROOT"
  done
}

function masterUpdateAll() {
  printf "\n"
  printf "$ROOT\n"
  for repo in "${REPO_LIST[@]}"; do
    echo "$BOLD_WHITE ${repo}: $COLOR_RESET"
    cd "${repo}" 
    git checkout .
    git checkout master
    git pull
    cd "$ROOT"
  done
}

function checkTreeAll() {
  printf "\n"
  printf "$ROOT\n"
  for repo in "${REPO_LIST[@]}"; do
    echo "$BOLD_WHITE ${repo}: $COLOR_RESET"
    cd "${repo}" 
    git log --graph --decorate --pretty=oneline --abbrev-commit --all
    cd "$ROOT"
  done
}


function checkTree() {
  printf "\n"
  printf "$ROOT\n"
  setRepo $1
  if [[("$REPOSITORY" == "")]] 
    then
      printf "$BOLD_BLUE  Please set a valid Repository $COLOR_RESET \n"
    else
      echo "$BOLD_WHITE $REPOSITORY: $COLOR_RESET"
      cd "$REPOSITORY" 
      git log --graph --decorate --pretty=oneline --abbrev-commit --all
      cd "$ROOT"
  fi
}

function deleteTAG() {
  printf "\n"
  printf "$ROOT\n"
  setRepo $1
  if [[("$REPOSITORY" == "")]] 
    then
      printf "$BOLD_BLUE  Please set a valid Repository $COLOR_RESET \n"
    else
      echo "$BOLD_WHITE $REPOSITORY: delete TAG $2 $COLOR_RESET"
      cd "$REPOSITORY" 
      git tag -d "$2"
      git push origin :refs/tags/"$2"
      cd "$ROOT"
  fi
}

function TAG() {
  printf "\n"
  printf "$ROOT\n"
  setRepo $1
  if [[("$REPOSITORY" == "")]] 
    then
      printf "$BOLD_BLUE  Please set a valid Repository $COLOR_RESET \n"
    else
      echo "$BOLD_WHITE $REPOSITORY: delete TAG $2 $COLOR_RESET"
      cd "$REPOSITORY" 
      git tag -a "$2" -m "$3"
      git push --tags
      cd "$ROOT"
  fi
}

function clone() {
  printf "\n"
  printf "$ROOT\n"
  setURLRepo $1
  if [[("$REPOSITORY" == "")]] 
    then
      printf "$BOLD_BLUE  Please set a valid Repository $COLOR_RESET \n"
    else
      echo "$BOLD_WHITE $REPOSITORY: Clone $COLOR_RESET" 
      git lfs clone "$REPOSITORY"
  fi
}

function cloneAll() {
  printf "\n"
  printf "$ROOT\n"
  for repo in "${REPO_CLONE_LIST[@]}"; do
    setURLRepo $repo
    if [[("$REPOSITORY" == "")]] 
      then
        printf "$BOLD_BLUE  Please set a valid Repository ($repo) $COLOR_RESET \n"
      else
        echo "$BOLD_WHITE $REPOSITORY: Clone $COLOR_RESET" 
        git lfs clone "$REPOSITORY"
    fi
  done
}

function branch() {
  printf "\n"
  printf "$ROOT\n"
  setRepo $1
  if [[("$REPOSITORY" == "")]] 
    then
      printf "$BOLD_BLUE  Please set a valid Repository $COLOR_RESET \n"
    else
      echo "$BOLD_WHITE $REPOSITORY: Branch $2 $COLOR_RESET"
      cd "$REPOSITORY" 
      git checkout -b "$2"
      git push -u origin "$2"
      cd "$ROOT"
  fi
}

function branchAndCommit() {
  printf "\n"
  printf "$ROOT\n"
  setRepo $1
  if [[("$REPOSITORY" == "")]] 
    then
      printf "$BOLD_BLUE  Please set a valid Repository $COLOR_RESET \n"
    else
      echo "$BOLD_WHITE $REPOSITORY: Branch $2 $COLOR_RESET"
      cd "$REPOSITORY" 
      git checkout -b "$2"
      git push -u origin "$2"
      git add .
      git commit
      git push
      cd "$ROOT"
  fi
}

if [ $# -lt 1 ]
  then
    printf "\n HELP:"
    printf "\n Run the script with next command:"
    printf "\n    GIT.sh [COMAND]"
    printf "\n"
    printf "\n Where for COMAND: "
    printf "\n UPDATE_ALL                 --> Updates all git Repos"  
    printf "\n MASTER_UPDATE_ALL          --> Reerts all changes, check out master, and update"
    printf "\n TREE_ALL                   --> Check TREE Graph for all Repos"
    printf "\n TREE REPO                  --> Check TREE Graph for Repo "
    printf "\n CREATE_TAG REPO TAG \"MSG\"  --> Create a tag on Repo with Name [TAG] with a Message [MSG]"
    printf "\n DELETE_TAG REPO TAG        --> Deletes a tag on Repo with Name [TAG]"
    printf "\n CLONE_ALL                  --> Clone all Repo"
    printf "\n CLONE REPO                 --> Clone the Repo"
    printf "\n BRANCH REPO B_NAME         --> Creates a Branch with name B_NAME in REPO"
    printf "\n BRANCH_COMMIT REPO B_NAME  --> Creates a Branch with name B_NAME in REPO, adds all changes Commits and pushes them to GIT"
    printf "\n"
    printf "\n REPO: FACELIFT, BAWAG_IOS, BAWAG_ANDROID, EASYBANK_IOS, EASYBANK_ANDROID"
    printf "\n        (Repos can be set in the Script It self)"
    printf "\n"
    printf "\n"
  else
    case $1 in
      UPDATE_ALL)
        printf "$BOLD_BLUE Update all: $COLOR_RESET"
        updateAll
        ;;
      MASTER_UPDATE_ALL)
        printf "$BOLD_BLUE Master pdate all: $COLOR_RESET"
        masterUpdateAll
        ;;
      TREE_ALL)
        printf "$BOLD_BLUE TREE all: $COLOR_RESET"
        checkTreeAll
        ;;
      TREE)
        printf "$BOLD_BLUE  TREE "$2": $COLOR_RESET"
        checkTree "$2"
        ;;
      CREATE_TAG)
        printf "$BOLD_BLUE  TAG "$2": $COLOR_RESET"
        TAG "$2" "$3" "$4"
        ;;
      DELETE_TAG)
        printf "$BOLD_BLUE  Delete TAG "$2": $COLOR_RESET"
        deleteTAG "$2" "$3"
        ;;
      CLONE)
        printf "$BOLD_BLUE  Clone "$2": $COLOR_RESET"
        clone "$2"
        ;;
      CLONE_ALL)
        printf "$BOLD_BLUE  Clone All: $COLOR_RESET"
        cloneAll
        ;;
      BRANCH)
        printf "$BOLD_BLUE  Branch "$2" (Branch Name: "$3"): $COLOR_RESET"
        branch "$2" "$3"
        ;;
      BRANCH_COMMIT)
        printf "$BOLD_BLUE  Branch and Commit "$2" (Branch Name: "$3"): $COLOR_RESET"
        branchAndCommit "$2" "$3"
        ;;
      *)
        printf "Command Not Found \n"
        sh GIT.sh
        ;;
    esac
fi
