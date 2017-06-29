#!/bin/sh

OUTPUT1=`$1 $2 | grep DSA`
OUTPUT2=`$1 $2 | grep RSA`

if [[ $OUTPUT1 ]]; then
  echo $OUTPUT1
  exit 1
fi
if [[ $OUTPUT2 ]]; then
  echo $OUTPUT2
  exit 1
fi
