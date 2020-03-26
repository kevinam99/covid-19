COMMIT_TAG ?= $(shell git log -1 --pretty="%h").zip

.PHONY: build
build:
	rm -rf ./dist && npm run build

.PHONY: transfer
transfer:
	zip -rq $(COMMIT_TAG) package*.json dist/
	scp $(COMMIT_TAG) do:/home/api/
	ssh do "cd /home/api && unzip -oq $(COMMIT_TAG) && rm $(COMMIT_TAG)"
	echo "Done. Transferred $(COMMIT_TAG)"
