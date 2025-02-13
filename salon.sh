#! /bin/bash

# Set up PSQL variable
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Function to display available services
display_services() {
    echo -e "\nAvailable Services:"
    $PSQL "SELECT service_id, name FROM services ORDER BY service_id;" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
}

# Prompt user to select a service
while true; do
    display_services
    echo -e "\nEnter the service ID you would like:"
    read SERVICE_ID_SELECTED

    # Check if the service exists
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | xargs)
    if [[ -n "$SERVICE_NAME" ]]; then
        break
    else
        echo -e "\nInvalid selection. Please choose a valid service."
    fi
done

# Prompt for phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)

# If customer doesn't exist, ask for their name and add to the database
if [[ -z "$CUSTOMER_NAME" ]]; then
    echo -e "\nYou're a new customer! Please enter your name:"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
fi

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)

# Prompt for appointment time
echo -e "\nEnter the time for your appointment:"
read SERVICE_TIME

# Insert appointment into the database
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Confirm appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
