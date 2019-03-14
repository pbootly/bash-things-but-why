#!/usr/bin/env bash

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
  sequence=$(seq 1 2 $((terms * 2)) | xargs -n1 -I{} echo '16*(1/5)^{}/{}-4*(1/239)^{}/{}')
  for i in $sequence; do
    echo $i
  done
}

format=$(genSeq | paste -sd-+)
result=$(echo "scale=$places; $format" | bc -l)
echo $result
