#!/bin/bash
# Throw error if input is empty
if [[ -z "$1" ]] ; then
    echo 'ERROR: No repository list received!'
    exit 1
fi

# Convert domain list
DOMAIN_LIST="$1,"
DOMAIN_LIST_MODIFIED=$(sed "s;,;\n;g" <<< $DOMAIN_LIST)
# Change special characters
# Needed for multi-line variable in github actions
DOMAIN_LIST_MODIFIED="${DOMAIN_LIST_MODIFIED//'%'/'%25'}"
DOMAIN_LIST_MODIFIED="${DOMAIN_LIST_MODIFIED//$'\n'/'%0A'}"
DOMAIN_LIST_MODIFIED="${DOMAIN_LIST_MODIFIED//$'\r'/'%0D'}"

echo "$DOMAIN_LIST_MODIFIED"