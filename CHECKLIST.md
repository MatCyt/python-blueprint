# New project checklist

## Repository layout
- [ ] Decide the layout and adjust the blueprint: monorepo with uv workspaces (`[tool.uv.workspace]` at root — one shared lockfile, services and shared packages as members) vs. fully isolated repo (single project, own `pyproject.toml` and lockfile)

## Setup
- [ ] Copy blueprint; rename project in `pyproject.toml` (name, description, authors)
- [ ] `git init`, create remote repo, set default branch /optional
- [ ] `uv sync` — verify Python 3.12+ and lockfile
- [ ] `make pre-commit` — install and run hooks (ruff, uv-lock, gitleaks)

## Docs & agent context
- [ ] Write `ARCHITECTURE.md` — purpose, services, key decisions
- [ ] Keep root `AGENTS.md`; copy relevant `conventions/*.md` into service directories
- [ ] Write minimal `README.md` — what it does, how to run it
- [ ] Delete this checklist (or blueprint files not needed)

## Configuration & secrets
- [ ] Create `.env.example` with every env var and placeholder values
- [ ] Create local `.env`; confirm it's gitignored
- [ ] Set up secrets in the target runtime (not in code or config)

## Quality gates
- [ ] `make verify` passes (ruff + mypy + pytest + deptry) on the empty skeleton
- [ ] Set up CI running `make verify` on push/PR

## Deployment (when applicable)
- [ ] Dockerfile + `.dockerignore`; pin base image
- [ ] Tag deployed artifacts with immutable version or Git SHA
