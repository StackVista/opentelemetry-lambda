import { MODULE } from '../definitions';
import {
  addAwsRequestAttribute,
  addGenericAwsRequestAttributes,
} from '../common';

export const lambda: MODULE = (service: string, span, action, inputs) => {
  // Although we know the service we still attempt to apply a generic mapping
  addGenericAwsRequestAttributes(span, action, inputs);

  if (inputs['function.name']) {
    addAwsRequestAttribute(span, 'function.name', inputs['function.name']);
  }
};