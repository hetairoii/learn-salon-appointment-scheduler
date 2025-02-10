#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Function to display services
display_services() {
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Function to get service name by ID
get_service_name() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
  echo $SERVICE_NAME | sed 's/^ *//;s/ *$//'
}

# Main loop
while true; do
  display_services
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$(get_service_name $SERVICE_ID_SELECTED)

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nI could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    break
  fi
done