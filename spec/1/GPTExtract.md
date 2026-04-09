Below, turn references use the transcript clock stamps. Where a user reply sits between two timestamps, I cite it as “the user reply between X and Y.” Source transcript: 

## Section 1: Locked decisions

### D1. Provider-native shapes must be normalized before they reach the frontend.

**Statement of the decision.** The frontend must not consume raw venue-native representations. Provider-specific data shapes are normalized before the UI layer.

**How it was reached.** Explicit. In the user material immediately before 7:32 PM, the user says, “it must get normalized in the front before I get to the front end.” At 7:32 PM the assistant responds: “That is the right instinct and it is non-negotiable.”

**Final form.** The final architecture assumes venue-specific adapters on the read side and a normalized display contract for the frontend. The frontend does not ingest raw Drift/Gains/Parcl/Polymarket payloads.

**Prior versions.** Earlier answers being assessed in the conversation had stopped at provider-exact boundary types and had not solved the downstream integration problem. That approach was explicitly criticized as creating “integration-times-N.”

**Cross-references.** D2, D3, D6, D7, D10, D13, Artifact A1, Artifact A2.

### D2. The read side is a single aggregated `getMarkets` path.

**Statement of the decision.** Viewing data is one outbound path that returns all markets together.

**How it was reached.** Explicit. In the user reply before 8:39 PM: “we normalize it so that we can call get market and we return all the markets. That’s an expected page outcome.” At 8:39 PM the assistant restates this as “one call, getMarkets, returns everything.”

**Final form.** There is one outbound/read contract for viewing. It is not stratified by venue at fetch time.

**Prior versions.** Earlier shapes discussed canonical DTOs and row objects, but the “one pipe out” rule is where the read-side API shape became operationally fixed.

**Cross-references.** D3, D6, D7, Artifact A1.

### D3. Read and write are separate contracts: one pipe out for viewing, singular/specific write path for execution.

**Statement of the decision.** The conversation commits to an asymmetric architecture: unified outbound viewing, specific inbound execution.

**How it was reached.** Explicit. In the user reply before 8:39 PM the user says the pipeline “going out” is everything already there for viewing, while execution is “singular” / “univocal.” At 8:39 PM the assistant formalizes that as “Outbound … one pipe. … Inbound … stratified.”

**Final form.** `getMarkets` is the read contract. Execution is a separate write contract keyed to the clicked row’s identity.

**Prior versions.** Before this, the conversation was still asking what the frontend should receive and how many normalization layers should sit before it. This decision froze the read/write split as a first-class architectural fact.

**Cross-references.** D2, D10, D13, Artifact A1, Artifact A2.

### D4. Displayed numbers must carry units; number-only display is insufficient.

**Statement of the decision.** A raw number is not enough for the wallet/table UI; the unit/meaning must travel with the value.

**How it was reached.** Explicit. In the user reply between 8:06 PM and 8:08 PM: “Just make sure that the units are there.” At 8:08 PM the assistant says this is “the entire architecture argument.”

**Final form.** The final display row includes `unit`. The frontend formats `price` by reading `unit`. The design does not rely on venue-specific frontend logic to recover meaning.

**Prior versions.** Before this, earlier proposals used `kind`, `semanticType`, or tagged constructors to carry meaning. The final display contract settled on a simpler outward-facing `unit` field plus an `info` string, while the earlier semantic-type talk remained upstream/background.

**Cross-references.** D5, D7, Artifact A1, Terminology items for `unit`, `kind`, and `dumb frontend`.

### D5. Polymarket should be shown to end users as a percentage on the display side.

**Statement of the decision.** For frontend display, Polymarket values are shown as percentages because that is “the most clear,” even if the venue itself supports price/cents/probability framings.

**How it was reached.** Explicit. In the user reply before 8:10 PM: “for the front end … I would just do percentage, because it’s the most clear.” At 8:10 PM the assistant distinguishes this as a display decision, separate from ingest.

**Final form.** The display route examples at the end of the conversation use `75%` for Polymarket rows.

**Prior versions.** The user had initially said they could imagine “percentage,” “cents,” or “literally writing probability.” That ambiguity was resolved in favor of percentage for the frontend.

**Cross-references.** D4, D7, D16, Artifact A1.

### D6. The frontend display contract is venue-agnostic and uses shared rows instead of venue-specific columns.

**Statement of the decision.** The table uses shared, agnostic fields rather than venue-specific dedicated columns.

**How it was reached.** Explicit. In the user reply before 9:23 PM: “you don’t show leverage as a column in a table. What you do is you do an agnostic name, symbol, price … and then you do info.” At 9:23 PM the assistant restates this as a four-column design and builds on it.

**Final form.** The mature row contract ends with shared top-level fields. Leverage, expiry, and similar venue-specific display details are pushed into `info` rather than separate typed UI columns.

**Prior versions.** Earlier proposals considered typed display fields such as leverage/expiration/category, and later a `capabilities` field for frontend routing logic. Those were not adopted in the final v1 row contract.

**Cross-references.** D7, D8, D10, D13, Artifact A1.

### D7. `Info` is a freeform display field, not a structured UI contract.

**Statement of the decision.** `Info` is opaque freeform display text, formatted by the adapter/backend side for human reading.

**How it was reached.** Explicit. The user says before 9:23 PM that for Drift/Parcl/Gains, the info area would include leverage, while for Polymarket it would contain something like “expires October 10th.” At 9:23 PM the assistant confirms that `Info` is “a single field that the table renders as-is.”

**Final form.** `info: string` survives into the final row artifact. It is not replaced by `max_leverage`, `expiration`, or a typed display-object renderer.

**Prior versions.** Structured typed display extras were repeatedly floated by the assistant and then walked back. A later `capabilities` field was proposed for routing, then rejected when routing moved to the endpoint.

**Cross-references.** D6, D10, Artifact A1.

