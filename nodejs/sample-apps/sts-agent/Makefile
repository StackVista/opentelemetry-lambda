pull-agent-docker-image:
	rm -rf otel-agent.docker
	docker rmi docker.io/stackstate/stackstate-agent-2-test:${AGENT_BRANCH} --force
	docker pull docker.io/stackstate/stackstate-agent-2-test:${AGENT_BRANCH}
	docker save -o otel-agent.docker docker.io/stackstate/stackstate-agent-2-test:${AGENT_BRANCH}

run-agent-image:
		./otel-agent-deploy-run.sh
