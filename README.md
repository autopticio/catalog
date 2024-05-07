## Getting started with PQL
Autoptic PQL is a functional language for time series data analysis. Here is an example program for Amazon CloudWatch.
```
//query cloudwatch and get instance CPU utilization for the last hour
where(@cw_aws)
.what("MetricName='CPUUtilization';InstanceId='*'; Namespace='AWS/EC2'")
.when(1h)
        .request($where[0];$what[0];$when[0]).as($ts_cpu)

//compute the 15th and 99th percentile summary statistics
.percentile($ts_cpu;0.99).as($perc_cpu_99)
.percentile($ts_cpu;0.90).as($perc_cpu_90)

//chart the percentile values, and all cpu time series data points.
.note("### CPU Utilization for EC2 instances")
.chart($perc_cpu_99;$perc_cpu_90 ; @barcombo)
.chart($ts_cpu ; @line)
```
Here is the resulting html you would expect: [Sample results](https://autoptic-www.s3.eu-west-1.amazonaws.com/assets/html/sample_result.html)

#### 1. Sign-up and run the demo program
[Signup and activate an Autoptic endpoint](https://www.autoptic.io/#signup). Follow the instructions to setup your environment and run the demo program. 

Add your account credentials "aws_access_key_id" and "aws_secret_access_key" in the env.json property file. The account must have read access to CloudWatch. For more information check the [AWS guide on access credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html). Autoptic does not cache or store the credentials you submit over the API.

The sample query is retrieving the "CPUUtilization" of an EC2 instance. [Check the full CloudWatch metrics list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html) for more options. Check out the [example programs](./examples/) for more ideas on how to use PQL for more programmable assessments.

#### 2. Use the VSCode Autoptic extension 
You can download and install our [VSCode exension](https://github.com/autopticio/vscode-pql) and edit/run PQL programs from the IDE. Using VSCode is very convenient when you are iterating and building a collection of programs or writing more extensive storybooks. The extension provides syntax highlighting and runtime access to run PQL programs. You can edit,run and view results directly from Visual Studio Code.

## Autoptic Architecture
PQL programs are edited locally and posted through a secure API endpoint to the Autoptic PQL runtime where code is executed. The runtime will get time series data from the remote sources configured in the program and return the computed results in html or json to the requesting client.  
![alt text](https://www.autoptic.io/assets/img/architecture_logical.png)

## PQL Program Structure
![alt text](https://www.autoptic.io/assets/img/pql_structure.png)
variables label collections of time series (data points with timestamps and dimensional metadata) or aggregates (signed float numbers with dimensional metadata).

### Query
Query functions describe data inputs from the data sources:

[3w's](#3ws) | [where](#where) | [what](#what) | [when](#when) | [window](#window) | [open](#open) | [as](#as) | [request](#request)

### Modification
Modification functions handle time series data reduction, filtering and summation:

[filter](#filter) | [merge](#merge) | [group](#group)

### Compute & Analytics
Compute functions allow computing aggregates for simple or more complex statistics: 

[average](#average) | [min](#min) | [max](#max) | [count](#count) | [percentile](#percentile) | [assert](#assert) | [math](#math) | [correlate](#correlate) | [diff](#diff)

### Presentation
Output functions direct how the resulting output will be handled:

[note](#note) | [chart](#chart) | [sort](#sort) | [head](#head) | [tail](#tail) | [print](#print) | [out](#out) | [style](#style)

### Data Source Reference
Data source references specify which data sources will be used from the environment definition:

[cloudwatch](#cloudwatch) | [prometheus](#prometheus)
		
## Functions
#### 3w's
A query consists of 3 required (what,where,when) and 1 optional (window) dimensions. Each combination of dimensions produces a distinct collection that can be used by other functions in the PQL program. Every such collection is automatically labeled with the tuple of dimensions and position index of the parameters referenced.
```
//The following query can produce 8 distinct time series collections:
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
Creates a named time series or a results variable from the results of the preceding function. Variables are used as inputs to other functions.
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
	- Remove a deminsion from a variable: 
		- Removing the Stat dimension: `.average($cpu_timeseries).as($avg_cpu ;Stat='!')`
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
Computes the average value for a time series.
- parameters: 1 time-series variable
- returns: aggregate[] collection
- use:
	- compute the average `average($cpu_utilization)`
---
#### chart 
Creates a graph visualization for the variables in scope. The graphs are rendered as html in the output.
- parameters: N time series or aggregate variables, and a graph template reference. Graph templates are configured in the env.json.
- returns: inserts the rendered graph in html format. Multiple chart calls append their output in the order they appear in PQL.
- use:
	- graph time series variables as individual  line charts `.chart($ts_cpu; $ts_mem; @line)`
	- graph aggregate variables as a stacked bar chart `.chart($cpu_idle_avg; $cpu_sys_avg; @barStacked)`
- templates
Graph templates are configured in the env.json and can be referenced in function calls. 
	- properties
		- name: reference name that will be used in the PQL program
		- type: type of chart
		- backgroundColor: chart background color
		- borderColor: chart frame color
		- stacked: if true all variables are charted in the same chart and stacked.
		- combo: this applies to bar charts only, if true all variables are charted side by side.
		- style max width: determins the horizontal size / length of the chart. 
		- aspectRatio: defines the size ratio of the chart and depends on the max-width. To get the expected height divide the width size by the aspect ratio. For example width of 200px with aspect ratio of 2 will draw a chart with 200px width and 100px height.
	- example configurations
		- line
		```
		{
      	"name": "linestack",
      	"type": "line",
      	"vars": {
        	"backgroundColor": "rgb(99, 99, 132)",
        	"borderColor": "rgb(99, 99, 132)",
        	"stacked": true,
        	"style": "max-width: 600px",
        	"aspectRatio": "3"
      		}
    	}
		``` 
	- bar
	```
	{
      "name": "barcombo",
      "type": "bar",
      "vars": {
          "backgroundColor": "rgb(255, 99, 132)",
          "borderColor": "rgb(255, 99, 132)",
          "stacked": true,
          "combo":true,
          "style": "max-width: 600px",
          "aspectRatio": "2.5"
      }
    }
	``` 
	- pie
	``` 
	{
      "name": "piestack",
      "type": "pie",
      "vars": {
          "backgroundColor": "rgb(99, 99, 132)",
          "borderColor": "rgb(99, 99, 132)",
          "stacked": true,
          "style": "max-width: 400px",
          "aspectRatio": "1"
      }
    }
	``` 
	- asserttable
	The assertable charts a table of true and false values along with a total summary. This chart is useful to quickly visualize assertions.
		- use:
			```
			.assert($errors_avg < 5 ).as($errors_asserts)
			//FunctionName will override the default MetricName in the asserttable as the row dimension
			.chart($errors_asserts;@tftable["FunctionName"])
			```
		- environment configuration properties
			- row_dimension: the default dimension to use for row labels.
			- true_label: the column header for true values.
			- false_label: the column header for false values.
			- mark: the characted that will show in the table if a value is true or false
		- example environment configuration
		```
		{
      	"name": "tftable",
      	"type": "asserttable",
      	"vars": {
          	"row_dimension": "MetricName",
          	"true_label": "pass",
          	"false_label" : "fail",
          	"mark": "&#9679;"
      		}
    	}
	```
---
#### correlate
Computes the degree of correlation between two time series variables.
- parameters: 2 time series variables
- returns: aggregate for degree of correlation. 1 is highest correlation to -1 for inverse correlation. Numbers closer to 0 indicate low or no correlation.
- use:
	- compute the number of data points `correlate($cpu_utilization; $memory_utilization).as($resource_correlation)`
---
#### count
Computes the number of data points in a time series.
- parameters: 1 time series variable
- returns: aggregate[] collection
- use:
	- compute the number of data points `count("$cpu_utilization")`
---
#### diff 
Computes the difference between every data point in two time series. The resutling time series can contain positive or negative values based on the differential result.
- parameters: 2 time series variables
- returns: 1 time series 
- use:
	- compute the the percent difference `diff("$cpu_today; $cpu_yesterday; percent")`
	- compute the the absolute difference `diff("$cpu_today; $cpu_yesterday; numeric")`
---
#### group
Creates a new variable from a collection of time series or aggregate variables. Only one data type is allowed per function call.
- parameters: N time series or aggregate variables
- returns: 1 time series[] or aggregate[] collection 
- use:
	- group time series  `.group($instance_cpu_a1; $instance_cpu_a2).as($cpu_all)`
	- group aggregates `.group($cpu_perc;$cpu_max;$cpu_avg).as($stats_all)`
---
#### head
Selects the first set of data points from a time series variable.
- parameters: 1 time series variable and 1 integer | percent value.
- returns: time series[] collection
- use: 
	- get the first 15 data points `head($cpu0_user; 15)`
	- get the first 2% of data points `head($cpu0_user; 2%)`
---
#### filter
Selects the time series matching a logical expression.
- parameters: 1 time series variable and 1 expression.
- returns: time series[] collection
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
- returns: aggregate
- use:
	- Sum of the CPU0 user and system utilization. 
	```
	math(($avg_cpu0_user + $avg_cpu0_system))
	```
	- Network Bytes in-to-out throughput ratio in percent
	```
	math((1 - $net_in/$net_out))
	```
---
#### max
Computes the maximum value for a timeseries.
- parameters: 1 time series variable
- returns: aggregate[] collection
- use:
	- compute the maximum `max($cpu_utilization)`
---
#### merge
Combines multiple time series into a single time series using an aggregation function.
- parameters: N+1 time series and 1 aggregation function (min | max | average | sum).
- returns: time series[] collection
- use:
	- Merges system and user CPU 0 into a timeseries by adding data points in the same time window.
	```
	merge($avg_cpu0_system; $avg_cpu0_user; sum)
	```
	- Merges the user CPU 0 and 1 into a single time series by computing the average for data points in the same time window. 
	```
	merge($cpu0_user_case3; $cpu1_user_case3; average)
	```
	- Merges the user CPU 0,1,2,3 into a single time series based on the max valye for data points in the same time widnow.
	```
	merge($cpu0_user; $cpu1_user; $cpu2_user; cpu3_user; max)
	```
---
#### min
Computes the minimum value for a time series.
- parameters: 1 time series variable
- returns: aggregate[] collection
- use:
	- compute the minimum `min($cpu_utilization)`
---
#### note 
Inserts html formatted text in the output.
- parameters: markdown or plain text. Note supports templating with providing optional aggregate variables and dimension references that get substituted in the markdown.
- returns: appends the contents to the output. Notes are displayed in the order they appear in PQL. 
- use:
	- renders markdown `note("### Hello! This is my first note. We love <b>PQL</b>!")`
	- the markdown template below renders the sentence "Average CPUUtilization is 0.19249771467106416 in eu-west-1"
	```
	.note($cpu_avg;$cpu_avg.Region;$cpu_avg.MetricName;"
	Average {{3}} is {{1}} in {{2}}
	")
	```
---
#### open
Opens a saved PQL results resource from a URI.
- parameters: 1 PQL results resource and N+1 variables to select.
- returns: time series[] collection
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
Computes percentile summaries for a time series.
- parameters: 1 time series variable and N+1 percentile float attributes.
- returns: aggregate[] collection
- use
	- compute 1st percentile `percentile($aws_cpu;0.01)`
	- compute 15th and 98th percentile `percentile($aws_cpu;0.15;0.98)`
---
#### print
Outputs the contents of the selected variables in json.
- parameters: N+1 time series variables
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
- paramertes: 1 time series[] or 1 aggregate[] variable and 1 integer flag.
- returns: times series[] or aggregate[] collection
- use:
	- sort in ascending order `sort($prom_cpu_5m_last30m_filtered; 1)`
	- sort in descending order `sort($prom_cpu_5m_last30m_filtered; 0)`
	---
#### style
Applies an external style sheet that overrides the default style of the html formatted storybooks. Only one style function call is allowed per PQL program. Style references are defined in the environment definition (env.json).
- paramertes: 1 environment reference
- returns: 
- use:
	- add a new css style to the storybook `style(@darkmode)`
	- sample environment configuration with 2 style options.
	```
	"style":[
    {
      "name": "darkmode",
      "type": "CSS",
      "vars": {
        "url": "https://www.autoptic.io/assets/css/darkmode.css"
      }
    },
    {
      "name": "bootstrap",
      "type": "CSS",
      "vars": {
        "url": "https://cdn.jsdelivr.net/npm/bootstrap@4.4.1/dist/css/bootstrap.min.css"
      }
    }
  ]
	```
---
#### tail
Selects the last set of data points from a time series.
- parameters: 1 time series variable and 1 integer | percent value.
- returns: time series[] or aggregate[] collection
- use: 
	- get the last 20 data points `tail($cpu0_user; 20)`
	- get the last 3% of data points `tail($cpu0_user; 3%)`
---
#### window
Specifies the granularity of the time series data retrieved from the data source.
- parameters: N+1 time windows/buckets
- use:
	- 30 second window selection `window(30s)`
	- 5 seconds and 1 hour window selections `window(5s;1h)`
- default: 300s
---
#### what
Specifies the query keywords and metadata submitted to the data sources.
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
Specifies the query time ranges for the program
- parameters:  N+1 time ranges
- use:
	- releative time selection 
		- recent 5 minutes `when(5m)` 
		- recent 1 hour `when(1h)`
		- recent 7 days `when(7d)`
		- Dynamic period selection simplifies time navigation. Previous historical periods can be specified with an index number next to the time value:
			- the second to last 7-day period `when(7d[1])
			- the third to last 7-day perdiod `when(7d[2])
			- the 10th to last 30-day perdiod `when(30d[10])
	- absolute time selection
		- start and end date time `when("start = '22-02-2022 00:00:00 +00'; end = '22-02-2022 23:59:59 +00'")`
	- multi selection
		- recent 24 hours and 2-22-22 `when(24h,"start = '22-02-2022 00:00:00 +00'; end = '22-02-2022 23:59:59 +00'";24h[5])`
---
#### where 
Specifies the data sources that will be used in the program from the [data source configuration](#data-sources).
- parameters: N+1 data source references
- use: 
	- 3 data source references `where(@dsA ; @dsB ; @dsC)`

## Data Sources
The environment definition is a global configuration that stores preferences and data source access. Multiple data sources of different types can be configured and used by a PQL program. [download the template](./examples/env_template.json)
#### cloudwatch
Multiple cloudwatch data sources can be configured in the environment definition. 
- attributes:
	- name: The name that will be referenced by the "where" function in a PQL program.
	- type: CloudWatch
	- vars:
		- AwsRegion: default AWS region that the PQL program will be querying, if "Region" is not specified in 'what'
		- window: default window size if not specified by the "window" function in a PQL program.
		- The source supports both static keys and dynamically generated keys through MFA.
			- aws_access_key_id: AWS key that you have to generate through IAM in AWS.
			- aws_secret_access_key: The token that is paired with the key id above.
			- aws_session_token: The session token generated by a MFA login through STS.This token is not needed when static keys are used for auth. 
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
