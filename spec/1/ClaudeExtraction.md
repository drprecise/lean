# Lossless Final-State Extraction — Socratic Spec Conversation

## Section 1: Locked Decisions

### D1 — Three-layer architecture, not two

**Statement:** The system has three distinct layers: (1) Adapter/ingress per venue, (2) Lean core (strict, proof-carrying, semantically tagged), (3) Frontend DTO (one flat language). These are structurally different layers with different goals (faithfulness, correctness, uniformity respectively) and different shapes.

**How reached:** Explicit. The assistant initially proposed two layers (lines 366–371). The user pasted a ChatGPT response (lines 417–437) that separated "Core Lean truth" from "Frontend language." The assistant acknowledged "your version is the right one" and "it's materially better than what I gave you" (line 441), stating "There are actually three layers, not two" (line 444).

**Final form:** Adapter (per venue, faithful ingest) → Lean core (strict, Fin, Subtype, fixed-scale, tagged sums) → Frontend DTO (flat, decimal, uniform).

**Prior versions:** Assistant initially proposed two layers (adapter + canonical core) at lines 366–371. Revised to three after the ChatGPT response surfaced that the Lean core and frontend DTO have different goals ("The Lean core wants strictness; the frontend wants uniformity; those are different goals and they want different shapes" — line 449).

**Cross-references:** D7, D8, D29.

---

### D2 — The canonical Lean core Price type is `structure Price where mantissa : Int; expo : Int`

**Statement:** The single canonical numeric carrier inside the Lean core is a structure with a signed integer mantissa and signed integer exponent, matching the Pyth oracle shape and FIX SBE floating-point decimal.

**How reached:** Explicit. The assistant recommended this at lines 277–279 as the "decisive Lean 4 mapping." Reaffirmed at lines 377–380 ("Of all the shapes in the evidence, exactly one can losslessly receive every other shape"). The user did not challenge it.

**Final form:**
```lean
structure Price where
  mantissa : Int    -- signed; matches Pyth i64, Drift i64, FIX
  expo     : Int    -- signed; matches Pyth i32, FIX
```

**Prior versions:**
- Original proposal (pre-conversation): `mantissa : Nat; expo : Int` — rejected because unsigned mantissa cannot represent PnL, deltas, funding rates, spreads (lines 356–358, 386).
- Encoding B recommendation (lines 138–141): `structure FixedDecimal (scale : Int) where mantissa : Int` with phantom scale. This was recommended first (line 151) but revised to the universal Price shape after the user pushed back on integration difficulty ("doesn't that make integration extremely difficult... we were not able to unify" — line 300). The FixedDecimal types survived only in the adapter/ingress layer.

**Cross-references:** D3, D29, D30, D35.

---

### D3 — Mantissa is signed (Int), not unsigned (Nat)

**Statement:** The mantissa of Price must be Int, not Nat, because PnL, deltas, basis, funding rates, spreads, and any derived quantity are signed. Pyth, FIX, Drift's i64, and dYdX all chose signed.

**How reached:** Explicit rejection of alternative. "Claude Code (doc 102)" recommended `Nat`. The assistant explicitly rejected this: "'domain fact: prices are non-negative' framing collapses the moment you compute priceNow - priceThen" (lines 357–358). "Signed mantissa is non-negotiable per FIX" (line 169). The user did not dispute.

**Final form:** `mantissa : Int` on the Lean core Price structure.

**Prior versions:** `mantissa : Nat` in original proposal and in "Claude Code (doc 102)" recommendation. Rejected.

**Cross-references:** D2.

---

### D4 — MarketPrice / Quote is a tagged inductive separating semantic kinds

**Statement:** FIX treats Price, Qty, Amt, Percentage as distinct semantic datatypes. The Lean core must separate them via tagged constructors, but share a common Price carrier underneath.

**How reached:** Explicit. Introduced at lines 160–165 (MarketPrice inductive). Revised to Quote at lines 391–395 after the unification decision. The user implicitly accepted by building on it in subsequent turns.

**Final form:**
```lean
inductive Quote where
  | spot        : Price → Quote   -- Drift, Gains: dollar price
  | index       : Price → Quote   -- Parcl: real estate index level
  | probability : Price → Quote   -- Polymarket: bounded [0,1]
```

**Prior versions:**
- First version (lines 160–165): `MarketPrice` with constructors using FixedDecimal types per provider.
- Second version (lines 282–286): `MarketPrice` with `.pythLike`, `.fixedScale`, `.probability` constructors.
- Final version (lines 391–395): `Quote` with `.spot`, `.index`, `.probability`, all wrapping the unified Price type.

The shift was from provider-centric constructors (Drift uses this scale, Gains uses that scale) to semantic-kind constructors (spot price vs index vs probability). The assistant explicitly described this as "unify the carrier, separate the meaning" (line 397).

**Cross-references:** D2, D35.

---

### D5 — The frontend is dumb about venues, smart about the user

**Statement:** The frontend does not know what Drift is, what condition IDs are, what Gains uses Arbitrum, etc. The frontend does know Privy wallet balances, user settings, last-trade history, leverage preferences.

**How reached:** The user drew a diagram (line 611) labeled "LEAF DUMB DISPLAY ONLY FRONTEND." Implicit acceptance through all subsequent turns. The "smart about the user" refinement came when the user described the context resolver at lines 1429–1437 and the assistant articulated the distinction explicitly at lines 1456–1461.

**Final form:** "The frontend is dumb about venues. The frontend is smart about the user." (line 1459) These are different parts of the frontend: table (dumb about venues) vs context resolver (smart about user). For v1, the "smart about user" part is deferred.

**Prior versions:** Initially stated flatly as "dumb frontend" without the refinement about user-smartness. Revised when the user described leverage-aware, balance-aware routing.

**Cross-references:** D22, D23.

---

### D6 — One outbound pipe (getMarkets returns everything), stratified inbound (execution is per-asset)

**Statement:** The outbound data flow is a single `getMarkets` call returning all markets from all providers in one list. The inbound execution flow is singular — one asset on one venue per execution call.

**How reached:** Explicit. The user said: "we normalize it so that we can call get market and we return all the markets. That's an expected page outcome. You want to have a data pipeline that is fully present and available, so we push everything" (lines 743–744). The assistant confirmed: "you picked (A) — one pipe going out, stratified pipes coming in" (line 749).

**Final form:** `getMarkets()` returns a flat list of all rows across all venues. `executionSignal()` takes a specific (asset_symbol, provider) pair.

**Prior versions:** None — this was the user's initial proposal and was never revised.

**Cross-references:** D7, D18.

---

### D7 — Display route contract (getMarkets) row shape

**Statement:** Each row in getMarkets has exactly seven fields, all primitives, no opaque payloads, no nested structures.

**How reached:** Built through iterative discussion. The final shape emerged at lines 1882–1889 and was restated at lines 2082–2090 with "The contract is now genuinely done."

**Final form:**
```json
{
  "id":           "string — unique within response, React key",
  "name":         "string — 'Bitcoin', 'Atlanta Housing', Poly question text",
  "asset_symbol": "string — 'BTC', 'ATL', Poly slug — bare, no suffixes",
  "provider":     "string — 'drift', 'gains', 'parcl', 'polymarket' — foreign key to Provider table",
  "price":        "number — plain JS number",
  "unit":         "string — 'USDC', '%', 'JPY' — tells the formatter what glyph to use",
  "info":         "string — pre-formatted display text: '10x max', 'expires Oct 10'"
}
```

**Prior versions (full revision chain):**
1. (lines 979–985): Four columns — name, symbol, price, info. User proposed this.
2. (lines 1074–1085): Five + one — name, symbol, price (pre-formatted string), info, plus execution opaque blob.
3. (lines 1113–1122): Six + one — added `id` for React keys, kept execution blob.
4. (lines 1167–1175): Added `priceNumeric` alongside formatted `price` string. Total: seven + one.
5. (lines 1282–1292): Restructured price to `{mantissa: string, scale: number, unit: string}`. Removed `priceNumeric`.
6. (lines 1337–1345): Simplified to `price: number` (plain JS number) + `unit: string`. Six fields + execution blob.
7. (lines 1647–1674): Removed execution blob entirely (made redundant by executionSignal design). Six fields.
8. (lines 1747–1752): Renamed `symbol` to `asset_symbol`, added `providers_chain` field. Seven fields.
9. (lines 1882–1889): Replaced `providers_chain` with `provider` as foreign key. Seven fields. **Final.**

