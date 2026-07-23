# AGENTS.md

Default working agreement for my projects. Project-specific context lives in `ARCHITECTURE.md` — read it before touching code.

## Communication
- Answer shortly by default.
- When being asked about recommended solution shortly list pros and cons together with possible alternative approaches.
- When I ask a conceptual or feasibility question, answer it first in chat before making any code edits. Wait for my go-ahead before implementing.

## Default stack
- **Python 3.12+** with **uv** for dependency management
- **Makefile** wrappers
- **ruff** default linter and formatter, strict template
- **mypy** for type-checking
- **pre-commit** running ruff, uv-lock, gitleaks. Fix hook failures, never bypass.

## Standard commands (from `make/common.mk`)
```
make format       # ruff format + ruff check --fix
make type-check   # mypy
make test         # pytest
make deptry       # unused/missing dependency check
make check        # type-check + test + deptry
make pre-commit   # install + run hooks
```
Use `uv run <cmd>` rather than activating a venv.

## Critial Rules
- Never commit unless explicitly instructed
- Avoid overengineering and complexity. Avoid abstractions unless requested. Prioritize readability. 
- Confirm before destructive operations. Read/search freely. For deleting data, force-pushing, sending messages, modifying shared infra — confirm first unless durably authorized.

## General Coding Conventions

### Python Application Design & Project Layout
- Smaller applications should be kept flat, without src/ nesting or sub-packages but rather with one module per concern (e.g 'models.py', 'auth.py', 'main.py'). Introduce a package or nested structure only when size, namespaces or reusable components justify it.
- Application entrypoint should be mainly kept as an orchestration layer only.
- Put reusable functionalities and infrastructure (DB clients, API wrappers, alerting) in shared repo packages.
- Separate modules by concrete responsibility, such as configuration, models, validation, persistence, external integrations, alerting, and orchestration.
- Prefer small named functions over generic service classes and premature abstractions.
- Inject databases, storage clients, HTTP clients, and cloud services so business logic can be tested without real infrastructure.

### Tooling & project setup
- Dev tools live in `[dependency-groups] dev`: ruff, mypy, pytest, pytest-mock, deptry, pre-commit 
- **ruff** as the only linter/formatter, configured once at repo root (`ruff.toml`), strict template
- **mypy** for type-checking. **deptry** for unused/missing dependency checks. **pre-commit** running ruff, uv-lock, gitleaks
- No `print()` in production code (logging only).
- Use immutable version or Git SHA identifiers for deployed artifacts.

### Typing, Docstrings, Style
- Full type hints on every function, including `-> None`. Use modern syntax: `str | None`, `list[X]`, `Generator[X]`, `Annotated`.
- Docstring on module, class, and public function level. Google convention. Default to a one-line docstring stating purpose; add full `Args:`/`Returns:`/`Raises:` sections only when the signature alone doesn't explain behavior. Docstrings are not required in unit tests modules.
- Use absolute imports.
- Comments should explain why an invariant or ordering matters, not restate the code

### Constants, Configuration, Secrets
- Read required configuration with `os.environ["X"]` so missing config fails fast at first use. Use `os.getenv` only for genuinely optional lookups.
- Magic values should be named as a module-level `UPPER_CASE` constant, grouped at the top of the module.
- Ship a `.env.example` listing every environment variable with placeholder values.
- Never hardcode secrets. Never place secrets in source code, committed configuration, logs, tests, or exception messages.

### Testing
- Mirror production modules with focused test modules.
- Mock external boundaries, not the business rule being tested.
- Cover boundary values explicitly.
- pytest + `pytest-mock` (`MockerFixture`). Test functions are fully type-annotated.
- Test names read as specifications: `test_<unit>_<expected_behavior>_<condition>`. One behavior per test. Group tests for the same unit under a `# --- unit_name ---` section comment.
- Ensure fixtures clean up dependency overrides, environment changes, and global state.
- Shared fixtures live in `conftest.py`. Each fixture has a docstring stating what is real and what is mocked;

### Exceptions and error handling
- Define custom exceptions when callers must distinguish failures. Store structured context as attributes and initialize
  the message with `super().__init__(...)`.
- Catch broad `Exception` only at external integration or outermost application boundaries, with one owner per failure
  path. Retry only plausibly transient operations, using bounded and logged attempts.
- When translating a failure, log one final traceback and preserve its cause:
  `raise ApplicationError(...) from exc`. Upstream handlers must not log the traceback again.
- Never suppress exceptions silently. Only best-effort side channels such as alerting or metrics may suppress broad
  exceptions, and they must log the failure with `logger.exception`.
- For writes spanning multiple systems, document the ordering, possible partial states, recovery procedure, and whether retrying is safe.


### Logging
- One `logger = logging.getLogger(__name__)` per module. Configure `logging.basicConfig(...)` only in the entrypoint.
- Use `%s` lazy placeholders, never f-strings, in log calls.
- Levels: `info` for main execution steps; `warning` for expected rejections; `logger.exception(...)` inside `except` blocks — it logs at ERROR and includes the traceback automatically.
- Generate a run, correlation, file, message, or order identifier for each unit of work. Include that identifier in logs for every important processing stage.

### Data or Input Validation
- Treat every external input as untrusted and validate it at the boundary before passing it to business logic.
- Two layers, cleanly split: shape/format validation at the deserialization boundary (Pydantic), business-rule validation as standalone `validate_*` functions.
- One rule per validator function, guard-clause style: compute the violation, return early if clean, otherwise raise a domain error.
- Validate the complete unit of work before side effects when processing is all-or-nothing.
- Parameterize SQL queries; never interpolate external values into SQL.


## Stack-specific coding conventions

### FastAPI services

- Define request and response bodies with explicit typed models.
- Document and enforce field types, formats, patterns, ranges, and collection limits.
- Return all API errors using one documented response structure with one body shape: `{"detail": {"error_code": "...", "message": "..."}}`. Re-format FastAPI's own `RequestValidationError` into the same shape (e.g. error code `PAYLOAD_INVALID`).
- Add a catch-all `Exception` handler so unexpected failures also return the standard JSON body.
- External clients get a generic `INTERNAL_ERROR` 500 that never reveals which internal step failed; specifics go to logs and internal alerts only.
- Inject request-scoped or replaceable external services through `Depends`; use generator dependencies (`yield`
  inside a context manager) for per-request lifetimes. Manage expensive shared clients through FastAPI lifespan
  and `app.state`.
- Register exception handlers in a single `register_exception_handlers(app)` function called at app creation.
- Keep API documentation derived from the code and audience-specific: configure FastAPI metadata with the public
  contract, use the README for internal flows, assumptions, failure modes, and recovery, and exclude infrastructure,
  secrets, alerting, and deployment details from external documentation.
- Test endpoints with FastAPI `TestClient` or an equivalent HTTP client.