#!/bin/sh

set -e

readonly RESET=$(tput sgr0) # Reset color and text style

readonly RED='\033[0;31m' # Color red
readonly GREEN='\033[0;32m' # Color green
readonly BLUE='\033[0;34m' # Color blue

readonly BOLD=$(tput bold) # Bold text

readonly SOFTWARE_NAME="${GREEN}PHP ${BOLD}declare(strict_types=1);${RESET} ${GREEN}directive checker & fixer${RESET}"

echo "${SOFTWARE_NAME}"
echo "Version ${BOLD}1.0.0${RESET} by ${BOLD}BaBeuloula${RESET} (https://github.com/babeuloula/php-strict-types).\n"

display_help() {
    cat <<-END
This script verifies if each new PHP files has the ${BOLD}declare(strict_types=1);${RESET} directive.
If not, it can automatically be added by adding the ${BOLD}--fix${RESET} option.

Usage:
    $(basename "$0") <paths to check> options

Options:
    --fix                   Fix the files by adding the directive
    --check                 Check if the files have the directive (default mode)

    --help                  Display help

END
    exit 0
}

main() {
  MODE="check" # Determine if the script must fix the files or just check

  eval set -- $(getopt -q --long help,fix,check: -n "${SOFTWARE_NAME}" -- "$@")
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
    echo "${RED}You must specify the paths to check (ex: ${BOLD}$0 foo bar --${MODE}${RESET}${RED}).${RESET}"
    exit 1
  fi

  # Retrieve the list of new files between the branch main and the current commit.
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
    echo "${GREEN} 👏 All new files have the directive.${RESET}"
    exit 0
  fi

  if [ "${MODE}" = "check" ]; then
    # If the mode is "check", we output all files.
    echo "Missing ${BOLD}declare(strict_types=1)${RESET} directive in file(s):"
    for file in $error_files; do
      echo " ${RED}✘${RESET} $file"
    done
    exit 1
  fi

  # Otherwise, we fix all the files in error by add the directive.
  echo "Fixing ${BOLD}declare(strict_types=1)${RESET} directive in file(s):"
  for file in $error_files; do
    sed -i "s/<?php/<?php\r\rdeclare(strict_types=1);/g" $file
    echo " ${GREEN}✔${RESET} $file"
  done
}

main $0 "$@"
