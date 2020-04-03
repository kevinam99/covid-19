COMMIT_TAG ?= $(shell git log -1 --pretty="%h").zip

.PHONY: build
build:
	MIX_ENV=prod mix release

.PHONY: transfer
transfer:
	zip -rq $(COMMIT_TAG) config/ lib/ mix.*  
	scp $(COMMIT_TAG) do:/home/notifier/
	ssh do "cd /home/notifier && unzip -oq $(COMMIT_TAG) && rm $(COMMIT_TAG)"
	echo "Done. Transferred $(COMMIT_TAG)"
