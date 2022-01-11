# Official Open Telemetry Collector Layer

These layers are officially hosted with an Open Telemetry account on https://aws-otel.github.io/docs/getting-started/lambda

We attempt to download these Lambda layers in their respective zip folders allowing the client to redeploy them


## Pull Official Layer Zip Folders
Run the `./pull-layers.sh` to pull all the latest layers based on the env variables defined above
This will pull the official Lambda layer zip files into the layers folder

## Deployment

- [NodeJS - README.md](layers/nodejs/README.md)
- [Python - README.md](layers/python38/README.md)
- [Golang - README.md]() [Not Available]
- [DotNET - README.md]() [Not Available]
- [Java - README.md]() [Not Available]

