AGENT_BRANCH=STAC-0-Open-telemetry-support
STACKSTATE_ENDPOINT=http://192.168.0.100:7077/stsAgent
OTLP_TRACES_PROTOCAL=https
OTLP_TRACES_ENDPOINT=stackstate.trace-agent.ngrok.io


##########################################################
#################### Official Layer ######################
##########################################################

official-collector-cleanup:
	rm -rf collector/official-layers/node_modules

	rm -rf build/nodejs/official-layer
	rm -rf collector/official-layers/layers/nodejs/layer
	rm -rf collector/official-layers/layers/nodejs/layer.zip

	rm -rf build/python38/official-layer
	rm -rf collector/official-layers/layers/python38/layer
	rm -rf collector/official-layers/layers/python38/layer.zip

official-collector-install:
	cd collector/official-layers && \
		./pull-layers.sh

official-collector-package: official-collector-install
	mkdir -p build/nodejs/official-layer/layers/nodejs
	mkdir -p build/python38/official-layer/layers/python38
	mkdir -p build/dotnet/official-layer/layers/dotnet
	mkdir -p build/golang/official-layer/layers/golang
	mkdir -p build/java/official-layer/layers/java

	cp collector/official-layers/layers/nodejs/layer.zip build/nodejs/official-layer/layers/nodejs/layer.zip
	cp collector/official-layers/layers/nodejs/README.md build/nodejs/official-layer/README.md
	cp collector/official-layers/serverless.yaml build/nodejs/official-layer/serverless.yaml
	cp collector/official-layers/package.json build/nodejs/official-layer/package.json

	cp collector/official-layers/layers/python38/layer.zip build/python38/official-layer/layers/python38/layer.zip
	cp collector/official-layers/layers/python38/README.md build/python38/official-layer/README.md
	cp collector/official-layers/serverless.yaml build/python38/official-layer/serverless.yaml
	cp collector/official-layers/package.json build/python38/official-layer/package.json

	cp collector/official-layers/layers/dotnet/layer.zip build/dotnet/official-layer/layers/dotnet/layer.zip
	cp collector/official-layers/layers/dotnet/README.md build/dotnet/official-layer/README.md
	cp collector/official-layers/serverless.yaml build/dotnet/official-layer/serverless.yaml
	cp collector/official-layers/package.json build/dotnet/official-layer/package.json

	cp collector/official-layers/layers/golang/layer.zip build/golang/official-layer/layers/golang/layer.zip
	cp collector/official-layers/layers/golang/README.md build/golang/official-layer/README.md
	cp collector/official-layers/serverless.yaml build/golang/official-layer/serverless.yaml
	cp collector/official-layers/package.json build/golang/official-layer/package.json

	cp collector/official-layers/layers/java/layer.zip build/java/official-layer/layers/java/layer.zip
	cp collector/official-layers/layers/java/README.md build/java/official-layer/README.md
	cp collector/official-layers/serverless.yaml build/java/official-layer/serverless.yaml
	cp collector/official-layers/package.json build/java/official-layer/package.json

official-collector-deploy-nodejs: official-collector-package
	cd build/nodejs/official-layer && npm install
	cd build/nodejs/official-layer && \
      	RUNTIME="nodejs14.x" \
      	PULL_LAYER_TYPE="nodejs" \
      	npx sls deploy

official-collector-deploy-python: official-collector-package
	cd build/python38/official-layer && npm install
	cd build/python38/official-layer && \
      	RUNTIME="python3.8" \
      	PULL_LAYER_TYPE="python38" \
      	npx sls deploy

official-collector-deploy-java: official-collector-package
	cd build/java/official-layer && npm install
	cd build/java/official-layer && \
      	RUNTIME="java11" \
      	PULL_LAYER_TYPE="java" \
      	npx sls deploy

official-collector-deploy-golang: official-collector-package
	cd build/golang/official-layer && npm install
	cd build/golang/official-layer && \
      	RUNTIME="go1.x" \
      	PULL_LAYER_TYPE="golang" \
      	npx sls deploy

official-collector-deploy-dotnet: official-collector-package
	cd build/dotnet/official-layer && npm install
	cd build/dotnet/official-layer && \
      	RUNTIME="dotnetcore3.1" \
      	PULL_LAYER_TYPE="dotnet" \
      	npx sls deploy

official-collector-remove-nodejs: official-collector-package
	cd build/nodejs/official-layer && npm install
	cd build/nodejs/official-layer && \
      	RUNTIME="nodejs14.x" \
      	PULL_LAYER_TYPE="nodejs" \
      	npx sls remove

official-collector-remove-python: official-collector-package
	cd build/python38/official-layer && npm install
	cd build/python38/official-layer && \
      	RUNTIME="python3.8" \
      	PULL_LAYER_TYPE="python38" \
      	npx sls remove

official-collector-remove-java: official-collector-package
	cd build/java/official-layer && npm install
	cd build/java/official-layer && \
      	RUNTIME="java11" \
      	PULL_LAYER_TYPE="java" \
      	npx sls remove

official-collector-remove-golang: official-collector-package
	cd build/golang/official-layer && npm install
	cd build/golang/official-layer && \
      	RUNTIME="go1.x" \
      	PULL_LAYER_TYPE="golang" \
      	npx sls remove

official-collector-remove-dotnet: official-collector-package
	cd build/dotnet/official-layer && npm install
	cd build/dotnet/official-layer && \
      	RUNTIME="dotnetcore3.1" \
      	PULL_LAYER_TYPE="dotnet" \
      	npx sls remove

