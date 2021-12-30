# Open Telemetry StackState NodeJS Layer

## Introduction

This layer enriches the data provided by the official Open Telemetry AWS Distro layer. This allows us to create complete traces which is missing in the core layer IE Lambda to Lambda communication.

## Lambda Requirements

By following the steps below you will have to perform the following changes

- Deploy your own or use the public hosted `Open Telemetry StackState NodeJS Layer`
- Lambda Script (The ones that you want Open Telemetry support for)
  - Add Environment Variables
  - Add the `Open Telemetry StackState NodeJS Layer` arn
  - Add the Official Open Telemetry Distro Layer arn hosted by OTEL `https://aws-otel.github.io/docs/getting-started/lambda/lambda-js#add-the-arn-of-the-lambda-layer`


## File Content Verification [Coming Soon]

Will give you the ability to verify the following:
- NodeJS Layer
  - [Manual Deployed Layer] Verify if the layer you deployed contains the same code SHA as verified by StackState
  - [StackState Deployed Layer] Verify the SHA of the layer you are deploying hosted by StackState
- Open Telemetry Official Layer
  - Verify the layer deployed against an approved StackState SHA

`aws lambda get-layer-version-by-arn` \ \
`--output text` \ \
`--query "Content.CodeSha256"` \ \
`--arn "arn:aws:lambda:<REGION>:<ACCOUNT>:layer:<LAYER>:<VERSION>"`

# Deployment

You can choose between hosting your own layer or using the one hosted by StackState.

## Manual Hosting [Recommended]

### Step 1 - Deploying the nodejs layer

You have two options when deploying manually.
You can create the required elements through the `AWS Console` or
run the `serverless script` which should automatically deploy the layer for you and make future upgrades a bit easier.

- `Serverless`
  - Make sure you have `node` & `npm` installed on your environment
  - Run `npm install serverless -g` to install the serverless npm package in your global structure
  - We are using an AWS_PROFILE to deploy this template as seen under the `serverless.yaml` `provider.profile` variable
    - To create this AWS_PROFILE create the following entry under these files:
      - `vi ~/.aws/config`
        - [profile otel-nodejs-dev] \
          region=`<REGION_FOR_DEPLOYMENT>` \
          source_profile=`otel-nodejs-dev` \
          role_arn=`<A_ROLE_WITH_SUFFICIENT_PERMISSIONS>`
      - `vi ~/.aws/credentials`
        - [otel-nodejs-dev] \
          aws_access_key_id=`<ACCESS_KEY>` \
          aws_secret_access_key=`<SECRET_ACCESS_KEY>`
  - Go into this directory with the `serverless.yaml` script
  - Run `sls deploy`


