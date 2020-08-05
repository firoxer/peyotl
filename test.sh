#!/bin/bash

cd $(dirname $BASH_SOURCE[0])

if [ $# -eq 0 ]; then
  files=`find src/ -name "*_test.lua"`

  for file in $files; do
      echo "testing $file"
      lua5.2 -l init $file
      if [ $? -ne 0 ]; then
          echo "error"
          exit 1
      fi
  done

  echo "all tests passed"
elif [ $# -eq 1 ]; then
    echo "testing $1"
    lua5.2 -l init $1
    if [ $? -ne 0 ]; then
        echo "error"
        exit 1
    fi

  echo "tests passed for $1"
fi
