# UNDECIDED ITEMS — Final Index with Recommendations

These are items where the conversation either left a decision genuinely open, where the four extractions disagreed on whether something was locked, or where I am flagging a gap that should be ratified before the spec is frozen. Recommendations below are based on correctness — what the architecture wants given everything that is locked — not on what was or was not said in the transcript.

Numbering continues from the locked file (which ended at 82) so the combined index has unique IDs across both files.

---

## Display Route — Field Status

83. **Should the Provider table be hardcoded as a frontend constant, or fetched from left-Lean at app load?**

Status across extractions: GPT Pro, Codex, and Gemini all treat this as deferred. Claude over-locked it as hardcoded. The conversation never resolved hardcoded vs fetched.

**Recommendation: hardcoded as a frontend constant for v1, mirrored from left-Lean's source-of-truth definition via codegen.**

Reasoning: the Provider table changes maybe twice a year (when you add a new venue), and a frontend deploy cadence of "twice a year" is acceptable. Fetching the table from left-Lean introduces an extra round-trip at app load, requires defining a new endpoint with its own contract, and adds a dependency on Lean being reachable before the frontend can render its first chrome. The benefit of fetching (adding a new venue without a frontend deploy) is real but does not earn its cost in v1 with only four venues. The hardcoded table should be generated from a Lean-side definition, not hand-typed in TypeScript, so Lean remains the source of truth.

84. **Where do tick-size validation and order-form input rules live?**

Status: Codex flagged this as a gap; Claude, Gemini, and GPT Pro silent. The earlier DTO sketch included a `tick` field per row, and it was silently dropped when the row shape simplified, but the responsibility for tick validation was never explicitly assigned. GPT Pro tracks tick as removed from the row but does not address where validation moved.

**Recommendation: tick validation lives entirely in right-Lean. The frontend does not check ticks; it sends `executionSignal` and right-Lean rejects ill-formed orders by returning `{kind: "rejected", reason: "amount X is not a valid tick for provider Y"}`.**

