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

# Remove @Ref if present
if [[ -n "$3" ]] ; then
  INPUT_LIST_MODIFIED="$( awk -F "$3" '{print $1}' <<< "$INPUT_LIST_MODIFIED" )"
else
  # Change special characters
  # Needed for multi-line variable in github actions
  INPUT_LIST_MODIFIED="${INPUT_LIST_MODIFIED//'%'/'%25'}"
  INPUT_LIST_MODIFIED="${INPUT_LIST_MODIFIED//$'\n'/'%0A'}"
  INPUT_LIST_MODIFIED="${INPUT_LIST_MODIFIED//$'\r'/'%0D'}"
fi

echo "$INPUT_LIST_MODIFIED"