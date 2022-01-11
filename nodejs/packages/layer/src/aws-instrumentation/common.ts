import { Span } from '@opentelemetry/api';
import { AwsSdkRequestHookInformation } from '@opentelemetry/instrumentation-aws-sdk';

/**
 * Add a aws request value into the span to enrich the attribute information
 */
export const addAwsRequestAttribute = (
  span: Span,
  key: string,
  value: string
) => span.setAttribute(`aws.request.${formatKey(key)}`, value);

/**
 * We attempt to map certain values regardless of the service name.
 * This is evaluated after the key has been formatted thus it will go from the following state
 *  CamelCase to camel.case where every word is split with a .
 *
 * Current Mappings:
 * - ARN
 */
export const addGenericAwsRequestAttributes = (
  span: Span,
  action: string,
  inputs: { [value: string]: string }
) => {
  Object.keys(inputs).map(key => {
    // We split the keys to look at them individually so that we do not mistake a word with the target inside the string
    // for example "index of arn on barn is also valid which is a bug"
    const keyParts = key.split('.');

    // Dynamically map if the input passed is a arn value
    if (keyParts.indexOf('arn') > -1) {
      addAwsRequestAttribute(span, key, inputs[key]);
    }
  });
};

/**
 * Format the index key to contain a valid format for a json object
 */
export const formatKey = (key: string): string => {
  return key
    .replace(/\s/g, '') // Remove spaces to prevent a invalid key
    .replace(/([a-z0-9])([A-Z])/g, '$1.$2') // Split camelcase with a . between
    .toLowerCase(); // Normalize strings
};

/**
 * We normalize the inputs seeing that the user input can contain any type of case IE camelcase, lowercase etc
 * For example the bucket name can be Bucket or bucket and for use to only test a single index we need to normalize
 */
const normalizeInputs = (inputs: {
  [value: string]: string;
}): { [value: string]: string } => {
  return Object.keys(inputs).reduce(
    (acc: { [value: string]: string }, key: string) => {
      acc[formatKey(key)] = inputs[key];
      return acc;
    },
    {}
  );
};

/**
 * Extract information we're going to use to map meta data with
 */
export const extractRequestInformation = (
  request: AwsSdkRequestHookInformation
) => {
  return {
    service: request?.request?.serviceName?.toLowerCase(), // SNS or SQS
    action: request?.request?.commandName?.toLowerCase(), // InsertRecord. Action taken
    inputs: normalizeInputs(request?.request?.commandInput || {}), // Parameters passed to the SDK call
  };
};
