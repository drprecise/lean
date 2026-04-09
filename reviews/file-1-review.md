# File 1 Review

## Verdict

Reject.

This is not production PR material for the stated mission.

## Functional Findings

1. The public contract is wrong.
   Lines 131-140 define `MarketRow` with eight fields, not the locked six-field row.
   Added fields `provider_id`, `provider_symbol`, and `price : Decimal` violate the required render contract.

2. The request type is wrong.
   Lines 109-115 define `HttpsRequest.body? : Option String`.
   The locked requirement is `Option Lean.Json`.
   This removes structured JSON at the request boundary and violates the type discipline requirement.

3. The transport is absent.
   Lines 117-123 and 441-448 define an abstract `HttpsResponse` and `HttpClient`.
   There is no `httpsExecute : HttpsRequest → IO String`.
   There is no `IO.Process.run`.
   There is no `curl`.
   This fails the transport requirement outright.

4. The file is not self-contained in the required sense.
   Lines 1145-1147 define `getMarkets (client : HttpClient)`.
   The required public surface is `getMarkets : IO (List MarketRow)`.
   This file delegates execution to an external caller and therefore does not satisfy the mission.

5. The Drift decoder does not match the current live payload.
   Lines 487-505 decode `currentPrice`, `priceChange`, and `priceChangePercent` as required decimals.
   The verified live Drift `/stats/markets/prices` payload currently returns empty strings for those fields.
   This means Drift decode fails on real data.

6. The endpoint literals are invalid URLs.
   Lines 771-827 embed markdown links inside string literals such as:
   `"[https://data.api.drift.trade/stats/markets/prices](https://data.api.drift.trade/stats/markets/prices)"`
   That is not a valid endpoint string.
   Any real HTTP client would fail against these values.

7. Polymarket normalization violates the row contract.
   Lines 988-1029 expand one market into one row per outcome.
   The locked normalization rule is one row per market, with `price := outcome probability * 100 as Float`.
   This code changes cardinality, `name`, `asset_symbol`, and identity semantics.

8. `canonicalizeSymbol` is broken.
   Lines 413-424 push `*`, not `_`, on non-alphanumeric separators, then trim `_`.
   The function name and implementation disagree, and emitted symbols are malformed.

9. Gains identity is knowingly non-canonical.
   Lines 878-903 use `pairIndex:{index}` as identity and explicitly warn that identity is positional.
   The locked design requires direct renderable rows, not a report object explaining instability.
   This is an admitted temporary path, not permanent production code.

10. The code returns report scaffolding rather than the minimal direct path.
   Lines 142-179 introduce `IssueSeverity`, `MarketIssue`, `AcceptedRow`, `RejectedRow`, `ProviderReport`, and `MarketReport`.
   None of this is required by the mission.
   This increases surface area and error paths while moving away from the required output.

## Permanence Findings

1. The code is structured as an adapter framework, not as the minimal final file.
   The `HttpClient` abstraction and report layer indicate an intermediate architecture, not the production file requested.

2. The code carries explicit “defense” metadata around accepted vs rejected rows instead of implementing the simple required behavior:
   drop malformed rows and continue.

3. The Gains path contains a built-in disclaimer that the identity is positional.
   That is a self-declared unstable production surface.

4. The Drift path binds itself to a payload shape that is already false on the verified live endpoint.
   That is not durable.

5. The markdown-link endpoint strings indicate the code was optimized for presentation, not execution.
   That is a permanence failure.

## Essentiality Findings

1. `Decimal` is non-essential for this task.
   The locked row contract requires `price : Float`.
   A bespoke decimal subsystem spanning lines 5-79 and 181-353 is substantial extra machinery that does not earn its place for this file.

2. The report/issue layer is non-essential.
   Lines 142-179 add a full audit framework not requested by the contract.
   The required behavior is much smaller: normalize valid rows, drop invalid rows.

3. `ProviderIdentity`, `provider_id`, and `provider_symbol` are non-essential and contract-breaking.

4. The abstraction level is too high for the task.
   The file should perform live fetch, typed decode, normalize, return rows.
   This submission instead introduces a transport protocol, response protocol, reporting hierarchy, identity hierarchy, and warning taxonomy.

5. Robustness theater is present.
   The accepted/rejected reporting system and issue annotations compensate for uncertainty instead of resolving the live interface and returning the exact output.

## Strengths

1. `Provider` and `Provider.toWire` are correct in shape and intent.
   Lines 81-92 are aligned with the locked provider wire values.

2. The provider response type partitioning is directionally correct.
   Drift, Gains, Parcl, and Polymarket each get dedicated response structures and decoders.

3. The Parcl catalog is useful.
   Lines 720-760 encode the human-readable market names needed because the live API does not return them directly.

4. The code does attempt to preserve typed decoding after JSON parse.
   That is the right direction even though the outer transport and row contract are wrong.

## Weaknesses

1. It does not execute the mission as written.

2. It violates multiple locked contracts simultaneously:
   row shape, request body type, public function type, transport choice, and endpoint string values.

3. It overbuilds secondary machinery instead of solving the primary live-ingestion problem.

4. It contains at least one concrete logic bug (`canonicalizeSymbol`) and one concrete live-data mismatch (Drift decimal decode).

5. It treats Polymarket as multi-row-per-outcome rather than one-row-per-market.

## Exact Sections Worth Extracting

Extract only the following, with edits.

1. Lines 81-92
   Keep `Provider` and `Provider.toWire` essentially as-is.

2. Lines 453-470
   Keep `DriftMarketKind` and its wire decoder, but only if the final Drift path still needs the kind.

3. Lines 513-604
   Keep the Gains response structures and decoders in substance.
   Replace `Decimal` fields with `String` or `Float` according to the final file’s simpler numeric path.

4. Lines 606-718
   Keep the Parcl and Polymarket response structures and decoders in substance.
   Again, replace `Decimal`-based decoding with the final file’s simpler numeric path.

5. Lines 725-760
   Keep the Parcl catalog and lookup logic.
   This is useful and earned.

## Sections Not Worth Extracting

Do not extract these.

1. Lines 5-79
   `Decimal` subsystem.

2. Lines 109-123
   `HttpsRequest` with `Option String`, `HttpsResponse`, and `HttpClient`.

3. Lines 125-179
   Identity/report/issue framework.

4. Lines 181-448
   Large custom numeric parsing and generic transport/decode plumbing.

5. Lines 413-424
   `canonicalizeSymbol` as written is defective.

6. Lines 771-827
   Endpoint builders as written use invalid markdown-link strings.

7. Lines 829-1147
   Normalization/report/fetch path should not be reused directly.
   It is built around the wrong row contract and wrong public surface.

## Final Disposition

This file should not be promoted.

Use it only as a donor for:

1. `Provider` / `Provider.toWire`
2. selected provider response shapes
3. Parcl catalog data

Everything else should be rebuilt around the actual required production file:

1. six-field `MarketRow`
2. `price : Float`
3. `HttpsRequest.body? : Option Lean.Json`
4. one real `httpsExecute` using `IO.Process.run` and `curl`
5. `getMarkets : IO (List MarketRow)`
