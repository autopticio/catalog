# Doc 

## Getting started with programmable assessment 
Autoptic PQL is a functional language timeseries data analysis. Here is an example of collecting CPU statistics from AWS Cloudwatch and computing the 98th percentile for the last hour.
```
where("$cloudwatch”)
.what("CPUUtilization; Average; InstanceId='i-00f8880d7a4d502db'; namespace='AWS/EC2'")
.when("1h")
	.alias("$where[0].what[0].when[0].window[0]").as(“ts_cpu")

.percentile("ts_cpu;0.15;0.99").as("perc_cpu")

.print(“$perc_cpu","$ts_cpu")
	.out("./data/cloudwatch_results.json")
```
Problem and simple example
Autoptic Architecture
Sign up here for access - send to google form

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
