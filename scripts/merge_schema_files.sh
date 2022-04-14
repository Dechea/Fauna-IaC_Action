#!/bin/bash

IFS="," read -a repoNames <<< "$1"
for index in "${!repoNames[@]}"
do
    echo "merging schema file for repo : ${repoNames[index]}"
    cat ${repoNames[index]}/${repoNames[index],,}.gql >> schema/schema.gql
done

echo "Successfully merge schema files"
