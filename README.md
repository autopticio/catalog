## Getting started with programmable assessments 
Autoptic PQL is a functional language for time-series data analysis. Here is a simple example with Amazon CloudWatch.
```
//query cloudwatch and get instance CPU utilization for the last hour
where(@cw_aws)
.what("MetricName='CPUUtilization';InstanceId='i-a0f8880d7a4d502db'; Namespace='AWS/EC2'")
.when(1h)
        .request($where[0];$what[0];$when[0]).as($ts_cpu)

//compute the 15th and 99th percentile summary statistics
.percentile($ts_cpu;0.15;0.99).as($perc_cpu)

//print the percentile values, and all cpu timeseries data points.
.print($perc_cpu ; $ts_cpu)
        .out("cloudwatch cpu results")
```

Follow the steps below to run the example program.

#### 1. Configure access to Amazon CloudWatch

Create a local env.json file and add the contents below or [download the template](./examples/env_template.json).
```
{
  "where":
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
Add your account credentials in the "aws_access_key_id" and "aws_secret_access_key". The account must have read access to CloudWatch. For more information check the [AWS guide on access credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html). Autoptic does not cache or store the credentials you submit over the API.

#### 2. Edit and save the PQL program
[Download the example](./examples/simple.pql) and change the query parameters in the "what" function to match an object in your AWS resources. The sample query is looking up "CPUUtilization" of an EC2 instance. [Check the full CloudWatch metrics list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html) for more options. Check out the [example programs](./examples/) for more ideas on how to use PQL for more programmable assessments. 

#### 3. Run the program through your endpoint and check the results
[Signup and activate an Autoptic endpoint](https://www.autoptic.io/#signup).

The simple script below illustrates how to submit a program to the Autoptic API. You can also [download the script from the examples](./examples/run).
```
#!/bin/bash

# Input params
#1 PQL environment definition json 
#2 PQL endpoint URL
#3 PQL program file

curl  -H "content-type: application/json" -X POST  \
--data '{"vars": "'$(cat $1 | base64 )'", "pql": "'$(cat $3 | base64 )'"}' $2
```

Substitute the URL in the example with the endpoint URL you received and run the script as follows: `sh run env.json https://autoptic.io/pql/ep/007/run simple.pql` 

Here the response you would expect in a json format: [Sample results](./examples/sample_result.json)

#### 4. Install the vscode Autoptic extension 

