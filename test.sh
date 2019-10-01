#!/bin/bash

cd $(dirname $BASH_SOURCE[0])

files=`find tests/ -name "*_test.lua"`

for file in $files; do
    echo "testing $file"
    lua5.1 -l init $file
    if [ $? -ne 0 ]; then
        echo "error"
        exit 1
    fi
done

echo "all tests passed"