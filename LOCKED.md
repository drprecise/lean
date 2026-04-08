# LOCKED — Finalized Definitions

Definitions in `world.lean` that are settled. Do not change without reopening.

## Ontological order

```
Asset → Provider → ProviderAsset
```

> `Asset` carries no qualifier. It is the only asset. The name is the claim.

## Types

| Name | Kind | File |
|---|---|---|
| `Asset` | inductive | world.lean |
| `Provider` | inductive | world.lean |
| `Network` | inductive | world.lean |
| `QuoteAsset` | inductive | world.lean |
| `Leverage` | inductive | world.lean |
| `GainsCategory` | inductive | world.lean |
| `PolyCategory` | inductive | world.lean |
| `ProviderAsset` | structure | world.lean |
| `DriftAsset` | structure extends ProviderAsset | world.lean |
| `GainsAsset` | structure extends ProviderAsset | world.lean |
| `ParclAsset` | structure extends ProviderAsset | world.lean |
| `PolyAsset` | structure extends ProviderAsset | world.lean |

## ProviderAsset fields (the deed)

| Field | Type | Note |
|---|---|---|
| `asset` | `Asset` | The thing itself |
| `provider` | `Provider` | The source |
| `network` | `Network` | Chain it trades on |
| `quoteAsset` | `QuoteAsset` | What it prices against |
| `leverage` | `Option Leverage` | `none` = leverage does not apply (e.g. Poly) |

## Provider extensions (what each child adds)

| Child | Extra field | Type |
|---|---|---|
| `DriftAsset` | `marketIndex` | `Fin 86` |
| `GainsAsset` | `category` | `GainsCategory` |
| `ParclAsset` | TBD | — |
| `PolyAsset` | `category` | `PolyCategory` |

## Decisions

| Decision | Rationale |
|---|---|
| `structure extends` over typeclass | Closed finite world. Hierarchy is known and immutable. Typeclass is for open-world extensibility. |
| `Instrument` dropped | Redundant over `ProviderAsset`. Provider determines all tradable facts. |
| `MarketType` dropped | Perp/Spot does not generalize across all four providers. |
| `marketIndex` at `DriftAsset` not `ProviderAsset` | Drift-specific. Other providers do not have it. |
| `category` split into `GainsCategory` / `PolyCategory` | Different value sets. Do not share a type even if concept is similar. |
| `symbol` deferred | Provider-specific formatting. Belongs in provider files. |
| All types are closed inductives | Closed world. No `String` or `Nat` where domain is bounded. |
| `leverage : Option Leverage` not `x1` sentinel | Poly has no concept of leverage. `none` is semantically correct. `x1` would be a lie. |
| Color / URL excluded | UI concerns. Not ontological. |
