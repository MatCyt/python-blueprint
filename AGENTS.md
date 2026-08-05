# AGENTS.md

Default working agreement for my projects. Project-specific context lives in `ARCHITECTURE.md` — read it before touching code.

## Communication
- Answer shortly by default.
- When asked for a recommended solution, shortly list pros and cons plus alternative approaches.
- For conceptual or feasibility questions, answer in chat first; wait for my go-ahead before implementing.

## Stack & tooling
- **Python 3.12+** with **uv**. Use `uv run <cmd>` rather than activating a venv.
- **Makefile** wrappers for the standard commands below.
- **ruff** as the only linter/formatter, strict template, configured once at repo root (`ruff.toml`).
- **mypy** for type-checking. **deptry** for unused/missing dependency checks.
- **pre-commit** running ruff, uv-lock, gitleaks. Fix hook failures, never bypass.
- Dev tools live in `[dependency-groups] dev`: ruff, mypy, pytest, pytest-mock, deptry, pre-commit.
- No `print()` in production code (logging only).
- Use immutable version or Git SHA identifiers for deployed artifacts.

## Verification
- After code changes, run `make verify`; it is the canonical full-project check.
- A change is done only when `make verify` passes. 

## Critical rules
- Never commit unless explicitly instructed.
- Avoid overengineering, complexity, and unrequested abstractions. Prioritize readability.
- Read/search freely, but confirm before destructive operations (deleting data, force-pushing, sending messages, modifying shared infra) unless durably authorized.

## Application design & project layout
- Keep smaller applications flat: one module per concern (`models.py`, `auth.py`, `main.py`), no `src/` nesting or sub-packages until size, namespaces, or reusable components justify them.
- Keep the entrypoint an orchestration layer only.
- Put reusable functionality and infrastructure (DB clients, API wrappers, alerting) in shared repo packages.
- Separate modules by concrete responsibility: configuration, models, validation, persistence, integrations, alerting, orchestration.
- Prefer small named functions over generic service classes and premature abstractions.
- Inject databases, storage clients, HTTP clients, and cloud services so business logic is testable without real infrastructure.

## Typing, docstrings, style
- Full type hints on every function, including `-> None`. Modern syntax: `str | None`, `list[X]`, `Generator[X]`, `Annotated`.
- Google-style docstrings on modules, classes, and public functions. One line stating purpose by default; add `Args:`/`Returns:`/`Raises:` only when the signature alone doesn't explain behavior. Not required in unit test modules.
- Use absolute imports.
- Comments explain why an invariant or ordering matters, not restate the code.

## Constants, configuration, secrets
- Read required configuration with `os.environ["X"]` so missing config fails fast. Use `os.getenv` only for genuinely optional lookups.
- Name magic values as module-level `UPPER_CASE` constants, grouped at the top of the module.
- Ship a `.env.example` listing every environment variable with placeholder values.
- Never hardcode secrets or place them in source, committed configuration, logs, tests, or exception messages.

## Testing
- pytest + `pytest-mock` (`MockerFixture`). Test functions fully type-annotated.
- Mirror production modules with focused test modules.
- Mock external boundaries, not the business rule being tested. Cover boundary values explicitly.
- Test names read as specifications: `test_<unit>_<expected_behavior>_<condition>`. One behavior per test; group tests per unit under a `# --- unit_name ---` comment.
- Fixtures clean up dependency overrides, environment changes, and global state.
- Shared fixtures live in `conftest.py`, each with a docstring stating what is real and what is mocked.

## Exceptions & error handling
- Define custom exceptions when callers must distinguish failures. Store structured context as attributes; initialize the message with `super().__init__(...)`.
- Catch broad `Exception` only at external integrations or outermost boundaries, one owner per failure path. Retry only plausibly transient operations, with bounded and logged attempts.
- When translating a failure, log one final traceback and preserve the cause: `raise ApplicationError(...) from exc`. Upstream handlers must not log it again.
- Never suppress exceptions silently. Only best-effort side channels (alerting, metrics) may suppress broad exceptions, and they must log via `logger.exception`.
- For writes spanning multiple systems, document ordering, possible partial states, recovery procedure, and retry safety.

## Logging
- One `logger = logging.getLogger(__name__)` per module. Configure `logging.basicConfig(...)` only in the entrypoint.
- Use `%s` lazy placeholders, never f-strings, in log calls.
- Levels: `info` for main execution steps; `warning` for expected rejections; `logger.exception(...)` inside `except` blocks.
- Generate a run/correlation/file/message/order identifier per unit of work and include it in logs at every important stage.

## Data & input validation
- Treat every external input as untrusted; validate at the boundary before business logic.
- No schemas for simple local values. Use dataclasses for internal data already validated at the boundary.
- Use Pydantic for data that might be wrong, is business-critical, or crosses a trust boundary: external API responses, LLM output, request/response bodies, webhook payloads, externally loaded config, final outputs. Not for batch/bulk/columnar/dataframe data.
- Two layers, cleanly split: shape/format validation at the deserialization boundary (Pydantic); business rules as standalone `validate_*` functions — one rule per function, guard-clause style: compute the violation, return early if clean, otherwise raise a domain error.
- Validate the complete unit of work before side effects when processing is all-or-nothing.
- Parameterize SQL queries; never interpolate external values into SQL.

## Stack-specific conventions
- Stack-specific rules live in `conventions/` (e.g. `conventions/fast-api.md`). Read the relevant file before working on that stack.
