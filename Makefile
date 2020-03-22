# Change this to `docker` if you want to user Docker
RUNTIME=podman
IMAGE_NAME=torism

.PHONY: build
build:
	${RUNTIME} build -f Containerfile -t ${IMAGE_NAME}