## Autoptic Architecture
PQL programs are edited locally and posted through a secure API endpoint to the Autoptic PQL runtime where code is executed. The runtime will get timeseries data from the remote sources configured in the program and return the computed results in html or json to the requesting client.  
![alt text](https://www.autoptic.io/assets/img/architecture_logical.png)

## PQL Program Structure
![alt text](https://www.autoptic.io/assets/img/pql_structure.png)
### Query
Query functions describe data inputs from the data sources:

[3w's](#3ws) | [where](#where) | [what](#what) | [when](#when) | [window](#window) | [open](#open) | [as](#as) | [request](#request)

### Aggregate
Aggregate functions handle timeseries data reduction or aggregation:

[filter](#filter) | [merge](#merge)

### Compute
Compute functions allow computing simple or more complex statistics: 

[average](#average) | [min](#min) | [max](#max) | [count](#count) | [percentile](#percentile) | [assert](#assert) | [math](#math) | [correlate](#correlate)

### Output
Output functions direct how the resulting output will be handled:

[sort](#sort) | [head](#head) | [tail](#tail) | [print](#print) | [chart](#chart) | [out](#out) 

### Data Source Reference
Data source references specify which data sources will be used from the environment definition:

[cloudwatch](#cloudwatch) | [prometheus](#prometheus)
		
## Functions
#### 3w's
A query consists of 3 required (what,where,when) and 1 optional (window) dimensions. Each combination of dimensions produces a distinct collection that can be used by other functions in the PQL program. Every such collection is automatically labeled with the tuple of dimensions and position index of the parameters referenced.
```
//The following query can produce 8 distinct time-series collections:
where(@cwA, @cwB)
.what(
    "MetricName='CPUUtilization';InstanceId='i-00f8880d7a4d502db'; Namespace='AWS/EC2'";
    "MetricName='NetworkOut'; InstanceId='i-00f8880d7a4d502db'; Namespace='AWS/EC2'"
)
.when(1d, 1h)

//The following collections are labeled as a response matrix.
//Collection1 is composed as where[0].what[0].when[0] for tuple [@cwA][CPUUtilization...][1d]
//Collection2 is composed as where[0].what[0].when[1] for tuple [@cwA][CPUUtilization...][1h]
//Collection3 is composed as where[0].what[1].when[0] for tuple [@cwA][NetworkOut...][1d]
//Collection4 is composed as where[0].what[1].when[1] for tuple [@cwA][NetworkOut...][1h]
//Collection5 is composed as where[1].what[0].when[0] for tuple [@cwB][CPUUtilization...][1d]
//Collection6 is composed as where[1].what[0].when[1] for tuple [@cwB][CPUUtilization...][1h]
//Collection7 is composed as where[1].what[1].when[0] for tuple [@cwB][NetworkOut...][1d]
//Collection8 is composed as where[1].what[1].when[1] for tuple [@cwB][NetworkOut...][1h]
```

#### as
Creates a named time-sieres or a results variable from the results of the preceding function. Variables are used as inputs to other functions.
- parameters: 1 variable name, N dimensions (optional)
- use:
	- Compute the average CPU and print the result
	```
	.average($cpu_timeseries).as($avg_cpu)
	.print($avg_cpu)
	.out("cpu results")
	```
	- Add dimensions to a variable
	```
	.average($cpu_timeseries).as($avg_cpu ; unit='ticks' ; description='cpu metrics')
	.print($avg_cpu")
	.out("cpu results")
	```
---
#### assert
Evaluates if a logical expression is true or false. 
- parameters: 1 logical expression.
- returns: 0 or 1
- use:
	- check if two counters are the same `assert($count_cpu_aws == $count_cpu_prom)`
	- check if CPU is greater than 50% `assert($cpu_avg_utilization > 0.5)`
---
#### average
Computes the average value for a timeseries.
- parameters: 1 time-series variable
- returns: float[] collection
- use:
	- compute the average `average($cpu_utilization)`
---
#### correlate
Computes the number of data points in a time-series.
- parameters: 2 time-series variables
- returns: float number of degree of correlation. 1 is highest correlation to -1 for inverse correlation. Numbers closer to 0 indicate low or no correlation.
- use:
	- compute the number of data points `correlate($cpu_utilization; $memory_utilization).as($resource_correlation)`
---
#### count
Computes the number of data points in a time-series.
- parameters: 1 time-series variable
- returns: float[] collection
- use:
	- compute the number of data points `count("$cpu_utilization")`
---
#### head
Selects the first set of data points from a time-series variable.
- parameters: 1 time-series variable and 1 integer | percent value.
- returns: time-series[] collection
- use: 
	- get the first 15 data points `head($cpu0_user; 15)`
	- get the first 2% of data points `head($cpu0_user; 2%)`
---
#### filter
Selects the time-series matching a logical expression.
- parameters: 1 time-series variable and 1 expression.
- returns: time-series[] collection
- use:
	- Select the time-series that match the 'user' mode for CPU 0 
	```
	filter($cpu_usage ; "{cpu='0' AND mode='user'}")
	``` 
	- Select the time-series that match the 'user' and/or 'system' mode for CPU 0 and/or 1 
	```
	filter($cpu_usage ; "{cpu='0' OR cpu='1'} AND {mode='user' OR mode='system'}")
	``` 
---
#### math
Computes a value from a mathematical expression.
- parameters: 1 math expression. Only variables that contain single values can be provided in the expression.
- returns: float
- use:
	- Sum of the CPU0 user and system utilization. 
	```
	math(($avg_cpu0_user + $avg_cpu0_system))
	```
	- Network Bytes in to out throughput ratio in percent
	```
	math((1 - $net_in/$net_out))
	```
---
#### max
Computes the maximum value for a timeseries.
- parameters: 1 time-series variable
- returns: float[] collection
- use:
	- compute the maximum `max($cpu_utilization)`
---
#### merge
Combines multiple time-series into a single timeseries using an aggregation function.
- parameters: N+1 time-series and 1 aggregation function (min | max | average | sum).
- returns: timeseries[] collection
- use:
	- Merges system and user CPU 0 into a timeseries by adding data points in the same time window.
	```
	merge($avg_cpu0_system; $avg_cpu0_user; sum)
	```
	- Merges the user CPU 0 and 1 into a single time-series by computing the average for data points in the same time window. 
	```
	merge($cpu0_user_case3; $cpu1_user_case3; average)
	```
	- Merges the user CPU 0,1,2,3 into a single time-series based on the max valye for data points in the same time widnow.
	```
	merge($cpu0_user; $cpu1_user; $cpu2_user; cpu3_user; max)
	```
---
#### min
Computes the minimum value for a time-series.
- parameters: 1 time-series variable
- returns: float[] collection
- use:
	- compute the minimum `min($cpu_utilization)`
---
#### open
Opens a saved PQL results resource from a URI.
- parameters: 1 PQL results resource and N+1 variables to select.
- returns: time-series[] collection
- use:
	- open a remote file with PQL results and select which variables will be loaded `.open("https://s3bucketurl/data/aws_saved_results.json;$varA;varB)`
---
#### out
Selects the output destination for the program for all preceding output functions calls. A single program can have multiple out calls.
- parameters: N+1 destinations.
- returns: html or json results.
- use:
	- send results to a single result group `.out("results")`
---
#### percentile
Computes percentile summaries for a time-series.
- parameters: 1 time-series variable and N+1 percentile float attributes.
- returns: float[] collection
- use
	- compute 1st percentile `percentile($aws_cpu;0.01)`
	- compute 15th and 98th percentile `percentile($aws_cpu;0.15;0.98)`
---
#### print
Outputs the contents of the selected variables in json.
- parameters: N+1 time-series variables
- returns: N/A
- use: 
	- output summary and time-series values `print($cnt_aws ; $cnt_prom ; $assert_cnts)`
---
#### request
Creates a variable name for a selection in the response matrix.
- parameters: 1 query matrix selection
- returns: time-series[] collection
- use:
	- Selecting the first and second time periods of the query.
	```
	.request($what[0]; $when[0] ; $where[0]).as($snapshot_A)
	.request($what[0]; $when[1] ; $where[0]).as($snapshot_B)
	```
	- Selecting the second data source and third time window of the query.
	```
	.request($what[0]; $when[0] ; $where[1]; $window[2]).as($snapshot_C)
	```
---
#### sort
Sorts all data points in a timeseries.
- paramertes: 1 time-series[] or 1 aggregate[] variable and 1 integer flag.
- returns: timeseries[] or float[] collection
- use:
	- sort in ascending order `sort($prom_cpu_5m_last30m_filtered; 1)`
	- sort in descending order `sort($prom_cpu_5m_last30m_filtered; 0)`
---
#### tail
Selects the last set of data points from a time-series.
- parameters: 1 time-series variable and 1 integer | percent value.
- returns: time-series[] or float[] collection
- use: 
	- get the last 20 data points `tail($cpu0_user; 20)`
	- get the last 3% of data points `tail($cpu0_user; 3%)`
---
#### window
Selects the granularity of the time-series data retrieved from the data source.
- parameters: N+1 time windows/buckets
- use:
	- 30 second window selection `window(30s)`
	- 5 seconds and 1 hour window selections `window(5s;1h)`
- default: 300s
---
#### what
Defines the query keywords and metadata submitted to the data sources.
- parameters: N+1 queries
- use:
	- get instance Cloudwatch CPU utilization from AWS `what("MetricName='CPUUtilization';InstanceId='i-00f8880d7a4d502db'; Namespace='AWS/EC2'")`
	- get cpu utilization from Prometheus `what("node_cpu_seconds_total")`
	- get multiple Cloudwatch metrics for an AWS EC2 instance
	```
	what(
	  "MetricName='CPUUtilization'; InstanceId='i-00f8880d7a4d502db'; Namespace='AWS/EC2'" ;
	  "MetricName='NetworkOut'; InstanceId='i-00f8880d7a4d502db'; Namespace='AWS/EC2'" ;
	  "MetricName='NetworkIn'; InstanceId='i-00f8880d7a4d502db'; Namespace='AWS/EC2'"
	)	
	```
	- get multiple Cloudwatch metrics using wildcards. Wildcards will match dimension values that contain the literal string preceding the wildcard. Multiple dimensions in a "what" function can be wildcarded. The results will match the union of dimensionsions and values specified.  
	```
	what(
	  //match any metric that contains 'Utilization' across all Namespaces
    	  "MetricName='Utilization*';Namespace='AWS/*'" ;
	  //match any metric that contains 'Utilization' across all Namespaces across all Regions
    	  "MetricName='Utilization*';Namespace='AWS/*';Region='eu-*'" ;
	  //match any metric that contains 'CPU' across all InstanceIds for the EC2 Namespace in us-east-1
    	  "MetricName='CPU*'; InstanceId='*';Namespace='AWS/EC2';Region='us-east-1';Stat='Maximum'" ;
	  //match the 'Latency' metric for APIs that contain 'Autoptic; in the ApiGateway Namespace in eu-west-1
    	  "MetricName='Latency';ApiName='Autoptic*';Namespace='AWS/ApiGateway';Region='eu-west-1'" ;
	  //match any metric that contains 'Latency' for tables that contain 'Endpoint' in DynamoDB Namespace in eu-west-1
    	  "MetricName='Latency*';TableName='Endpoint*';Namespace='AWS/DynamoDB';Region='eu-west-1'" ;
	  //match any metric that contains 'Latency' for tables that contain 'Endpoint' for all operations in DynamoDB Namespace in eu-west-1
    	  "MetricName='Latency*';TableName='Endpoint*';Operation='*';Namespace='AWS/DynamoDB';Region='eu-west-1'"
	)	
	```
	- get metrics from AWS and Prometheus
	```
	what(
	  "MetricName='CPUUtilization';InstanceId='i-00f8880d7a4d502db'; Namespace='AWS/EC2'" ;
	  "node_cpu_seconds_total"
	)
	```
---
#### when
Selects the query time ranges for the program
- parameters:  N+1 time ranges
- use:
	- releative time selection 
		- recent 5 minutes `when(5m)` 
		- recent 1 hour `when(1h)`
		- recent 7 days `when(7d)`
	- absolute time selection
		- start and end date time `when("start = '22-02-2022 00:00:00 +00'; end = '22-02-2022 23:59:59 +00'")`
	- multi selection
		- recent 24 hours and 2-22-22 `when(24h,"start = '22-02-2022 00:00:00 +00'; end = '22-02-2022 23:59:59 +00'")`
---
#### where 
Selects the data sources that will be used in the program from the [data source configuration](#data-sources).
- parameters: N+1 data source references
- use: 
	- 3 data source references `where(@dsA ; @dsB ; @dsC)`

## Data Sources
The environment definition is a global configuration that stores preferences and data source access. Multiple data sources of different types can be configured and used by a PQL program. [download the template](./examples/env_cw.json)
#### cloudwatch
Multiple cloudwatch data sources can be configured in the environment definition. 
- attributes:
	- name: The name that will be referenced by the "where" function in a PQL program.
	- type: CloudWatch
	- vars:
		- AwsRegion: default AWS region that the PQL program will be querying, if "Region" is not specified in 'what'
		- window: default window size if not specified by the "window" function in a PQL program.
		- aws_access_key_id: AWS key that you have to generate through IAM in AWS.
		- aws_secret_access_key: The token token that is paired with the key id above.
```
{
"name": "aws_prod",
"type": "CloudWatch",
"vars": {
	"AwsRegion": "eu-west-1",
	"window": "300s",
	"aws_access_key_id": "<aws_key_id>",
	"aws_secret_access_key": "<key_value>"
	}
}
```
#### prometheus
Multiple Promethues data sources can be configured in the environment definition. 
- attributes:
	- name: The name that will be referenced by the "where" function in a PQL program.
	- type: Prometheus
	- vars:
		- prom_address: The http url for the Prometheus server.
		- window: default window size if not specified by the "window" function in a PQL program.
```
{
"name": "localprom",
"type": "Prometheus",
"vars": {
	"prom_address": "http://192.168.0.15:9090",
	"window": "300s"
	}
}
```

## Example programs
Check out the [example programs](./examples/) for more ideas on how to use PQL for more programmable assessments. 
