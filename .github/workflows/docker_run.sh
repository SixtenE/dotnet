docker run -d --name gha-runner-test \
  --restart unless-stopped \
  -e REPO_URL="https://github.com/SixtenE/dotnet" \
  -e RUNNER_TOKEN="APUHQ3O2KCZHRZTYC7AF4ITJTXIB4" \
  -e RUNNER_NAME="macbook-test-runner" \
  -e RUNNER_LABELS="mac-test,self-hosted" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v gha-runner-work:/_work \
  myoung34/github-runner:latest