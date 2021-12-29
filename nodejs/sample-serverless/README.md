# OpenTelemetry NodeJS Layer
## Introduction
This layer is required for running NodeJS applications on AWS Lambda with OpenTelemetry

#### ⚠ ⚠ WARNING ⚠ ⚠ - This layer will not work if you did not deploy the `Collector Lambda Layer` both is required for Open Telemetry to work

## File Content Verification
Coming Soon, Can be used to verify the content of your zip against a officially deployed zip file. \
Run one of the following commands and compare the result to the SHA artifact to confirm the content of this zip file is legit.

- MacOS
  - `shasum --algorithm 256 layer.zip`
- Windows
  - `Get-FileHash -Path layer.zip -Algorithm SHA256`
- Linux
  - `sha256sum layer.zip`



## Deploy this NodeJS layer [Required]
There is 2 methods to deploy this layer (Each containing a local and official zip method), you can either `manually` create the layer or deploy it with the given `serverless` script

The local version allows you to use the zip file from your local drive and the
`official artifact` version allows you to point and download a zip file hosted by StackState instead of using a local one (Recommended version with the Hash comparisons).



#### ⚠ ⚠ Official Artifacts Coming Soon ⚠ ⚠
#### ⚠ ⚠ WARNING ⚠ ⚠ - This layer will not work if you did not deploy the `Collector Lambda Layer` both is required for Open Telemetry to work

### Manual (Local Zip File)
- Head over to your AWS Lambda Layer page https://console.aws.amazon.com/lambda/home#/layers
- Click on the `Create Layer` button in the top right corner
- Give the lambda layer a name (Recommended calling it `OpenTelemetryNodeJS` and required if you are planning to use any of the other serverless.yaml scripts)
- Tick the `Upload a .zip file` and click the `upload button`
- Select and Upload the [`layer.zip`](layer.zip) found next to this README
- Click the create button to create this Lambda Layer

### Serverless (Local Zip File)
- Make sure you have `node` & `npm` installed
- Run `npm install serverless -g` to install the serverless npm package in your global structure
- Go into this directory `cd build/nodejs` and run `sls deploy`



## Deploy Example [Not Required - Optional]
By deploying this file [serverless.example.yaml](serverless.example.yaml) you will have access to an example Lambda using the Layers you deployed with Open Telemetry.

#### ⚠ ⚠ WARNING ⚠ ⚠
Only works if you used the recommended names for your layers IE `OpenTelemetryNodeJS`

This example will show you traces for the following services:
- **SQS**
- **SNS**
- **Lambda to Lambda** Communication
- **S3**
- **Step Function**
- .... This list may contain more based on generic mappings ....

Run the following command to deploy the example. (It will deploy a AWS service for each of the examples above to show communication)
- Change the `OTEL_EXPORTER_OTLP_ENDPOINT` variable to point to your StackState agent in the `serverless.example.yaml` file
- Make sure you have `node` & `npm` installed
- Run `npm install serverless -g` to install the serverless npm package in your global structure
- Run `sls deploy --config serverless.example.yaml`

## Update your Lambda function to support Open Telemetry [Required]
The last steps required to allow your Lambda to work with Open Telemetry is doing the following for each of your Lambda Functions:

- Open the Lambda Function you wish to add Open Telemetry support to.
- Add the following Environment Variables
  - `AWS_LAMBDA_EXEC_WRAPPER`
    - /opt/otel-handler
  - `OTEL_TRACES_EXPORTER`
    - logging
  - `OTEL_METRICS_EXPORTER`
    - logging
  - `OTEL_LOG_LEVEL`
    - DEBUG
  - `OTEL_EXPORTER_OTLP_ENDPOINT`
    - http://localhost:55681/v1/traces
      - Change this URL to point to the location your StackState agent is running


- Also change the Lambda Tracing Config to PassThrough, Unable to find a PassThrough option directly on the console, thus here is a cli command to set this
  - `aws lambda update-function-configuration` \ \
    `--region <REGION FOR YOUR FUNCTION>` \ \
    `--function-name <ENTER YOUR FUNCTION NAME HERE>` \ \
    `--profile <OPTIONAL PROFILE FOR AWS ACCESS FOR EXAMPLE sts-opentelemetry-nodejs-dev>` \ \
    `--tracing-config "Mode=PassThrough"`


- You can verify if you did everything by running the `./verify-lambda-otel-support.sh` script
    - It will ask for the following inputs
      - Lambda Function Region
      - Lambda Function Name
      - [Optional] AWS Profile
      - Collector Lambda Layer Name
      - NodeJS Lambda Layer Name
    - The information above will be used to run Unit Tests against that Lambda Funciton to make sure that it contains all the correct information to work with Open Telemetry






