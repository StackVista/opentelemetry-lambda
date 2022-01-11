import { OPEN_TELEMETRY_ENRICH_MODULE } from '../definitions';
import {
  addAwsRequestAttribute,
  addGenericAwsRequestAttributes,
} from '../common';

export const lambda: OPEN_TELEMETRY_ENRICH_MODULE = (
  service: string,
  span,
  action,
  inputs
) => {
  console.log('[STS] LAMBDA - Mapping custom information for lambda.');

  // Although we know the service we still attempt to apply a generic mapping
  addGenericAwsRequestAttributes(span, action, inputs);

  if (inputs['function.name']) {
    addAwsRequestAttribute(span, 'function.name', inputs['function.name']);
  }
};
