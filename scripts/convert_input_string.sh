#!/bin/bash
# Throw error if input is empty
if [[ -z "$1" ]] ; then
    echo 'ERROR: No repository list received!'
    exit 1
fi

# Convert INPUT list
INPUT_LIST="$1,"
SED_STRING=$2
INPUT_LIST_MODIFIED=$(sed "$SED_STRING" <<< "$INPUT_LIST")
# Change special characters
## Needed for multi-line variable in github actions
if [[ -z "$3" ]] ; then
    INPUT_LIST_MODIFIED="${INPUT_LIST_MODIFIED//'%'/'%25'}"
    INPUT_LIST_MODIFIED="${INPUT_LIST_MODIFIED//$'\n'/'%0A'}"
    INPUT_LIST_MODIFIED="${INPUT_LIST_MODIFIED//$'\r'/'%0D'}"
else
  INPUT_LIST_MODIFIED="$( awk -F "$3" '{print $1}' <<< "$INPUT_LIST_MODIFIED" )"
fi

echo "$INPUT_LIST_MODIFIED"