# Open Telemetry StackState NodeJS Layer

## Introduction

The functionality below will allow communication between your Lambda and the StackState Trace agent by using a service called Open Telemetry.
This Open Telemetry service will be deployed as a Lambda layer and included within your Lambda function to complete the cycle.
You will also deploy a second layer that enhances this data allowing a more enriched trace overview.

## Prerequisites

- A running StackState instance `[Usually on port 7070]`
- `Amazon Web Services Stackpack` installed and setup completed
  - Will contain the same key, role and external id where this layer will be hosted.
- `StackState Agent V2 Stackpack` installed

## Lambda Requirements

Summary of the steps required:

- Deploy a Lambda Layer for the Open Telemetry Collector
- Deploy a Lambda Layer for the NodeJS Enrich Layer
- Existing Lambda script updates
  - Add Environment Variables
  - Reference the `Open Telemetry Collector` layer.
  - Reference the `NodeJS Enrich` layer.

## Deploying the Open Telemetry Collector Layer [Recommended]

You have two options when deploying, serverless or manual.

You can create the required elements through the `AWS Console` or
run the `Serverless script`, Which should automatically deploy the layer for you and make future upgrades a bit easier.

- `Serverless`
  - Make sure you have `node` & `npm` installed on your environment
  - Go into the directory `build/collector-layer` and run the following command `npm install` to install the node and serverless packages.
  - An `AWS_PROFILE` is required to deploy this template as seen in the `serverless.yaml` under the `provider.profile` variable
    - To create this `AWS_PROFILE` create the following entry under these files:
      - `vi ~/.aws/config`
        ```
        [profile otel-nodejs-collector-dev]
        region=<REGION_FOR_DEPLOYMENT>
        source_profile=otel-nodejs-collector-dev
        role_arn=<A_ROLE_WITH_SUFFICIENT_PERMISSIONS>
        ```
      - `vi ~/.aws/credentials`
        ```
        [otel-nodejs-collector-dev]
        aws_access_key_id=`<ACCESS_KEY>`
        aws_secret_access_key=`<SECRET_ACCESS_KEY>`
        ```
  - Run the following to deploy the serverless template
    ```
      RUNTIME="nodejs14.x" \
      PULL_LAYER_TYPE="nodejs" \
      npx sls deploy
    ```
  - To verify the cloudformation template, you can go to your AWS account under cloudformation and see an active job called`otel-nodejs-collector-dev`


