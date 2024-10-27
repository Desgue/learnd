CONTAINER_NAME ?= document_processor

# Default target
all: docker-auth build tag push

# Authenticate Docker to AWS ECR
docker-auth:
	@echo "Authenticating Docker with AWS ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_REPOSITORY)

# Build the Docker image
build:
	@echo "Building Docker image..."
	docker build -t $(CONTAINER_NAME) .

# Tag the Docker image
tag:
	@echo "Tagging Docker image..."
	docker tag $(CONTAINER_NAME):latest $(ECR_REPOSITORY):latest

# Push the image to ECR
push:
	@echo "Pushing Docker image to ECR..."
	docker push $(ECR_REPOSITORY):latest

# Clean up local Docker images (optional target)
clean:
	@echo "Cleaning up local Docker images..."
	docker rmi $(CONTAINER_NAME):latest || true
	docker rmi $(ECR_REPOSITORY):latest || true