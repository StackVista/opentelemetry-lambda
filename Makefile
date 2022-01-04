AGENT_BRANCH=STAC-0-Open-telemetry-support
STACKSTATE_ENDPOINT=http://192.168.0.100:7077/stsAgent


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

nodejs-package: nodejs-agent-package
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

	# Cleanup Before Packaging
	rm -rf build/nodejs-build.zip
	rm -rf build/nodejs/sample-agent/Makefile
	mv build/nodejs/layer-deploy/README.md build/nodejs/README.md

	chmod +x build/nodejs/sample-agent/otel-agent-deploy-run.sh
	zip build/nodejs-build.zip build/nodejs/* -r
	# shasum --algorithm 256 build/nodejs/layer.zip > build/nodejs/layer.sha-256

nodejs-deploy-layer:
	cd build/nodejs/layer-deploy && \
		npm install && \
		npx sls deploy

nodejs-deploy-example:
	cd build/nodejs/layer-usage && \
		npm install && \
		OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=https://stackstate.trace-agent.ngrok.io \
		npx sls deploy

nodejs-verify-support:
	AWS_PROFILE=otel-nodejs-example-dev \
		./build/nodejs/layer-deploy/otel-support.sh

nodejs-verify-example-otel-support:
	IGNORE_OPTIONS=true \
		AWS_PROFILE=otel-nodejs-example-dev \
		FUNCTION=otel-nodejs-example-dev-ExampleOpenTelemetry \
		./build/nodejs/layer-deploy/otel-support.sh

nodejs-stop-agent-background:
	cd build/nodejs/sample-agent && \
		AGENT_BRANCH=${AGENT_BRANCH} \
		STACKSTATE_ENDPOINT=${STACKSTATE_ENDPOINT} \
        STS_API_KEY="${STS_API_KEY}" \
		docker-compose --file otel-agent-docker-compose.yml kill

nodejs-run-agent-background: nodejs-stop-agent-background
	cd build/nodejs/sample-agent && \
		docker load -i otel-agent.docker

	cd build/nodejs/sample-agent && \
		AGENT_BRANCH=${AGENT_BRANCH} \
        STS_API_KEY="${STS_API_KEY}" \
        STACKSTATE_ENDPOINT="${STACKSTATE_ENDPOINT}" \
        docker-compose --file otel-agent-docker-compose.yml up

nodejs-remove:
	cd build/nodejs/layer-deploy && \
		npm install && \
		npx sls remove

nodejs-remove-example:
	cd build/nodejs/layer-usage && \
        npm install && \
        OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=https://stackstate.trace-agent.ngrok.io \
        npx sls remove

nodejs-complete-install: nodejs-package nodejs-deploy-layer nodejs-deploy-example nodejs-verify-example-otel-support nodejs-stop-agent-background
	read -n 1 -r -s -p '!!!!!!! Edit the build/nodejs/sample-agent/aws_topology.yaml file, Then press enter ... !!!!!!!'
	make nodejs-run-agent-background

nodejs-complete-uninstall: nodejs-verify-dir nodejs-remove-example nodejs-remove nodejs-stop-agent-background nodejs-cleanup

ngrok-local:
	ngrok http --region=us --hostname=stackstate.trace-agent.ngrok.io 8126
