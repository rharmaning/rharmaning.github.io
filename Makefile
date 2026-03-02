.PHONY: setup install serve check resume-format

SCRIPT_DIR := ./scripts

setup:
	$(SCRIPT_DIR)/setup_env.sh $(CURDIR)

install: setup

check:
	npm run check:resume

resume-format:
	npm run format:resume

serve:
	$(SCRIPT_DIR)/serve_local.sh $(CURDIR)
