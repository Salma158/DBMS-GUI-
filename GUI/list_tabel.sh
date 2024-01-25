#!/bin/bash


function show_warning() {
  zenity --warning --title="Warning" --text="<span font='25' foreground='red'>$1</span>" --width=500
}

if [ ! -d "database" ]; then

  show_warning "No databases yet"
  ./connectToDatabase
  exit
else

  tables_folder="database/$1"
  if [ ! -d "$tables_folder" ] || [ -z "$(ls -A "$tables_folder")" ]; then
    show_warning "No tables found in the database '$1'."
    ./connectToDatabase
    exit
  else
    tables=$(ls "$tables_folder" | grep -v "_meta$")

    if [ -n "$tables" ]; then

      echo -e "Already existing Tables:\n$tables" >/tmp/result.txt
      zenity --text-info --title="Query Result" --filename="/tmp/result.txt" --cancel-label="Back" --width=500 --height=400

      ./connectToDatabase
      exit
    else
      show_warning "No tables found in the database '$1'."
      ./connectToDatabase
      exit
    fi
  fi
fi
