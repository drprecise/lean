# LOCKED DECISIONS — Final Combined Index

Source: triangulation across Claude, Codex, Gemini, and GPT Pro extractions of the COINCHIP architecture conversation. Items here are committed and require no further user input. Sequential numbering throughout the file. The undecided file continues numbering from where this one ends.

---

## Architectural Principles

1. The system has two top level layers LEAN vs TYPESCRIPT. And LEAN has two SUB-LAYERS: 
    1. LEAN
        A. per-venue Adapters (ingest)
        B. Lean core (normalize, route, execute)
    2. TYPESCRIPT
        A. Frontend (display only)

2. Lean is on both sides of the frontend: left-Lean handles ingest and normalization for display; right-Lean handles execution routing and venue API calls.

3. The frontend is dumb about venues (no venue-specific knowledge, no routing logic, no parsing of opaque payloads), and smart about the user (may read Privy wallet state, settings, preferences for context resolution in v2).

4. New concerns get added as new thin Lean layers, not as additions to existing layers. Currency translation (USDC → JPY), theming, and orchestration all slot in as additional thin layers between existing components without modifying them.

5. Asymmetric data flow: one outbound pipe (`getMarkets` returns everything in one call), many inbound pipes (execution is per-asset, stratified by venue at execution time).

6. Two distinct API routes are committed in principle: a display route for human-readable values (locked, designed) and a future blockchain-native route for raw on-chain precision data like wei-resolution token quantities (committed as a separate route, contract not yet designed).

---

## Display Route Contract — Row Shape

7. The display route endpoint is named `getMarkets` and returns a flat list of row objects.

8. The row shape is exactly seven fields: `id`, `name`, `asset_symbol`, `provider`, `price`, `unit`, `info`.

9. `id` is a string, unique within the response, used as the React key for list rendering.

10. `name` is a string carrying the human-readable display name (e.g., "Bitcoin", "Atlanta Housing", or the full text of a Polymarket question).

11. `asset_symbol` is a string carrying the bare canonical symbol (e.g., "BTC", "ATL", or a Polymarket slug). It does not contain venue or chain suffixes. Suffixing for display is a rendering decision, not a contract decision.

12. `provider` is a string acting as a foreign key into the Provider table (e.g., "drift", "gains", "parcl", "polymarket"). It carries no display formatting.

13. `price` is a plain JavaScript `number`. Not a string, not a structured `{mantissa, scale}` pair, not a `{coeff, scale}` DTO. Plain number.

14. `unit` is a string that tells the frontend's formatter which display glyph to use (e.g., "USDC", "%", "JPY"). It is the only piece of information the frontend formatter needs to render `price`.

15. `info` is a freeform display string formatted by the adapter. It carries human-readable extras like "10x max" or "expires Oct 10". The frontend renders it as-is and does not parse it. This was explicitly locked at the moment the user said for Drift/Parcl/Gains the info would include leverage and for Polymarket it would say something like "expires October 10th."

16. The row contains no opaque execution payload field. The earlier `execution: <opaque>` field was explicitly removed when the two-resolvers model made it redundant.

17. The row contains no `priceNumeric` field. The earlier proposal to ship a parallel numeric field alongside a formatted string was rejected when `price` became a plain number.

18. The row contains no `tick`, `meta`, `mantissa`, `scale`, `expo`, `coeff`, or `kind` field. All earlier proposals using these names were rejected.

---

## Display Route Contract — Number Handling

19. Lean owns all unit conversion, scale normalization, and currency translation. Whatever number arrives in `price` is already in the units the user wants to see.

20. The frontend has exactly one piece of formatting logic: a small function that takes `(price, unit)` and produces the rendered string by branching on `unit`. This function has zero venue knowledge.

21. JavaScript `number` precision is sufficient for all human-readable price values in COINCHIP because no display value approaches the 2^53 precision limit. Wei-resolution and other big-integer concerns are handled by the future blockchain-native route, not the display route.

22. Pre-formatted strings for `price` are rejected. The frontend formats from a raw number plus a unit tag at render time.

---

## Display Route Contract — Provider as Structure

23. Provider information is factored out of the row into a separate Provider table, looked up by the `provider` field on each row.

24. Each Provider entry contains at minimum: provider identity and the network where the provider operates. Display name, network display name, and glyph were proposed by the assistant but not explicitly confirmed by the user, so they are tentatively part of the Provider entry but their exact presence is left to implementation.

