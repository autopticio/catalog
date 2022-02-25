## Getting started with programmable assessments 
Autoptic PQL is a functional language for timeseries data analysis. Here is a simple example with AWS Cloudwatch.
```
//query cloudwatch and get instance CPU utilization for the last hour
where("$cw_aws")
.what("CPUUtilization; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'")
.when("1h")
        .alias("$where[0].what[0].when[0]").as("ts_cpu")

//compute the 15th and 99th percentile summary statistics
.percentile("$ts_cpu;0.15;0.99").as("perc_cpu")

//print the percentile values, and all cpu timeseries data points.
.print("$perc_cpu","$ts_cpu")
        .out("cloudwatch_results.json")
```
PQL programs are executed through the Autoptic API. [Get a free endpoint]() and follow the steps to run the example.

#### 1 Configure access to AWS Cloudwatch

Create a local env.json file and add the contents below or [download the template](./examples/env_cw.json).
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

#### 2 Edit and save the PQL program
[Download the example](./examples/simple.pql) and change the query parameters in the "what" function to match an object in your AWS resources. The sample query is looking up "CPUUtilization" of an EC2 instance. [Check the full Cloudwatch metrics list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html) for more options.

#### 3 Run the program through your endpoint and check the results

## Autoptic Architecture
PQL programs are edited locally and posted through a secure API endpoint to the Autoptic PQL runtime where code is executed. The runtime will get timeseries data from the remote sources configured in the program and return the computed results to the requesting client.  
![alt text](https://www.autoptic.io/assets/img/architecture_logical.png)

## PQL Program Structure
![alt text](https://www.autoptic.io/assets/img/pql_structure.png)
### Query
Query functions describe data inputs from the data sources.

[where](#where) [what](#what) [when](#when) [window](#window) [open](#open) [as](#as) [alias](#alias)

### Aggregate
Aggregate functions handle timeseries data reduction or aggregation.
filter,merge
### Compute
Compute functions allow computing simple or more complex math. 
average,min,max,[count](#count),percentile,math
### Output
Output functions direct how the resulting output will be handled.
assert,sort,head,tail,print,out
### Data Source Reference
Data source references specify which data sources will be used from the environment definition.
cloudwatch,prometheus
		
## Functions
#### alias
#### as
#### assert
#### average
#### count
#### head
#### filter
#### math
#### max
#### merge
#### min
#### open
#### out
#### percentile
#### print
#### sort
#### tail
#### window
#### what
#### when
#### where 

## Example programs

## API Reference
