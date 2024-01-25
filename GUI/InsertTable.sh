#!/bin/bash

source validateDataType
source validateConstraint


function show_success() {
  zenity --info --title="Success" --text="<span font='25' foreground='green'>$1</span>" --width=500
}
function show_warning() {
  zenity --warning --title="Warning" --text="<span font='25' foreground='red'>$1</span>" --width=500
}

function insert() {
  metaData=$(awk 'BEGIN {FS=":"} {print $0}' "./database/$1/${2}_meta")
  counter=1

  for x in $metaData; do
    colName=$(echo "$x" | cut -d ":" -f 1)
    dataType=$(echo "$x" | cut -d ":" -f 2)
    constraints=$(awk -F: -v target="$counter" '{if (NR == target) for (i=3; i<=NF; i++) {print $i}}' "./database/$1/${2}_meta")

    while true; do
      value=$(zenity --entry --title="Insert Data" --text="Insert data for column $colName" --width=500)

      if [ $? -eq 1 ]; then
         sed -i '$d' "./database/$1/$2"
        ./connectToDatabase
        exit
      fi

      if [ -z "$value" ]; then
        value="_"
      fi
      

      isValidDataType "$value" $dataType
      DTvalid=$?
   

      if [[ $DTvalid -eq 1 ]]; then
        constraintValid=1
        if [[ $constraints != "" ]]; then
          for i in $constraints; do
            validateConstraints $counter "$value" $1 $2 $i
            constraintValid=$?
            if [[ $constraintValid -eq 0 ]]; then
              break
            fi
          done
        fi

        if [[ $constraintValid -eq 1 ]]; then
          if [[ $counter -eq 1 ]]; then
            echo -n "$value" >>"./database/$1/$2"
          else
            echo -n ":$value" >>"./database/$1/$2"
          fi
          break
        else
          show_warning "Invalid value: violates the constraints of the column\nTry again!"
        fi
      else
        show_warning "Invalid value data type: violates the data type of the column\nTry again!"
      fi
    done

    ((counter++))
  done

  echo -e -n "\n" >>"./database/$1/$2"
  show_success "Successfully inserted data inside the table"
  ./connectToDatabase
  exit
}

directory="./database/$1"

if [ -z "$(ls -A $directory)" ]; then
  show_warning "The database is empty."
  ./connectToDatabase
  exit
else
  tables=($(ls -F "./database/$1" | grep -v / | grep -v "_meta$"))
  selectedTable=$(zenity --list --title="Select Table" --text="Select a table from the list to insert into :" --column="Tables" "${tables[@]}" --width=500 --height=400)

  if [ $? -eq 1 ]; then
    ./connectToDatabase
    exit
  fi

  if [ -f "./database/$1/$selectedTable" ]; then
    insert $1 "$selectedTable"
  else
    show_warning "There is no table with this name in the database!"
  fi
fi
