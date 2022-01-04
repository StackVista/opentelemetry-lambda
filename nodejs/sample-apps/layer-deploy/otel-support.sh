clear
echo "-- Open Telemetry Lambda Support --"
echo ""
echo "This script will validate if a Lambda function contains all the correct settings and layers to functions with Open Telemetry.\n"


# In what region is the function running
echo "'AWS Region' the function is running in? [default: eu-west-1]"
echo "Press Enter to proceed with the default"
read -p ':' REGION
REGION=${REGION:-eu-west-1}
printf "Using region '%s'\n\n" "$REGION"

# Determine the function name
functionName () {
  read -p 'Enter your lambda function name [required]: ' FUNCTION_NAME
  if [ -z "$FUNCTION_NAME" ]
  then
    # Function name should not be empty
    functionName
  fi
}

if [ -n "$FUNCTION" ]
then
  FUNCTION_NAME=$FUNCTION
else
  functionName
fi

echo "Using function name '$FUNCTION_NAME'\n"


# Determine and set a AWS_PROFILE for the cli command
echo "Enter your 'AWS_PROFILE' to use with the AWS CLI calls? [default: ${AWS_PROFILE-None}]"
echo "Press Enter to either use the default or your local env"

read -p ":" AWS_PROFILE_INPUT
if [ -n "$AWS_PROFILE_INPUT" ]
  then
    AWS_PROFILE=$AWS_PROFILE_INPUT
fi
echo ""

read -p 'Enter the Nodejs Lambda layer name [default: OpenTelemetryNodeJS]: ' NODEJS_LAMBDA_LAYER_NAME

NODEJS_LAMBDA_LAYER_NAME=${NODEJS_LAMBDA_LAYER_NAME:-OpenTelemetryNodeJS}
COLLECTOR_LAMBDA_LAYER_NAME=${COLLECTOR_LAMBDA_LAYER_NAME:-aws-otel-nodejs-ver}

echo ""
echo "** Running unit tests for the Lambda function '$FUNCTION_NAME' **"
echo "** Open telemetry will not function if any of the tests below fails **"
echo ""

# Determine Tracing Config
if [[ -n $AWS_PROFILE ]]
then
  TRACING_CONFIG_MODE=$(aws lambda get-function-configuration \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --profile "$AWS_PROFILE" \
    --query 'TracingConfig.Mode' \
    --output text)
else
  TRACING_CONFIG_MODE=$(aws lambda get-function-configuration \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --query 'TracingConfig.Mode' \
    --output text)
fi


if [[ "$TRACING_CONFIG_MODE" != "PassThrough" && "$TRACING_CONFIG_MODE" != "Active" ]]; then
  echo "[FAILURE] - Tracing config '$TRACING_CONFIG_MODE' is invalid, The tracing config for this function is incorrect. It needs to be either 'PassThrough' or 'Active' for Open Telemetry to work (Please note that 'PassThrough' is recommended as 'Active' costs $)"
else
  echo "[SUCCESS] - Tracing config '$TRACING_CONFIG_MODE' is valid"
fi



function missing_env_variable_test {
  if [[ -n $AWS_PROFILE ]]
  then
    LAMBDA_ENV_VARIABLE=$(aws lambda get-function-configuration \
      --region "$REGION" \
      --function-name "$FUNCTION_NAME" \
      --profile "$AWS_PROFILE" \
      --query "Environment.Variables.$1" \
      --output text)
  else
    LAMBDA_ENV_VARIABLE=$(aws lambda get-function-configuration \
      --region "$REGION" \
      --function-name "$FUNCTION_NAME" \
      --query "Environment.Variables.$1" \
      --output text)
  fi

  if [[ -z $2 && $LAMBDA_ENV_VARIABLE == "None" ]]; then
    echo "[FAILURE] - Missing environment variable for '$1'"
  elif [[ $LAMBDA_ENV_VARIABLE == "None" ]]; then
    echo "[FAILURE] - Missing environment variable for '$1'. Recommended value '$2'"
  elif [[ -n $2 && "$LAMBDA_ENV_VARIABLE" != "$2" ]]; then
    echo "[FAILURE] - Incorrect or Missing environment variable for '$1'. Current variable is '$LAMBDA_ENV_VARIABLE', Required variable is '$2'"
  else
    echo "[SUCCESS] - '$1' environment variable is valid, found '$LAMBDA_ENV_VARIABLE'"
  fi
}

missing_env_variable_test "AWS_LAMBDA_EXEC_WRAPPER" "/opt/otel-handler"
missing_env_variable_test "OTEL_TRACES_EXPORTER" "otlp"
missing_env_variable_test "OTEL_PROPAGATORS" "tracecontext"
missing_env_variable_test "OTEL_TRACES_SAMPLER" "always_on"
missing_env_variable_test "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"


if [[ -n $AWS_PROFILE ]]
then
  LAYERS=$(aws lambda get-function-configuration \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --profile "$AWS_PROFILE" \
    --output text \
    --query "Layers")
else
  LAYERS=$(aws lambda get-function-configuration \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --output text \
    --query "Layers")
fi

if [[ "$LAYERS" == *"layer:$COLLECTOR_LAMBDA_LAYER_NAME"* ]]; then
  echo "[SUCCESS] - Collector Lambda Layer Found"
else
  echo "[FAILURE] - Collector Lambda Layer Not Found, Looked for the layer name '$COLLECTOR_LAMBDA_LAYER_NAME'. Supported layers can be found at https://aws-otel.github.io/docs/getting-started/lambda/lambda-js"
fi

if [[ "$LAYERS" == *"layer:$NODEJS_LAMBDA_LAYER_NAME"* ]]; then
  echo "[SUCCESS] - NodeJS Lambda Layer Found"
else
  echo "[FAILURE] - NodeJS Lambda Layer Not Found, Looked for the layer name '$NODEJS_LAMBDA_LAYER_NAME'. Please add this Lambda Layer to your Lambda Function"
fi