Reasoning: tick rules are venue-specific knowledge (Hyperliquid's "5 sig figs and (MAX_DECIMALS − szDecimals) decimal places," Polymarket's per-market tick from {0.1, 0.01, 0.001, 0.0001}, Drift's per-market base/quote precision). Putting any of this on the frontend re-introduces venue knowledge into the dumb layer, violating the load-bearing principle. The cost is that the user gets server-side rejection instead of inline form validation when they enter an invalid amount. This is acceptable for v1 because most users will use round numbers that pass any tick rule.

---

## Frontend Implementation

85. **Is TanStack Table the locked choice, or just the named candidate?**

Status: GPT Pro, Codex, and Gemini agree this is named but not locked. Only Claude treated it as locked. GPT Pro Section 6 item 10 is explicit: "TanStack Table, Zustand, and Zod are discussed, but only the presence of a table-like renderer is operationally assumed. Exact library choice is not locked."

**Recommendation: lock TanStack Table for v1.**

Reasoning: the row shape is intentionally a flat list of primitives, which is exactly TanStack Table's input format. TanStack Table handles sorting, pagination, and column configuration without coupling to any specific data source. The alternatives (custom table component, AG Grid, Material UI Table) are either more work than TanStack Table or more opinionated about data shape. There is no architectural reason to defer this choice; it is a frontend implementation decision that can be made now and locked.

86. **Is Zustand the locked state manager, or just a named candidate?**

Status: same situation as TanStack Table. All four extractions list Zustand as named but not committed.

**Recommendation: defer until v1 has more than two distinct components reading the markets list. If COINCHIP v1 has one wallet view that fetches markets and renders them, skip Zustand entirely and use component state.**

Reasoning: state managers earn their cost when multiple components need to read and react to the same data. If v1 has one consumer, skip the dependency. If v1 has three or more consumers, lock Zustand. If v1 has two consumers, either is defensible and component state is simpler. The decision depends on the v1 surface area, which the conversation never enumerated. Defer until the second consumer appears, then re-evaluate.

87. **What is the exact endpoint name for the execution route?**

Status: GPT Pro is the only extraction that flagged this. The user said "execution signal listen"; the assistant standardized to `executionSignal`. The concept is clear; the literal endpoint name was never frozen.

**Recommendation: lock the endpoint name as `executionSignal`.**

Reasoning: `executionSignal` is the operative label in the conversation's later turns, it is more conventional than `executionSignalListen` (which reads as a verb phrase rather than an endpoint), and it matches the JavaScript convention of camelCase function names. The literal string matters for implementation because every developer touching the system will type it many times. Lock it now to prevent future bikeshedding.

---

## v1 Scope Items That Were Underspecified

88. **What does the wallet view actually contain in v1?**

Status: the conversation consistently referenced "the wallet view" as the primary surface but never enumerated what is in it beyond the markets list. Implicit assumption: it is a list of markets the user can buy. Open question: does it also show open positions, balances, transaction history, or anything else?

**Recommendation: v1 wallet view is the markets list only.** Open positions, balances, and transaction history are out of scope for v1. They would each require their own endpoint and their own row shape (positions need entry price, current PnL, liquidation price, etc.), which is real design work that was not done in the conversation. Locking v1 to "markets list only" is the smallest shippable surface area and matches what the conversation actually designed. Add positions/balances/history in v2 with their own dedicated endpoints.

89. **What is the v1 buy flow's UI surface?**

Status: the conversation discussed `executionSignal` as the wire call and discussed click handlers, but did not specify what UI element the user clicks. Is it a Buy button on each row? A separate trade form? An always-visible buy panel?

**Recommendation: each row has an inline Buy button with an inline amount input. Click submits `executionSignal` immediately. No separate trade form, no advanced order types, no order-book visualization.**

Reasoning: this is the minimum shippable buy flow that exercises the entire architecture (display → click → executionSignal → response handler). Anything more elaborate is real product design work that was not done in the conversation. Locking the inline-buy-on-row pattern for v1 keeps the UI surface minimal and matches the dumb-frontend principle.

90. **Is there a confirmation modal on BUY clicks in v1?**

Status: GPT Pro caught this as a gap. The assistant earlier posed a confirmation-modal question. The conversation later removed the disambiguation modal from v1 by making venue choice manual, but never explicitly answered whether every trade should still have a confirmation step.

**Recommendation: no confirmation modal in v1. The manual click on a specific row is the user's commitment.**

Reasoning: the manual-rows v1 design already makes execution unambiguous (the row encodes asset and provider). A confirmation modal adds friction without preventing the most common error category, which is not "wrong venue" but "wrong amount." Wrong-amount errors are mitigated by the inline amount input being visible at click time. If you want a fat-finger guard, add it as a v1.5 feature for trades above a configurable USD threshold rather than as a universal v1 friction layer.

---

## Data Freshness and Updates

91. **How does the frontend update `getMarkets` data over time? Polling, websocket, manual refresh?**

Status: not discussed in the conversation. The implicit assumption is that `getMarkets` is called once at page load and the data is static until the user navigates away.

**Recommendation: polling at a fixed interval (e.g., every 5 to 10 seconds) for v1.**

Reasoning: real-time updates via websocket are a real architectural concern that adds significant complexity (subscription management, reconnection, partial updates, ordering). v1 does not need them; trading-style real-time is a v2 concern. Polling is good enough for a wallet view where the user is making decisions on the timescale of seconds to minutes. The polling cadence should be configurable in left-Lean, not hardcoded in the frontend.

92. **Does `getMarkets` return all markets, or paginated?**

Status: not discussed. The implicit assumption is that all markets fit in a single response.

**Recommendation: return all markets in a single response for v1, no pagination.**

Reasoning: with four venues and a total active market count probably under a few hundred, the total fits comfortably in a single response. Pagination adds complexity (cursor management, inconsistent ordering across pages, "load more" UI) that does not earn its cost at this scale.

---

## Error Handling

93. **What errors can `getMarkets` return, and how does the frontend handle them?**

Status: not discussed. The conversation focused on the happy path.

**Recommendation: `getMarkets` either returns the full list or returns an error response with `{kind: "error", reason: "..."}`. The frontend renders the error reason as a top-of-page message and shows a retry button. Partial results (some venues succeed, some fail) are not supported in v1.**

Reasoning: partial results introduce a design question (do you show the markets you got and a warning about the missing ones? do you show nothing?) that was not designed in the conversation. The simplest v1 model is all-or-nothing. If a single adapter fails, the entire `getMarkets` call fails and the user gets a retry. Add per-venue error tolerance in v2.

94. **What errors can `executionSignal` return beyond `rejected`?**

Status: the conversation locked `{kind: "executed"}` and `{kind: "rejected"}` as the two response shapes. It did not enumerate what kinds of `rejected` reasons exist.

**Recommendation: `rejected` carries a `reason` string and a `code` enum. Codes for v1: `INSUFFICIENT_BALANCE`, `INVALID_TICK`, `VENUE_UNAVAILABLE`, `LEVERAGE_NOT_SUPPORTED`, `UNKNOWN`. The `reason` is a human-readable string the frontend can display directly; the `code` is for the frontend to use if it wants to render different UI for different error classes.**

Reasoning: error categorization is low-cost to design now and high-cost to retrofit later. Locking five enum codes for v1 covers the realistic failure modes without committing to an exhaustive taxonomy.

---

## Documentation and Spec Status

95. **Is there a frozen one-page spec document that left-Lean and frontend developers should work against?**

Status: this is the spec we are producing right now, but the question of where it lives, who owns it, and how it is updated when v1 reveals issues is open.

**Recommendation: the locked-decisions file plus the resolved versions of these undecided items become the v1 frozen spec, stored in your repo as `docs/v1-spec.md` or equivalent. Changes to v1 require an explicit revision marker (a date and a brief note on what changed and why), not silent edits. v2 decisions go into a separate `docs/v2-roadmap.md` so the v1 spec stays narrowly scoped.**

Reasoning: a single canonical document with explicit revision markers is the minimum process needed to prevent the same decisions from being re-litigated every time a developer asks "wait, is `info` freeform or structured?" Without this discipline, the four extractions you ran will become five next month and you will be in the same triangulation problem again.

---

## Items I Cannot Recommend On

These are open items where I do not have enough context to make a correctness-based recommendation. They require user input, not architectural reasoning.

96. **What are the actual asset and market counts you intend to support in v1?** This affects pagination, filtering, and search decisions. I assumed "few hundred" above; if it is "a few thousand" the recommendations change.

97. **What is the deployment target for the frontend?** Web only, web + mobile, embedded widget, partner integrations? I assumed web-only React for v1; if there are other targets, the contract may need different consideration.

98. **Is COINCHIP open-source, source-available, or closed?** This affects whether the hardcoded Provider table and the codegen pipeline can live in a single repo or need to be split. Does not change the architecture, but changes the file layout.

99. **Are there regulatory constraints on what `getMarkets` can return to which users?** Geo-filtering, KYC gating, accredited-investor restrictions on certain market types? None of this was discussed. If it exists, it needs to live in left-Lean as a filter on `getMarkets` output, and the spec should note that the contract is the maximum surface, not the per-user surface.

These four items are not blockers for the v1 spec — the spec can be written without resolving them — but they should be answered before implementation begins, because each one can invalidate v1 work if the answer is unexpected.

---

## Summary

82 locked decisions in the locked file (items 1 through 82). 17 undecided items in this file (items 83 through 99), of which:

- 12 have a clear correctness-based recommendation (83, 84, 85, 87, 88, 89, 90, 91, 92, 93, 94, 95)
- 1 has a conditional recommendation pending one user input (86, depends on v1 component count)
- 4 are flagged as needing user input rather than architectural reasoning (96, 97, 98, 99)

Total combined index: **99 items.**

When you ratify the recommendations on items 83 through 95 the spec can be frozen. Items 96 through 99 should be answered before implementation but do not block the spec.
