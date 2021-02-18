INSTALL_DIR ?= ~/.config/rofi/scripts/rofi-file-selector
SHELL=bash
FILES=chooseexe.sh fd_cache.sh mimeapps mimeapps.sh config.sh.example

.DEFAULT_GOAL := help
.PHONY: help

help: ### Print this help message
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	 | sed -n 's/^\(.*\):\(.*\)##\(.*\)/\1▅\3/p' \
	| column -t  -s '▅'


.PHONY: doc
doc: README.md  ## Update README with configuration example file
	mdsh

.PHONY: install
install: ## Install to INSTALL_DIR variable (make INSTALL_DIR=/tmp)
	mkdir -p ${INSTALL_DIR}
	cp ${FILES} ${INSTALL_DIR}




