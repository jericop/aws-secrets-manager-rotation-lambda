#!/bin/bash

set -euo pipefail

registry_repo="$1"

for row in $(cat images.json | jq -r '.folders[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }

  folder=$(_jq '.folder')
  system_packages=$(_jq '.install_system_packages') # returns 'null' if key is not present
  python_packages=$(_jq '.python_packages')         # returns 'null' if key is not present
  tag=$(_jq '.tag')
  
  cp Dockerfile $folder
  
  docker buildx build \
    --build-arg "system_packages=$system_packages" \
    --build-arg "python_packages=$python_packages" \
    --platform linux/amd64,linux/arm64 \
    --tag "$registry_repo:$tag" \
    --push  $folder 
  
  rm $folder/Dockerfile
  
done