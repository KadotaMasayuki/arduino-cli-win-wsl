#!/bin/bash

project_dir="$(basename $(pwd))"
target_dir="${HOME}/Arduino/build/${project_dir}"
fqbn=m5stack:esp32:m5stack_core2

echo $target_dir

mkdir -p $target_dir
arduino-cli compile \
        --fqbn $fqbn \
        --build-path $target_dir

