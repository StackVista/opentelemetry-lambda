docker load -i otel-agent.docker

STS_API_KEY="${STS_API_KEY}" \
  AGENT_BRANCH="${AGENT_BRANCH}" \
  STACKSTATE_ENDPOINT="${STACKSTATE_ENDPOINT}" \
  docker-compose --file otel-agent-docker-compose.yml up
