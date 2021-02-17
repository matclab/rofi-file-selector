
SHELL=bash

.DEFAULT_GOAL := help
.PHONY: help

help: ### Print this help message
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	 | sed -n 's/^\(.*\):\(.*\)##\(.*\)/\1▅\3/p' \
	| column -t  -s '▅'


.PHONY: doc
doc: README.md  ## Update README with configuration example file
	mdsh





