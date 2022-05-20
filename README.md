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
PQL programs are executed through the Autoptic API. [Get a free endpoint](https://www.autoptic.io/#signup) and follow the steps to run the example.

#### 1. Configure access to AWS Cloudwatch

Create a local env_cw.json file and add the contents below or [download the template](./examples/env_cw.json).
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
Add your account credentials in the "aws_access_key_id" and "aws_secret_access_key". The account must have read access to Cloudwatch. For more information check the [AWS guide on access credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html). Autoptic does not cache or store the credentials you submit over the API.

#### 2. Edit and save the PQL program
[Download the example](./examples/simple.pql) and change the query parameters in the "what" function to match an object in your AWS resources. The sample query is looking up "CPUUtilization" of an EC2 instance. [Check the full Cloudwatch metrics list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html) for more options. Check out the [example programs](./examples/) for more ideas on how to use PQL for more programmable assessments. 

#### 3. Run the program through your endpoint and check the results
You will need an active endpoint to run PQL programs. [Signup for an endpoint.](https://www.autoptic.io/#signup).

The run.sh script below illustrates how to submit a program to the Autoptic API.
```
#!/bin/bash

# Input params
#1 PQL environment definition json 
#2 PQL program file
#3 PQL endpoint URL

curl  -H "content-type: application/json" -X POST  \
--data '{"vars": "'$(cat $1 | base64 )'", "pql": "'$(cat $2 | base64 )'"}' $3
```

Substitute the URL in the example with the endpoint URL you received and run the script as follows: `sh run.sh simple.pql env_cw.json https://autoptic.io/pql/ep/007/run ` 

Here the response you would expect:
```
{
 "Errors": "0",
 "Info": "Rm91bmQgMSBQUUwgdmFyaWFibGVzLgpUSU1FIFRPT0sgZ2V0dGluZyByb3cgbWV0cmljcyBmcm9tIFswIDAgMCAyNTVdICg2MC4wOTIwN21zKQpQcWwgc291cmNlIGlkOiAkd2hlcmVbMF0ud2hhdFswXS53aGVuWzBdOyBQcm9jZXNzZWQgYWxpYXMoIiR3aGVyZVswXS53aGF0WzBdLndoZW5bMF0iKSAtLT4gRE9ORQpQcWwgc291cmNlIGlkOiAkd2hlcmVbMF0ud2hhdFswXS53aGVuWzBdOyBQcm9jZXNzZWQgYWxpYXMoIiR3aGVyZVswXS53aGF0WzBdLndoZW5bMF0iKTsgQ2FsbGluZyBzdGF0aXN0aWMgZnVuY3Rpb24gcGVyY2VudGlsZSB3aXRoIHBhcmFtZXRlciAkdHNfY3B1OzAuMTU7MC45OSBvbiBQUUwgU2VyaWVzIHJlc3VsdGluZyBvZiB0aGUgZWFybHkgaW5mbyAtLT4gRE9ORQoyIGVudHJpZXMgaGFzIGJlZW4gd3JpdHRlbiBpbiBhIG91dHB1dCBjbG91ZHdhdGNoX3Jlc3VsdHMuanNvbiAoY2xvdWR3YXRjaF9yZXN1bHRzLmpzb24gdmFsdWUgfCBiYXNlNjQgLWQpCgoKCSoqKioqKiogICBUSU1FIFRPT0soZnJvbSBzdGFydCB0byBlbmQpIDE2MC4yNTQ4NzRtcyAgICoqKioqKioKMCBFcnJvcnMK",
 "cloudwatch_results.json": "WwogewogICJwcWxfdmFyIjogIiR0c19jcHUiLAogICJzZXJpZXMiOiB7CiAgICJpbmZvX3NvdXJjZSI6IHsKICAgICJvbiI6ICIxOS4wNS4yMDIyIDAwOjM5OjI5ICswMDAwIiwKICAgICJtZXRyaWNfc291cmNlIjogIkNsb3VkV2F0Y2ggKHByb2ZpbGU6ICwgcmVnaW9uOiBldS13ZXN0LTEpIiwKICAgICJ3aGVuIjogIlN0YXJ0OiAxOS4wNS4yMDIyIDAwOjA5OjI5ICswMDAwOyBFbmQ6IDE5LjA1LjIwMjIgMDA6Mzk6MjkgKzAwMDAiLAogICAgInN0ZXAiOiAiNW0wcyIsCiAgICAicXVlcnkiOiBbCiAgICAgewogICAgICAibWV0cmljX25hbWUiOiAiQ1BVVXRpbGl6YXRpb24iLAogICAgICAibmFtZXNwYWNlIjogIkFXUy9FQzIiLAogICAgICAiaWQiOiAiYXV0b3B0aWNfMTY1MjkyMDc2OTg0ODg4NjQxNyIsCiAgICAgICJsYWJlbCI6ICJhdXRvcHRpYy0xNjUyOTIwNzY5ODQ4ODg2NDE3IiwKICAgICAgInN0YXQiOiAiQXZlcmFnZSIsCiAgICAgICJleHByZXNzaW9uIjogIiIsCiAgICAgICJwZXJpb2QiOiAzMDAsCiAgICAgICJEaW1lbnNpb25zIjogWwogICAgICAgewogICAgICAgICJuYW1lIjogIkluc3RhbmNlSWQiLAogICAgICAgICJ2YWx1ZSI6ICJpLTAwZjg4ODBkN2E0ZDUwMmRiIgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgXQogICB9LAogICAicHFsX2V4cHJlc3Npb24iOiAiJHdoZXJlWzBdLndoYXRbMF0ud2hlblswXSIsCiAgICJtc2dzIjogWwogICAgIlBxbCBzb3VyY2UgaWQ6ICR3aGVyZVswXS53aGF0WzBdLndoZW5bMF0iLAogICAgIlByb2Nlc3NlZCBhbGlhcyhcIiR3aGVyZVswXS53aGF0WzBdLndoZW5bMF1cIikiCiAgIF0sCiAgICJwcWxfc2VyaWVzIjogWwogICAgewogICAgICJkaW1fcGFpcnMiOiBbCiAgICAgIHsKICAgICAgICJrIjogIk1ldHJpY19pZCIsCiAgICAgICAidiI6ICJhdXRvcHRpY18xNjUyOTIwNzY5ODQ4ODg2NDE3IgogICAgICB9LAogICAgICB7CiAgICAgICAiayI6ICJNZXRyaWNfbGFiZWwiLAogICAgICAgInYiOiAiYXV0b3B0aWMtMTY1MjkyMDc2OTg0ODg4NjQxNyIKICAgICAgfQogICAgIF0sCiAgICAgImxlbmd0aCI6IDUsCiAgICAgInN0YXR1cyI6ICJPSyIsCiAgICAgInRzIjogWwogICAgICB7CiAgICAgICAidGltZXN0YW1wIjogMTY1MjkyMDE0MCwKICAgICAgICJ2YWx1ZSI6IDAuMTUwODQ3NDU3NjI2MTE1MzcKICAgICAgfSwKICAgICAgewogICAgICAgInRpbWVzdGFtcCI6IDE2NTI5MTk4NDAsCiAgICAgICAidmFsdWUiOiAwLjE0OTc1NDU2MTQ1MzczNDY3CiAgICAgIH0sCiAgICAgIHsKICAgICAgICJ0aW1lc3RhbXAiOiAxNjUyOTE5NTQwLAogICAgICAgInZhbHVlIjogMC4xNjU4NjU1MTgxOTk0OTE2CiAgICAgIH0sCiAgICAgIHsKICAgICAgICJ0aW1lc3RhbXAiOiAxNjUyOTE5MjQwLAogICAgICAgInZhbHVlIjogMC4xMzMzNTE4NTY5OTc4NDAxNgogICAgICB9LAogICAgICB7CiAgICAgICAidGltZXN0YW1wIjogMTY1MjkxODk0MCwKICAgICAgICJ2YWx1ZSI6IDAuMTY3MjUwMTYyMDgyMDExNAogICAgICB9CiAgICAgXQogICAgfQogICBdCiAgfQogfSwKIHsKICAicHFsX3ZhciI6ICIkcGVyY19jcHUiLAogICJ3aG9faXNfdGhlcmUiOiAxLAogICJyZXN1bHQiOiB7CiAgICJpbmZvIjogWwogICAgIlBxbCBzb3VyY2UgaWQ6ICR3aGVyZVswXS53aGF0WzBdLndoZW5bMF0iLAogICAgIlByb2Nlc3NlZCBhbGlhcyhcIiR3aGVyZVswXS53aGF0WzBdLndoZW5bMF1cIikiLAogICAgIkNhbGxpbmcgc3RhdGlzdGljIGZ1bmN0aW9uIHBlcmNlbnRpbGUgd2l0aCBwYXJhbWV0ZXIgJHRzX2NwdTswLjE1OzAuOTkgb24gUFFMIFNlcmllcyByZXN1bHRpbmcgb2YgdGhlIGVhcmx5IGluZm8iCiAgIF0sCiAgICJvbiI6ICIxOS4wNS4yMDIyIDAwOjM5OjI5ICswMDAwIiwKICAgInBxbF9mdW5jdGlvbiI6ICJwZXJjZW50aWxlIiwKICAgInRoZV9yZXNfdmFsIjogWwogICAgewogICAgICJtZXRyaWMiOiBbCiAgICAgIHsKICAgICAgICJrIjogIk1ldHJpY19pZCIsCiAgICAgICAidiI6ICJhdXRvcHRpY18xNjUyOTIwNzY5ODQ4ODg2NDE3IgogICAgICB9LAogICAgICB7CiAgICAgICAiayI6ICJNZXRyaWNfbGFiZWwiLAogICAgICAgInYiOiAiYXV0b3B0aWMtMTY1MjkyMDc2OTg0ODg4NjQxNyIKICAgICAgfQogICAgIF0sCiAgICAgInN0YXR1cyI6IDAsCiAgICAgInBhcmFtZXRlcnMiOiBbCiAgICAgIDAuMTUsCiAgICAgIDAuOTkKICAgICBdLAogICAgICJ2YWx1ZXMiOiBbCiAgICAgIDAuMTQ1NjUzODg1MzM5NzYxMDQsCiAgICAgIDAuMTY3MTgwOTI5ODg3ODg1NAogICAgIF0KICAgIH0KICAgXQogIH0KIH0KXQ=="
}
```
The results are base64 encoded and can be decoded with `base64 -D`.

## Autoptic Architecture
PQL programs are edited locally and posted through a secure API endpoint to the Autoptic PQL runtime where code is executed. The runtime will get timeseries data from the remote sources configured in the program and return the computed results to the requesting client.  
![alt text](https://www.autoptic.io/assets/img/architecture_logical.png)

## PQL Program Structure
![alt text](https://www.autoptic.io/assets/img/pql_structure.png)
### Query
Query functions describe data inputs from the data sources:

[3w's](#3ws) | [where](#where) | [what](#what) | [when](#when) | [window](#window) | [open](#open) | [as](#as) | [alias](#alias)

### Aggregate
Aggregate functions handle timeseries data reduction or aggregation:

[filter](#filter) | [merge](#merge)

### Compute
Compute functions allow computing simple or more complex statistics: 

[average](#average) | [min](#min) | [max](#max) | [count](#count) | [percentile](#percentile) | [math](#math)

### Output
Output functions direct how the resulting output will be handled:

[assert](#assert) | [sort](#sort) | [head](#head) | [tail](#tail) | [print](#print) | [out](#out)

### Data Source Reference
Data source references specify which data sources will be used from the environment definition:

[cloudwatch](#cloudwatch) | [prometheus](#prometheus)
		
## Functions
#### 3w's
A query consists of 3 required (what,where,when) and 1 optional (window) dimensions. Each combination of dimensions produces a distinct collection that can be used by other functions in the PQL program. Every such collection is automatically labeled with the tuple of dimensions and position index of the parameters referenced.
```
//The following query can produce 8 distinct timeseries collections:
where("$cwA", "$cwB")
.what(
    "CPUUtilization; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'",
    "NetworkOut; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'",
)
.when("1d", "1h")

//The following collections are labeled as a response matrix.
//Collection1 is labeled where[0].what[0].when[0] for tuple [$cwA][CPUUtilization...][1d]
//Collection2 is labeled where[0].what[0].when[1] for tuple [$cwA][CPUUtilization...][1h]
//Collection3 is labeled where[0].what[1].when[0] for tuple [$cwA][NetworkOut...][1d]
//Collection4 is labeled where[0].what[1].when[1] for tuple [$cwA][NetworkOut...][1h]
//Collection5 is labeled where[1].what[0].when[0] for tuple [$cwB][CPUUtilization...][1d]
//Collection6 is labeled where[1].what[0].when[1] for tuple [$cwB][CPUUtilization...][1h]
//Collection7 is labeled where[1].what[1].when[0] for tuple [$cwB][NetworkOut...][1d]
//Collection8 is labeled where[1].what[1].when[1] for tuple [$cwB][NetworkOut...][1h]
```

#### alias
Creates a variable name for a selection in the response matrix.
- parameters: 1 query matrix selection
- use:
	- Selecting the first and second time periods of the query.
	```
	.alias("$what[0].when[0].where[0]").as("snapshot_A")
	.alias("$what[0].when[1].where[0]").as("snapshot_B")
	```
	- Selecting the second data source and third time window of the query.
	```
	alias("$what[0].when[0].where[1].window[2]").as("snapshot_C")
	```
	- Selecting all data sources and all time periods of the query.
	```
	alias("$what[0].when[*].where[*]").as("snapshot_D")
	```
---
#### as
Creates a named timesieres variable from the results of the preceding function. Variables are used as inputs to other functions.
- parameters: 1 variable name
- use:
	- Compute the average CPU and print the result
	```
	average("$cpu_timeseries").as("avg_cpu")
	.print("$avg_cpu")
	.out("results.json")
	```
	- Filter query data and merge into a single timeseries and print it
	```
	filter("$prom_cpu_5m_last30m", "{cpu='0' OR cpu='1'} AND mode='user'").as("cpu_filtered")
	.merge("$cpu_filtered;average").as("single_cpu_ts")
	.print("$single_cpu_ts")
	.out("results.json")
	```
---
#### assert
Evaluates if a logical expression is true(1) or false(0). 
- parameters: 1 logical expression.
- use:
	- check if two counters are the same `assert("$count_cpu_aws == $count_cpu_prom")`
	- check if CPU is greater than 50% `assert("$cpu_avg_utilization > 0.5")`
---
#### average
Computes the average value for a timeseries.
- parameters: 1 timeseries variable
- use:
	- compute the average `average("$cpu_utilization")`
---
#### count
Computes the number of data points in a timeseries.
- parameters: 1 timeseries variable
- use:
	- compute the number of data points `count("$cpu_utilization")`
---
#### head
Selects the first set of data points from a timeseries variable.
- parameters: 1 timeseries variable and 1 integer | percent value.
- use: 
	- get the first 15 data points `head("$cpu0_user; 15")`
	- get the first 2% of data points `head("$cpu0_user; 2%")`
---
#### filter
Selects the timeseries matching a logical expression.
- parameters: 1 timeseries variable and 1 expression.
- use:
	- Select the timeseries that match the 'user' mode for CPU 0 
	```
	filter("$cpu_usage", "{cpu='0' AND mode='user'}")
	``` 
	- Select the timeseries that match the 'user' and/or 'system' mode for CPU 0 and/or 1 
	```
	filter("$cpu_usage", "{cpu='0' OR cpu='1'} AND {mode='user' OR mode='system'}")
	``` 
---
#### math
Computes a value from a mathematical expression.
- parameters: 1 math expression. Only single value variables can be provided in the expression.
- use:
	- Sum of the CPU0 user and system utilization. 
	```
	math("($avg_cpu0_user + $avg_cpu0_system)")
	```
	- Network Bytes in to out throughput ratio in percent
	```
	math("(1 - $net_in/$net_out)")
	```
---
#### max
Computes the maximum value for a timeseries.
- parameters: 1 timeseries variable
- use:
	- compute the maximum `max("$cpu_utilization")`
---
#### merge
Combines multiple timeseries into a single timeseries using an aggregation function.
- parameters: N+1 timeseries and 1 aggregation function (min | max | average | sum).
- use:
	- Merges system and user CPU 0 into a timeseries by adding data points in the same time window.
	```
	merge("$avg_cpu0_system; $avg_cpu0_user; sum")
	```
	- Merges the user CPU 0 and 1 into a single timeseries by computing the average for data points in the same time window. 
	```
	merge("$cpu0_user_case3; $cpu1_user_case3; avg")
	```
	- Merges the user CPU 0,1,2,3 into a single timeseries based on the max valye for data points in the same time widnow.
	```
	merge("$cpu0_user; $cpu1_user; $cpu2_user; cpu3_user; max")
	```
---
#### min
Computes the minimum value for a timeseries.
- parameters: 1 timeseries variable
- use:
	- compute the minimum `min("$cpu_utilization")`
---
#### open
Opens a saved PQL results resource from a URI.
- parameters: 1 PQL results resource and N+1 variables to select.
- use:
	- open a remote file with PQL results and select which variables will be loaded `.open("https://s3bucketurl/data/aws_saved_results.json;$varA;varB")`
---
#### out
Selects the output destination for the program.
- parameters: N+1 destinations.
- use:
	- send results to a single json result `.out("results.json")`
	- send results to a multile json results `.out("resultA.json","resultB.json")`
---
#### percentile
Computes percentile summaries for a timeseries.
- parameters: 1 timeseries variable and N+1 percentile float attributes.
- use
	- compute 1st percentile `percentile("$aws_cpu;0.01")`
	- compute 15th and 98th percentile `percentile("$aws_cpu;0.15;0.98")`
---
#### print
Outputs a set of timeseries or computed statistics.
- parameters: N+1 timeseries variables
- use: 
	- output summary and timeseries values `print("$cnt_aws", "$cnt_prom", "$assert_cnts")`
---
#### sort
Sorts all data points in a timeseries.
- paramertes: 1 timeseries variable and 1 integer flag.
- use:
	- sort in ascending order `sort("$prom_cpu_5m_last30m_filtered; 1")`
	- sort in descending order `sort("$prom_cpu_5m_last30m_filtered; 0")`
---
#### tail
Selects the last set of data points from a timeseries.
- parameters: 1 timeseries variable and 1 integer | percent value.
- use: 
	- get the last 20 data points `tail("$cpu0_user; 20")`
	- get the last 3% of data points `tail("$cpu0_user; 3%")`
---
#### window
Selects the granularity of the timeseries data retrieved from the data source.
- parameters: N+1 time windows/buckets
- use:
	- 30 second window selection `window("30s")`
	- 5 seconds and 1 hour window selections `window("5s","1h")`
- default: 300s
---
#### what
Defines the query keywords and metadata submitted to the data sources.
- parameters: N+1 queries
- use:
	- get instance CPU utilization from AWS `what("CPUUtilization; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'")`
	- get cpu utilization from Prometheus `what("node_cpu_seconds_total")`
	- get multiple metrics from AWS EC2 instance
	```
	what(
	  "CPUUtilization; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'",
	  "NetworkOut; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'",
	  "NetworkIn; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'"
	)	
	```
	- get metrics from AWS and Prometheus
	```
	what(
	  "CPUUtilization; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'",
	  "node_cpu_seconds_total"
	)
	```
---
#### when
Selects the query time ranges for the program
- parameters:  N+1 time ranges
- use:
	- releative time selection 
		- recent 5 minutes `when("5m")` 
		- recent 1 hour `when("1h")`
		- recent 7 days `when("7d")`
	- absolute time selection
		- start and end date time `"when("start = '02-22-2022 00:00:00 +00'; end = '02-22-2022 23:59:59 +00'")`
	- multi selection
		- recent 24 hours and 2-22-22 `when("24h","start = '02-22-2022 00:00:00 +00'; end = '02-22-2022 23:59:59 +00'")`
---
#### where 
Selects the data sources that will be used in the program from the [data source configuration](#data-sources).
- parameters: N+1 data source references
- use: 
	- 3 data source references `where("$dsA","$dsB","$dsC")`

## Data Sources
The environment definition is a global configuration that stores preferences and data source access. Multiple data sources of different types can be configured and used by a PQL program. [download the template](./examples/env_cw.json)
#### cloudwatch
Multiple cloudwatch data sources can be configured in the environment definition. 
- attributes:
	- name: The name that will be referenced by the "where" function in a PQL program.
	- type: CloudWatch
	- vars:
		- AwsRegion: AWS region that the PQL program will be querying.
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
