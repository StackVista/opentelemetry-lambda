# Deploying the Official Open Telemetry Lambda Layer

You have two options when deploying, serverless or manual.

You can create the required elements through the `AWS Console` or
run the `Serverless` script, Which should automatically deploy the layer for you and make future upgrades a bit easier.

- `Serverless`
    - Make sure you have `node` & `npm` installed on your environment
    - Run the following command in this directory `npm install` to install the node and serverless packages.
    - An `AWS_PROFILE` is required to deploy this template as seen in the `serverless.yaml` under the `provider.profile` variable
        - To create this `AWS_PROFILE` create the following entry under these files:
            - `vi ~/.aws/config`
              ```
              [profile otel-python38-collector-dev]
              region=<REGION_FOR_DEPLOYMENT>
              source_profile=otel-python38-collector-dev
              role_arn=<A_ROLE_WITH_SUFFICIENT_PERMISSIONS>
              ```
            - `vi ~/.aws/credentials`
              ```
              [otel-python38-collector-dev]
              aws_access_key_id=`<ACCESS_KEY>`
              aws_secret_access_key=`<SECRET_ACCESS_KEY>`
              ```
    - Run the following to deploy the serverless template (No need to bump the layer version this is the version we pulled from the official Lambda Layer)
      ```
      RUNTIME="python3.8" \
      PULL_LAYER_TYPE="python38" \
      npx sls deploy
      ```
    - To verify the cloudformation template, you can go to your AWS account under cloudformation and see an active job called `otel-python38-collector-dev`

After the deployment is done a Lambda Layer should appear under [https://eu-west-1.console.aws.amazon.com/lambda/home#/layers](https://eu-west-1.console.aws.amazon.com/lambda/home#/layers) called `otel-python38-collector-layer`




