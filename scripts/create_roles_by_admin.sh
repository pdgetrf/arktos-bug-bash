#!/bin/bash

set -e
set -x

kubectl create -f role-reader.yaml 
kubectl create -f rolebinding-reader.yaml 
