import { MODULE } from '../definitions';
import {
  addAwsRequestAttribute,
  addGenericAwsRequestAttributes,
} from '../common';

export const sns: MODULE = (service: string, span, action, inputs) => {
  // Although we know the service we still attempt to apply a generic mapping
  addGenericAwsRequestAttributes(span, action, inputs);

  if (inputs['topic.arn']) {
    addAwsRequestAttribute(span, 'topic.arn', inputs['topic.arn']);
  }
};
