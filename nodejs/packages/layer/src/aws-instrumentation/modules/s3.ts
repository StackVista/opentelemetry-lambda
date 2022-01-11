import { OPEN_TELEMETRY_ENRICH_MODULE } from '../definitions';
import {
  addAwsRequestAttribute,
  addGenericAwsRequestAttributes,
} from '../common';

export const s3: OPEN_TELEMETRY_ENRICH_MODULE = (
  service: string,
  span,
  action,
  inputs
) => {
  console.log('[STS] S3 - Mapping custom information for s3.');

  // Although we know the service we still attempt to apply a generic mapping
  addGenericAwsRequestAttributes(span, action, inputs);

  // We do not have to switch per action for S3 seeing that all we want out of it is is the bucket name
  // Bucket names are unique thus you can use this to create a trace on both ends of the spectrum
  if (inputs['bucket']) {
    addAwsRequestAttribute(span, 'bucket', inputs['bucket']);
  }
};