official-collector-deploy-all: official-collector-deploy-nodejs official-collector-deploy-python official-collector-deploy-java official-collector-deploy-golang official-collector-deploy-dotnet
official-collector-remove-all: official-collector-remove-nodejs official-collector-remove-python official-collector-remove-java official-collector-remove-golang official-collector-remove-dotnet






##################################################
#################### NODEJS ######################
##################################################

nodejs-verify-dir:
	mkdir -p build/nodejs/layer-deploy
	mkdir -p build/nodejs/layer-usage
	mkdir -p build/nodejs/sample-agent

nodejs-cleanup: nodejs-verify-dir
	rm -rf build/nodejs
	rm -rf build/nodejs-build.zip
	rm -rf nodejs/node_modules
	rm -rf nodejs/packages/layer/build
	rm -rf nodejs/packages/layer/node_modules
	rm -rf nodejs/sample-apps/aws-sdk/build
	rm -rf nodejs/sample-apps/aws-sdk/node_modules
	rm -rf nodejs/sample-apps/layer-usage/node_modules
	rm -rf nodejs/sample-apps/sts-agent/otel-agent.docker

nodejs-install: nodejs-cleanup
	cd nodejs && \
		npm install
	cd nodejs/sample-apps/layer-usage && \
		npm install

nodejs-test: nodejs-install
	cd nodejs && \
		npm run lint && \
		npm run test

nodejs-compile: nodejs-test
	cd nodejs && \
		npm run compile

nodejs-agent-package: nodejs-compile
	cd nodejs/sample-apps/sts-agent && \
		AGENT_BRANCH=${AGENT_BRANCH} \
		STS_API_KEY=${STS_API_KEY} \
		STACKSTATE_ENDPOINT=${STACKSTATE_ENDPOINT} \
		make pull-agent-docker-image

nodejs-package: nodejs-agent-package official-collector-package
	# nodejs-agent-package
	mkdir -p build/nodejs/layer-deploy
	mkdir -p build/nodejs/layer-usage
	mkdir -p build/nodejs/sample-agent

	# Cleanup Before Copy
	rm -rf nodejs/sample-apps/layer-usage/node_modules
	rm -rf nodejs/sample-apps/layer-deploy/node_modules

	cp -R nodejs/packages/layer/build/layer.zip build/nodejs/layer-deploy/layer.zip # NodeJS Lambda
	cp -R nodejs/sample-apps/layer-deploy/* build/nodejs/layer-deploy # Serverless base
	cp -R nodejs/sample-apps/layer-usage/* build/nodejs/layer-usage # Serverless example base
	cp -R nodejs/sample-apps/sts-agent/* build/nodejs/sample-agent
	cp -R nodejs/sample-apps/README.md build/nodejs/README.md

	# Cleanup Before Packaging
	rm -rf build/nodejs-build.zip
	rm -rf build/nodejs/sample-agent/Makefile

	chmod +x build/nodejs/sample-agent/otel-agent-deploy-run.sh

	# TODO
	# zip build/nodejs-build.zip build/nodejs/* -r

nodejs-deploy-layer: official-collector-deploy-nodejs
	cd build/nodejs/layer-deploy && \
		npm install && \
		npx sls deploy

nodejs-deploy-example: nodejs-deploy-layer
	cd build/nodejs/layer-usage && \
		npm install && \
		OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=${OTLP_TRACES_PROTOCAL}://${OTLP_TRACES_ENDPOINT} \
		npx sls deploy

	IGNORE_OPTIONS=true \
		AWS_PROFILE=otel-nodejs-example-dev \
		FUNCTION=otel-nodejs-example-dev-ExampleOpenTelemetry \
		./build/nodejs/layer-deploy/otel-support.sh

nodejs-remove:
	cd build/nodejs/layer-deploy && \
		npm install && \
		npx sls remove

nodejs-remove-example:
	cd build/nodejs/layer-usage && \
        npm install && \
        OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=${OTLP_TRACES_PROTOCAL}://${OTLP_TRACES_ENDPOINT} \
        npx sls remove

nodejs-run-agent-background: nodejs-stop-agent-background
	cd build/nodejs/sample-agent && \
		docker load -i otel-agent.docker

	cd build/nodejs/sample-agent && \
		AGENT_BRANCH=${AGENT_BRANCH} \
        STS_API_KEY="${STS_API_KEY}" \
        STACKSTATE_ENDPOINT="${STACKSTATE_ENDPOINT}" \
        docker-compose --file otel-agent-docker-compose.yml up

nodejs-stop-agent-background:
	cd build/nodejs/sample-agent && \
		AGENT_BRANCH=${AGENT_BRANCH} \
		STACKSTATE_ENDPOINT=${STACKSTATE_ENDPOINT} \
        STS_API_KEY="${STS_API_KEY}" \
		docker-compose --file otel-agent-docker-compose.yml kill




# Dev Extra - TODO Remove or Integrate into this script

nodejs-complete-install: nodejs-package nodejs-deploy-layer nodejs-deploy-example nodejs-verify-example-otel-support nodejs-stop-agent-background
	read -n 1 -r -s -p '!!!!!!! Edit the build/nodejs/sample-agent/aws_topology.yaml file, Then press enter ... !!!!!!!'
	make nodejs-run-agent-background

nodejs-complete-uninstall: nodejs-verify-dir nodejs-remove-example nodejs-remove nodejs-stop-agent-background nodejs-cleanup

ngrok-local:
	ngrok http --region=us --hostname="${OTLP_TRACES_ENDPOINT}" 8126
