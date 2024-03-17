AUTOPTIC_HOME=~/autoptic
AUTOPTIC_RUN=$AUTOPTIC_HOME/run
AUTOPTIC_ENV=$AUTOPTIC_HOME/env.json
AUTOPTIC_PQL=$AUTOPTIC_HOME/demo.pql
AUTOPTIC_TRUN=/tmp/run

curl -s --create-dirs -o $AUTOPTIC_TRUN "https://raw.githubusercontent.com/autopticio/catalog/main/examples/_core/run"
curl -s --create-dirs -o $AUTOPTIC_ENV "https://raw.githubusercontent.com/autopticio/catalog/main/examples/_core/env_template.json"
curl -s --create-dirs -o $AUTOPTIC_PQL "https://raw.githubusercontent.com/autopticio/catalog/main/examples/_core/demo.pql"
echo "AUTOPTIC_EP=$AUTOPTIC_EP" > $AUTOPTIC_RUN
echo "$(cat $AUTOPTIC_TRUN)" >> $AUTOPTIC_RUN
chmod u+x $AUTOPTIC_RUN
rm $AUTOPTIC_TRUN

echo "-------------------------------------------------------------------------------------"
echo "Let's get started!"
echo "1. Add your AWS keys with CloudWatch access to $AUTOPTIC_ENV"
echo "2. Run a simple demo PQL program to query EC2 CPUUtilization from CloudWatch and chart the results:"
echo ""
echo "$AUTOPTIC_RUN $AUTOPTIC_PQL"
echo ""
echo "3. Find more examples and docs in our public repo https://github.com/autopticio/catalog"
echo "Happy PQL-ing!"
echo "-------------------------------------------------------------------------------------"
