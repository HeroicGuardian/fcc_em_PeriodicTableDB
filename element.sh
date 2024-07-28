#!/bin/bash

# If the user didn't give an argument, the database-searching code isn't activated.
if [[ -z $1 ]]
then
  # Give the user a guiding message.
  echo Please provide an element as an argument.
else
  # Contain the database query preface within a variable.
  PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

  # Enter all the data within the 'element' table into a variable.
  ELEMENT_TABLE_DATA=$($PSQL "SELECT * FROM elements ORDER BY atomic_number")

  # Set up the main loop's incrementing variable.
  I=0

  # Loop through the data from the 'element' table, trying to find if the user's argument matches an element within the database.
  echo "$ELEMENT_TABLE_DATA" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
  do
    # Check if the user entered an element's atomic number, symbol, or name as their argument. If a match is found, an informational message about the element is echoed to the temrinal.
    if [[ $1 == $ATOMIC_NUMBER || $1 == $SYMBOL || $1 == $NAME ]]
    then
      # Find the row within the 'properties' table that belongs to the matched element, and store it in a variable.
      ELEMENT_PROPERTIES=$($PSQL "SELECT * FROM properties WHERE atomic_number=$ATOMIC_NUMBER")

      # Enter a one-cycle read loop that extracts the important information from the recently-stored row, stores those pieces of information into variables, and uses those variables to put together the informational message.
      echo "$ELEMENT_PROPERTIES" | while read REPEAT_VARIABLE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE_ID
      do
        # Search for the matched element's type within the 'types' table, enter it into a variable.
        RAW_TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
        # Remove any extra spaces at the beginning or end of the 'type' variable's text value, and store that cleaned-up version in a new variable.
        TYPE=$(echo "$RAW_TYPE" | sed -E 's/^ *| *$//g')

        # Echo the informational message for the matched element to the terminal.
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
      
      # Exit the main loop and end the script.
      break
    fi

    # Count the loop cycle that has just finished by incrementing the 'I' variable.
    (( I++ ))
    # Check if the number of loop cycles that have occurred is equivalent to the number of rows in the 'element' table, so the user is given a message regarding their inquiry's failure just before the script ends.
    # If the check turns out true, it means that the while loop is about to finish without the user's argument having been matched to an element in the database, which indicates that the user entered something that isn't in the database.
    if [[ $I == $(echo "$ELEMENT_TABLE_DATA" | wc -l) ]]
    then
      # Give the user a clarifying message regarding the failure of their inquiry.
      echo "I could not find that element in the database."
    fi
  done
fi