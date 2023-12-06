#!/usr/bin/env bash

set -x
opa eval --format raw -d sites.json -d sites_1.rego  'data.play.all_hosts' 
