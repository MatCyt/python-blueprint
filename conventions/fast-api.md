# FastAPI conventions

Rules for FastAPI services. Load only when working on a FastAPI service — copy into the service directory as its local `AGENTS.md`, or read on demand.

- Define request and response bodies with explicit typed models. Enforce field types, formats, patterns, ranges, and collection limits.
- Return all API errors in one documented shape: `{"detail": {"error_code": "...", "message": "..."}}`. Re-format `RequestValidationError` into it (e.g. `PAYLOAD_INVALID`). Add a catch-all `Exception` handler returning the same shape.
- External clients get a generic `INTERNAL_ERROR` 500 that never reveals which internal step failed; specifics go to logs and internal alerts only.
- Inject request-scoped or replaceable services through `Depends`; use generator dependencies for per-request lifetimes; manage expensive shared clients through lifespan and `app.state`.
- Register exception handlers in a single `register_exception_handlers(app)` called at app creation.
- Keep API docs derived from code and audience-specific: FastAPI metadata holds the public contract; README covers internal flows, assumptions, failure modes, recovery; exclude infrastructure, secrets, alerting, and deployment details from external docs.
- Test endpoints with FastAPI `TestClient` or an equivalent HTTP client.