25. The provider's network is implicit in which adapter handles it; right-Lean does not need it as a separate parameter on execution calls.

26. The chain glyph the user sees in the table is the provider's network glyph, derived by Provider table lookup, rendered as a separate visual element next to `asset_symbol`. It is not a string concatenated into the symbol.

27. The provider name itself ("Drift", "Gains") is not rendered to the user in the v1 wallet view. The user sees `BTC` plus a chain glyph; they do not see the word "Drift" or "Gains."

28. The native network of an asset (e.g., BTC's native network is Bitcoin) is explicitly out of scope for v1. There is no Asset table for native-network metadata. The chain the user sees is the provider's chain, not the asset's native chain.

---

## Display Route — Multi-Venue Asset Rendering

29. When the same asset is available on multiple providers (e.g., BTC on Drift via Solana and BTC on Gains via Arbitrum), it appears as multiple distinct rows in `getMarkets`, one per provider. Each row has the same `asset_symbol` ("BTC") but a different `provider`, and renders with a different chain glyph.

30. The frontend does not merge or deduplicate same-asset rows in v1. The user sees both rows side by side and picks manually.

31. There is no auto-routing in v1. The user is the disambiguator; clicking a row is the unambiguous selection of provider plus asset.

32. There is no unifying "BTC" row that hides the venue split in v1. Each provider gets its own row.

---

## Execution Route Contract

33. The execution route endpoint is conceptually `executionSignal` (operative label). The exact endpoint string is not formally frozen — see undecided item 87.

34. `executionSignal` takes an object containing the two resolvers (`asset_symbol`, `provider`) plus user inputs (`amount`, optionally `side`, optionally `leverage`) plus zero-or-more "supporters" (additional context signals like wallet preference, page context, settings).

35. The two resolvers `asset_symbol` and `provider` together form the primary key of any tradeable market in COINCHIP. They are sufficient to identify exactly one market because no two providers in the stack share both an asset and a provider identity.

36. The frontend does not construct opaque execution payloads. It sends signals; right-Lean does the lookup, dispatch, and venue-specific call construction.

37. The `executionSignal` response shape has exactly two kinds for v1: `{kind: "executed", ...}` and `{kind: "rejected", reason: "..."}`. The earlier proposed third kind `{kind: "disambiguate", options: [...]}` was removed when the manual-rows v1 decision made disambiguation unnecessary.

38. The frontend's response handler for `executionSignal` is a two-branch switch: success toast on `executed`, error toast on `rejected`.

39. Right-Lean is the single source of truth for routing rules. Knowledge like "Drift max leverage is X," "Gains supports stocks but Drift doesn't," "Polymarket only takes Polygon USDC" lives in right-Lean's dispatcher and nowhere else.

---

## Backend — Adapters and Normalization

40. Each venue (Drift, Parcl, Gains, Polymarket) has its own adapter in left-Lean. Adapters are independent, isolated, and faithful to each venue's native data shape.

41. Each adapter terminates at the canonical row shape (the seven-field display contract). The canonical shape is the boundary between adapter-internal venue knowledge and the rest of the system.

42. Adapters are responsible for unit normalization on output. Whatever scale, exponent, or representation the venue uses internally, the adapter converts to the canonical unit before emitting a row.

43. Adding a new venue requires writing one new adapter and one new dispatcher branch in right-Lean. It does not require touching the frontend, the row shape, or any existing adapter.

---

## Backend — Internal Type Findings (Research Reference)

44. Drift uses signed 64-bit integers (`i64`) with a fixed schema-level price precision of 1e6 (i.e., exponent fixed at -6). Source: Drift Rust SDK.

45. Gains uses unsigned 256-bit integers (`uint256`) with a fixed schema-level price precision of 1e10 (exponent fixed at -10). Source: Gains contract documentation.

46. Polymarket uses decimal strings on the wire with dynamic per-market tick sizes from the set {0.1, 0.01, 0.001, 0.0001} and a hard price range of [0.01, 0.99]. Source: py-clob-client `ROUNDING_CONFIG` and CLOB API error messages.

47. Parcl consumes Pyth oracle feeds directly and inherits Pyth's representation. Parcl does not define its own price representation.

48. Pyth uses `(int64 price, uint64 conf, int32 expo, uint64 publish_time)` — signed 64-bit mantissa, signed 32-bit exponent, per-value floating-point decimal. Both Drift and Parcl consume Pyth, making this the most authoritative oracle shape in the COINCHIP stack. Source: Pyth Solana Rust SDK and EVM Solidity SDK (identical structures).

49. FIX SBE (the institutional wire-format reference) uses signed integer mantissa plus signed integer exponent for prices, with two encoding modes: floating-point decimal (exponent on the wire per value) and fixed-point decimal (exponent fixed in schema). Source: FIX Trading Community spec.

50. MakerDAO/Ethereum DSS uses three named fixed-scale `uint256` types (Wad = 1e18, Ray = 1e27, Rad = 1e45) and the K-framework formal verification of MakerDAO keeps them as distinct sorts even though they share the same underlying carrier. This is the closest precedent in formally verified DeFi to a multi-scale architecture. Source: `sky-ecosystem/dss` `DEVELOPING.md` and `mkr-mcd-spec` repo.

51. Hyperliquid uses decimal strings on the wire with a "max 5 significant figures AND max (MAX_DECIMALS − szDecimals) decimal places" rule, where MAX_DECIMALS is 6 for perps and 8 for spot. Trailing zeros must be removed for signing. Source: Hyperliquid official docs and Python SDK.

---

## Frontend Implementation — Locked

52. The frontend is a React application.

53. The frontend uses a table-like renderer for the `getMarkets` rows. The specific library choice (TanStack Table, AG Grid, custom, etc.) is not locked at the architecture level — see undecided item 85.

54. Zod is explicitly rejected for the frontend. A formally verified Lean backend makes runtime schema validation on the frontend redundant. Type safety at the wire boundary should come from Lean-derived TypeScript types (codegen from Lean's `ToJson`/`FromJson`), not from a frontend schema library.

---

## Authentication and Wallet Model

55. Authentication is handled by Privy, providing embedded wallets.

56. Privy provides two embedded wallets per user: one Solana wallet (used for Solana-network providers like Drift and Parcl) and one EVM wallet (used for EVM-network providers like Gains and Polymarket).

57. The dual-wallet model is a load-bearing constraint on the architecture: the auto-routing design (deferred to v2) depends on the ability to read balances from both wallets and route execution to whichever wallet has funds for a given trade.

58. Privy dual embedded wallets (one Solana, one EVM, both embedded) is confirmed available and previously built by the user. This is treated as ground truth, not as an unverified assumption. The v2 auto-routing design can rely on it without re-verification.

---

## Scope Boundaries — v1 vs v2

59. The smart context resolver (read settings → read balances → read trade history → fall back to default → ask user) is designed and on file but explicitly deferred to v2. The design is not abandoned; it is preserved for v2 implementation. See item 82 for the preserved design.

60. Cross-chain orchestration (e.g., "user has funds on Solana but wants to trade on Arbitrum, bridge automatically") is out of scope for v1 and slots in as a future thin layer between right-Lean and venue execution APIs without changing the contract.

61. The disambiguation modal is not built for v1. It will be needed in v2 when auto-routing introduces ambiguous-context cases.

62. Wallet balance reading from Privy is not implemented in v1 because the manual-rows design makes it unnecessary for execution routing.

63. Default chain preference in user settings is not implemented in v1.

64. Last-trade memory (remember which venue the user last used for an asset) is not implemented in v1.

65. Currency translation (USDC → JPY, USDC → rupees, etc.) is not implemented in v1. The architecture supports it as a future thin Lean layer, but no such layer exists yet. Lean always hands USDC to the frontend in v1.

66. Theming is not implemented in v1. The architecture supports it as a future thin layer, but no such layer exists yet.

67. Sorting by leverage, filtering by expiration date, and other operations that would require parsing the `info` string are not supported in v1. The frontend can sort by `name`, `asset_symbol`, `provider`, or `price` only.

---

## Out of Scope — Display Layer Rejections

68. The `meta` field from the early DTO sketch was silently dropped during revisions and is not part of the final contract.

69. The `tick` field from the early DTO sketch was silently dropped. Tick validation is implicitly the responsibility of right-Lean (because right-Lean handles execution and would reject ill-formed orders), but this responsibility was never explicitly assigned in the conversation. See undecided item 84.

70. An Asset table for native-network metadata (e.g., "BTC's native chain is Bitcoin") is explicitly out of scope per user clarification. The user-facing chain glyph is the provider's chain, not the asset's native chain.

71. The Pyth `(mantissa, expo)` shape was proposed as the canonical internal Lean type and was rejected in favor of "send the number." It remains a research finding about how external systems represent prices, but it is not the COINCHIP internal type.

72. The mantissa/scale/string-bigint DTO was proposed as a defensive shape against precision loss and was rejected as over-engineering for human-readable display values.

73. A merged BTC row that hides the venue split was discussed and rejected for v1 (deferred to v2 auto-routing).

---

## Future Lean Internal Design — Pre-emptive Constraints

These are constraints carried over from the early challenger-exchange that happened before the COINCHIP design discussion proper. They are rejections of internal Lean type designs and they bound what any future internal Lean conversation can do. They are not active design questions for COINCHIP v1, but they must be honored when the internal Lean design conversation eventually happens.

74. `Price` as `mantissa : Nat` and `expo : Int` without type-level canonicality is rejected. The shape admits multiple structural inhabitants for the same semantic value and leaves equality wrong unless supplemented by a canonical-form invariant encoded in the type.

75. `provenance : Nat` is rejected as type erasure. It discards both provider association and bounded identifier space (e.g., `Fin 86` for Drift, `Fin 452` for Gains).

76. `normalizePoly : PolyCategory → Probability → Market` is rejected as unsound. Category plus probability is insufficient to uniquely identify a Polymarket market; market id and side are needed at minimum.

77. Silently dropping provider-specific semantic refinements (`GainsCategory`, `ParclLocationType`, `PolyCategory`) from the normalized record is rejected as lossy unless explicitly declared non-semantic with proof obligations.

78. Defining `Price` before resolving Polymarket and Parcl market identity is rejected as backward order of work. Identity must be resolved first because it constrains what `Price` needs to represent.

79. The single universal internal `Price { mantissa : Int, expo : Int }` plus `Quote` as the entire integration answer is rejected. It collapses the Lean core and the frontend DTO into one type and fails to serve either layer's needs.

---

## Internal Lean Core — Deferred to Future Conversation

These are decisions the COINCHIP conversation explicitly walked away from. They are not display-route v2 deferrals — they are Lean-internal core design questions that have no recommendation because they are for a future, separate conversation.

80. The exact internal Lean numeric representation is deferred. Fixed-scale per-provider types, signed mantissa/exponent pairs, provider-exact wrappers, `MarketPrice`, `Quote`, `FixedDecimal`, `ScaledDecimal`, and other variants were all proposed during the research phase but the conversation pivoted to the frontend/read-write contract problem before any internal carrier was chosen. A later dedicated internal Lean conversation must resolve this.

81. The exact internal Lean market and provenance schema is deferred. Open questions include: `provenance : Nat` vs tagged inductive, `PolyMarketId`/side/question identity, whether provider-specific categories remain in the normalized core, whether `Market.provider` is stored or derived. None of these are blocking for the COINCHIP v1 spec because the spec defines the external contract, not the internal Lean core, but they must be resolved before Lean implementation begins.

---

## Smart Context Resolver Design (Preserved for v2)

82. The smart context resolver design is preserved on file for v2 implementation. Its decision tree, as articulated by the user, is:

> 1. Read the user's provider setting. The setting can be `trading on base`, `trading on arbitrum`, `trading on Solana`, or `trading agnostically` (auto). If the setting is one of the explicit chain choices, route to that chain.
> 2. If the setting is `auto`, read wallet balances from Privy's two embedded wallets. If only one wallet has funds for the trade, route to the provider on that chain.
> 3. If both wallets have funds, read last-trade memory for the relevant asset. Route to whichever provider the user last used for that asset.
> 4. If there is no last-trade record, fall back to default-preference setting.
> 5. If even the default does not resolve, ask the user via a disambiguation modal.

The design also includes a leverage filter as a parallel pre-filter: if the user's leverage requirement exceeds what a provider supports (e.g., leverage > 200 eliminates Drift from candidates), that provider is removed from the candidate set before the chain above runs.

This design is not implemented in v1 but is committed for v2 and must be honored when the auto-routing mode is built.