**Cross-references:** D8, D10, D11, D14, D16, D20.

---

### D8 — price is a plain JavaScript number

**Statement:** The price field in the display contract is a plain JS `number`, not a pre-formatted string, not a mantissa/scale pair, not a BigInt-encoded string.

**How reached:** Explicit, through the user's pushback. The user asked: "why don't we just send the numbers as they are?" (line 1317). The assistant responded: "You can. And you should" (line 1320) and admitted the prior complexity was wrong: "I was solving a problem you don't have" (line 1325). Locked at line 1337.

**Final form:** `price: number` — e.g., `78343.03`, `575.65`, `0.75`.

**Prior versions:**
1. Pre-formatted string `"$78,343.03"` (lines 1096–1100). Rejected by user's sort concern.
2. Pre-formatted string + parallel `priceNumeric: number` (lines 1161–1175). Rejected by assistant as incoherent duplication.
3. `{mantissa: "78343030000", scale: 6, unit: "USDC"}` (lines 1282–1292). Rejected by user: "why can't I say, 'Here, this is 70,000. Here you go'" (line 1317).
4. `{value: 78343.03, unit: "USDC"}` (line 1311) — offered as option (A). Close to final.
5. Plain `number` (line 1337). **Final.**

**Cross-references:** D9, D21.

---

### D9 — Two separate routes: display route (human-readable) and blockchain-native route (full-precision)

**Statement:** The display route sends plain JS numbers for prices humans look at. A separate blockchain-native route (to be defined later) will use string-encoded big integers or {value, decimals} pairs for wei-scale amounts. The two routes do not share a contract.

**How reached:** Explicit. The user proposed: "when we are displaying regular numbers and regular data to the regular front end, we'll just use handover numbers. When it comes to giving people blockchain history logs or whatever, we can have a different route" (lines 1376–1377). The assistant confirmed: "Yes. Exactly that. You just said it cleanly and it's correct" (line 1379).

**Final form:** Display route uses `price: number`. Blockchain-native route is deferred, will look different, not blocking anything.

**Prior versions:** Earlier attempts tried to make one type handle both cases (mantissa/scale structure), which the user rejected.

**Cross-references:** D8.

---

### D10 — info is a freeform pre-formatted string

**Statement:** The `info` field is a plain string that the adapter formats and the frontend renders as-is. It contains venue-specific context: "10x max" for perps, "expires Oct 10" for Polymarket, etc. The frontend cannot sort or filter by info contents.

**How reached:** Implicit acceptance. The user proposed the four-column layout including info as a catch-all at lines 973–975. The assistant confirmed the design at lines 984–986. The user never challenged info being opaque text. The tradeoff (can't sort/filter by info contents) was explicitly stated at lines 1013–1014 and not pushed back on.

**Final form:** `info: string` — pre-formatted display text. The adapter puts whatever venue-specific context is relevant. The frontend renders it verbatim.

**Prior versions:** Earlier designs had structured fields like `leverage`, `expiration`, `category` as separate typed columns. The user collapsed all of these into the single freeform `info` string.

**Cross-references:** D13.

---

### D11 — Drift BTC and Gains BTC are two separate rows, not merged

**Statement:** When the same underlying asset (e.g., BTC) exists on multiple venues, it appears as two distinct rows in the market list. No deduplication, no merging, no "unified BTC row" for v1.

**How reached:** Explicit. The user's sticky note said "better is BTC.SOL, BTC.ARB, BTC.BASE, BTC" (referenced at line 846). The assistant asked "one row or two?" and the user's diagrams and responses confirmed two rows. At lines 1718–1720: "For now, no auto, no unifying. Just show both BTC rows." The user confirmed by building on this without challenge.

**Final form:** Each (asset, provider) pair gets its own row. BTC-Drift and BTC-Gains are two rows in the same list, distinguished by the `provider` field and the chain glyph rendered from the Provider table.

**Prior versions:** Earlier turns discussed merging into one BTC row with automatic venue selection, unified pricing, and smart routing. All deferred to v2+.

**Cross-references:** D19, D22, D23.

---

### D12 — Polymarket uses dynamic asset names (the question text)

**Statement:** The `name` field for Polymarket rows holds the full question text (e.g., "Will Trump win NH?"). The `asset_symbol` holds the Poly slug. No separate tab or special handling for prediction markets.

**How reached:** Explicit. The user said "cant i just put dynamic for poly" (line 919). The assistant confirmed: "That's actually a better answer than any of the four options I was pushing" (line 922). Accepted: "The four venues stop being 'three perpetuals venues and one weird one' and become 'four sources of rows'" (line 929).

**Final form:** Poly rows sit in the same list as perpetual rows. The table renders the question text in the name column and "75%" (or equivalent) in the price column. The `info` field contains Poly-specific context like "expires Oct 10."

**Prior versions:** The assistant proposed two options: (A) same list, mixed rows; (B) separate tabs, one for perpetuals and one for predictions. The user's "dynamic" answer collapsed Gap 1 by choosing (A) in the simplest possible way.

**Cross-references:** D10, D13.

---

### D13 — No separate columns for leverage, expiration, etc.

**Statement:** The table does not have a leverage column, an expiration column, or any other venue-specific column. All such information goes into the `info` string. The table columns are: Asset (with chain glyph), Price, and Info.

**How reached:** Explicit. The user stated: "u dont show leverage you don't show leverage as a column in a table. What you do is you do an agnostic name, symbol, price where all those can go in, and then you do info or asset info or data" (lines 973–975). The assistant confirmed this was "a meaningfully better design" (line 976).

**Final form:** Four visual display areas: Asset (name + chain glyph), Price (formatted with unit), Info (freeform string). The table rendering may use additional columns for visual layout (e.g., chain as its own column), but the data contract has only the seven flat fields.

**Prior versions:** Earlier discussion assumed typed columns for leverage, expiration, category, etc. The user collapsed all of these into info.

**Cross-references:** D10, D12.

---

### D14 — Provider table as a separate lookup, hardcoded in frontend for v1

**Statement:** Provider metadata (display name, network, network display name, glyph) lives in a Provider table, not repeated on every row. The row carries `provider: string` as a foreign key. The Provider table is mirrored between left-Lean and the frontend.

**How reached:** Explicit. The user proposed "we could just keep the Provider as its own structure that includes where they operate so we dont need to restate it" (line 1853). The assistant confirmed: "your second instinct is the correct one" (line 1856). Hardcoded vs fetched was proposed by the assistant at lines 1997–2001; the assistant leaned hardcoded for v1, the user did not push back (implicit acceptance).

**Final form:**
```json
{
  "id":              "drift",
  "display_name":    "Drift",
  "network":         "solana",
  "network_display": "Solana",
  "glyph":           "/icons/solana.svg"
}
```
One entry per provider. Hardcoded in the frontend bundle for v1.

**Prior versions:** Earlier versions carried `providers_chain: string` directly on every row, which the user recognized as conflating provider identity with network.

**Cross-references:** D15, D16, D17.

---

### D15 — Three distinct "where" concepts: native network, provider network, provider

**Statement:** There are three independent "where" concepts:
- **Native network:** where the asset natively lives (BTC → Bitcoin)
- **Provider network:** where the provider operates (Drift → Solana)
- **Provider:** the venue itself (Drift, Gains, Parcl, Polymarket)

**How reached:** Explicit. The user identified this distinction at lines 1845–1853: "BTC is on bitcoin network and you can buy it through the solana network which is the chain the provider Drift operates on." The user then proposed three fields: Network, ProviderNetwork, Provider. The assistant confirmed and refined: only `provider` goes on the row, the network is derived from the Provider table.

**Final form:** The row carries `provider`. The Provider table carries `network`. The asset's native network is optionally stored in an Asset table. The row does not carry network directly.

**Prior versions:** Previous lock had `providers_chain: string` on the row, conflating provider and network.

**Cross-references:** D14.

---

### D16 — asset_symbol is bare, no suffixes

**Statement:** The `asset_symbol` field contains the bare symbol ("BTC", "ATL", Poly slug), not "BTC.solana" or "BTC.drift." The provider/chain suffix is a rendering concern, not a contract concern.

**How reached:** Implicit acceptance. The assistant proposed this at lines 2003–2006. The user's response ("just a seperate icon/column or thing to add?" at line 2009) implicitly confirmed by agreeing the chain is a separate visual element.

**Final form:** `asset_symbol: "BTC"` — the rendering code composes `BTC` + chain glyph from the Provider table lookup.

**Prior versions:** The user's earlier sticky note used "BTC.SOL BTC.ARB BTC.BASE BTC" as a display convention. This was reinterpreted: the suffix convention is for human display, not for the contract's data field.

**Cross-references:** D7, D17.

---

### D17 — Chain glyph is a separate visual element, not baked into the symbol

**Statement:** The chain/provider indication is rendered as a separate icon, column, or visual element next to the asset symbol. The rendering approach (inline icon, separate column, hover, color-coding) is a CSS/component decision that can change without touching the contract.

**How reached:** Explicit. The user asked "just a seperate icon/column or thing to add?" (line 2009). The assistant confirmed: "Yes — exactly that. A separate visual element" (line 2012).

**Final form:** The table renders `row.asset_symbol` as text and looks up `providers[row.provider].glyph` for the icon. They appear side by side in whatever visual layout the designer chooses.

**Prior versions:** Earlier discussion had "BTC.SOL" as a baked-in string in the symbol field.

**Cross-references:** D14, D16.

---

### D18 — Execution route (executionSignal) shape

**Statement:** The execution endpoint takes two required resolver fields plus optional supporters, and returns one of two response kinds for v1.

**How reached:** Evolved through multiple turns. The user proposed the two-resolver concept at line 1701 (diagram with "two resolvers + n supporters"). The assistant confirmed at lines 1710–1714. Simplified at lines 1768–1780 (removing disambiguation for v1).

**Final form:**
```
executionSignal({
  asset_symbol: string,      // resolver 1
  provider:     string,      // resolver 2
  amount:       number,
  // optional supporters: leverage, side, etc.
})
→ { kind: "executed", venue, txHash, ... }
| { kind: "rejected", reason }
```
Two response kinds for v1. The `disambiguate` kind is deferred to when auto-routing is built.

**Prior versions:**
1. (lines 1086–1092): Row carried an opaque execution blob; click handler sent `{execution: <blob>, amount}`.
2. (lines 1615–1638): `executionSignal({asset, amount, leverage, side, walletPreference, ...})` with three response kinds (executed, disambiguate, rejected).
3. (lines 1803–1811): Simplified to two resolvers (asset_symbol, provider), two response kinds. **Final.**

**Cross-references:** D19, D20, D22.

---

### D19 — (asset_symbol, provider) is a primary key for the venue universe

**Statement:** The combination of asset_symbol and provider uniquely identifies any tradeable market in the stack. No two providers share both an asset and a chain.

**How reached:** Explicit assertion by the assistant at line 1714: "Those two together are univocal — they identify exactly one thing in the world." The user confirmed this by building on it.

**Final form:** Two fields compose the primary key. BTC + drift = Drift BTC perp. BTC + gains = Gains BTC pair. Right-Lean dispatches on this pair.

**Prior versions:** Earlier versions used the opaque execution blob as the market identifier. Before that, the conversation discussed Provenance as a tagged inductive with Fin n indices.

**Cross-references:** D18, D7.

---

### D20 — No opaque execution payload in the display row

**Statement:** The row does not carry an opaque execution blob. The execution endpoint receives (asset_symbol, provider) as a lookup key and right-Lean resolves the venue-specific parameters internally.

**How reached:** Explicit. The assistant noted at lines 1663–1677: "the execution field in the row is redundant and should be removed" because the executionSignal design makes it unnecessary.

**Final form:** The row has six fields plus id, all primitives, zero opaque payloads.

**Prior versions:**
1. (lines 1074–1085): Row carried `execution: <opaque venue payload>`.
2. (lines 1199–1223): The opaque blob was explicitly defended as "the engineering-correct answer."
3. (lines 1663–1677): Removed. The two resolvers replaced it. **Final.**

**Cross-references:** D7, D18.

---

### D21 — Frontend number formatting is acceptable and does not violate the dumb-frontend principle

**Statement:** The frontend has a small `format(price, unit)` function that branches on `unit` (not on venue) to add currency symbols, percent signs, etc. This is consistent with the dumb-frontend principle because the principle is about venue knowledge, not about all logic.

**How reached:** Explicit. The assistant stated at lines 1275–1276: "Number formatting is not venue-specific... It just requires knowing the unit ('USDC') and applying Intl.NumberFormat. This is a one-line function. It doesn't leak any venue knowledge into the frontend."

**Final form:**
```js
format(price, unit) {
  if (unit === "%") return price + "%"
  if (unit === "USDC") return "$" + price.toLocaleString()
  if (unit === "JPY") return "¥" + Math.round(price).toLocaleString()
}
```

**Prior versions:** The assistant initially advocated for fully pre-formatted strings from the backend, which would have eliminated even this formatting logic from the frontend. Reversed when the user raised the sorting concern.

**Cross-references:** D5, D8.

---

### D22 — No confirmation modal for v1; disambiguation modal deferred

**Statement:** Clicking BUY does not trigger an "are you sure?" confirmation modal. For v1, the user's click on a specific row IS the unambiguous decision. The disambiguation modal (for when auto-routing can't decide) is deferred to v2+.

