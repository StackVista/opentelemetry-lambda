import { MODULE } from './definitions';

import { s3 } from './modules/s3';
import { lambda } from './modules/lambda';
import { sns } from './modules/sns';
import { stateMachine } from './modules/state-machine';
import { genericService } from './modules/generic';

export const awsEnrichServices: {
  [value: string]: MODULE;
} = {
  s3,
  sns,
  lambda,
  sfn: stateMachine,
  genericService,
};
