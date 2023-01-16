#!/bin/bash

AUTOPTIC_HOME=~/autoptic
AUTOPTIC_RUN=$AUTOPTIC_HOME/run
AUTOPTIC_ENV=$AUTOPTIC_HOME/env.json
AUTOPTIC_PQL=$AUTOPTIC_HOME/demo.pql

curl -s --create-dirs -o $AUTOPTIC_RUN "https://raw.githubusercontent.com/autopticio/catalog/main/examples/run"
curl -s --create-dirs -o $AUTOPTIC_ENV "https://raw.githubusercontent.com/autopticio/catalog/main/examples/env_cw.json"
curl -s --create-dirs -o $AUTOPTIC_PQL "https://raw.githubusercontent.com/autopticio/catalog/main/examples/demo.pql"

echo "-------------------------------------------------------------------------------------"
echo "Let's run your first PQL program with Amazon CloudWatch!"
echo "1. Add your AWS keys with CloudWatch access to $AUTOPTIC_ENV"
echo "2. Take a look at $AUTOPTIC_PQL, a simple PQL program to query EC2 CPUUtilization"
echo "3. Execute the command below to run the PQL program"
echo ""
echo "export AUTOPTIC_EP=$AUTOPTIC_EP && AUTOPTIC_ENV=$AUTOPTIC_ENV && sh $AUTOPTIC_RUN $AUTOPTIC_PQL"
echo ""
echo "4. You can get more examples and docs from the Autoptic public repo https://github.com/autopticio/catalog"
echo "5. Let us know what you think at support@autoptic.com! Happy PQL-ing!"
echo "-------------------------------------------------------------------------------------"
