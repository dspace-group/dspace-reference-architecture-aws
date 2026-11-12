#!/bin/sh
#[ ! -d ".terraform" ] && terraform init || echo "skipping terraform init"
# Fresh data dir inside the container, so the workspace's .terraform is never read or modified
export TF_DATA_DIR="$(mktemp -d)"
terraform init -backend=false
terraform validate
