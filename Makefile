SHELL := /bin/bash

.PHONY: lint test backup disk users logs health

lint:
	shellcheck scripts/*.sh tests/*.sh

test: lint
	@for f in scripts/*.sh tests/*.sh; do bash -n "$$f"; done
	./tests/smoke.sh

backup:
	./scripts/backup.sh

disk:
	./scripts/disk-report.sh

users:
	./scripts/user-audit.sh

logs:
	DRY_RUN=$${DRY_RUN:-1} ./scripts/log-cleanup.sh

health:
	./scripts/service-health.sh
