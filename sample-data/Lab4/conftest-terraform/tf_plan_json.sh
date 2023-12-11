#!/usr/bin/env bash

cd $( dirname $0 )

pwd
set -x

terraform init &&
    terraform plan -out tfplan.bin &&
    terraform show -json ./tfplan.bin > tfplan.json

