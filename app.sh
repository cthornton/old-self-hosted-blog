#!/bin/bash

case "$1" in
"start")
  export NODE_ENV=production
  forever start index.js
  exit 0
  ;;
"stop")
  forever stopall
  exit 0
  ;;
*)
  echo "Invalid command"
  exit 1
  ;;
esac