### D8. Polymarket rows are allowed in the same list via dynamic human-readable naming.

**Statement of the decision.** Polymarket is not forced into a separate list/tab purely because its “asset” is a question. A dynamic string is allowed in the display contract.

**How it was reached.** Explicit. The user asks before 9:20 PM, “cant i just put dynamic for poly”. At 9:20 PM the assistant replies, “Yes, you can.”

**Final form.** The conversation’s end-state examples show rows like `Will Trump win NH?` in the same table shape as BTC and ATL rows.

**Prior versions.** The assistant had explicitly raised “same list or separate tab” as a gap. That gap was collapsed by the user’s dynamic-name move.

**Cross-references.** D6, D7, D16, Artifact A1.

### D9. Display-facing information and execution-facing information are separate concerns.

**Statement of the decision.** What the human sees and what the system needs to execute are separate layers. They should not be conflated.

**How it was reached.** Explicit. In the user reply before 9:27 PM, the user says the front presents things for human readability, while execution needs “a packet of information, a metadata that is full enough to execute anything it needs.” At 9:27 PM the assistant formalizes this as “Layer 1 — Display layer” and “Layer 2 — Execution metadata layer.”

**Final form.** Even though the row-carried opaque execution blob is later removed, the separation survives as a stronger read/write split: display rows stay display-oriented; execution data is handled on the write path by `executionSignal` and right-Lean.

**Prior versions.** The first concrete mechanism for this separation was an opaque per-row `execution` payload. That mechanism was later replaced; the conceptual separation remained.

**Cross-references.** D3, D10, D13, Artifact A1, Artifact A2.

### D10. Zod is dropped for the formally verified backend path.

**Statement of the decision.** The frontend will not use Zod as a runtime validator for the formally verified Lean backend’s row contract.

**How it was reached.** Explicit. At 8:46 PM the assistant says, “Zod — you’re right, drop it.” This directly answers the user’s question about why Zod would be needed on a formally verified backend.

**Final form.** No Zod layer is part of the agreed architecture for the main display contract.

**Prior versions.** At 8:39 PM the assistant had suggested TanStack, Zustand, and Zod as composable frontend pieces. Zod was then explicitly removed.

**Cross-references.** Section 5 rejected proposals, Section 6 implicit assumptions about formal verification.

### D11. For the display route, send plain numeric prices, not preformatted strings or exact-decimal frontend payloads.

**Statement of the decision.** The frontend display route receives `price` as a plain JavaScript number, not as a preformatted string and not as a mantissa/scale or `{coeff, scale}` exact-decimal object.

**How it was reached.** Explicit. The user first pushes at 9:38 PM and 9:40 PM: “Why can’t I say, ‘Here, this is 70,000. Here you go.’” At 9:40 PM the assistant answers: “You can. And you should. … Send the number.”

**Final form.** Final display rows carry `price: number` and `unit: string`. The frontend formats using `unit`.

**Prior versions.** This decision superseded:

* preformatted `price: string`,
* preformatted `price` plus `priceNumeric`,
* `{ mantissa, scale, unit }`,
* exact-decimal frontend DTOs using `{ coeff, scale }`,
* frontend-facing `Price { mantissa, expo }`.

**Cross-references.** D4, D5, D12, Artifact A1, Section 5 rejected proposals.

### D12. Human-readable display data and blockchain-native precision data are split into different routes.

**Statement of the decision.** The display route is for human-scale numbers. Blockchain-native precision logs/balances/history get a different route and different shape.

**How it was reached.** Explicit. In the user reply before 9:45 PM: “when we are displaying regular numbers … we’ll just use handover numbers. When it comes to … blockchain history logs … we can have a different route.” At 9:41 PM the assistant says, “Yes. Exactly that.”

**Final form.** Display route uses plain numbers. Exact big-int/native-precision schemas are not part of the display-route contract.

**Prior versions.** Several earlier attempts tried to carry exact-decimal or big-int-safe forms on the main display route. Those were removed once the route split was accepted.

**Cross-references.** D11, Artifact A1, Section 4 deferred decisions.

### D13. Venue capability/routing logic belongs in the execution endpoint/right-Lean, not in frontend row capabilities.

**Statement of the decision.** The frontend should send an execution signal with whatever context it has; the endpoint/right-Lean decides venue compatibility and routing.

**How it was reached.** Explicit. In the user reply before 9:50 PM: “the front end should just send the signal to initiate … one single API called ‘execution signal listen’ … I would rather just make it part of the endpoint itself.” At 9:50 PM the assistant explicitly adopts option B and says right-Lean does the smart routing.

**Final form.** The execution path centers on a single write-side signal contract. Venue rules such as leverage support do not live in row `capabilities` fields read by the frontend.

**Prior versions.** Before this, the assistant had proposed a frontend `contextResolver` plus a `capabilities` field on each row. That was rejected in favor of backend/right-Lean routing.

**Cross-references.** D3, D9, D14, Artifact A2.

### D14. v1 is manual-only: no auto mode, no unified BTC row, no disambiguation logic on the shipping path.

**Statement of the decision.** For v1, the user sees separate venue rows and manually picks the row they want. Auto-routing/unifying is deferred.

**How it was reached.** Explicit in the assistant’s reading of the user’s later diagram at 10:08 PM: “For now, no auto, no unifying. Just show both BTC rows.” This is then treated as operative in the following turns, where the user no longer argues for merged BTC rows and instead refactors provider identity. That is implicit acceptance.

**Final form.** Drift BTC and Gains BTC are separate rows in v1. Future auto-selection, wallet-balance routing, last-trade memory, and unified BTC rows are postponed.

**Prior versions.** Immediately before this, the user had described an “auto” provider setting and context-aware routing based on balances, defaults, last trade, and leverage. That future design was not discarded, but it was explicitly moved out of v1.

**Cross-references.** D13, D15, D16, Artifact A1, Artifact A2, Section 4 deferred decisions.

