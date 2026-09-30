#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

#função para mostrar as opções do menu
SHOW_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # gera o menu de serviços
  MENU=$($PSQL "SELECT service_id::text || ') ' || name FROM services ORDER BY service_id")

  echo "$MENU"
  read SERVICE_ID_SELECTED
  
  #verifica se o id do serviço existe, caso contrário repete o menu
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE ]]
  then
    SHOW_MENU "I could not find that service. What would you like today?"
  else

    #pede o telefone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # verifica se o cliente está cadastrado, senão pede o nome e cadastra
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi

    #pergunta o horário
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME

    #cria o appointment
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME';")
    APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED');")

    #mensagem final
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

SHOW_MENU