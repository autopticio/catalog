## About the catalog
You can accomplish wonderful things with PQL and we want to share our learnings and experience through the example PQL programs. We are steadily researching and adding new recipes in this repository. The examples are curated through research, review and thorough testing, however feedback is always welcome so please submit PRs or issues for matters that can be improved! 

### 1.  What's up with your AWS S3 buckets? 
[aha-s3-changes.pql](./aha-s3-changes.pql)  retrieves metrics related to S3 bucket size and object count, calculates statistics and percentage changes, and generates charts to visualize the results. The program then outputs the analysis description "what changes in S3."

#### When should I use it? 
The program provides a systematic approach to analyzing S3 bucket metrics, helping you gain insights into the usage, performance, and cost aspects of your S3 storage. It empowers you to make informed decisions, optimize resource allocation, and ensure the efficient management of your S3 environment.Here are some reasons why this program can be valuable:

1. **Performance Optimization**: By tracking the changes in bucket size and object count, you can identify any significant fluctuations that may indicate performance issues or abnormal growth. This information can help you optimize your S3 usage and storage allocation.

2. **Capacity Planning**: Understanding the trends and changes in S3 bucket metrics allows you to plan your capacity requirements more effectively. By analyzing the average and percentile values, you can estimate future storage needs and ensure that your S3 resources are adequately provisioned.

3. **Cost Management**: S3 storage costs are directly influenced by the size of the stored objects and the number of objects. By monitoring these metrics, you can identify any unexpected increases in storage consumption and take necessary actions to manage costs efficiently.

4. **Anomaly Detection**: The program calculates the percentage change between the average and 95th percentile values for both the size and count metrics. This can help you identify any outliers or anomalies in the S3 bucket data, enabling you to investigate and address any potential issues.

5. **Visualization and Reporting**: The program generates charts in both bar and pie chart formats, which provide a visual representation of the changes in S3 metrics. These charts make it easier to communicate and share the analysis results with stakeholders, such as management or team members.

#### How does it work?
This program performs a series of operations on AWS CloudWatch metrics related to S3 buckets in the "eu-west-1" region. Here's a breakdown of the program:

1. The `where` clause specifies the target AWS account and region for the metrics.
2. The `what` clause defines two metrics to be collected: "BucketSizeBytes" and "NumberOfObjects" for all buckets in the specified region.
3. The `when` clause sets the time interval to 3600 hours (150 days).
4. The `window` clause sets the aggregation window to 168 hours (1 week).
5. The first `request` statement retrieves the data for the "BucketSizeBytes" metric and assigns it to the variable `$size`.
6. The second `request` statement retrieves the data for the "NumberOfObjects" metric and assigns it to the variable `$count`.
7. The `merge` statements calculate the average of the `$size` and `$count` variables and assign them to `$size_merged` and `$count_merged`, respectively.
8. The `percentile` and `average` statements calculate the 95th percentile and average values of `$size_merged` and `$count_merged`.
9. The `math` statements calculate the percentage change between the average and 95th percentile values for both size and count metrics, assigning the results to `$size_change` and `$count_change`.
10. The `assert` statement compares the `$count_change` with `$size_change` to determine if the count metric has changed more significantly, assigning the boolean result to `$count_has_changed_the_most`.
11. The `chart` statements create visualizations of the size change, count change, and the boolean result in bar and pie chart formats.
12. The `out` statement specifies the output format and provides a description of the analysis, which is "what changes in S3".

### 2.  What are the busiest CPU times across your AWS accounts and zones?
[top_utilization_periods.pql](./top_utilization_periods.pql) facilitates the analysis, comparison, and visualization of CPU utilization data across multiple accounts and regions, offering insights that can drive performance optimization, cost savings, capacity planning, and centralized monitoring.

#### When should I use it?
It can be useful for analyzing and comparing CPU utilization across multiple AWS accounts and regions. Here are a few scenarios where you can get more insights:

1. **Performance Monitoring**: By retrieving CPU utilization metrics, you can monitor the performance of your EC2 instances over time. This information helps identify patterns, spikes, or anomalies in CPU usage, which can be crucial for optimizing resource allocation, identifying performance bottlenecks, or detecting instances that may require scaling.

2. **Cross-Account and Cross-Region Comparison**: The program allows you to gather CPU utilization data from different AWS accounts and regions. This capability is particularly useful for organizations with a multi-account or multi-region infrastructure, as it provides a consolidated view of CPU usage across various environments. You can compare CPU utilization patterns, identify regional differences, or identify instances with higher or lower utilization across different accounts.

3. **Resource Allocation and Cost Optimization**: CPU utilization is directly related to the cost and efficiency of your infrastructure. By analyzing the CPU utilization data, you can identify overutilized instances that may require resizing or load balancing, leading to cost optimization. Additionally, underutilized instances can be identified and potentially downsized or terminated to reduce unnecessary expenses.

4. **Capacity Planning**: The program's ability to aggregate and visualize CPU utilization data helps with capacity planning. By analyzing historical trends and identifying peak CPU times across accounts and regions, you can estimate future resource needs and plan for scaling activities accordingly. This proactive approach ensures that you have sufficient resources to handle workload spikes and avoid performance degradation.

5. **Centralized Monitoring and Reporting**: The program streamlines the process of gathering CPU utilization data from multiple accounts and regions, providing a centralized view of important metrics. This centralized monitoring enables easier reporting, allows for the identification of overall trends, and provides a comprehensive understanding of the CPU utilization landscape across your AWS infrastructure.

#### How does it work?
This program performs a series of operations on AWS CloudWatch metrics related to CPU utilization in EC2 instances. It retrieves CPU utilization metrics for EC2 instances, combines the data from multiple accounts and regions, sorts it, selects the top 5%, and presents the result as a bar chart.Here is a breakdown of the steps:

1. The program defines two variables: @cw_aws and @cw_aws_x representing AWS CloudWatch accounts.
2. The .what() function specifies the metric to retrieve, in this case, "CPUUtilization," and applies filters to limit the results to specific instances, regions, and namespaces.
3. The .when() function sets the time range for the metric data. In this case, it retrieves data from the past 7 days.
4. The .window() function sets the aggregation window size to 1 hour. This means that the metric data will be aggregated in one-hour intervals.
5. The .request() function is used twice to retrieve the metric data for both @cw_aws and @cw_aws_x. The retrieved data is stored in variables $ts_cpu_acct_1 and $ts_cpu_acct_2, respectively.
6. The .merge() function combines the two sets of metric data ($ts_cpu_acct_1 and $ts_cpu_acct_2) using the "max" aggregation method. The merged data is stored in the variable $data.
7. The .sort() function sorts the merged data $data based on the second column in ascending order (1 indicates the second column).
8. The .head() function selects the top 5% of rows from the sorted data $sorted and stores them in the variable $top5.
9. The .chart() function generates a chart using the data $top5 and specifies the chart type as a bar chart (@bar).
10. Finally, the .out() function displays the resulting chart with a description: "top percent peak CPU times across accounts and regions."