### D15. The execution identity is finalized as `(asset_symbol, provider)`, not `(asset_symbol, providers_chain)`.

**Statement of the decision.** The final row-level execution resolver pair is `asset_symbol` plus `provider`.

**How it was reached.** Explicit. In the user reply before 10:16 PM: “we could just keep the Provider as its own structure that includes where they operate.” At 10:16 PM the assistant agrees and changes the row uniqueness rule from `(asset_symbol, providers_chain)` to `(asset_symbol, provider)`.

**Final form.** The write path uses `asset_symbol` and `provider` as required identifiers. Provider network is derived from provider, not duplicated in the row.

**Prior versions.** This superseded:

* row-carried opaque execution payloads,
* ad hoc suffix strings like `BTC.gains` as the execution key,
* `asset_symbol + providers_chain` as the required resolver pair.

**Cross-references.** D13, D16, Artifact A1, Artifact A2, Artifact A3.

### D16. `Network`, `ProviderNetwork`, and `Provider` are distinct concepts; the row carries `provider`, and provider/chain display is rendered separately from the symbol.

**Statement of the decision.** The conversation finalizes a three-way distinction:

* native asset network,
* provider operating network,
* provider/venue itself.
  The row does not bake provider/chain into the symbol string.

**How it was reached.** Explicit. The user states before 10:16 PM:
“Network (native, provider agnostic) / ProviderNetwork / Provider.”
At 10:16 PM the assistant confirms that distinction and says provider should be its own structure. In the final user reply before 10:20 PM, the user asks, “just a seperate icon/column or thing to add ?” and the assistant answers, “Yes — exactly that. A separate visual element. Not baked into the symbol string.”

**Final form.** Final rows use bare `asset_symbol` plus `provider`. The UI renders the provider/chain as a separate icon/column/visual element derived from provider lookup.

**Prior versions.** Earlier versions used `providers_chain` directly on the row or symbol suffixes such as `BTC.solana`, `BTC.arbitrum`, `BTC.drift`.

**Cross-references.** D14, D15, Artifact A1, Artifact A3, Terminology for `Provider`, `ProviderNetwork`, `Network`.

## Section 2: Locked artifacts

### Artifact A1. `getMarkets` display row contract

**Type.** API contract / row schema.

**Final form.**

```text
getMarkets() → [
  {
    id:           string,
    name:         string,
    asset_symbol: string,
    provider:     string,
    price:        number,
    unit:         string,
    info:         string,
  },
  ...
]
```

**Field history.**

* `id: string` — **in final version**. Introduced as a stable row key for React. The user explicitly questioned ID necessity only in the execution sense, not as a row key; the field remained present and unchallenged through the final row shape.
* `name: string` — **in final version**. Human-readable display name. Example meanings attached in the conversation: “Bitcoin,” “Atlanta Housing,” full Polymarket question text.
* `asset_symbol: string` — **in final version**. Final name for the canonical short asset identifier on the row. Earlier versions used `symbol`.
* `provider: string` — **in final version**. Final row-level venue selector. Foreign-key-like reference into a provider lookup/structure.
* `price: number` — **in final version**. Plain JS number for the display route.
* `unit: string` — **in final version**. Rendering unit/meaning for `price`. Examples discussed: `"USDC"`, `"%"`, `"JPY"`.
* `info: string` — **in final version**. Freeform human-readable field for venue-specific display context.

**Earlier-version removed fields.**

* `symbol: string` — **earlier version removed/renamed**. Used before the row finalized on `asset_symbol`.
* `providers_chain: string` — **earlier version removed**. Was used briefly as the second execution resolver before being replaced by `provider`.
* `execution: <opaque>` — **earlier version removed**. Early row shapes carried an opaque execution blob; later removed once the write-side contract became `executionSignal`.
* `price: string` — **earlier version removed**. Preformatted display string version of `price`.
* `priceNumeric: number` — **earlier version removed**. Transitional companion field added only because the preformatted-string design broke sorting.

**Proposed but never adopted fields.**

* `kind` — **proposed never adopted**. Early frontend DTO design used a semantic `kind` enum.
* `value = { coeff: "digits", scale: Nat }` — **proposed never adopted**. Early exact-decimal frontend DTO.
* `tick = { coeff: "digits", scale: Nat }?` — **proposed never adopted**.
* `meta` — **proposed never adopted**.
* `capabilities: { ... }` — **proposed never adopted**. Proposed to support frontend-side venue filtering/routing.
* typed display extras such as `max_leverage`, `expiration`, separate category fields — **proposed never adopted** as first-class row fields.

**Constraints/comments attached during the conversation.**

* The row is venue-agnostic on the display side.
* Polymarket fits the same row shape by allowing dynamic human-readable naming.
* Chain/provider rendering must not be encoded inside `asset_symbol`; it is rendered separately from `provider`.
* The row is for the human-readable display route only, not for blockchain-native precision logs.

**Provenance.**

* Introduced conceptually as a “canonical frontend language” at 7:36 PM.
* First concretized as `name/symbol/price/info` at 9:23 PM.
* Revised at 9:27 PM to include top-level `id` and `execution`.
* Revised at 9:36 PM to preformatted `price` plus `priceNumeric`.
* Revised at 9:40 PM to `price: number` and `unit: string`.
* Revised at 9:50 PM to remove `execution`.
* Revised at 10:08 PM to `asset_symbol` and `providers_chain`.
* Finalized at 10:16 PM / 10:20 PM as `asset_symbol` plus `provider`, with provider/chain rendered separately.

### Artifact A2. `executionSignal` write-side contract

**Type.** API contract / endpoint shape.

**Final form.**

```text
executionSignal({
  asset_symbol: string,
  provider:     string,
  amount:       number,
  // supporters: leverage, side, wallet preference, page context, etc. may be present
})
  → { kind: "executed", ... }
  | { kind: "rejected", reason: string }
```

