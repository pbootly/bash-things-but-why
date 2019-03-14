#!/usr/bin/env bash

# A convergent series expressed as
# 1 - 1/3 + 1/5 - 1/7 + 1/9 -... = pi/4

# The higher the number of terms, the greater the accuract - though
# comutationally this convergence occurs very slowly.

if [ ! -z $1 ]; then
  terms=$1
else
  terms=100
fi

if [ ! -z $2 ]; then
  places=$2
else
  places=100
fi

genSeq () {
  sequence=$(seq -f '4/%g' 1 2 $((terms * 2)))
  for i in $sequence; do
    echo $i
  done
}

format=$(genSeq | paste -sd-+)
result=$(echo "scale=$places; $format" | bc -l)
echo $result
