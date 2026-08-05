.PHONY: format lint type-check test test-cov check pre-commit pre-commit-update help

## Run code formatter
format:
	uv run ruff format .
	uv run ruff check . --fix

## Run type checker
type-check:
	uv run mypy .

## Run tests
test:
	uv run pytest

## Run tests with coverage
test-cov:
	uv run pytest --cov --cov-report=term-missing

## Run dependency checks
deptry:
	uv run deptry .

## Run all checks (lint + type-check + test + deptry)
verify: format type-check test deptry

## Install/update pre-commit hooks
pre-commit:
	uv run pre-commit install
	uv run pre-commit run --all-files

## update pre-commit hooks
pre-commit-update:
	uv run pre-commit autoupdate

## Show this help
help:
	@grep -E '^## ' Makefile | sed 's/## //'
