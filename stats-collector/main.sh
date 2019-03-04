#!/usr/bin/env bash

source "./config"

#
# DATABASE
#

# ADD
# DEL
# FIND <x> <y> where x is a time before y
# REAP <z> where things older than z are deleted
# SNAP write db out to file
# Yup storing the DB in an array pair - only accepting linear results (no back filling)
# so for what we're doing, [1][1],[2][2],[x][x] is a fair assumption. Its a bash DB...
DBTime=()
DBData=()

# The server takes the timestamp and stores it as that - this allows
# me to ignore handling latency induced issues where a datapoint should
# be placed above another. Don't mess with time - keep it linar
timestamp() {
  echo $(date +%s)
}

ADD() {
  time=$(timestamp)
  datapoint=$1
  DBTime+=($time)
  DBData+=($datapoint)
}

DEL() {
  # Take the index in the array you want to delete
  index=$1
  unset DBData[$index]
  unset DBTime[$index]
}

GETALL() {
  for index in "${!DBData[@]}"; do
    echo "{ "datapoint_$index:" "${DBData[index]}", "time_$index:" "${DBTime[index]}" },"
  done
}

REAP() {
  if [ -z $retention ]; then
    # 30 days default
    retention="2592000"
  fi
  time=$(timestamp)
  rettime=$((time-retention))
  for index in "${!DBTime[@]}"; do
    if [[ "${DBTime[$index]}" -le "${rettime}" ]]; then
      $(DEL $index)
    fi
  done
}


#
# Main
#


countWriter() {
  cn=$1
  cc=$2
  data="channel-${cn}-${cc}"
  ADD $data
}

getChannelCounts() {
  channelId=$1
  channelName=$2
  url="https://www.googleapis.com/youtube/v3/channels?part=statistics&id=${channelId}&key=${ApiKey}"
  count=$(curl -s ${url} | grep subscriberCount | awk -F'["|"]' '{print $4}')
  countWriter $channelName $count
}

getChannelIds() {
  for name in ${channelNames[*]}; do
    url="https://www.googleapis.com/youtube/v3/channels?key=${ApiKey}&forUsername=${name}&part=id"
    id=$(curl -s ${url} | grep id | awk -F'["|"]' '{print $4}')
    getChannelCounts $id $name
  done
}




#
# API
#

while true; do
  getChannelIds
  echo -e "HTTP/1.1 200 OK\n\n $(GETALL)" | nc -l -p 1500
done