**How reached:** The user described the context resolver with automatic fallbacks (lines 1429–1437). The assistant distinguished confirmation modals from disambiguation modals (lines 1463–1471) and read the user's intent as "no confirmation modal, yes disambiguation modal when needed" (line 1472). The user did not dispute. Then the user's two-resolver design eliminated even the disambiguation need for v1 (lines 1718–1720: "For now, no auto, no unifying").

**Final form:** For v1: click → executionSignal → executed or rejected. No modals. For future auto-routing: disambiguation modal as last-resort when the context resolver cannot decide.

**Prior versions:** The assistant asked multiple times about confirmation modals. The user never opted for one.

**Cross-references:** D18, D23.

---

### D23 — V1 is manual-only; auto-routing, smart context, and unified rows are deferred

**Statement:** V1 ships without: auto-routing mode, wallet-balance-based venue selection, last-trade memory, leverage-based filtering, default chain preferences, disambiguation modals, or unified BTC rows. These are explicitly planned for later but not blocking v1.

**How reached:** Explicit. The user's diagram (line 1701) and the assistant's readback: "For now, no auto, no unifying. Just show both BTC rows" (line 1718). "Save the smart logic for later" (line 1722). The user implicitly confirmed by not challenging.

**Final form:** V1 ships with: the seven-field row shape, the two-resolver executionSignal, manual venue selection (user picks row), two response kinds (executed, rejected). The deferred features slot in additively.

**Prior versions:** The user extensively described the smart context layer (wallet balances, settings, last-trade, leverage preferences) at lines 1429–1437. All preserved as a design but deferred from v1.

**Cross-references:** D22.

---

### D24 — Zod is unnecessary; drop it

**Statement:** Zod is dropped from the frontend stack. A formally verified Lean backend makes JavaScript runtime validation backwards — JavaScript auditing Lean's proofs is the weaker system checking the stronger one.

**How reached:** Explicit. The user asked: "why Zod would even need to play an error handling role on a formally verified backend" (line 787). The assistant confirmed: "you don't need it, and keeping it would be a category error" (line 792). The only remaining validation need is at the JSON deserialization boundary, handled by generated TypeScript types from the Lean spec, not Zod.

**Final form:** No Zod. Generated TypeScript types from Lean spec for deserialization safety.

**Prior versions:** Zod was initially listed as part of the frontend tooling alongside TanStack Table and Zustand (lines 772–775).

**Cross-references:** D25.

---

### D25 — TanStack Table for rendering, Zustand for state management

**Statement:** TanStack Table renders the sortable/filterable/paginated market list. Zustand stores the fetched data so multiple components can read from the same store without re-fetching.

**How reached:** Explicit. The user raised TanStack, Zustand, and Zod at line 744. The assistant separated their responsibilities (lines 770–775). TanStack and Zustand were confirmed; Zod was dropped per D24.

**Final form:** TanStack Table (table renderer) + Zustand (state store). Both confirmed as appropriate. They compose naturally.

**Prior versions:** None — these were the user's own tool choices and were confirmed immediately.

**Cross-references:** D24.

---

### D26 — Privy for authentication with embedded wallets

**Statement:** Privy is the authentication system. It provides embedded wallets for both Solana and ETH.

