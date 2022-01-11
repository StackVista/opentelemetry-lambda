import { Span } from '@opentelemetry/api';

/**
 * Basic mapping required to process a aws service from Open Telemetry
 */
export type OPEN_TELEMETRY_ENRICH_MODULE = (
  service: string,
  span: Span,
  action: string,
  inputs: { [value: string]: string }
) => void;
