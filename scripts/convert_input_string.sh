#!/bin/bash
# Throw error if input is empty
if [[ -z "$1" ]] ; then
    echo 'ERROR: No domain list received!'
    exit 1
elif [[ -z "$2" ]] ; then
    echo 'ERROR: No branch received!'
    exit 1
fi

echo "Received list of domains: $1, $2"

# Convert domain list
BRANCH=$2
DOMAINS_MODIFIED=$1
$DOMAINS_MODIFIED+=,
$DOMAINS_MODIFIED=$(sed "s;,;@$BRANCH\n;g" <<< $DOMAINS_MODIFIED)

echo $DOMAINS_MODIFIED