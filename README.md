# Guidance for Digital Customer Engagement on AWS

## Introduction
This guidance helps businesses build a comprehensive digital customer engagement platform by leveraging RudderStack's warehouse-first CDP platform and AWS services such as Amazon Redshift, Amazon Athena, Amazon Pinpoint, and Amazon Quicksight. With RudderStack's platform, businesses can collect and store customer data from various sources, such as mobile apps and websites, and make it available for analysis and engagement. The guidance is designed to support various use cases, including Customer 360, personalized recommendation and advertisement attribution analysis.


## Prerequisites
1. Register in RudderStack control panel ([open source version](https://app.rudderstack.com/signup?type=opensource)) (not the cloud version).

2. You need the following to be installed on your local machine to access the Amazon EKS cluster
* [AWS CLI V2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html) 

## Architecture Diagram

![Arch for Redshift](./images/arch-redshift.png)
1. Developers configure data sources (Web, Mobile), data destinations (Amazon Redshift), and connections in the Control Plane hosted by RudderStack.

2. Developers use the SDK provided by RudderStack's Event Stream to develop tracking for data sources.

3. The SDK sends tracking events to Application Load Balancer, which then enters the RudderStack Data Plane deployed on Amazon Elastic Kubernetes Service (EKS). The Data Plane writes the events to the Amazon Simple Storage Service (S3) staging bucket.

4. The RudderStack Data Plane periodically sends Copy commands, data merge SQL, and DDL to Amazon Redshift Serverless, importing the event data files from the S3 Staging bucket into Amazon Redshift tables.

5. Using Amazon Redshift Serverless, the event table is processed according to analysis requirements to create user behavior analysis detail tables, summary tables, and user profile tables. Use Amazon Managed Workflows for Apache Airflow (MWAA) for task scheduling.

6. Use Amazon QuickSight to create dashboards like user behavior analysis, web attribution report and funnel analysis, with the data source being the summary level tables read through Amazon Redshift Serverless.

7. The interaction data between Users and Items will be sent in real-time as events from the RudderStack Data Plane to the Amazon Personalize. Based on different recommendation algorithms, corresponding recommendation results will be generated.


Included Modules:
   - 2-DataCollection/DataPlaneDeployment
   - 2-DataCollection/RedshiftDestination
   - 3-DataUnify/RedshiftTransformation

## Modules

### 1-DemoSource

A retail store demo web UI with RudderStack JavaScript SDK integrated.

### 2-DataCollection/DataPlaneDeployment

A Comprehensive guide to deploying the RudderStack Data Plane service on Amazon EKS for production use.

### 2-DataCollection/RedshiftDestination

A Comprehensive guide to setup the Redshift Destination in RudderStack control plane and AWS Console.


### 3-DataUnify/RedshiftTransformation

A DBT project designed to construct data models in Amazon Redshift, which can be utilized in Data Visualization services like Amazon Quicksight and Customer Engagement services such as Amazon Pinpoint.


### 4-Recommendation

This detailed guide on how to implement personalized recommendations specifically utilizes the integration of RudderStack and Amazon Personalize, achieving real-time event tracking to promptly respond to changes in user interests.

### 9-Tools/JSSourceDataGenerator

A Python script designed to send event requests, containing mock data, from a JavaScript source directly to the RudderStack Data Plane.


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