**How reached:** Stated as fact by the user at lines 1429–1430: "because we're doing Privy as the authentication system and Privy lets us do embedded wallets for both Solana and ETH." Not questioned or discussed further.

**Final form:** Privy provides the wallet infrastructure. The context resolver (when built for v2+) reads Privy wallet balances to inform routing decisions.

**Prior versions:** None.

**Cross-references:** D23.

---

### D27 — COINCHIP is the product name

**Statement:** The product/brand being built is called COINCHIP.

**How reached:** Appears in the assistant's references starting at line 811 ("COINCHIP at the top in purple — the brand, the product") and is used consistently thereafter. Originates from the user's diagram (line 611, referenced at 811).

**Final form:** Product name: COINCHIP.

**Prior versions:** None.

**Cross-references:** N/A.

---

### D28 — "Thin Lean on top" architecture for future concerns

**Statement:** New cross-cutting concerns (currency translation, theme, orchestration) are handled by adding new thin Lean layers in the pipeline, not by enlarging existing layers or making the frontend smarter. Each layer does one job.

**How reached:** Explicit. The user proposed: "if later we want to add something... we just add another thin lean to sit on top of the current lean, and it just strictly just translates USDC into JPY" (lines 659–660). The assistant confirmed: "you just independently described a pattern that has a name in systems architecture: pipeline of transformations, or more specifically, middleware layers" (lines 671–672).

**Final form:**
```
venue raw → Lean #1 (ingest+normalize to USDC) → [Lean #2 (USDC→JPY, optional)] → [Lean #3 (display adaptation, optional)] → frontend
```

**Prior versions:** None — this was the user's own design and was immediately confirmed.

**Cross-references:** D5.

---

### D29 — Lean core uses FixedDecimal with provider-specific phantom scale in the adapter layer

**Statement:** The adapter/ingress layer uses `structure FixedDecimal (scale : Int) where mantissa : Int` with provider-specific scales: FixedDecimal (-6) for Drift, FixedDecimal (-10) for Gains, etc. Cross-scale arithmetic is a type error.

**How reached:** Recommended at lines 138–165 as "Encoding B." Accepted as the right encoding for the ingress/adapter layer. The canonical core type was later changed to the universal Price (D2), but the adapter layer retained FixedDecimal types.

**Final form:** Adapter layer: FixedDecimal per provider. Lean core: universal Price. The adapter's normalize function converts FixedDecimal → Price.

**Prior versions:** Initially recommended as the single core Price type (lines 151–156). Revised when the user pushed back on integration difficulty — the core type became the universal Price, and FixedDecimal moved to the adapter layer only.

**Cross-references:** D2, D4.

---

### D30 — Semantic-kind separation uses a thin tagged wrapper over a shared carrier

**Statement:** The MakerDAO/K-framework principle applies: "unify the carrier, separate the meaning." Different semantic kinds (spot price, index, probability) share the same underlying Price type but are distinguished by tagged constructors.

**How reached:** Explicit. Drawn from the MakerDAO precedent (lines 240–243, 396–397). The assistant stated: "The lesson isn't 'never unify' — it's 'unify the carrier, separate the meaning'" (line 397).

**Final form:** Quote inductive with .spot, .index, .probability constructors, all wrapping Price.

**Prior versions:** ChatGPT's recommendation was to keep entirely separate types per semantic kind. Rejected as producing the "integration-times-N" problem.

**Cross-references:** D4, D35.

---

### D31 — Price canonicality in the Lean core: zero pinned, trailing zeros stripped

**Statement:** Zero has exactly one representative: `(mantissa = 0, expo = 0)`. Nonzero values have no trailing zeros in the mantissa.

**How reached:** Explicit. The challenger identified the bug at lines 55–58. The fix was proposed: `h : (mantissa = 0 ∧ expo = 0) ∨ (mantissa ≠ 0 ∧ mantissa % 10 ≠ 0)`.

**Final form:** A Subtype or proof-carrying structure:
```lean
h : (mantissa = 0 ∧ expo = 0) ∨ (mantissa ≠ 0 ∧ mantissa % 10 ≠ 0)
```

**Prior versions:**
1. Original: `mantissa = 0 ∨ mantissa % 10 ≠ 0` — permitted `(0, -2)`, `(0, -10)`, `(0, +5)` as distinct inhabitants of zero. Bug identified at line 55.
2. Fixed version at line 57. **Final.**

Note: The conversation also noted that IEEE 754-2008 deliberately does not canonicalize trailing zeros (line 117), but this concern was addressed by Encoding B (FixedDecimal) avoiding the question by construction for the adapter layer. The canonicalization rule applies in the Lean core when using the universal Price type.

**Cross-references:** D2.

---

### D32 — Provenance is a tagged inductive with per-provider indices and categories

**Statement:** The Lean core carries a Provenance type that jointly constrains provider identity and market identity, making a Drift market with a Gains provenance unrepresentable.

**How reached:** Explicit. Introduced at lines 22–27. Refined at lines 74–80.

**Final form:**
```lean
inductive Provenance where
  | drift  : DriftMarketIndex → Provenance
  | gains  : GainsPairIndex   → GainsCategory     → Provenance
  | parcl  : ParclMarketId    → ParclLocationType → Provenance
  | poly   : PolyMarketId     → PolyCategory      → Provenance
```
Each index is a named `Fin n` abbreviation so the bound is part of the type's name.

**Prior versions:**
1. (lines 22–27): Initial version with `Fin 86`, `Fin 452`, `Fin 28`, `PolyMarketId`.
2. (lines 63–71): Discussion of whether category belongs in Provenance or in Asset.
3. (lines 74–80): Final symmetric form with named indices and categories. **Final.**

**Cross-references:** D33, D34.

---

### D33 — Market.provider is derived from Provenance, not stored as a field

**Statement:** The provider field on Market is a computed function derived from the Provenance tag, not a stored field, eliminating the duplication-and-disagreement failure mode.

**How reached:** Explicit. The assistant confirmed at lines 83–84: "Market.provider as derived function — good, keep it."

**Final form:** `Market.provider m = .Drift ↔ ∃ i, m.provenance = .drift i` (and similarly for other providers).

**Prior versions:** None — this was proposed and immediately accepted.

**Cross-references:** D32.

---

### D34 — Lean always hands the frontend USDC (or the user's chosen currency)

**Statement:** The Lean pipeline normalizes all monetary values to USDC before handing them to the frontend. If currency translation is added later, a thin Lean layer converts USDC to the user's chosen currency.

**How reached:** Explicit. The user said: "Lean will always want to hand in hand to the front end, USDC. USDC is economical" (line 659). The assistant confirmed: "Lean always hands the frontend USDC. One unit. Always. No ambiguity" (line 666).

**Final form:** The `unit` field in the row contract is "USDC" by default. A future currency translation layer may change it to "JPY" etc.

**Prior versions:** None — this was the user's own decision.

**Cross-references:** D28, D8.

---

### D35 — The MakerDAO / K-framework precedent governs the formal design

**Statement:** The K-framework formal specification of MakerDAO DSS, which is the closest precedent in production-formally-verified DeFi, deliberately keeps Wad, Ray, and Rad as distinct sorts even though they share the same uint256 carrier. The lesson: different scales are different types, conversions are explicit.

**How reached:** Explicit. Stated at lines 240–243 and reinforced at lines 286–287 and line 397.

**Final form:** The Lean core follows this precedent: the Quote inductive separates semantic kinds, the FixedDecimal types in the adapter layer separate scale levels.

**Prior versions:** None — this was research-derived and immediately accepted.

**Cross-references:** D4, D29, D30.

---

### D36 — The execution routing logic lives entirely in right-Lean, not the frontend

**Statement:** The frontend does not filter venues, check leverage compatibility, or make routing decisions. It sends signals (what the user clicked, leverage setting, etc.) and right-Lean decides.

**How reached:** Explicit. The user proposed this at lines 1570–1572: "the front end should just send the signal to initiate... 'Here's an execution signal; here's all the information I have for you guys.'" The assistant confirmed: "You just resolved the (A) vs (B) question, and you picked (B)" (line 1575).

**Final form:** Frontend gathers signals → executionSignal() → right-Lean does all routing/filtering/dispatch.

**Prior versions:** Option (A) had the frontend reading a `capabilities` field on each row to make routing decisions. Rejected by user in favor of dumb signal-sending.

**Cross-references:** D5, D18.

---

## Section 2: Locked Artifacts

