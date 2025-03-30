#!/bin/bash
p=`/home/brmlab/brmbar/brmbar3/brmbar-cli.py userlog "$1" yesterday`

if [ -n "$p" ]; then
  echo "$p" | mail -s "brmbar report" "$2"
fi
