#!/bin/bash

if [ ! -d "database" ]; then
  mkdir "database"
  zenity --info --text="Created database folder."  --width=500
fi

function show_success() {
  zenity --info --title="Success" --text="<span font='25' foreground='green'>$1</span>" --width=500
}
function show_warning() {
  zenity --warning --title="Warning" --text="<span font='25' foreground='red'>$1</span>" --width=500
}

function createDB() {

  dbname=$(zenity --entry --title="Enter Database Name" --text="Please enter a valid database name :" --width=500)

  if [ $? -eq 1 ]; then
    ./main
    exit
  fi

  if [ -z "$dbname" ]; then
    show_warning "Error: You entered an empty name. Please enter a proper name."
    createDB
    return
  fi

  if [[ $dbname == *' ' || $dbname == *' '* ]]; then
    show_success "Warning: Spaces in the name have been replaced with underscores."
    dbname=$(echo "$dbname" | tr ' ' '_')
    show_success "New name: $dbname"
  fi

  if [[ $dbname == [0-9]* ]]; then
    show_warning "Error: The name should not start with numbers."
    createDB
    return
  fi

  if [[ $dbname == *[!a-zA-Z0-9_]* ]]; then
    show_warning "Error: The name should not contain special characters."
    createDB
    return
  fi

  dbpath="database/$dbname"
  if [ -n "$(find "database" -type d -name "$dbname" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
    show_warning "Error: Database '$dbname' already exists in database.\nExisting databases:\n$(ls -1 "database")"
    ./main
    exit
  else
    mkdir -p "$dbpath" && show_success "Success: Database directory '$dbname' created."
    ./main
    exit
  fi
}

createDB
