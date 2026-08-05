# Architecture - <PROJECT_NAME>
::Context relevant only to this specific project

## Project Description
<2-4 sentences shortly descripting the high-level project purpose>

## System Overview
<high level design>

## Tech Stack
<example>
- **Language & tooling:** Python 3.14+, uv
- **Cloud:** Microsoft Azure — Azure SQL, Container Apps, Container Registry, Key Vault, Blob Storage
- **CI/CD:** GitHub Actions (path-based triggers per service)
- **Branching:** trunk-based (`main` always deployable, short-lived feature branches)

## Project Terminology
<domain terms and abbreviations an agent must know; one line each>
<example>
- **Run** — one end-to-end execution of the pipeline for a single input file.

## Architectural Constraints
<example>
- **Service isolation.** Each service is an independent container with its own compute, networking, and lifecycle. One service failing must not cascade. The monorepo is a code-organization choice only.
- **Trunk-based development.** `main` is the single long-lived branch and is always deployable. Feature branches are short-lived and merged frequently.

## Project Constraints
<example>
- **Microsoft-native solutions preferred.**  When evaluating approaches for any challenge, always list and consider the Microsoft-native option (Azure services, M365 integrations, Entra ID, etc.) alongside alternatives.

## Repo Structure
<example>
```
project-c/
├── ruff.toml                       # repo-wide linting rules
├── make/common.mk                  # shared make targets
├── packages/
│   ├── package1/                   # shared utils 
│   ├── package2/                   # shared utils
├── services/
│   ├── service1/                   # service 1
│   └── service2/                   # service 2
├── database/
│   ├── tables/                     # table definitions
│   ├── migrations/                 # numbered SQL migrations
│   ├── seeds/                      # seed data
│   └── scripts/                    # one-time scripts
└── .github/workflows/              # per-service deploy, repo-wide CI
```
