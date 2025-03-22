#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAKE_HAIR_APPOINTMENT(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n~~ Welcome to My Salon, how can I help you?  ~~\n"
  SERVICES=$($PSQL "SELECT name, service_id FROM services")
  if [[ -z $SERVICES ]]
  then
    MAKE_HAIR_APPOINTMENT "No services found, contact the IT support"
  else
    echo "$SERVICES" | while read NAME BAR SERVICE_ID
    do
      echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      IS_SERVICE_IN_DB=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $IS_SERVICE_IN_DB ]]
      then
        MAKE_HAIR_APPOINTMENT "No valid service selected "
      else
        SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        echo "What's your phone number?"
        read CUSTOMER_PHONE
        IS_CUSTOMER_PHONE_IN_DB=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ -z $IS_CUSTOMER_PHONE_IN_DB ]]
        then
          echo "I don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          CUSTOMER_IN_DB=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
          
          if [[ $CUSTOMER_IN_DB == 'INSERT 0 1' ]]
          then
            echo "Customer: $CUSTOMER_NAME registered"
          fi

          echo "What time would you like your$SERVICE_SELECTED, $CUSTOMER_NAME?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
          SET_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
          if [[ $SET_APPOINTMENT == 'INSERT 0 1' ]]
          then
            echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
        else
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          echo "What time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
          read SERVICE_TIME
          SET_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
          echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
        fi

      fi
    else 
      MAKE_HAIR_APPOINTMENT "Sorry, that is not a valid number"
    fi
  fi
}



MAKE_HAIR_APPOINTMENT


