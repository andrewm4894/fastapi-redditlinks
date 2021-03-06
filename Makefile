include .env

ENV=local
APP=redditlinks

.PHONY: build
build:
	docker build -t $(APP) . --build-arg ENV=$(ENV)

.PHONY: stop
stop:
	@echo "Stopping existing containers..."
	@eval $$(docker ps -a | grep $(APP) | awk '{print $$1}' | xargs docker stop > /dev/null 2>&1)

.PHONY: start
start: stop
	docker run --rm -d -p 80:80 -e LOG_LEVEL=DEBUG $(APP)

.PHONY: logs
logs:
	@docker ps -a | grep $(APP) | awk '{print $$1}' | xargs docker logs -f

.PHONY: test
test:
	cd app; pytest

.PHONY: requirements
requirements:
	pipenv lock -r > requirements.txt

.PHONY: container
container:
	gcloud builds --project $(GCP_PROJECT_ID) submit --tag gcr.io/$(GCP_PROJECT_ID)/$(APP)

.PHONY: deploy
deploy:
	gcloud run --project $(GCP_PROJECT_ID) deploy --image gcr.io/$(GCP_PROJECT_ID)/$(APP) --platform managed

