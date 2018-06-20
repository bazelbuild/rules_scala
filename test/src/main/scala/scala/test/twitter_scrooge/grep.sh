#!/bin/sh

if grep -q $1 $2 ; then
  echo "ERROR: found $1"
  exit 1
else
  exit 0
fi