**Field history.**

* `asset_symbol: string` — **in final version**. Required resolver.
* `provider: string` — **in final version**. Required resolver, replacing `providers_chain`.
* `amount: number` — **in final version**. Required execution quantity.

**Earlier-version removed fields.**

* `providers_chain: string` — **earlier version removed**. Brief v1 resolver before provider refactor.
* `execution: <opaque>` as request input — **earlier version removed**. Earlier design used a row-carried opaque blob returned to right-Lean on click.
* response kind `disambiguate` — **earlier version removed for v1**. Present during the auto-routing/context-resolver phase; removed once v1 became manual-only.

**Proposed but never adopted fields.**

* `walletPreference` — **proposed never adopted as a final required field**. Part of the auto-routing phase.
* `side` — **proposed never adopted as a final required field**.
* `leverage` — **proposed as a supporter**, but not frozen as a mandatory field in the final v1 contract.
* page/context/settings signals generally — **proposed as supporters**, not frozen as mandatory fields.
* separate endpoint `confirmExecution(payload)` — **proposed never adopted**.
* exact response payload fields like `venue`, `txHash` — **assistant examples, not explicitly finalized by the user**.

**Constraints/comments attached during the conversation.**

* Frontend sends signals; right-Lean owns routing/capability logic.
* In v1 manual mode, no disambiguation branch is needed because the clicked row already encodes the provider.
* Supporters are quality-of-life inputs, not required to uniquely identify the venue in v1.

**Provenance.**

* Introduced conceptually when the user said the frontend should send “one single API called ‘execution signal listen’” in the reply before 9:50 PM.
* Formalized by the assistant at 9:50 PM as `executionSignal(...)`.
* Revised at 10:08 PM to the two-resolver model (`asset_symbol`, `providers_chain`) plus supporters.
* Finalized at 10:16 PM as `asset_symbol`, `provider`, `amount`, with supporters optional and `disambiguate` removed for v1.

### Artifact A3. `Provider` as a separate structure / lookup

**Type.** Struct / lookup-table concept.

**Minimal locked form.**

```text
Provider
  includes:
    - provider identity
    - where the provider operates
```

**What is actually locked.**

* There is a distinct `Provider` concept.
* `Provider` carries where the provider operates.
* The row references `provider`; provider network is derived from that, not duplicated on every row.

**Fields in the final conversation state.**

* `id` / provider identity — **in final version by implication**, because rows carry `provider`.
* operating network (`network` / provider network) — **in final version**, because that is the whole purpose of the provider structure refactor.

**Proposed but never explicitly adopted fields.**

* `display_name`
* `network_display`
* `glyph`
* future capability fields such as leverage support

These were suggested by the assistant at 10:16 PM as a possible concrete structure, but the user did not explicitly confirm those exact fields before the transcript ended.

**Related proposed artifacts not adopted.**

* `Asset` lookup table carrying native network — **proposed never adopted**.
* hardcoded provider table in the frontend bundle — **not finalized**.
* fetched provider table from left-Lean at app load — **not finalized**.

**Provenance.**

* Introduced explicitly by the user before 10:16 PM: “we could just keep the Provider as its own structure that includes where they operate.”
* Finalized minimally at 10:16 PM, then used again at 10:20 PM to justify separate provider/chain rendering.

## Section 3: Locked terminology

### 1. `Price`

**Definition in the conversation.** This term was overloaded. It referred at different times to:

* an internal Lean decimal-like structure (`mantissa` / `expo`),
* a provider-exact numeric domain,
* later, a plain display-route number.
  The conversation never canonicalized `Price` to one stable meaning across all layers.

**Synonyms / near-synonyms.** `price`, `value`, `quote`, `probability` were not treated as equivalent. `Quote` was proposed as a wrapper over `Price`; `probability` was explicitly treated as a separate semantic kind in some turns.

**First / last appearance.** First at 6:44 PM; last materially at 9:40 PM.

### 2. `kind`

**Definition in the conversation.** In the earlier DTO phase, `kind` was the semantic label for values such as `price | probability | index | qty | amt | pct`.

**Synonyms / near-synonyms.** The assistant also related this to FIX `semanticType` and to tagged constructors like `.perpetual / .index / .probability`. These were treated as analogous, not identical artifacts.

**First / last appearance.** First materially at 7:32 PM / 7:36 PM; last substantive use around 8:30 PM, after which the final row contract moved away from `kind`.

### 3. `unit`

**Definition in the conversation.** The display-side semantic/unit label that tells the frontend how to render a plain number.

**Synonyms / near-synonyms.** Not treated as the same thing as `kind`; `unit` became the final display-side carrier of meaning, while `kind` was an earlier DTO proposal. Examples discussed: USD/USDC, percentage, probability display.

**First / last appearance.** First materially in the user reply before 8:08 PM (“Just make sure that the units are there”); last at 10:20 PM in the final row contract.

### 4. `getMarkets`

**Definition in the conversation.** The unified read-side call returning the market list for viewing.

**Synonyms / near-synonyms.** `get market`, `getMarkets`, “one pipe out.” Treated as the same read-side idea.

**First / last appearance.** First explicit use in the user reply before 8:39 PM; last at 10:16 PM/10:20 PM.

### 5. `execution signal listen` / `executionSignal`

**Definition in the conversation.** The single write-side endpoint receiving an execution intent plus context/signals.

**Synonyms / near-synonyms.** The user says “execution signal listen”; the assistant standardizes it as `executionSignal`. These were treated as the same concept, but the exact final endpoint name was not fully frozen.

**First / last appearance.** First in the user reply before 9:50 PM; last at 10:20 PM.

### 6. `Info` / `asset info` / `data`

**Definition in the conversation.** A freeform display field carrying venue-specific human-readable extra context.

