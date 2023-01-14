#!/bin/bash

# Input params
#1 PQL environment definition json 
#2 PQL endpoint URL
#3 PQL program file
AUTOPTIC_EP="AUTOPTIC_EP_VAL"

curl -H "content-type: application/json" -X POST  \
--data '{"vars": "'$(cat $1 | base64 )'", "pql": "'$(cat $3 | base64 )'"}' $2 
