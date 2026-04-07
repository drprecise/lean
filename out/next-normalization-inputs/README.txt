Next normalization input artifacts

This directory is a preflight staging area for the next provider-normalization task.

Planned deliverables:
- Paired raw JSON + clean TXT per provider.
- Audit and provenance notes tied to the exact source endpoints and filters used.
- Minimal transformation only, with raw data preserved separately from derived output.

Scope:
- Gains
- Drift
- Parcl
- Polymarket

Rules:
- Do not fetch provider data until the next task explicitly authorizes it.
- Keep provider identifiers and availability semantics explicit.
- Keep machine-readable JSON and human-readable TXT outputs separate.