### A1 — getMarkets Row Shape (final)

**Type:** JSON schema / data contract

**Final form:**
```json
{
  "id":           "string",
  "name":         "string",
  "asset_symbol": "string",
  "provider":     "string",
  "price":        "number",
  "unit":         "string",
  "info":         "string"
}
```

**Field details:**

| Field | Status | Notes |
|-------|--------|-------|
| `id` | Final | Unique within response, used as React key. Added at revision 3 (lines 1107–1111). |
| `name` | Final | Human-readable display name. "Bitcoin", "Atlanta Housing", full Poly question text. Present since user's first proposal (line 979). |
| `asset_symbol` | Final | Was called `symbol` in earlier revisions. Renamed to `asset_symbol` at revision 8 (line 1751). Bare, no suffixes. |
| `provider` | Final | Foreign key into Provider table. Replaced `providers_chain` at revision 9 (line 1886). |
| `price` | Final | Plain JS number. Was a pre-formatted string (rev 2), then string+numeric (rev 4), then mantissa/scale/unit (rev 5), then plain number (rev 6 onward). |
| `unit` | Final | Tells the formatter what glyph to use. "USDC", "%", "JPY". Separated from price at revision 6. |
| `info` | Final | Pre-formatted freeform display text. Present since user's first proposal (line 979). |
| `execution` | Removed | Was present in revisions 2–6 as an opaque venue payload. Removed at revision 7 (line 1663) because executionSignal doesn't need it. |
| `priceNumeric` | Removed | Was present in revision 4 only (line 1168). Removed as incoherent duplication. |
| `providers_chain` | Removed | Was present in revision 8 only (line 1752). Replaced by `provider` foreign key. |
| `capabilities` | Never adopted | Proposed by assistant at lines 1546–1553 as Option (A). User chose Option (B) instead — routing logic in right-Lean. |

**Provenance:** Iterated across the conversation from line ~979 to final lock at line ~2082. Nine revisions total.

---

### A2 — executionSignal Request Shape

**Type:** API endpoint request

**Final form:**
```json
{
  "asset_symbol": "string",
  "provider":     "string",
  "amount":       "number",
  "...supporters": "optional: leverage, side, walletPreference, etc."
}
```

**Field details:**

| Field | Status | Notes |
|-------|--------|-------|
| `asset_symbol` | Final — resolver 1 | The canonical asset identifier from the clicked row. |
| `provider` | Final — resolver 2 | The provider from the clicked row. Together with asset_symbol, forms the primary key. |
| `amount` | Final | User-entered trade amount. |
| Supporters | Final (open-ended) | Optional fields: leverage, side ("long"/"short"), walletPreference ("auto"/"solana"/"arbitrum"/"base"), etc. Right-Lean reads them if present, ignores if absent. |

**Provenance:** First appeared at lines 1615–1622 with different field names. Simplified at lines 1803–1808.

---

### A3 — executionSignal Response Shape

**Type:** API endpoint response (discriminated union)

**Final form:**
```json
// Kind 1: success
{ "kind": "executed", "venue": "string", "txHash": "string", "..." }

// Kind 2: rejection
{ "kind": "rejected", "reason": "string" }
```

**Fields proposed but not in v1:**

| Field | Status | Notes |
|-------|--------|-------|
| `kind: "disambiguate"` | Deferred to v2+ | Would include `options: [{label, payload}, ...]`. Only needed when auto-routing is implemented. |

**Provenance:** Three kinds at lines 1627–1638. Reduced to two at lines 1776–1779.

---

### A4 — Provider Table Entry

**Type:** Static lookup table / constants

**Final form:**
```json
{
  "id":              "drift",
  "display_name":    "Drift",
  "network":         "solana",
  "network_display": "Solana",
  "glyph":           "/icons/solana.svg"
}
```

**Entries:**

| Provider ID | Network | Notes |
|-------------|---------|-------|
| `drift` | solana | |
| `gains` | arbitrum | |
| `parcl` | solana | |
| `polymarket` | polygon | |

**Fields proposed but not finalized:**

| Field | Status | Notes |
|-------|--------|-------|
| `max_leverage_supported` | Mentioned as future possibility (line 1903) | Not in v1. |
| `kinds_of_assets` | Mentioned as future possibility (line 1903) | Not in v1. |

**Provenance:** Introduced at lines 1894–1913. Confirmed at lines 1965–1972.

---

### A5 — Optional Asset Table Entry

**Type:** Static lookup table / constants

**Final form:**
```json
{
  "BTC": { "display_name": "Bitcoin", "native_network": "bitcoin", "glyph": "..." },
  "ETH": { "display_name": "Ethereum", "native_network": "ethereum", "glyph": "..." }
}
```

Note: Synthetics like ATL (Parcl Atlanta index) would have `native_network: null` because they don't exist on any chain.

**Provenance:** Introduced at lines 1975–1979 as optional.

---

### A6 — Lean Core Price Structure

**Type:** Lean 4 structure

**Final form:**
```lean
structure Price where
  mantissa : Int
  expo     : Int
```
With canonicality proof:
```lean
h : (mantissa = 0 ∧ expo = 0) ∨ (mantissa ≠ 0 ∧ mantissa % 10 ≠ 0)
```

**Provenance:** Introduced at lines 277–279. Canonicality proof at line 57.

---

### A7 — Lean Core Quote Inductive

**Type:** Lean 4 inductive type

**Final form:**
```lean
inductive Quote where
  | spot        : Price → Quote
  | index       : Price → Quote
  | probability : Price → Quote
```

**Provenance:** Introduced at lines 391–395.

---

### A8 — Lean Core Provenance Inductive

**Type:** Lean 4 inductive type

**Final form:**
```lean
inductive Provenance where
  | drift  : DriftMarketIndex → Provenance
  | gains  : GainsPairIndex   → GainsCategory     → Provenance
  | parcl  : ParclMarketId    → ParclLocationType → Provenance
  | poly   : PolyMarketId     → PolyCategory      → Provenance
```

**Provenance:** First version at lines 22–27. Revised to final at lines 74–80.

---

### A9 — FixedDecimal (Adapter-layer type)

**Type:** Lean 4 parameterized structure

**Final form:**
```lean
structure FixedDecimal (scale : Int) where
  mantissa : Int
```

Provider-specific instantiations:
- `FixedDecimal (-6)` — Drift
- `FixedDecimal (-10)` — Gains
- `FixedDecimal (-8)` — Parcl

**Provenance:** Introduced at lines 138–141.

---

### A10 — System Architecture (Eight-layer pipeline)

**Type:** Architecture diagram

**Final form (lines 1493–1508):**
1. Venue raw data — whatever Drift, Parcl, Gains, Poly natively emit
2. Adapters (left-Lean) — one per venue, normalize to the display contract
3. Display route (getMarkets) — one HTTP endpoint, returns seven-field rows
4. Frontend table — TanStack Table, renders rows, sorts on price, formats with unit
5. Context resolver (frontend) — *deferred to v2+*
6. Disambiguation modal (frontend) — *deferred to v2+*
7. Execution call (right-Lean) — receives executionSignal, dispatches to correct venue API
8. Venue execution APIs — Drift, Parcl, Gains, Poly, each in native format

Future thin layers:
- Currency translation Lean between (3) and (4)
- Theme layer at (4)
- Orchestrator for cross-chain between (7) and (8)

**Provenance:** Assembled incrementally across lines 366–1508. User's diagram at line 611 established the basic shape. Refined through Socratic dialogue.

---

## Section 3: Locked Terminology

### T1 — "Left-Lean" / "Right-Lean"

**Definition:** Left-Lean is the adapter/normalization pipeline that processes venue raw data into the display contract (getMarkets rows). Right-Lean is the execution dispatcher that receives executionSignal and routes to venue-specific APIs.

**First appearance:** Line 621 (assistant's readback of user's diagram).
**Last appearance:** Line 2091.
**Treated as:** Consistently used as a pair throughout the architectural discussion.

---

### T2 — "Dumb frontend" / "LEAF DUMB DISPLAY ONLY FRONTEND"

**Definition:** The frontend does not contain venue-specific knowledge. It does not know what Drift is, does not parse opaque execution payloads, does not perform routing decisions.

**Refinement:** Later refined to "dumb about venues, smart about the user" (line 1459), acknowledging the frontend may have user-context logic.

