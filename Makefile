.PHONY: setup install serve

SCRIPT_DIR := ./scripts

setup:
	$(SCRIPT_DIR)/setup_env.sh $(CURDIR)

install: setup

serve:
	$(SCRIPT_DIR)/serve_local.sh $(CURDIR)
