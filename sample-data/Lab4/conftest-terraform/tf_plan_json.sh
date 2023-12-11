#!/usr/bin/env bash

cd $( dirname $0 )

die() { echo "$0: die - $*" >&2; exit 1; }

pwd
[ -f tfplan.json ] && die "Exiting - tfplan.json already exists"

set -x

terraform init &&
    terraform plan -out tfplan.bin &&
    terraform show -json ./tfplan.bin > tfplan.json

