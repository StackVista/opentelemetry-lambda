# Official Open Telemetry Collector Layer

These layers are officially hosted with an Open Telemetry account on https://aws-otel.github.io/docs/getting-started/lambda

We attempt to download these Lambda layers in their respective zip folders allowing the client to redeploy them


## Pull Official Layer Zip Folders
Run the `./pull-layers.sh` to pull all the latest layers based on the env variables defined above
This will pull the official Lambda layer zip files into the layers folder


## Flows
Because of the way things are built within this project there's two README files for each language. One for a dev flow and one for a official package flow.


### Developer Flows
When you are developing features and only want to test this single layer without packing everything

- [NodeJS - README.DEV.md](layers/nodejs/README.DEV.md)
- [Python - README.DEV.md](layers/python38/README.DEV.md)
- [Golang - README.DEV.md]() [Not Available]
- [DotNET - README.DEV.md]() [Not Available]
- [Java - README.DEV.md]() [Not Available]

### Build Flows

For builds packing in the official layer to allow a full deploy process [Do not use this if you are attempting to directly deploy from this folder and not the build folder]

- [NodeJS - README.BUILD.md](layers/nodejs/README.BUILD.md)
- [Python - README.BUILD.md]() [Not Available]
- [Golang - README.BUILD.md]() [Not Available]
- [DotNET - README.BUILD.md]() [Not Available]
- [Java - README.BUILD.md]() [Not Available]

