## Addon AWS Instrumentation
These modules add functionality on top of the already existing @opentelemetry/instrumentation-aws-sdk library adding missing information or information required to create a
complete trace from the left to right.

For example with the current SNS SDK Open Telemetry response we do not receive a Topic ARN making it impossible to create a link
showing the Lambda and the SNS that was targeted.

Current Addon Support Added:

- Lambda
  - Add the `invoked function` name into sample


- Step Function
  - .

- S3
  - Add the `bucket name` into the sample


- SNS
  - Add the `topic arn` into the sample
