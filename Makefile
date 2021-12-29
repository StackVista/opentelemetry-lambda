# For some reason the collector layer does not work thus we are using the full open telemetry layer from
# https://aws-otel.github.io/docs/getting-started/lambda/lambda-js

#   # Open Telemetry Collector
#   collector-compile:
#   	cd collector && make package
#
#   collector-package: collector-compile
#   	mkdir -p build
#   	rm -rf build/collector
#   	mkdir -p build/collector
#   	cp collector/build/collector-extension.zip build/collector/layer.zip
#   	cp collector/sample-serverless/* build/collector/
#   	shasum --algorithm 256 build/collector/layer.zip > build/collector/layer.sha-256
#
#   collector-deploy:
#   	cd build/collector && serverless deploy
#
#   collector-remove:
#   	cd build/collector && serverless remove



# General Functions
cleanup:
	rm -rf build
	rm -rf collector/build
	rm -rf nodejs/node_modules
	rm -rf nodejs/packages/layer/build
	rm -rf nodejs/packages/layer/node_modules
	rm -rf nodejs/sample-apps/aws-sdk/build
	rm -rf nodejs/sample-apps/aws-sdk/node_modules


# Nodejs Install Functions
node-install: cleanup
	cd nodejs && npm install

node-test: node-install
	cd nodejs && npm run lint && npm run test

node-compile: node-test
	cd nodejs && npm run compile

node-package: node-compile
	mkdir -p build
	rm -rf build/nodejs
	mkdir -p build/nodejs
	cp nodejs/packages/layer/build/layer.zip build/nodejs/layer.zip
	cp nodejs/sample-serverless/* build/nodejs/
	shasum --algorithm 256 build/nodejs/layer.zip > build/nodejs/layer.sha-256

node-deploy: node-package
	cd build/nodejs && serverless deploy

node-deploy-example: node-package
	cd build/nodejs && serverless deploy --config serverless.example.yaml


# Nodejs Verify OTEL Support
node-example-otel-support:
	AWS_PROFILE=otel-nodejs-example-dev \
	FUNCTION=otel-nodejs-example-dev-ExampleOpenTelemetry \
	./build/nodejs/verify-lambda-otel-support.sh


# Nodejs Remove Functions
node-remove:
	cd build/nodejs && serverless remove

node-remove-example:
	cd build/nodejs && serverless remove --config serverless.example.yaml

node-remove-all: node-package node-remove-example node-remove cleanup