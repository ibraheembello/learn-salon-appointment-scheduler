#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Display services
DISPLAY_SERVICES() {
  echo -e "\nAvailable Services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Main script
MAIN_MENU() {
  echo -e "\n~~~~~ Welcome to the Salon Appointment Scheduler ~~~~~"
  DISPLAY_SERVICES
  echo -e "\nEnter the service ID you would like to book:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nInvalid service ID. Please try again."
    MAIN_MENU
  else
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nYou are not in our system. Please enter your name:"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    echo -e "\nEnter the time for your appointment (e.g., 10:30):"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
