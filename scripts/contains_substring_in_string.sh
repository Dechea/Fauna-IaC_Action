#!/bin/bash

[[ "$1" == *"$2"* ]] && isContains="true" || isContains="false"
echo "$isContains"
