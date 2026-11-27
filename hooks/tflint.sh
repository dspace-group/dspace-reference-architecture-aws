#!/bin/sh
[ ! -d ".tflint.d" ] && tflint --init
tflint --recursive
