#!/bin/bash

function show_warning() {
  zenity --warning --title="Warning" --text="<span font='25' foreground='red'>$1</span>" --width=500
}

if [ ! -d "database" ]; then

  show_warning "No databases yet"
  ./main
  exit
else

  existing_databases=$(ls -F "database" 2>/dev/null | grep / | tr / " ")

  if [ $? -eq 1 ]; then
    ./main
    exit
  fi

  if [ -n "$existing_databases" ]; then

    echo -e "Already existing databases:\n$existing_databases" >/tmp/result.txt
    zenity --text-info --title="Query Result" --filename="/tmp/result.txt" --cancel-label="Back" --width=500 --height=400
    ./main
    exit
  else
    show_warning "No databases yet."
    ./main
    exit
  fi
fi
