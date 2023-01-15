#!/bin/bash

PQL_PROGRAM=$1

if [ -z "$AUTOPTIC_EP" ] || [ -z "$PQL_PROGRAM" ] || [ -z "$AUTOPTIC_ENV" ]
then
	echo "Missing inputs: AUTOPTIC_ENV or AUTOPTIC_EP environment variables were not set, or a PQL program  was not provided as an input parameter."
	echo "example ..."
else
curl -H "content-type: application/json" -X POST  \
--data '{"vars": "'$(cat $AUTOPTIC_ENV | base64 )'", "pql": "'$(cat $PQL_PROGRAM | base64 )'"}' $AUTOPTIC_EP 
fi

