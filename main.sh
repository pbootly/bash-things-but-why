#!/usr/bin/env bash

# Simple function to handle unrecoverable failures and exit the service
fail () {
  FailMsg=$*
  log $FailMsg
  exit 1 
}

# Simple logging function. If no logfile found in config - stdout used
log () {
  # Try and datetime the message
  LogMsg=$*
  LogTime=$(date '+%Y-%m-%d %H:%M:%S') || LogTime=false
  if [ "$LogTime" != false ]; then
    FullMsg="$LogTime $LogMsg"
  else
    FullMsg="$LogMsg"
  fi

  # Confirm if logfile is used or stdout
  if [ -z $LogFile ]; then
    echo -e $FullMsg
  else
    echo -e $FullMsg > $LogFile 2>&1
  fi
}

api () {
  nc -vvlp $port >> "$TmpFile" 2>&1
}

# Data functions
get_ip() {
  cat "$TmpFile"
  # This is some nasty sed. Regex not super fast but it's working so...
  # Note - this will fail from localhost, as netcat gives a different message
  # however if you're on the machine you need the IP info from, probably use
  # system tools...
  REMOTEADDR=$(grep -i connection "$TmpFile" | awk '{print $3}' | sed 's/\(\[\|\]\)//g')
}

get_req_time() {
  REQTIME=$(date)
}

send_reply() {
  echo -e "HTTP/1.1 200 OK\r\n$(date)\r\n\r\n{time: \"${REQTIME}\", ip: \"${REMOTEADDR}\"" 
}

clean_tmp() {
  echo -e "" > $TmpFile
}

# Load configuration file
if [ -f "./config" ]; then
  source "./config"
else
  fail "Unable to find configuration file at \"./config\""
fi

# TODO: Confirm binaries used. Netcat, curl etc.

if [ -z $port ]; then
  port=80
fi

if [ -z $TmpFile ]; then
  TmpFile="/tmp/bash_net_api.tmp"
fi


# Main loop
while true; do
  # Get the time of the request, the IP of the remote host
  # TODO: Add more metrics and information
  
  # Using co-processes to await process end. Ideally replace tmpfile with ins and outs (reading) coprocs output.
  #This is pretty gross but works fairly reliably.
  coproc (api)
  {
    get_ip
    get_req_time
    send_reply
    clean_tmp
  } <&${COPROC[0]} >&${COPROC[1]}
  wait "$COPROC_PID"
done
exit 0