**Synonyms / near-synonyms.** The user floated `info or asset info or data`. The conversation settled operationally on `info`. These were treated as near-synonyms.

**First / last appearance.** First before 9:23 PM; last at 10:20 PM.

### 7. `dynamic for Poly`

**Definition in the conversation.** The idea that Polymarket can use a dynamic display string—e.g., the full market question—inside the same shared row schema.

**Synonyms / near-synonyms.** Not treated as the same as `asset_symbol`. This applies to the human-readable display side.

**First / last appearance.** First before 9:20 PM; still operative through the final table examples at 10:20 PM.

### 8. `symbol` and `asset_symbol`

**Definition in the conversation.** `symbol` was the earlier name for the canonical short identifier on the display row. Later it was renamed to `asset_symbol` when the row was refactored around provider identity.

**Synonyms / near-synonyms.** `symbol` and `asset_symbol` were treated as successive names for the same slot. They were not treated as equivalent to `name`.

**First / last appearance.** `symbol` first materially at 9:23 PM; `asset_symbol` first materially at 10:08 PM; `asset_symbol` persists through 10:20 PM.

### 9. `name`

**Definition in the conversation.** The human-facing display name / dynamic display string. Examples attached to it included “Bitcoin,” “Atlanta Housing,” and full Polymarket question text.

**Synonyms / near-synonyms.** Not treated as equivalent to `symbol` / `asset_symbol`. The distinction remained somewhat verbal rather than fully formal.

**First / last appearance.** First materially at 9:23 PM; persists through 10:20 PM.

### 10. `Provider`

**Definition in the conversation.** The venue itself: Drift, Gains, Parcl, Polymarket.

**Synonyms / near-synonyms.** Not equivalent to `ProviderNetwork` and not equivalent to native `Network`.

**First / last appearance.** The term appears earlier informally, but it is explicitly formalized at 10:16 PM and remains final at 10:20 PM.

### 11. `ProviderNetwork`

**Definition in the conversation.** Where the provider operates: Solana for Drift/Parcl, Arbitrum for Gains, Polygon for Polymarket.

**Synonyms / near-synonyms.** Earlier `provider's chain` and `providers_chain` referred to this idea. Final terminology distinguishes it from `Provider`.

**First / last appearance.** First as `provider's chain` at 10:08 PM; formalized as `ProviderNetwork` by the user before 10:16 PM.

### 12. `Network (native, provider agnostic)`

**Definition in the conversation.** The asset’s native chain/network, distinct from the provider’s operating network.

**Synonyms / near-synonyms.** Not equivalent to `ProviderNetwork`.

**First / last appearance.** Explicitly introduced by the user before 10:16 PM; discussed at 10:16 PM.

### 13. `dumb frontend` / `LEAF DUMB DISPLAY ONLY FRONTEND`

**Definition in the conversation.** A frontend that does not own venue-specific knowledge or raw protocol semantics.

**Synonyms / near-synonyms.** Later refined to “dumb about venues,” not “dumb about the user.”

**First / last appearance.** First explicit via the user’s diagram discussed at 8:30 PM; last materially at 10:20 PM.

### 14. `smart about the user`

**Definition in the conversation.** A frontend or future layer that may use user state such as wallet balances, defaults, and recent choices to guide execution selection.

**Synonyms / near-synonyms.** Related to `context resolver`, `auto`, `trading agnostically`. Not the same as venue knowledge.

**First / last appearance.** First materially in the user reply before 9:45 PM; later deferred for v2 at 10:08 PM.

### 15. `resolvers` and `supporters`

**Definition in the conversation.** In the v1 execution packet, the required identity fields are “resolvers”; optional extra context fields are “supporters.”

**Synonyms / near-synonyms.** None treated as equivalent.

**First / last appearance.** First explicit at 10:08 PM; survives into the provider refactor at 10:16 PM.

### 16. `auto` / `trading agnostically`

**Definition in the conversation.** A future provider-selection mode that would use balances, defaults, history, and other signals to choose venue automatically.

**Synonyms / near-synonyms.** `auto`, `trading agnostically`, `smart context` were related. This was explicitly deferred for v1.

**First / last appearance.** First in the user reply before 9:45 PM; deferred at 10:08 PM.

### 17. `execution payload` / `execution blob` / `opaque blob`

**Definition in the conversation.** A venue-specific object attached to a row and round-tripped by the frontend without inspection.

**Synonyms / near-synonyms.** Treated as equivalent labels for the same earlier proposal.

**First / last appearance.** First materially at 9:27 PM; removed from the final row contract by 9:50 PM.

### 18. `canonical frontend language` / `Frontend DTO`

**Definition in the conversation.** The earlier proposal for a unified frontend-facing language independent of provider-native shapes.

**Synonyms / near-synonyms.** `canonical frontend language`, `DTO`, `front-end language`, `flat project-defined DTO`. These were treated as equivalent during the 7:32–7:36 phase.

**First / last appearance.** First materially at 7:32 PM; last substantive use at 8:30 PM before the simpler row contract took over.

## Section 4: Open questions and deferred decisions

### 1. Exact internal Lean numeric representation

**Question or deferred item.** The conversation never finalized the internal Lean numeric carrier(s): fixed-scale per-provider types, signed mantissa/exponent pairs, provider-exact wrappers, and other variants were all proposed.

**Why it was deferred.** The conversation pivoted from Lean-internal number ontology to the frontend/read-write contract problem.

**What would need to happen to lock it.** A later discussion must explicitly choose the Lean-internal representation and revision-free scope: `Price`, `MarketPrice`, `Quote`, `FixedDecimal`, `ScaledDecimal`, or some other structure.

**Default in the meantime.** None specified beyond “left-Lean adapters exist” and “right-Lean exists.”

### 2. Exact internal Lean market/provenance schema

**Question or deferred item.** Early discussion raised unresolved internal questions about `Provenance`, `PolyAsset`, `ParclAsset`, `Market.provider` being derived vs stored, and whether provider-specific semantic refinements are retained.

