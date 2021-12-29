# Open Telemetry Collector
collector-compile:
	cd collector && make package

collector-package: collector-compile
	mkdir -p build
	rm -rf build/collector
	mkdir -p build/collector
	cp collector/build/collector-extension.zip build/collector/layer.zip
	cp collector/sample-serverless/* build/collector/
	shasum --algorithm 256 build/collector/layer.zip > build/collector/layer.sha-256

collector-deploy:
	cd build/collector && serverless deploy

collector-remove:
	cd build/collector && serverless remove



# Nodejs Functions
node-install:
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

node-deploy: collector-deploy
	cd build/nodejs && serverless deploy

node-remove:
	cd build/nodejs && serverless remove



# Custom Steps
complete-package: collector-package node-package

manual-package-nodejs:
	rm -rf build
	make collector-package
	make node-package
	cp README.BUILD.md build/README.md
	zip -r build/manual-sts-open-telemetry.zip build
	shasum --algorithm 256 build/manual-sts-open-telemetry.zip > build/manual-sts-open-telemetry.sha-256