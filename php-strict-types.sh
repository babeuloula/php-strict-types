#!/bin/sh

set -e

readonly RESET='\033[0;0m' # Reset color and text style

readonly RED='\033[0;31m' # Color red
readonly GREEN='\033[0;32m' # Color green
readonly BLUE='\033[0;34m' # Color blue

readonly SOFTWARE_NAME="${GREEN}PHP declare(strict_types=1); directive checker & fixer${RESET}"

echo -e "${SOFTWARE_NAME}"
echo -e "Version 1.0.1 by BaBeuloula (https://github.com/babeuloula/php-strict-types).\n"

display_help() {
    echo -e "This script verifies if each new PHP files has the declare(strict_types=1); directive.
If not, it can automatically be added by adding the --fix option.

Usage:
    $(basename "$0") options <paths to check>

Options:
    --fix                   Fix the files by adding the directive
    --check                 Check if the files have the directive (default mode)

    --help                  Display help
"
    exit 0
}

main() {
  MODE="check" # Determine if the script must fix the files or just check

  eval set -- $(getopt -q --long help,fix,check -n "${SOFTWARE_NAME}" -- "$@")
  while true; do
    case "$1" in
      --fix)
        MODE="fix"
      ;;

      --check)
        MODE="check"
      ;;

      --help)
        display_help
        ;;

      --)
        shift
        break
      ;;
    esac
    shift
  done

  PATHS_TO_CHECK=$@ # List of path to check as arguments

  if [ -z "${PATHS_TO_CHECK}" ]; then
    echo -e "${RED}You must specify the paths to check (ex: $0 foo bar --${MODE}).${RESET}"
    exit 1
  fi

  # Retrieve the list of new files between the branch previous commit and the current commit.
  # Files must be committed when this script is executed.
  # ("awk -F ' ' '{print $6}'" allow to get the 6th column of the previous command.
  diff_files=$(git diff --diff-filter=A HEAD^1 HEAD --raw -- $PATHS_TO_CHECK | awk -F ' ' '{print $6}')

  error_files="" # List of files in error
  for file in $diff_files; do
    # Determine if the directive is present in the file (only for *.php files).
    if [ -f "$file" ] && [ ! $(grep -i 'declare(strict_types=1);' "$file") ] && [ "${file##*.}" = "php" ]; then
        error_files="${error_files} $file"
    fi
  done

  # If there are no files found, we can return a success.
  if [ -z "$error_files" ]; then
    echo -e "${GREEN} 👏 All new files have the directive.${RESET}"
    exit 0
  fi

  if [ "${MODE}" = "check" ]; then
    # If the mode is "check", we output all files.
    echo -e "Missing declare(strict_types=1) directive in file(s):"
    for file in $error_files; do
      echo -e " ${RED}✘${RESET} $file"
    done
    exit 1
  fi

  # Otherwise, we fix all the files in error by add the directive.
  echo -e "Fixing declare(strict_types=1) directive in file(s):"
  for file in $error_files; do
    sed -i "s/<?php/<?php\r\rdeclare(strict_types=1);/g" $file
    echo -e " ${GREEN}✔${RESET} $file"
  done
}

main $0 "$@"
