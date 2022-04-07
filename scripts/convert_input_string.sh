#!/bin/bash
# Throw error if input is empty
if [[ -z "$1" ]] ; then
    echo 'ERROR: No domain list received!'
    exit 1
elif [[ -z "$2" ]] ; then
    echo 'ERROR: No branch received!'
    exit 1
fi

# echo "Received list of domains: $1, $2"

# Convert domain list
BRANCH=$2
DOMAIN_LIST="$1,"
DOMAIN_LIST_MODIFIED=$(sed "s;,;@$BRANCH\n;g" <<< $DOMAIN_LIST)
# Change special characters
# Needed for multi-line variable in github actions
DOMAIN_LIST_MODIFIED="${DOMAIN_LIST_MODIFIED//'%'/'%25'}"
DOMAIN_LIST_MODIFIED="${DOMAIN_LIST_MODIFIED//$'\n'/'%0A'}"
DOMAIN_LIST_MODIFIED="${DOMAIN_LIST_MODIFIED//$'\r'/'%0D'}"

echo "$DOMAIN_LIST_MODIFIED"