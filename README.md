# Doc 

## Getting started with programmable assessments 
Autoptic PQL is a functional language for timeseries data analysis. Here is a simple example for collecting CPU statistics from AWS Cloudwatch and computing the 99th and 15th percentile for the last hour.
```
//query cloudwatch and get CPU utilization
where("$cw_aws")
.what("CPUUtilization; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'")
.when("1h")
        .alias("$where[0].what[0].when[0]").as("ts_cpu")

//compute the 15th and 99th percentile summary statistics for the last hour
.percentile("$ts_cpu;0.15;0.99").as("perc_cpu")

//print the percentile values, and all cpu timeseries data points.
.print("$perc_cpu","$ts_cpu")
        .out("cloudwatch_results.json")
```
PQL programs are executed through the Autoptic API. Get a free endpoint here:

Once you have an endpoint, run through the following steps to execute the example above.
1. Configure access to AWS Cloudwatch

	Create a local env.json file and add the contents below. You can also download the template here.
```
{
  "data":
  [
    {
      "name": "cw_aws",
      "type": "CloudWatch",
      "vars": {
        "AwsRegion": "us-east-1",
        "window": "300s",
        "aws_access_key_id": "",
        "aws_secret_access_key": ""
      }
    }
  ]
}
```
	Add your account credentials in the "aws_access_key_id" and "aws_secret_access_key". The account must have read access to Cloudwatch. For more information check the [AWS guide on access credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) .

2. Edit and save the PQL program
3. Run the program through your endpoint and check the results

## Autoptic Architecture

## Understanding PQL
PQL Program
<Explanation>
<program structure diagram>
				
### Sources
cloudwatch,prometheus
### Query
where,what,when,window, open, as
### Aggregation
filter, merge
### Computation
average, min, max, count, percentile,math
### Results
assert, sort,head,tail,print,out
		
## Functions
purpose | params | sample

## Example programs

## API Reference
