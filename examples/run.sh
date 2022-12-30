#!/bin/bash

# Input params
#1 PQL environment definition json 
#2 PQL program file
#3 PQL endpoint URL

curl -H "content-type: application/json" -X POST  \
--data '{"vars": "'$(cat $1 | base64 )'", "pql": "'$(cat $2 | base64 )'"}' $3 
