import { OPEN_TELEMETRY_ENRICH_MODULE } from '../definitions';
import { addGenericAwsRequestAttributes } from '../common';

export const genericService: OPEN_TELEMETRY_ENRICH_MODULE = (
  service: string,
  span,
  action,
  inputs
) => {
  console.log(
    `[STS] GENERIC - Mapping information for the '${service}' service`
  );

  addGenericAwsRequestAttributes(span, action, inputs);
};
