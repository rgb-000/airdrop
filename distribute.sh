#!/bin/bash

RPC_HOST=${3:-"https://api.devnet.solana.com/"}
STARTINDEX=${1:-0}

TOKEN_LIST_FILE="mints.txt"
RECIPIENT_LIST_FILE="addresses.txt"
OUTFILE="sent.txt"

TOKEN_LIST=()
while IFS= read -r line; do
   TOKEN_LIST+=("$line")
done <${TOKEN_LIST_FILE}

RECIPIENT_LIST=()
while IFS= read -r line; do
   RECIPIENT_LIST+=("$line")
done <${RECIPIENT_LIST_FILE}

if [ "${#TOKEN_LIST[@]}" -ne "${#RECIPIENT_LIST[@]}" ]; then
    echo "Recipient Length: ${#RECIPIENT_LIST[@]} is not equal to Minted Tokens Length: ${#TOKEN_LIST[@]}"
    echo "Do you wish to continue?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes )break;;
        No ) exit;;
    esac
done

fi

if [ "${#TOKEN_LIST[@]}" -lt "${#RECIPIENT_LIST[@]}" ]; then
    LOOP_COUNT=${#TOKEN_LIST[@]}
else
    LOOP_COUNT=${#RECIPIENT_LIST[@]}
fi


for (( i=$STARTINDEX; i<${LOOP_COUNT}; i++ ));
do
  TOKEN_MINT_ADDRESS=${TOKEN_LIST[$i]}
  RECIPIENT=${RECIPIENT_LIST[$i]}
  TOKEN_ACCOUNT_ADDRESS=$(spl-token accounts --output json | jq ".accounts[] | select(.mint==\"${TOKEN_MINT_ADDRESS}\") | .address" | sed s/\\\"//g)

  echo ""
  echo "${i}: spl-token transfer ${TOKEN_MINT_ADDRESS} 1 ${RECIPIENT} --from ${TOKEN_ACCOUNT_ADDRESS} --url ${RPC_HOST} --fund-recipient --allow-unfunded-recipient | tee -a ${OUTFILE}"
  echo ""

  spl-token transfer ${TOKEN_MINT_ADDRESS} 1 ${RECIPIENT} --from ${TOKEN_ACCOUNT_ADDRESS} --url ${RPC_HOST} --fund-recipient --allow-unfunded-recipient | tee -a ${OUTFILE} 
done

echo ""
echo "All done. Transactions stored to ${OUTFILE}"
