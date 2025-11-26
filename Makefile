.PHONY: help build build-ubuntu build-alpine clean

# Default target
help:
	@echo "Zulu JDK 21 Base Images Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build          Build both Docker images (Ubuntu and Alpine)"
	@echo "  build-ubuntu   Build the Ubuntu 24.04 with Azul Zulu JDK 21 image"
	@echo "  build-alpine   Build the Alpine with Azul Zulu JDK 21 image"
	@echo "  clean          Remove built Docker images"
	@echo "  help           Show this help message"

# Build both images
build: build-ubuntu build-alpine
	@echo "Both Docker images built successfully!"

# Build Ubuntu 24.04 with Azul Zulu JDK 21 image
build-ubuntu:
	@echo "Building Ubuntu 24.04 with Azul Zulu JDK 21 image..."
	docker build -t jdellostritto/docker-jdk-base:ubuntu-jdk21-latest ./flip-azulzulu-openjdk-ubuntu24.04-jdk21
	@echo "Ubuntu image built: jdellostritto/docker-jdk-base:ubuntu-jdk21-latest"

# Build Alpine with Azul Zulu JDK 21 image
build-alpine:
	@echo "Building Alpine with Azul Zulu JDK 21 image..."
	docker build -t jdellostritto/docker-jdk-base:alpine-jdk21-latest ./flip-zulu-alpine21
	@echo "Alpine image built: jdellostritto/docker-jdk-base:alpine-jdk21-latest"

# Clean up built images
clean:
	@echo "Removing Docker images..."
	docker rmi -f jdellostritto/docker-jdk-base:ubuntu-jdk21-latest || true
	docker rmi -f jdellostritto/docker-jdk-base:alpine-jdk21-latest || true
	@echo "Cleanup complete!"
