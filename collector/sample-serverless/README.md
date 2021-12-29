# OpenTelemetry Collector Layer
This layer is a stripped-down version of [OpenTelemetry Collector Contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib) inside an [AWS Extension Layer](https://aws.amazon.com/blogs/compute/introducing-aws-lambda-extensions-in-preview/).
This allows lambdas to use the OpenTelemetry Collector Exporter to send traces and metrics to any configured backend.

This layer is required alongside another layer for the language you are using for example a NodeJS layer.
They will work together to accomplish the same goal by sending aws-sdk data to a backend.


## File Content Verification

Run one of the following commands and compare the result to the SHA artifact to confirm the content of this zip file is legit.

- MacOS
  - `shasum --algorithm 256 layer.zip`
- Windows
  - `Get-FileHash -Path layer.zip -Algorithm SHA256`
- Linux
  - `sha256sum layer.zip`


## Deploy this Collector Layer [Required]
There is 2 methods to deploy this layer (Each containing a local and official zip method), you can either `manually` create the layer or deploy it with the given `serverless` script

The local version allows you to use the zip file from your local drive and the
`official artifact` version allows you to point and download a zip file hosted by StackState instead of using a local one (Recommended version with the Hash comparisons).


#### ⚠ ⚠ Official Artifacts Coming Soon ⚠ ⚠
### Manual (Local Zip File)
- Head over to this AWS Lambda Layer page https://console.aws.amazon.com/lambda/home#/layers
- Click on the `Create Layer` button in the top right corner
- Give the lambda layer a name (Recommended calling it `OpenTelemetryCollector` and required if you are planning to use any of the other serverless.yaml scripts)
- Tick the `Upload a .zip file` and click the `upload button`
- Select and Upload the [`layer.zip`](layer.zip) found next to this README
- Click the create button to create this Lambda Layer
- Open the README.md of the language layer you wish to deploy IE `/build/nodejs/README.md`

### Serverless (Local Zip File)
- Make sure you have `node` & `npm` installed
- Run `npm install serverless -g` to install the serverless npm package in your global structure
- Go into this directory `cd build/collector` and run `sls deploy`
- Open the README.md of the language layer you wish to deploy IE `/build/nodejs/README.md`

