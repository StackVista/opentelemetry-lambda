import { Span } from '@opentelemetry/api';

export type MODULE = (
  service: string,
  span: Span,
  action: string,
  inputs: { [value: string]: string }
) => void;
