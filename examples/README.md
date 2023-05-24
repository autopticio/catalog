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
3. The `when` clause sets the time interval to 3600 hours (1 hour).
4. The `window` clause sets the aggregation window to 168 hours (1 week).
5. The first `request` statement retrieves the data for the "BucketSizeBytes" metric and assigns it to the variable `$size`.
6. The second `request` statement retrieves the data for the "NumberOfObjects" metric and assigns it to the variable `$count`.
7. The `merge` statements calculate the average of the `$size` and `$count` variables and assign them to `$size_merged` and `$count_merged`, respectively.
8. The `percentile` and `average` statements calculate the 95th percentile and average values of `$size_merged` and `$count_merged`.
9. The `math` statements calculate the percentage change between the average and 95th percentile values for both size and count metrics, assigning the results to `$size_change` and `$count_change`.
10. The `assert` statement compares the `$count_change` with `$size_change` to determine if the count metric has changed more significantly, assigning the boolean result to `$count_has_changed_the_most`.
11. The `chart` statements create visualizations of the size change, count change, and the boolean result in bar and pie chart formats.
12. The `out` statement specifies the output format and provides a description of the analysis, which is "what changes in S3".