**Why it was deferred.** The conversation moved away from internal closed-world Lean modeling and into display/execution API design.

**What would need to happen to lock it.** A dedicated internal Lean schema conversation must resolve:

* `provenance : Nat` vs tagged inductive,
* `PolyMarketId`/side/question identity,
* whether provider-specific categories remain in the normalized core,
* whether `provider` is stored or derived.

**Default in the meantime.** None identified.

### 3. Exact semantics of `name` vs `asset_symbol`

**Question or deferred item.** The conversation stabilized on both fields existing, but the exact boundary remained partly verbal.

**Why it was deferred.** The user and assistant got to a workable distinction for the row contract, but not to a full normalization rule for every venue.

**What would need to happen to lock it.** A later pass must specify, per venue, what populates `name` and what populates `asset_symbol`, especially for Polymarket question/slug cases.

**Default in the meantime.** Operative assumption: `name` is the human-facing string; `asset_symbol` is the canonical short symbol/slug.

### 4. Whether `id` is required, and if so how it is generated

**Question or deferred item.** `id` remained in the final row shape, but the user explicitly questioned ID necessity in the execution discussion and never explicitly signed off on its generation semantics.

**Why it was deferred.** The conversation moved on once execution stopped depending on the ID.

**What would need to happen to lock it.** A later pass must specify whether `id` is mandatory, what guarantees it provides, and how it is generated.

**Default in the meantime.** Assistant examples treated `id` as a stable row key.

### 5. Provider table delivery: hardcoded or fetched

**Question or deferred item.** The assistant explicitly asked whether the provider table should be a hardcoded frontend constant or fetched from left-Lean. The user did not answer before the transcript ended.

**Why it was deferred.** The conversation ended after resolving the row/provider abstraction, not the distribution mechanism.

**What would need to happen to lock it.** A later pass must choose deployment/update strategy for provider metadata.

**Default in the meantime.** None identified.

### 6. Whether there is an explicit asset/native-network lookup table

**Question or deferred item.** An optional `Asset` table for native-network rendering was proposed but never adopted.

**Why it was deferred.** It was presented as optional and not required for the row contract.

**What would need to happen to lock it.** A later decision must say whether native-network metadata is needed in the UI or execution path at all.

**Default in the meantime.** None; provider-based rendering is enough for the finalized v1 row contract.

### 7. Exact visual presentation of provider/chain in the table

**Question or deferred item.** The conversation locked that provider/chain must be rendered separately from `asset_symbol`, but not whether it is inline icon, separate column, hover element, badge, etc.

**Why it was deferred.** The assistant explicitly treated it as a rendering-only concern.

**What would need to happen to lock it.** A UI design decision, not a contract decision.

**Default in the meantime.** No default beyond “separate visual element.”

### 8. Future auto-routing / unified asset rows

**Question or deferred item.** The user explicitly described a future “auto” mode using wallet balances, defaults, last trade, leverage, and other context. That logic was deferred out of v1.

**Why it was deferred.** The conversation explicitly simplified v1 to manual rows and manual venue choice.

**What would need to happen to lock it.** A later v2 design pass must specify:

* whether rows merge by asset,
* exact signal priority,
* whether right-Lean or frontend owns final resolution,
* whether/how disambiguation modal returns control.

**Default in the meantime.** Manual-only v1 with separate rows.

### 9. Exact shape of the blockchain/native-precision route

**Question or deferred item.** The existence of a separate blockchain-native route was accepted, but its schema was never designed.

**Why it was deferred.** The user explicitly separated it from the current display-route problem.

**What would need to happen to lock it.** A later route-specific contract design.

**Default in the meantime.** None identified.

### 10. Exact execution endpoint name

**Question or deferred item.** The user says “execution signal listen”; the assistant standardizes to `executionSignal`. The concept is clear; the exact endpoint name was not formally frozen.

**Why it was deferred.** Naming was secondary to routing/location of logic.

**What would need to happen to lock it.** A later naming pass or implementation PR.

**Default in the meantime.** `executionSignal` is the operative label in the later assistant turns.

### 11. Confirmation modal for manual v1 trades

**Question or deferred item.** Early on, the assistant posed a confirmation-modal question. Later the conversation removed disambiguation from v1 by making venue choice manual, but never explicitly settled whether every trade should still have a confirmation modal.

**Why it was deferred.** The conversation shifted from modal behavior to route simplification and provider identity.

**What would need to happen to lock it.** A product/UI decision.

**Default in the meantime.** None specified in the transcript.

## Section 5: Rejected proposals

### 1. `Price` as `mantissa : Nat` and `expo : Int` without type-level canonicality

**Who proposed it.** This was the design under critique in the opening proposal/revision material.

**Why it was rejected.** At 6:44 PM and 7:05 PM it is rejected because it admits multiple structural inhabitants for the same semantic value and leaves equality wrong unless supplemented elsewhere.

**What replaced it.** No final internal Lean replacement was locked. The eventual display contract abandoned this entire frontend-facing direction and used `price: number`.

### 2. `provenance : Nat`

**Who proposed it.** Earlier revision under critique.

**Why it was rejected.** At 6:44 PM it is called “type erasure” because it discards both provider association and bounded identifier space.

**What replaced it.** No finalized internal Lean provenance replacement was adopted in the final conversation state.

### 3. `normalizePoly : PolyCategory → Probability → Market`

**Who proposed it.** Earlier revision under critique.

**Why it was rejected.** At 6:44 PM it is rejected as unsound because category plus probability does not uniquely identify a market; the assistant says market id and side are needed at minimum.

**What replaced it.** No finalized internal Poly-normalizer signature was adopted.

### 4. Silently dropping provider-specific semantic refinements in the normalized record

**Who proposed it.** Earlier normalized-market design under critique.