- `AWS Console [Manual]`
  - Head over to your AWS lambda layers page: [https://console.aws.amazon.com/lambda/home#/layers](https://console.aws.amazon.com/lambda/home#/layers)
  - Click on the `Create Layer` button in the top right corner
  - Give the lambda layer a name `(Recommended calling it 'otel-nodejs-layer' and is required if you are planning to use any of the example serverless.yaml scripts)`
  - Tick the `Upload a .zip file` and click the `upload button
  - Select and Upload the [`build/collector-layer/layers/nodejs/layer.zip`](build/collector-layer/layers/nodejs//layer.zip)
  - Click the Create button to create this Lambda Layer


## Deploying the Open Telemetry Enrich Layer [Recommended]

- `Serverless`
  - Make sure you have `node` & `npm` installed on your environment
  - Go into the directory `build/enrich-layer` and run the following command `npm install` to install the node and serverless packages.
  - An `AWS_PROFILE` is required to deploy this template as seen in the `serverless.yaml` under the `provider.profile` variable
    - To create this `AWS_PROFILE` create the following entry under these files:
      - `vi ~/.aws/config`
        ```
        [profile otel-nodejs-dev]
        region=<REGION_FOR_DEPLOYMENT>
        source_profile=otel-nodejs-dev
        role_arn=<A_ROLE_WITH_SUFFICIENT_PERMISSIONS>
        ```
      - `vi ~/.aws/credentials`
        ```
        [otel-nodejs-dev]
        aws_access_key_id=`<ACCESS_KEY>`
        aws_secret_access_key=`<SECRET_ACCESS_KEY>`
        ```
  - Run the following to deploy the serverless template
    ```
    npx sls deploy
    ```
  - To verify the cloudformation template, you can go to your AWS account under cloudformation and see a active job called`otel-nodejs-dev`


- `AWS Console [Manual]`
  - Head over to your AWS lambda layers page: [https://console.aws.amazon.com/lambda/home#/layers](https://console.aws.amazon.com/lambda/home#/layers)
  - Click on the `Create Layer` button in the top right corner
  - Give the lambda layer a name `(Recommended calling it 'otel-nodejs-layer' and is required if you are planning to use any of the example serverless.yaml scripts)`
  - Tick the `Upload a .zip file` and click the `upload button
  - Select and Upload the [`build/enrich-layer/layer.zip`](build/enrich-layer/layer.zip)
  - Click the Create button to create this Lambda Layer


## Open Telemetry Usage Example [Optional]

#### ⚠ ⚠ WARNING ⚠ ⚠
It only works if you used the recommended name for the layer you deployed above IE `otel-nodejs-layer`

Deploying this example will create the following AWS Services allowing you to see traces from all of them:
- `Lambda Function`
  - Primary Open Telemetry Example Function
- `Lambda Receiver Function`
  - Receive calls from the first Lambda to show Lambda communications
- `SQS`
- `SNS`
- `S3`
- `Step Function`

### Deploying the example

You have two options when deploying, serverless or manual.

You can create the required elements through the `AWS Console` or
run the `Serverless script`, Which should automatically deploy the layer for you and make future upgrades a bit easier.

- `Serverless`
  - Make sure you have `node` & `npm` installed on your environment
  - Go into the directory `build/enrich-layer/usage-example` and run the following command `npm install` to install the npm packages
  - We are using a different `AWS_PROFILE` to deploy this example template as seen under the `serverless.yaml` `provider.profile` variable
    - To create this `AWS_PROFILE` create the following entry under these files:
      - `vi ~/.aws/config`
        ```
        [profile otel-nodejs-example-dev]
        region=`<REGION_FOR_DEPLOYMENT>`
        source_profile=`otel-nodejs-example-dev`
        role_arn=`<A_ROLE_WITH_SUFFICIENT_PERMISSIONS>`
        ```
      - `vi ~/.aws/credentials`
        ```
        [otel-nodejs-example-dev]
        aws_access_key_id=`<ACCESS_KEY>`
        aws_secret_access_key=`<SECRET_ACCESS_KEY>`
        ```
  - Go into this directory with the `enrich-layer/usage-example/serverless.yaml` script
  - Run
    ```
    npx sls plugin install -n serverless-step-functions
    ```
  - Run the following to deploy the serverless template [Change the URL to the location where the StackState Trace Agent is running]:
    ```
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=https://stackstate.trace-agent.ngrok.io \
    npx sls deploy
    ```
  - To verify the cloudformation template, you can go to your AWS account and see it under cloudformation as `otel-nodejs-example-dev`


## Update your Lambda functions to support Open Telemetry [Required]

The last step is required to allow Open Telemetry to function within your Lambda.

This step will have to be repeated for each Lambda function you want Open Telemetry to work with.

- Open the Lambda Function you wish to add Open Telemetry support to (One of your existing Lambda functions).
- Add the following `Lambda Layers`.  ***Also note they MUST be added in this order***
  - The `Collector Layer` you deployed above under the `Manual Hosting`
    - `arn:aws:lambda:<REGION>:<ACCOUNT>:layer:otel-nodejs-collector-layer:<VERSION>`
  - The `NodeJS Enrich Layer` you deployed above under the `Manual Hosting`
    - `arn:aws:lambda:<REGION>:<ACCOUNT>:layer:otel-nodejs-layer:<VERSION>`
- Add the following `Environment Variables`
  - `AWS_LAMBDA_EXEC_WRAPPER`: /opt/otel-handler
  - `OTEL_LOG_LEVEL`: info
  - `OTEL_TRACES_EXPORTER`: otlp
  - `OTEL_PROPAGATORS`: tracecontext
  - `OTEL_TRACES_SAMPLER`: always_on
  - `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`: https://**\<STACKSTATE AGENT LOCATION>**/open-telemetry
    - Change the URL to point to the location your StackState Agent is running at, *** Remember to end the URL with /open-telemetry as seen above***.
- Also change your Lambda Tracing Config to `PassThrough` or leave it if it is already `Active`
  - What is this ?
    - AWS Lambda functions should have TracingConfig enabled since it activates the AWS X-Ray service. AWS X-Ray service collects information on requests that a specific function performed. It reduces the investigation, debugging and diagnostics time and effort. The value can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service. If no tracing header is received, Lambda will call X-Ray for a tracing decision. It is recommended to use 'Active'.
    - `PassThrough` is recommended, `Active` costs a lot to run
  - Unable to find where PassThrough is set directly on the AWS console, thus here is a CLI command to set this
    - ```
      aws lambda update-function-configuration \
      --region <REGION FOR YOUR FUNCTION> \
      --function-name <ENTER YOUR FUNCTION NAME HERE> \
      --profile <OPTIONAL PROFILE FOR AWS ACCESS> \
      --tracing-config "Mode=PassThrough"
      ```

## Verify your Lambda Function [Optional but Recommended]

- You can verify if you did everything by running the `./build/enrich-layer/otel-support.sh` script
  - It will ask for the following inputs
    - `Lambda Function Region`
    - `Lambda Function Name`
    - [Optional] `AWS Profile`
    - `NodeJS Lambda Layer Name`
      - This will be the layer you deployed manually above
  - The information above will be used to run `Unit Tests` against that Lambda Function to make sure that it contains all the correct information to work with Open Telemetry. If anything fails then your Open Telemetry might not work.


# Custom Agent Deployment [Pre Release]

Follow these steps to run the agent that contains the current Open Telemetry example code.

- Enter the `sample-agent` directory
  - You will notice a `otel-agent.docker` file. This temp file is a Docker file containing the updated code for open telemetry
- Edit the `aws_topology.yaml` details to contain the same information entered for your `AWS Stackpack` the agent will use this file in the conf.d section
  - `Role ARN` - the ARN of the IAM Role created by the CloudFormation Stack. For example, arn:aws:iam::<account id>:role/StackStateAwsIntegrationRole where <account id> is the 12-digit AWS account ID that is being monitored.
  - `External ID` - a shared secret that StackState will present when assuming a role. Use the same value across all AWS accounts. For example, uniquesecret!1
  - `AWS Access Key ID` - The Access Key ID of the IAM user used by the StackState Agent. If the StackState instance is running within AWS, enter the value use-role and the instance will authenticate using the attached IAM role.
  - `AWS Secret Access Key` - The Secret Access Key of the IAM user used by the StackState Agent. If the StackState instance is running within AWS, enter the value use-role and the instance will authenticate using the attached IAM role.
- Make sure the following env variables are available for the docker agent to function. (This environment variable values can be found on the StackPack Agent v2 installation page)
  - `STACKSTATE_ENDPOINT`
    - The location where you are running your `StackState Receiver` and `Port [Usually 7077]`. You can see where this URL is used in the `otel-agent-docker-compose.yml` file
    - Example of this URL will look like this: http://192.168.1.104:7077/stsAgent
  - `STS_API_KEY`
    - Your StackState agent API key
  - `AGENT_BRANCH`
    - Make this value `STAC-0-Open-telemetry-support` as this is the current test branch used
- You can run the `otel-agent-deploy-run.sh` to deploy and run this docker image
- To manually run this docker instance execute these two commands
  ```
  docker load -i otel-agent.docker
  ```
  ```
  STACKSTATE_ENDPOINT=${STACKSTATE_ENDPOINT} \
  STS_API_KEY="${STS_API_KEY}" \
  AGENT_BRANCH="${AGENT_BRANCH}" \
  docker-compose --file otel-agent-docker-compose.yml up
  ```

To remove this Docker image run the following command:
```
docker rmi stackstate/stackstate-agent-2-test:STAC-0-Open-telemetry-support --force
```

## ***You can now run the ExampleOpenTelemetry Lambda or Lambda function you added OTEL support for***
