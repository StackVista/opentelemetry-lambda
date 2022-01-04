docker load -i otel-agent.docker

AGENT_ENDPOINT=${AGENT_ENDPOINT} \
  STS_API_KEY="${STS_API_KEY}" \
  AGENT_BRANCH="${AGENT_BRANCH}" \
  docker-compose --file otel-agent-docker-compose.yml up
