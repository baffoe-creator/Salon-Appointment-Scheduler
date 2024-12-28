#!/bin/bash

# Database connection parameters
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services
display_services() {
    echo "Welcome to the Salon. Here are the services we offer:"
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
}

# Main booking function
book_appointment() {
    # Display services
    display_services

    # Prompt for service
    while true; do
        echo -e "\nWhich service would you like to book?"
        read SERVICE_ID_SELECTED

        # Validate service
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        SERVICE_NAME=$(echo "$SERVICE_NAME" | sed -E 's/^ *| *$//g')
        
        if [[ -z $SERVICE_NAME ]]
        then
            # Invalid service, show services again
            display_services
            continue
        else
            break
        fi
    done

    # Prompt for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # If customer doesn't exist, get name and insert
    if [[ -z $CUSTOMER_ID ]]
    then
        echo -e "\nI don't have a record for that phone number. What's your name?"
        read CUSTOMER_NAME

        # Insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        
        # Get the new customer ID
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
        # Customer exists, get name
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -E 's/^ *| *$//g')
    fi

    # Prompt for time
    echo -e "\nWhat time would you like your $SERVICE_NAME?"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Confirm appointment
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Run the booking function
book_appointment