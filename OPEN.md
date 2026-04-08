# OPEN — Omitted / Placeholder

Items not yet defined. Each needs a decision or a provider-specific file before it can be locked.

## ProviderAsset fields (deferred)

| Field | Reason deferred |
|---|---|
| `symbol` | Format varies by provider (`SOL-PERP` on Drift, `SOL/USD` on Gains). Belongs in provider files. |
| `marketIndex` | Dropped. Bounds are provider-specific. Cannot be typed correctly at world level. |
| `marketType` | Dropped. Perp/Spot does not describe Parcl or Poly. Provider files handle this. |

## Asset (incomplete)

Only 10 assets listed. Full list not yet enumerated.

## Network (incomplete)

Only 5 networks listed. Full list not yet enumerated.

## Provider-specific files (not yet written)

| Provider | File | Status |
|---|---|---|
| Drift | out/Drift.lean | Exists but predates world.lean ontology. Needs `DriftPerp.asset : DriftPerp -> Asset` to connect. |
| Gains | — | Not defined |
| Parcl | — | Not defined |
| Poly | — | Not defined |

## UI layer (out of scope for domain)

Color and URL — decided as display concerns. Storage location not yet determined.
