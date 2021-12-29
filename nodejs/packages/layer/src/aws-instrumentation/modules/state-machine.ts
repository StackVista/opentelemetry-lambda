import { MODULE } from '../definitions';
import { addGenericAwsRequestAttributes } from '../common';

export const stateMachine: MODULE = (service: string, span, action, inputs) => {
  console.log(
    '[STS] STATE MACHINE - Mapping custom information for state machine.'
  );

  // Although we know the service we still attempt to apply a generic mapping
  // All we require is the ARN which the dynamic mapping already does
  addGenericAwsRequestAttributes(span, action, inputs);
};
