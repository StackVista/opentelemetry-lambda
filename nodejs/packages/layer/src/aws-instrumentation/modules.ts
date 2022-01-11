import { OPEN_TELEMETRY_ENRICH_MODULE } from './definitions';

import { s3 } from './modules/s3';
import { lambda } from './modules/lambda';
import { sns } from './modules/sns';
import { stateMachine } from './modules/state-machine';
import { genericService } from './modules/generic';

/**
 * Contains mappings for services passed down from Open Telemetry
 *
 * For example if you want to add xyz service add a module for it below and it will automatically be diverted to your module
 */
export const awsEnrichOpenTelemetry: {
  [value: string]: OPEN_TELEMETRY_ENRICH_MODULE;
} = {
  s3,
  sns,
  lambda,
  sfn: stateMachine,
  genericService,
};
