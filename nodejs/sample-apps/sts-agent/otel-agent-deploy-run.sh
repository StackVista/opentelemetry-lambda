docker load -i otel-agent.docker

AGENT_ENDPOINT=${AGENT_ENDPOINT} \
  STS_API_KEY="${STS_API_KEY}" \
  STACKSTATE_ENDPOINT="${STACKSTATE_ENDPOINT}" \
  docker-compose --file otel-agent-docker-compose.yml up
