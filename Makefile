.PHONY=clean

SHELL=/bin/bash -o pipefail

default: polyglot-co-demo-backend

polyglot-co-demo-backend: static/build-number
	docker run --rm \
	  -v "$$(pwd):/src" \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  centurylink/golang-builder | sed 's/^Step/--- Step/'

static/build-number:
	echo "$${BUILDKITE_BUILD_NUMBER:-42}" > $@

eb.zip: polyglot-co-demo-backend
	mkdir -p eb
	cp Dockerfile-production eb/Dockerfile
	cp -r templates static polyglot-co-demo-backend eb/
	echo '{"AWSEBDockerrunVersion": "1","Ports": [{"ContainerPort": "8080"}]}' > eb/Dockerrun.aws.json
	docker run --rm -v "$$(pwd):/src" alpine sh -c 'apk add --no-cache zip && cd /src/eb && zip -r /src/eb.zip .' | sed 's/^Step/--- Step/'

clean:
	rm -rf static/build-number polyglot-co-demo-backend eb.zip eb
