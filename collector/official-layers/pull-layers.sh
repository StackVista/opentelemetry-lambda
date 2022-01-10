source env-setup.sh

echo "Downloading Official Open Telemetry Layers ..."

download_official_layer () {
  LANGUAGE="$1"
  IDENTIFIER="$2"
  REGION="$3"
  LAYER_VERSION="$4"
  VERSION="$5"
  
  LAYER_PATH="layers/$IDENTIFIER"

  if [ ! -f "$LAYER_PATH/layer.zip" ]; then
    LAMBDA_LAYER="arn:aws:lambda:$REGION:901920570463:layer:aws-otel-$LANGUAGE-ver-$VERSION:$LAYER_VERSION"

    echo "Attempting to get layer version from $LAMBDA_LAYER"

    TARGET_URL=$(aws lambda get-layer-version-by-arn --arn "$LAMBDA_LAYER" --output text --query "Content.Location")

    if [[ "$TARGET_URL" == *"error"* || -z $TARGET_URL ]]; then
      echo "[FAILURE] Unable to retrieve the layer: $LANGUAGE $REGION $VERSION:$LAYER_VERSION"
      exit 1
    fi

    mkdir -p "$LAYER_PATH"
    curl "$TARGET_URL" -L -o "$LAYER_PATH/layer.zip"
    unzip "$LAYER_PATH/layer.zip" -d "$LAYER_PATH/layer"
  else
    rm -rf "$LAYER_PATH/layer"
    unzip "$LAYER_PATH/layer.zip" -d "$LAYER_PATH/layer"
  fi
}

# We can work with one region instead of multiples and just package it together
download_official_layer "nodejs" "nodejs" \
  "$NODEJS_OTEL_LAYER_REGION" \
  "$NODEJS_OTEL_LAYER_VERSION" \
  "$NODEJS_OTEL_LAYER_NAME_VERSION"

download_official_layer "python38" "python38" \
  "$PHYTON_OTEL_LAYER_REGION" \
  "$PHYTON_OTEL_LAYER_VERSION" \
  "$PHYTON_OTEL_LAYER_NAME_VERSION"

download_official_layer "java-agent" "java" \
  "$JAVA_OTEL_LAYER_REGION" \
  "$JAVA_OTEL_LAYER_VERSION" \
  "$JAVA_OTEL_LAYER_NAME_VERSION"

download_official_layer "collector" "dotnet" \
  "$DOTNET_OTEL_LAYER_REGION" \
  "$DOTNET_OTEL_LAYER_VERSION" \
  "$DOTNET_OTEL_LAYER_NAME_VERSION"

download_official_layer "collector" "golang" \
  "$GOLANG_OTEL_LAYER_REGION" \
  "$GOLANG_OTEL_LAYER_VERSION" \
  "$GOLANG_OTEL_LAYER_NAME_VERSION"