- `AWS Console`
  - Head over to your AWS lambda layers page: [https://console.aws.amazon.com/lambda/home#/layers](https://console.aws.amazon.com/lambda/home#/layers)
  - Click on the `Create Layer` button in the top right corner
  - Give the lambda layer a name (Recommended calling it `OpenTelemetryNodeJS` and is required if you are planning to use any of the example serverless.yaml scripts)
  - Tick the `Upload a .zip file` and click the `upload button
  - Select and Upload the [`layer.zip`](layer.zip) found next to this README
  - Click the create button to create this Lambda Layer



## Open Telemetry Usage Example [Optional]

#### ⚠ ⚠ WARNING ⚠ ⚠ Only works if you used the recommended name for your layer you deployed above.

Deploying this example will create the following AWS Services allowing you to see traces to all of them:
- **Lambda Function - Contains Open Telemetry Layers**
- **Lambda Function - Receives calls to show Lambda communications**
- **SQS**
- **SNS**
- **S3**
- **Step Function**

### Step 1 - Deploying the example

You have two options when deploying this example.
You can create the required elements through the `AWS Console` or
run the `serverless script` which should automatically deploy the layer for you and make future upgrades a bit easier.

- `Serverless`
  - We will assume that you already have node, npm and serverless installed from the steps above
  - Edit the `serverless.example.yaml` file and change the `OTEL_EXPORTER_OTLP_ENDPOINT` variable to point to your StackState Agent.
  - We are using a different AWS_PROFILE to deploy this example template as seen under the `serverless.example.yaml` `provider.profile` variable
    - To create this AWS_PROFILE create the following entry under these files:
      - `vi ~/.aws/config`
        - [profile otel-nodejs-example-dev] \
          region=`<REGION_FOR_DEPLOYMENT>` \
          source_profile=`otel-nodejs-example-dev` \
          role_arn=`<A_ROLE_WITH_SUFFICIENT_PERMISSIONS>`
      - `vi ~/.aws/credentials`
        - [otel-nodejs-example-dev] \
          aws_access_key_id=`<ACCESS_KEY>` \
          aws_secret_access_key=`<SECRET_ACCESS_KEY>`
  - Go into this directory with the `serverless.yaml` script
  - Run`sls deploy --config serverless.example.yaml`


## Update your Lambda functions to support Open Telemetry [Required]
The last step is required to allow Open Telemetry to work within your Lambda function.

This step has to be repeated for each of the Lambda functions you want Open Telemetry to work with.

- Open the Lambda Function you wish to add Open Telemetry support to.


- Add the following `Lambda Layers`. ***Also note they MUST be added in this order***
  - An official Open Telemetry layer. This is required for Open Telemetry to process data
    - [https://aws-otel.github.io/docs/getting-started/lambda/lambda-js#add-the-arn-of-the-lambda-layer](https://aws-otel.github.io/docs/getting-started/lambda/lambda-js#add-the-arn-of-the-lambda-layer)
    - Tested with `arn:aws:lambda:<AWS_REGION>:901920570463:layer:aws-otel-nodejs-ver-1-0-0:1`
  - The `nodejs layer` you deployed above under the `Manual Hosting` section. This is required for enriched `StackState Open Telemetry` data.
    - `arn:aws:lambda:<REGION>:<ACCOUNT>:layer:OpenTelemetryNodeJS:<VERSION>`


- Add the following `Environment Variables`
  - `AWS_LAMBDA_EXEC_WRAPPER`
    - /opt/otel-handler
  - `OTEL_LOG_LEVEL`
    - info
  - `OTEL_TRACES_EXPORTER`
    - otlp
  - `OTEL_PROPAGATORS`
    - tracecontext
  - `OTEL_TRACES_SAMPLER`
    - always_on
  - `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`
    - https://**\<STACKSTATE AGENT LOCATION>**/open-telemetry
      - Change this URL to point to the location your StackState Agent is running at

- Also change your Lambda Tracing Config to `PassThrough` or leave it if it is already `Active`
  - What is this ?
    - AWS Lambda functions should have TracingConfig enabled since it activates the AWS X-Ray service. AWS X-Ray service collects information on requests that a specific function performed. It reduces the investigation, debugging and diagnostics time and effort. The value can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service. If no tracing header is received, Lambda will call X-Ray for a tracing decision. It is recommended to use 'Active'.
    - `PassThrough` is recommended, `Active` costs a lot to run
  - Unable to find where PassThrough is set directly on the AWS console, thus here is a cli command to set this
    - `aws lambda update-function-configuration` \ \
      `--region <REGION FOR YOUR FUNCTION>` \ \
      `--function-name <ENTER YOUR FUNCTION NAME HERE>` \ \
      `--profile <OPTIONAL PROFILE FOR AWS ACCESS>` \ \
      `--tracing-config "Mode=PassThrough"`

## Verify your Lambda Function [Optional but Recommended]

- You can verify if you did everything by running the `./verify-otel-support.sh` script
    - It will ask for the following inputs
      - Lambda Function Region
      - Lambda Function Name
      - [Optional] AWS Profile
      - Collector Lambda Layer Name
        - The ARN value you used for the `official Open Telemetry layer` from [https://aws-otel.github.io/docs/getting-started/lambda/lambda-js#add-the-arn-of-the-lambda-layer](https://aws-otel.github.io/docs/getting-started/lambda/lambda-js#add-the-arn-of-the-lambda-layer)
      - NodeJS Lambda Layer Name
        - This will be the layer you deployed manually above
    - The information above will be used to run `Unit Tests` against that Lambda Function to make sure that it contains all the correct information to work with Open Telemetry






