#!/bin/bash

AUTOPTIC_HOME=~/autoptic
AUTOPTIC_RUN=$AUTOPTIC_HOME/run.sh
AUTOPTIC_ENV=$AUTOPTIC_HOME/env.json
AUTOPTIC_PQL=$AUTOPTIC_HOME/simple.pql

curl -s --create-dirs -o $AUTOPTIC_RUN "https://raw.githubusercontent.com/autopticio/catalog/main/examples/run.sh"
curl -s --create-dirs -o $AUTOPTIC_ENV "https://raw.githubusercontent.com/autopticio/catalog/main/examples/env_cw.json"
curl -s --create-dirs -o $AUTOPTIC_PQL "https://raw.githubusercontent.com/autopticio/catalog/main/examples/simple.pql"

echo "-------------------------------------------------------------------------------------"
echo "Let's run your first PQL program with Amazon CloudWatch!"
echo "1. Add your AWS keys with CloudWatch access to $AUTOPTIC_ENV"
echo "2. Take a look at $AUTOPTIC_PQL, a simple PQL program to query EC2 CPUUtilization"
echo "3. Execute the command below to run the PQL program"
echo "sh $AUTOPTIC_RUN $AUTOPTIC_ENV $AUTOPTIC_PQL $AUTOPTIC_EP"
echo ""
echo "4. You can get more examples and docs from the Autoptic public repo https://github.com/autopticio/catalog"
echo "5. Let us know if what you think support@autoptic.com! Happy PQL-ing!"
echo "-------------------------------------------------------------------------------------"