**Why it was rejected.** At 6:44 PM the assistant says dropping `GainsCategory`, `ParclLocationType`, `PolyCategory` is lossy unless explicitly declared non-semantic with proof obligations.

**What replaced it.** No final internal Lean answer was adopted.

### 5. Treating price-definition work as prior to Poly/Parcl identity resolution

**Who proposed it.** Earlier work order implied in the design under critique.

**Why it was rejected.** At 6:44 PM the assistant says the order is backward: Poly/Parcl market identity must be resolved before price modeling.

**What replaced it.** No later internal Lean work order was finalized; the conversation pivoted.

### 6. The single universal internal `Price { mantissa : Int, expo : Int }` plus `Quote` as the whole answer to integration

**Who proposed it.** Assistant at 7:32 PM.

**Why it was rejected.** At 7:36 PM the assistant itself says that answer collapsed Lean core and frontend DTO into one thing and was wrong for the user’s actual problem.

**What replaced it.** A multi-layer design where frontend/view contract is separate from the stricter internal world.

### 7. The exact-decimal frontend DTO `{ kind, value={coeff,scale}, tick, unit, id, meta }` as the final frontend contract

**Who proposed it.** The pasted “simpler solution” the assistant endorsed at 7:36 PM.

**Why it was rejected.** The conversation later stripped this down in favor of a simpler row/list contract with plain numbers and `unit`, then later a provider-based row contract.

**What replaced it.** Artifact A1, the final row shape.

### 8. Frontend branching on `kind`

**Who proposed it.** Earlier DTO/semantic-type discussion.

**Why it was rejected.** By 8:34 PM the user insists on thin Lean layers so that the frontend “just renders whatever the last Lean in the chain hands it.” Later the final row/UI path uses `unit` and provider rendering, not a `kind`-branching frontend DTO.

**What replaced it.** Upstream transformation plus a simpler row contract.

### 9. Separate Polymarket tab/list purely because Poly is semantically different

**Who proposed it.** Raised explicitly by the assistant as a design fork at 9:14 PM.

**Why it was rejected.** The user replies “cant i just put dynamic for poly” and the assistant accepts that, eliminating the separate-list requirement.

**What replaced it.** Same unified row schema with dynamic naming for Poly.

### 10. Dedicated leverage column

**Who proposed it.** Implicitly assumed in earlier assistant gap analysis.

**Why it was rejected.** The user says before 9:23 PM, “you don’t show leverage as a column in a table.”

**What replaced it.** `info: string`.

### 11. Structured typed display extras (`expiration`, `maxLeverage`, typed generic renderers)

**Who proposed it.** Assistant in several mid-conversation turns.

**Why it was rejected.** The user’s display contract insists on an opaque human-readable `info` field. Typed display extras would push venue knowledge back into the UI.

**What replaced it.** `info: string`.

### 12. Opaque execution blob as the final row-level execution mechanism

**Who proposed it.** Assistant at 9:27 PM and 9:36 PM.

**Why it was rejected.** Once the user wanted a single endpoint that receives signals and does routing itself, the row-carried blob became redundant.

**What replaced it.** `executionSignal` with explicit required resolvers on the write side.

### 13. Suffix string such as `BTC.drift` / `BTC.arbitrum` as the execution payload

**Who proposed it.** Raised as an option by the user and assistant.

**Why it was rejected.** At 9:36 PM the assistant argues this collapses under venues needing multiple identifiers and becomes an ad hoc serialization format.

**What replaced it.** First opaque execution blobs, then finally `asset_symbol + provider` on the write path.

### 14. Database ID lookup as the execution mechanism

**Who proposed it.** Assistant at 9:36 PM as one of three options.

**Why it was rejected.** The assistant rejects it as a bad fit for real-time market data because of stale-ID/cache/lookup race risks.

**What replaced it.** Not adopted; the conversation moves to a signal-based execution endpoint.

### 15. Preformatted price strings as the final display route value

**Who proposed it.** Assistant at 9:27 PM and 9:36 PM.

**Why it was rejected.** The user pushes back because sorting and simple display do not require that extra indirection; at 9:38 PM the assistant admits contradiction; at 9:40 PM the assistant switches to plain numbers.

**What replaced it.** `price: number` plus `unit: string`.

### 16. `priceNumeric` companion field

**Who proposed it.** Assistant at 9:36 PM to rescue sortable preformatted strings.

**Why it was rejected.** The assistant itself retracts the whole mixed strategy at 9:38 PM after the user points out the incoherence.

**What replaced it.** `price: number`.

### 17. Mantissa/scale/unit exact-display payloads for the main display route

**Who proposed it.** Assistant at 9:38 PM in response to the sorting contradiction.

**Why it was rejected.** The user asks directly why they cannot “just send the numbers as they are,” and at 9:40 PM the assistant agrees.

**What replaced it.** `price: number`.

### 18. Frontend `capabilities` field and frontend-side filtering/routing

**Who proposed it.** Assistant at 9:45 PM.

**Why it was rejected.** The user says the endpoint itself should own the rule logic, because that is simpler and keeps the venue knowledge in one place.

**What replaced it.** Right-Lean execution routing via `executionSignal`.

### 19. Auto/unified BTC routing in v1

**Who proposed it.** The user described it as a desired future behavior around 9:41–9:45 PM.

**Why it was rejected for v1.** At 10:08 PM the conversation explicitly simplifies to “For now, no auto, no unifying. Just show both BTC rows.”

**What replaced it.** Manual v1 with separate rows; auto remains deferred.

### 20. `providers_chain` as a row field and execution resolver

**Who proposed it.** Assistant at 10:08 PM as the simplified v1 resolver pair.

**Why it was rejected.** The user immediately points out the distinction between native network, provider network, and provider, and suggests keeping `Provider` as its own structure. At 10:16 PM the assistant agrees and removes `providers_chain` from the row.

**What replaced it.** `provider`, with provider network derived from provider metadata.