**First appearance:** Line 622 (user's diagram label).
**Last appearance:** Line 2063.
**Note:** "LEAF DUMB DISPLAY ONLY FRONTEND" is the user's exact phrasing from their diagram.

---

### T3 — "Resolvers" / "Supporters"

**Definition:** Resolvers are the two fields (asset_symbol, provider) that are necessary and sufficient to identify a market for execution. Supporters are optional contextual fields (leverage, side, walletPreference, etc.) that right-Lean uses to enhance routing but does not require.

**First appearance:** Line 1710 (assistant's readback of user's diagram: "The two resolvers... are... Asset Symbol... Provider's Chain").
**Last appearance:** Line 1811.
**Note:** The user introduced this distinction in their diagram at line 1701, using the literal terms "resolvers" and "supporters."

---

### T4 — "Adapter" / "Ingress"

**Definition:** A per-venue module that faithfully parses what the protocol natively gives and normalizes it to the canonical contract. Used interchangeably with "left-Lean adapter."

**First appearance:** Lines 367–368.
**Last appearance:** Line 2091.
**Synonyms:** "Adapter," "ingress," and "normalizer" are used interchangeably. "left-Lean adapter" is the full form.

---

### T5 — "Display route" / "Blockchain-native route" / "Blockchain route"

**Definition:** Display route: the getMarkets API surface returning human-readable data with plain JS numbers. Blockchain-native route: a future API surface returning full-precision data with string-encoded big integers.

**First appearance:** Lines 1383–1395 (assistant introduced the terms after the user proposed the separation).
**Last appearance:** Line 1420.
**Note:** "Blockchain route" and "blockchain-native route" are used interchangeably.

---

### T6 — "Context resolver"

**Definition:** A piece of frontend code that reads Privy wallet state, user settings, trade history, and leverage preferences to resolve an ambiguous click into an unambiguous execution intent.

**First appearance:** Line 1460 (assistant named it).
**Last appearance:** Line 1532.
**Note:** Deferred to v2+. Not part of v1 implementation.

---

### T7 — "Disambiguation modal"

**Definition:** A UI modal that appears only when the context resolver genuinely cannot determine which venue to route to. Shows the user multiple options (e.g., "Drift (Solana)" / "Gains (Arbitrum)") and lets them pick.

**Distinction from:** A "confirmation modal" ("are you sure?"), which would appear on every trade. The confirmation modal was implicitly rejected. The disambiguation modal was explicitly designed but deferred.

**First appearance:** Line 1466 (assistant introduced the distinction).
**Last appearance:** Line 1826.

---

### T8 — "executionSignal"

**Definition:** The single execution endpoint through which the frontend communicates user intent to right-Lean. Takes two resolvers plus optional supporters, returns executed or rejected.

**First appearance:** Line 1580 (user used the term "execution signal listen," assistant formalized to `executionSignal`).
**Last appearance:** Line 2091.

---

### T9 — "COINCHIP"

**Definition:** The product/brand name for the multi-venue trading frontend being designed.

**First appearance:** Line 811 (user's diagram showed "COINCHIP" as the top-level brand).
**Last appearance:** Line 2093.

---

### T10 — "Thin Lean on top" / "Middleware layers"

**Definition:** Each new cross-cutting concern (currency translation, theming, orchestration) is added as a separate thin processing layer in the pipeline, not by enlarging existing layers.

**First appearance:** Line 659 (user's phrasing: "we just add another thin lean to sit on top").
**Last appearance:** Line 1507.
**Synonyms:** The assistant called this "pipeline of transformations" and "middleware layers" (line 671).

---

### T11 — "Encoding A" / "Encoding B" / "Encoding C"

**Definition:**
- **Encoding A:** FIX floating-point decimal. `structure ScaledDecimal where mantissa : Int; exponent : Int`. Per-value exponent.
- **Encoding B:** FIX fixed-point decimal. `structure FixedDecimal (scale : Int) where mantissa : Int`. Phantom type-level scale parameter.
- **Encoding C:** ISO 4217 minor units. `structure MinorUnits (asset : Asset) where value : Int`. Scale recovered from asset.

**First appearance:** Lines 131–148.
**Last appearance:** Line 168.
**Note:** Encoding B was initially recommended for the core type. Later, the canonical core type shifted to Encoding A (the universal Price), while Encoding B was retained for adapter-layer types.

---

### T12 — "Wad" / "Ray" / "Rad"

**Definition:** MakerDAO's three fixed-scale types: Wad = 10^18, Ray = 10^27, Rad = 10^45. Used as the primary precedent for "different scales are different types." These are K-framework sorts in the formal spec.

**First appearance:** Lines 237–243.
**Last appearance:** Line 397.

---

### T13 — "Provider table"

**Definition:** A small static lookup table (mirrored between left-Lean and the frontend) mapping provider IDs to their metadata: display name, network, glyph.

**First appearance:** Lines 1894–1913.
**Last appearance:** Line 2091.

---

### T14 — "Native network" / "Provider network" / "Provider"

**Definition:** Three distinct "where" concepts the user identified:
- Native network: where the asset natively lives (BTC → Bitcoin)
- Provider network: where the provider operates (Drift → Solana)
- Provider: the venue itself (Drift)

**First appearance:** Lines 1849–1851 (user's proposal).
**Last appearance:** Lines 1860–1864.

---

## Section 4: Open Questions and Deferred Decisions

### OQ1 — PolyMarketId type: String vs refined type

**Question:** Should PolyMarketId be raw `String` or a refinement type like `{ s : String // isHex32 s }`?

**Why deferred:** The conversation flagged that Polymarket conditionId values may be 0x-prefixed 32-byte hex strings (lines 81–82), which would make a refinement type stricter. But the format claim is **UNVERIFIED against current Polymarket docs** (line 82, line 88). The conversation also noted this may be a repo-rules violation re: the String justification requirement (line 80).

**What would need to happen:** Verify the conditionId format against current Polymarket API/contract docs. If the format is constrained, define the refinement type. If it's truly arbitrary text, add the required AGENTS.md justification.

**Default behavior:** Currently treated as `String` in the Provenance type.

---

### OQ2 — Blockchain-native route contract

**Question:** What is the shape of the blockchain-native route (for displaying wei-scale token amounts, transaction histories, raw on-chain data)?

**Why deferred:** Explicitly deferred at line 1401: "The blockchain-native route is a separate contract that you'll define when you actually build that feature. It doesn't need to be designed now."

**What would need to happen:** A product requirement to display raw token quantities at full precision in the UI.

**Default behavior:** None. The display route uses plain JS numbers. The blockchain route does not exist yet.

---

### OQ3 — Auto-routing implementation details

**Question:** When the auto-routing feature is built, what is the exact decision tree? What is the priority order of signals? What happens in edge cases?

**Why deferred:** The user described the decision tree conceptually (lines 1429–1437) — wallet balances → last-used venue → default preference → ask user — but explicitly deferred implementation: "Save the smart logic for later" (line 1722).

**What would need to happen:** Ship v1 with manual mode, observe user behavior, then design the auto-routing based on real usage patterns.

**Default behavior:** V1 is manual-only. Two separate rows for assets available on multiple venues.

---

### OQ4 — Whether info should remain freeform or have leverage split out

**Question:** Should the `info` field remain a freeform string, or should `max_leverage` be extracted as a structured numeric field?

**Why deferred:** The assistant proposed keeping info as freeform (lines 1995–1996, 1837–1839) and leaned that direction, but the user never explicitly confirmed. The question was part of a three-part confirmation set (lines 1831–1841) that was interrupted by the provider/network discussion.

**What would need to happen:** An explicit decision before the first adapter is built, since it determines what the adapter puts in info vs a separate field.

**Default behavior:** The conversation's lean was toward keeping info as freeform.

---

### OQ5 — Exponent domain in the Lean core Price type

**Question:** Should `expo : Int` be bounded (to the admissible set of exponents across all providers) or left as unbounded Int?

**Why deferred:** Raised at lines 18–19 ("expo : Int admits +1000 and -1000. No provider emits these") and again at lines 59–61 ("the proposal sidesteps positive exponents with 'providers determine valid scale at normalization site.' That's punting. Either the provider scale set is closed... or you accept that Price is intentionally wider than any single provider and document why"). The conversation never definitively resolved this.

**What would need to happen:** An explicit decision: either constrain expo to a Fin-style range (the closed-world posture), or document why Int is intentionally wider.

**Default behavior:** Currently `expo : Int` in the Price structure.

---

### OQ6 — The specific fields inside each Provider's execution dispatch

**Question:** When right-Lean receives `(asset_symbol: "BTC", provider: "drift")`, what specific fields does it look up internally to construct the Drift API call?

**Why deferred:** The conversation identified the venue-specific fields at a high level (lines 1051–1057: Drift needs market index, base/quote precision, Solana wallet pubkey; Poly needs conditionId, questionId, tokenId, etc.) but never locked the specific internal shapes. This was intentional — the execution payload was made opaque/internal to right-Lean.

**What would need to happen:** Right-Lean implementation must define the internal mapping from (asset_symbol, provider) to venue-specific execution parameters. This is an implementation detail, not a contract decision.

**Default behavior:** Right-Lean owns this mapping entirely. The frontend has no visibility.

---

### OQ7 — The "are you sure?" confirmation modal

**Question:** Should there ever be a confirmation modal before trade execution?

**Why deferred:** The assistant asked this question multiple times (lines 1242–1250, 1370–1374, 1424–1427). The user never directly answered "yes" or "no" to the confirmation modal specifically. The assistant inferred "no confirmation modal" (line 1472) from the user's context-resolver design, and the user did not dispute. But the question was never explicitly answered with a "yes" or "no."

**What would need to happen:** A product decision. The architecture supports either answer without changes to the contract.

**Default behavior:** The architecture as designed for v1 has no modal at all (user clicks → execute → success/reject).

---

## Section 5: Rejected Proposals

### R1 — Nat for mantissa (unsigned Price)

**Proposal:** "Claude Code (doc 102)" recommended `mantissa : Nat` because "domain fact: prices are non-negative."

**Who proposed:** Claude Code (referred to as "doc 102").

**Why rejected:** "If Price is Nat, then PnL, deltas, basis, funding rates, spreads, and any derived quantity needs a separate signed type. Now you have two types where Pyth, FIX, Drift, and dYdX all use one" (lines 357–358). "Signed mantissa is non-negotiable per FIX, even though every example in the proposal happens to be non-negative" (line 169).

**What replaced it:** `mantissa : Int` — signed, matching Pyth, FIX, Drift i64.

---

### R2 — Keeping all types separate per provider (no unification)

**Proposal:** ChatGPT (doc 101) recommended keeping provider-tagged exact types, separate Lean types per semantic kind, with no unification downstream.

**Who proposed:** ChatGPT (referred to as "doc 101").

**Why rejected:** It produces the "integration-times-N" problem the user identified. "ChatGPT's framing — keep them separate forever — would force you to write the wallet/price/UI layer N times, once per provider, and re-do it every time you add a fifth protocol" (lines 362–363). The user explicitly pushed back: "we were not able to unify... it didn't tell me... it still did not answer: what language are we unifying" (lines 300–302).

**What replaced it:** Three-layer architecture with unification at the canonical core and at the frontend DTO.

---

### R3 — Pre-formatted strings for price in the frontend contract

**Proposal:** The assistant recommended `price: "$78,343.03"` — a fully pre-formatted string that the frontend renders verbatim.

**Who proposed:** The assistant.

**Why rejected:** The user identified the contradiction immediately: "if we can't sort them, then why don't we just send it as integers" (line 1252). The assistant acknowledged: "I tried to have it both ways" and "The pre-formatted-string answer was wrong the moment you mentioned sorting" (lines 1256, 1306).

**What replaced it:** `price: number` (plain JS number) + `unit: string` (glyph selector).

---

### R4 — mantissa/scale/unit triple for price

**Proposal:** `price: { mantissa: "78343030000", scale: 6, unit: "USDC" }` with string-encoded big integer mantissa.

**Who proposed:** The assistant.

**Why rejected:** The user asked: "why don't we just send the numbers as they are. Why do we have to transform them?" (line 1317). The assistant conceded: "I was solving a problem you don't have" — the precision issue only matters for wei-scale amounts, not for human-readable prices (lines 1325–1326).

**What replaced it:** `price: number` — plain JS number.

---

### R5 — priceNumeric alongside formatted price string

**Proposal:** Ship both `price: "$78,343.03"` (display) and `priceNumeric: 78343.03` (sort).

**Who proposed:** The assistant.

**Why rejected:** "It duplicates state — now there are two representations of the same value in every row, and they can drift if anything changes one without the other" (lines 1269–1270). The assistant called their own proposal "the worst of both" (line 1269).

**What replaced it:** `price: number` as the single source of truth.

---

### R6 — Opaque execution blob on each row

**Proposal:** Each row carries `execution: <opaque venue payload>` that the frontend round-trips to right-Lean on click.

**Who proposed:** The assistant.

**Why rejected:** Made redundant by the executionSignal design. The frontend constructs the execution call from (asset_symbol, provider) + signals, and right-Lean does the lookup internally. "The execution field in the row is redundant and should be removed" (line 1663).

**What replaced it:** The two-resolver executionSignal design. The row has no opaque payload.

---

### R7 — Database-style ID for execution (Option C)

**Proposal:** Lean assigns each market a persistent ID (e.g., "market_8472"), the frontend sends back the ID, and right-Lean looks up execution context from its database.

**Who proposed:** The assistant (as one of three options, lines 1201–1208).

**Why rejected:** "Systems where the market list is streamed live and IDs would need to be kept in sync between the streaming layer and a persistent store, with cache invalidation problems, with race conditions where the user clicks on a row whose ID has just rotated" (lines 1205–1207). "Correct for stateful CRUD systems, wrong for real-time market data" (line 1208).

**What replaced it:** Option B (opaque blob), which was itself later replaced by the two-resolver design.

---

### R8 — Suffix string as execution payload (Option A)

**Proposal:** Send a string like "BTC.drift" as the execution identifier. Right-Lean parses, splits on ".", dispatches.

**Who proposed:** The assistant (as one of three options, lines 1184–1191).

**Why rejected:** "The moment a venue needs more than just 'which venue.' Polymarket needs (conditionId, tokenId, signatureType). Drift needs (marketIndex, baseAssetSymbol, oracleSource). ... You cannot encode all of that into 'BTC.drift' without inventing a serialization format inside the string, at which point you've reinvented JSON inside a string" (lines 1188–1189).

**What replaced it:** Suffix strings are for display (`symbol` field). The execution uses the two-resolver approach.

---

### R9 — Zod for runtime validation

**Proposal:** Use Zod to validate the shape of getMarkets responses at the frontend boundary.

**Who proposed:** The assistant (line 772–774).

**Why rejected:** The user asked why Zod would be needed with a formally verified backend. The assistant agreed: "you don't need it, and keeping it would be a category error... JavaScript's types disappear at runtime and JavaScript will happily hand you {price: null}... A formally verified Lean backend is the opposite situation" (lines 792–798).

**What replaced it:** Generated TypeScript types derived from the Lean spec via ToJson/FromJson or codegen.

---

### R10 — Capabilities field on the row for frontend routing

**Proposal:** Add `capabilities: { maxLeverage?: number, supportedChains?: string[], ... }` to each row so the frontend's context resolver can make routing decisions.

**Who proposed:** The assistant (Option A, lines 1546–1553).

**Why rejected:** The user chose Option B — push all routing logic to right-Lean. "I don't want to do the option that is more difficult; I want to do the option that's simplest" (line 1572). The assistant confirmed: keeping capabilities on the row "splits the leverage-vs-venue knowledge across two layers" (line 1598).

**What replaced it:** The frontend sends all signals blindly via executionSignal; right-Lean does all filtering.

---

### R11 — One merged BTC row with automatic venue selection

**Proposal:** BTC appears as one row; the system automatically picks Drift vs Gains based on wallet balance, preferences, etc.

**Who proposed:** Explored in discussion (lines 955–968).

**Why rejected:** Requires building the entire smart context layer (wallet balance reader, preference UI, disambiguation modal). The user decided: "For now, no auto, no unifying. Just show both BTC rows" (line 1718). Deferred, not abandoned.

**What replaced it:** Two separate rows, manual selection by clicking.

---

### R12 — Separate tabs for perpetuals vs predictions (Gap 1, Option B)

**Proposal:** Wallet view has a "Perpetuals" tab and a "Predictions" tab, each homogeneous.

**Who proposed:** The assistant (Option B, lines 867–869).

**Why rejected:** The user chose "dynamic" for Poly (line 919), meaning Poly rows sit in the same list as perpetual rows, with the `name` field holding the question text.

**What replaced it:** One unified list. The `info` field carries venue-specific context.

---

### R13 — provenance : Nat (collapsing provider identity to bare natural number)

**Proposal:** The original pre-conversation proposal used `provenance : Nat` for market identity.

**Who proposed:** The original proposal author (pre-conversation).

**Why rejected:** "provenance : Nat is type erasure. You already have Fin 86, Fin 452, Fin 28 for the three identifier spaces. Collapsing them to Nat discards the bound and the provider association in one move" (lines 20–21).

**What replaced it:** The tagged Provenance inductive with per-provider Fin n indices.

---

### R14 — normalizePoly : PolyCategory → Probability → Market

**Proposal:** A normalizer function that takes only category and probability.

**Who proposed:** The original proposal (pre-conversation).

**Why rejected:** "PolyCategory + a probability does not identify a market. You need at minimum: the question/market id... the side (YES/NO), since the probability you're carrying is side-relative" (lines 29–33). "This is a prerequisite blocker, not a follow-up" (line 33).

**What replaced it:** The normalizer must take PolyMarketId (and optionally PolyCategory) in addition to probability.

---

## Section 6: Implicit Assumptions

### IA1 — Lean 4 is the backend language

The entire conversation assumes Lean 4 as the backend/core language. This is stated in the repository name (`lean/`) and referenced throughout, but never explicitly decided within the conversation itself. The conversation's first line references Lean types. Operative in every turn.

---

### IA2 — React and TypeScript for the frontend

React is mentioned at lines 504, 744, 1048, etc. TypeScript is implied (discussion of JS Number precision limits, Intl.NumberFormat, BigInt). No explicit decision was made to use React — it is taken as given.

---

### IA3 — Exactly four providers: Drift, Gains, Parcl, Polymarket

The entire architecture is designed around these four providers. While the conversation discusses "adding a fifth protocol" as a future scenario, the current design and all examples use exactly these four. No decision was made about when or how to add a fifth.

---

### IA4 — USDC as the base denomination for all monetary values

The user stated "Lean will always want to hand in hand to the front end, USDC" (line 659). This assumes all providers denominate in USDC (or can be converted to USDC in the adapter). This is true for the current four providers but was not explicitly verified or discussed as a constraint.

---

### IA5 — The Lean backend serves an HTTP API to the frontend

The conversation discusses `getMarkets()` and `executionSignal()` as API endpoints, and references "one HTTP endpoint" (line 1497). The HTTP transport layer is assumed without discussion.

---

### IA6 — The (asset_symbol, provider) primary key holds — no two providers share both an asset and a chain

The assistant asserted this at line 1714 and stated it was verified by checking the stack. This is a runtime invariant, not a proven type-level constraint. If a second provider on Solana offered BTC (e.g., a hypothetical second Solana DEX), this invariant would break and the primary key would need a third component.

---

### IA7 — JavaScript/TypeScript BigInt is available when needed

The conversation references `BigInt` (lines 1295, 1332) as the solution for wei-scale precision. This assumes the frontend targets environments where `BigInt` is supported (modern browsers). Not discussed.

---

### IA8 — The frontend is a web application (not mobile-first)

React, TanStack Table, browser dev tools, CSS — all web-oriented. The user mentioned future mobile app and embed widget (lines 601, 744), but the current design is web-first.

---

### IA9 — The system is read-heavy, write-light

The architecture optimizes for one bulk-read endpoint (getMarkets) and sparse individual writes (executionSignal). No discussion of write throughput, order queuing, or high-frequency trading patterns.

---

### IA10 — Left-Lean adapters run server-side, not in the browser

The adapters consume venue APIs, normalize data, and serve it via getMarkets. This is assumed to be server-side code, not client-side fetching. Not explicitly stated but implied by the architecture diagrams and the data flow.

---

## Section 7: Unresolved Contradictions

### C1 — IEEE 754-2008 trailing zeros vs Lean core canonicalization

**Statement 1 (line 117–119):** "IEEE 754-2008 decimal types... preserve trailing zeros as significant (the 'cohort'). 1.20 and 1.2 are distinct representations of the same numerical value. IEEE 754 explicitly does not canonicalize away trailing zeros, because in finance trailing zeros carry meaning (quoted precision, tick scale)."

**Statement 2 (line 57):** The Lean core canonicalization proof strips trailing zeros: `h : (mantissa = 0 ∧ expo = 0) ∨ (mantissa ≠ 0 ∧ mantissa % 10 ≠ 0)`.

**Attempted resolution in conversation:** The assistant said "Encoding B avoids the question by construction" (line 168) because FixedDecimal has no per-value exponent to vary. But the final canonical core type is the universal Price (Encoding A, which has a per-value exponent), not FixedDecimal. The canonicalization proof is applied to this universal Price.

**Status:** The conversation moved to the universal Price with the canonicalization proof and did not revisit the IEEE 754-2008 trailing-zeros-are-semantic argument. The two positions are not fully reconciled for the Lean core universal Price type. The conversation's implicit position is that the DTO's tick field handles the "quoted precision" concern (line 470–471), and the Lean core can safely canonicalize because precision is tracked elsewhere (via the Quote constructor or the FixedDecimal adapter type). But this was never explicitly stated as a resolution.

---

### C2 — Encoding B recommended first, then the universal Price (Encoding A) adopted

**Statement 1 (lines 151–156):** "Pick Encoding B for Price. Justification: [five reasons]." This was a strong recommendation for FixedDecimal as the core Price type.

**Statement 2 (lines 269–280, 377–380):** The "decisive Lean 4 mapping" and "the canonical type should be" both use the universal Price (mantissa:Int, expo:Int) — which is Encoding A.

**Status:** The shift happened because the user pushed back on integration difficulty. The conversation implicitly treats Encoding B as the adapter-layer type and Encoding A as the canonical core type. But the original recommendation was specifically "Pick Encoding B for Price" (the core type), not for the adapter. This revision was handled without explicitly acknowledging the reversal from the earlier recommendation. The reader should note that the "decisive" answer supersedes the earlier Encoding B recommendation for the core type.

---

## Section 8: Out-of-Scope Mentions

### OS1 — Cross-chain orchestrator

Mentioned at line 1507: "Orchestrator backend for cross-chain trades... letting 'BUY $20 of BTC on Gains using Solana funds' become 'swap Solana funds → bridge to Arbitrum → execute on Gains.'" The user explicitly deferred this: "now we're diving into the deeper layers and deeper workings, which is beyond the point" (line 1429).

---

### OS2 — Mobile app

Mentioned at lines 601, 744 as a future possibility ("In six months, you build a mobile app"). Used as a test case for the architecture's extensibility, not as a current requirement.

---

### OS3 — Partner embeddable widget

Mentioned at line 601 ("In a year, a partner wants an embeddable widget on their site"). Same as OS2 — a future scenario for architecture validation.

---

### OS4 — Dafny formal verification in Ethereum

The user mentioned Ethereum having "some formal verification done with Dafny" (line 172). The assistant corrected: "the formally verified Ethereum-adjacent system that uses Wad/Ray/Rad is MakerDAO, verified in K framework, not Dafny. The Dafny work in the Ethereum ecosystem is the ConsenSys Eth2.0 beacon-chain spec, which concerns consensus state transitions, not price arithmetic — so it is not directly relevant" (lines 288–289).

---

### OS5 — Kalshi, Augur, PredictIt (alternative prediction markets)

Mentioned at line 600 as hypothetical future additions: "Tomorrow you add a second prediction market (Kalshi, say, or Augur, or PredictIt)." Used as a test case for extensibility, not as a planned integration.

---

### OS6 — The specific Solidity fixed-point limitations

Lines 315–317 note that "Solidity says fixed-point numbers are not fully supported and cannot be assigned to or from." This is contextual background about the EVM ecosystem, not part of the current design.

---

### OS7 — Specific oracle details (Chainlink DON, Pyth confidence intervals)

Lines 213–227 detail Pyth's confidence interval (`conf : u64`) and publish time. Lines 308–314 reference Chainlink's DON and median price mechanism. These are source-material context for the Price type design but are not themselves in scope for the current system's design.

---

### OS8 — Bybit API format

Lines 336–338 reference Bybit's API returning prices as strings. Used as evidence for the "decimal strings at the boundary" pattern, not as a planned integration.
