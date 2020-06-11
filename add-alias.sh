#!/bin/bash

if [ "$#" -lt 1 ]
then
        echo "Usage: add-alias.sh [tenant]"
        exit 1
fi

alias be-tenant-admin='kubectl config use-context $1-admin-context'
alias be-john='kubectl config use-context $1-john-context'
