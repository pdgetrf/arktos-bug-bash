#!/bin/bash

set -e
set -x

kubectl create -f futureweirole-reader.yaml 
kubectl create -f futureweirole-pod-reader.yaml 
kubectl create -f futureweirolebinding-pengdu.yaml 
kubectl create -f futureweirolebinding-xiaoning.yaml 
