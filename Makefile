# Placeholder

build:
	docker buildx build -t primeroz/hitch:latest --push --platform linux/amd64,linux/arm64 .