### 21. Baked symbol suffixes such as `BTC.solana` as part of the data contract

**Who proposed it.** Earlier in the mid-conversation symbol discussions.

**Why it was rejected.** At 10:20 PM the assistant says provider/chain should be a “separate visual element. Not baked into the symbol string.”

**What replaced it.** Bare `asset_symbol` plus provider-derived rendering.

### 22. Zod runtime validation on the frontend

**Who proposed it.** Assistant at 8:39 PM.

**Why it was rejected.** At 8:46 PM the assistant explicitly drops it in response to the user’s formally-verified-backend objection.

**What replaced it.** Nothing in the main contract path.

## Section 6: Implicit assumptions

### 1. React is the frontend rendering environment.

**Why this is implicit.** The assistant frames Socratic questions as “Pretend you’re writing the React component” at 7:39 PM; the user later talks about “a React table.”

**Operative turns.** 7:39 PM, 8:36–8:39 PM, 10:20 PM.

### 2. The backend/core is Lean and is intended to be formally verified.

**Why this is implicit.** The whole architecture is framed around “left-Lean” / “right-Lean”; the user explicitly says the backend is planned to be fully formally verified when questioning Zod.

**Operative turns.** 6:44–7:36 PM, 8:30 PM onward, especially 8:46 PM.

### 3. The provider set in scope is Drift, Gains, Parcl, and Polymarket.

**Why this is implicit.** Those four venues are treated as the live integration set throughout the architecture phase.

**Operative turns.** 7:22 PM survey; 7:32 PM onward throughout the design.

### 4. The UI surface is a unified wallet/market list with a Buy action.

**Why this is implicit.** The conversation repeatedly uses a list/table with rows and “click BUY” as the main frontend artifact.

**Operative turns.** 7:39 PM, 8:30 PM, 8:39 PM, 9:23 PM onward.

### 5. Human-readable prices on the display route fit safely in frontend numeric handling.

**Why this is implicit.** The user rejects exact-decimal display payloads in favor of “just send the number,” and the assistant agrees because the displayed values are human-scale.

**Operative turns.** 9:38 PM, 9:40 PM, 9:41 PM.

### 6. User identity / wallet context exists and is available to the system.

**Why this is implicit.** The user introduces Privy, embedded wallets, and settings/defaults as data sources for future routing logic.

**Operative turns.** 9:41 PM, 9:45 PM.

### 7. Privy is the assumed auth/wallet layer.

**Why this is implicit.** The user names Privy as the auth system and describes embedded Solana and ETH wallets. The design then uses wallet context as a future routing signal.

**Operative turns.** 9:41 PM.

### 8. Provider rows currently correspond to a single provider operating network in the current product, even though the final model avoids hard-coding that forever.

**Why this is implicit.** The v1 simplification works because each in-scope provider maps cleanly to one chain today; the 10:16 PM refactor exists precisely to avoid baking that assumption into the permanent row schema.

**Operative turns.** 10:08 PM, 10:16 PM.

### 9. The frontend is allowed to do generic UI work such as sorting and formatting, as long as it does not own venue semantics.

**Why this is implicit.** The “dumb frontend” slogan is repeatedly narrowed. The final design allows frontend formatting by `unit`, and the user explicitly says the frontend can do “sorting or settling or context in a comfort-for-the-user kind of way,” though most of that is later deferred out of v1.

**Operative turns.** 9:40 PM, 9:41 PM, 9:45 PM, 10:08 PM.

### 10. Table tooling and rendering specifics are implementation choices, not architecture drivers.

**Why this is implicit.** TanStack Table, Zustand, and Zod are discussed, but only the presence of a table-like renderer is operationally assumed. Exact library choice is not locked.

**Operative turns.** 8:39 PM, later table examples at 10:20 PM.

## Section 7: Unresolved contradictions

None identified.

Earlier contradictions were resolved by explicit revision chains rather than being left simultaneously operative. The major examples are:

* preformatted `price: string` vs plain `price: number`,
* row-carried opaque `execution` payload vs write-side `executionSignal`,
* `providers_chain` vs `provider`,
* auto/unified BTC routing vs manual v1 separate rows.

Those were not left in conflict at the end; they were revised.

## Section 8: Out-of-scope mentions

### 1. Cross-chain orchestration backend

This was explicitly mentioned by the user as “beyond the point” when discussing using funds on one chain to trade on another. It was named as a deeper layer, not part of the current v1 contract decision.

### 2. Currency/theme/global translation layers beyond the first display contract

The user and assistant discussed later thin layers for USDC → JPY/rupees and theme/display translation. These were illustrative future layers, not part of the frozen v1 contract.

### 3. Mobile app, embeddable widget, partner integrations

These appear as motivating examples for centralizing normalization/formatting, not as current implementation targets.

### 4. Exact blockchain-native/history-route schema

The route was explicitly separated conceptually, but its detailed schema was out of scope for the current design effort.

### 5. Multi-chain future provider expansions (e.g., hypothetical additional provider deployments)

These were used as arguments for not baking `providers_chain` into rows. They were future-proofing examples, not current deliverables.

### 6. Exact provider-table distribution mechanism

Hardcoded-vs-fetched was raised, but the detailed implementation path remained out of scope for the current contract freeze.

### 7. TanStack Table / Zustand / exact frontend library stack

These were mentioned as examples of implementation tooling, not locked architecture.

### 8. External verification of Polymarket lexical-domain details and live API specifics

The early assistant notes repeatedly marked those claims as unverified. They were part of research context, not part of the final frontend/read-write contract.

### 9. Ethereum/Dafny / MakerDAO / FIX / Hyperliquid evidence survey details

These informed the earlier reasoning but were not themselves part of the final v1 UI and execution contract.

### 10. “Summarize recent commits”

This appears in pasted material from another agent output and is unrelated to the design decisions actually being made in this transcript.
