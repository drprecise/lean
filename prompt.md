# Coinchip Live Market Ingress — Self-Contained Lean 4 File

> Latest spec is here /Users/mo/Code/1/base/wahid/for/mama/and/baba/awal/lean/spec/2/latest-spec.md 

## Who You Are Working For

You are working for Zen, who is building Coinchip — a unified trading interface across four DeFi/prediction-market providers (Drift, Gains, Parcl, Polymarket). The backend is Lean 4, formally verified. Zen has high standards: correctness over polish, completeness over partial delivery, first-class types over stringly-typed escape hatches, and direct execution over hedging. When you are uncertain, you do the work to become certain or you ask one clear question and wait. You do not pad responses with caveats. You do not propose alternatives Zen did not ask for. You do what you are told and you do it correctly the first time.

## What You Are Building

One Lean 4 file. Self-contained. The file is the live source of renderable market data for Coinchip. It fetches live HTTPS data from four providers, decodes it into first-class provider response types, normalizes it to a canonical row shape, and exposes a single public function that returns real renderable rows.

## Mission

Implement `getMarkets : IO (List MarketRow)` in one Lean file that, when run against live provider endpoints, returns a non-empty list of real market data from all four providers.

## Transport Decision (Locked, Do Not Re-evaluate)

Use `IO.Process.run` calling `curl`. Reasoning:

- curl is on the build and deploy machines already.
- curl handles TLS, certificate validation, SNI, redirects, HTTP/2 correctly.
- The file stays self-contained: imports are `Lean.Data.Json` and core Lean only. No Lake dependencies, no external packages, no toolchain upgrade, no libuv, no FFI.
- The first-class type discipline lives *after decode*, where it has always lived. The wire boundary returning a `String` from curl's stdout is identical in type discipline to returning a `String` from a libuv socket.

Do not propose `axiomed/Http.lean`, `algebraic-dev/Http`, `JamesGallicchio/http`, `Std.Http` (it is not merged into Lean master as of this writing — verified), FFI bindings, or any other transport. The decision is locked. If you find yourself wanting to use something else, stop and ask Zen one direct question; do not silently substitute.

## Canonical Row Shape (Locked)

```
structure MarketRow where
  name         : String   -- human-readable display name
  asset_symbol : String   -- bare canonical symbol, no venue/chain suffix
  provider     : String   -- exactly "drift" | "gains" | "parcl" | "polymarket"
  price        : Float    -- plain number, already in display units
  unit         : String   -- "USDC" for Drift/Gains/Parcl, "%" for Polymarket
  info         : String   -- freeform display extras (leverage info, expiry, etc.)
  deriving Repr
```

Six fields. No `id` field — the rendering layer computes React keys from `(provider, asset_symbol)` because that pair is already a primary key. No additional fields.

The four provider strings on the wire must be exactly `"drift"`, `"gains"`, `"parcl"`, `"polymarket"`. Use an explicit `Provider.toWire : Provider → String` function. Do not use `deriving ToJson` shortcuts — they will produce constructor names that do not match.

## Hard Requirements

These are non-negotiable. Each is achievable. If you cannot satisfy one, stop and ask; do not ship a partial solution.

1. **One self-contained file.** The file imports only `Lean.Data.Json` and core Lean (`IO.Process` is in core Lean — no extra import needed beyond `import Lean`). It does not depend on a parent Coinchip module. Every type the file uses, the file declares. A reviewer reads the file top to bottom and confirms it compiles standalone.

2. **Live endpoints only.** Every URL in the file points to a currently-live provider endpoint that you have verified by fetching the provider's official documentation in this task session. Cite the exact documentation URL in a comment next to each request builder.

3. **First-class types end-to-end after decode.** Each provider has a first-class decoded response type with named fields:
   - `DriftMarketsResponse`
   - `GainsMarketsResponse`
   - `ParclMarketIdsResponse`
   - `ParclMarketsResponse`
   - `PolymarketMarketsResponse`

   After decode, no `Json` value survives in the data flow. No `Option String` where an enum exists. No `List Json` where a typed list exists.

4. **`String` is allowed only at the wire boundary.** URLs, header values, query string values, outgoing JSON body field values that are themselves strings on the wire — those may be `String`. Internal labels, internal identifiers, internal enums, decoded fields representing closed-world concepts — none of these are `String`.

5. **No placeholders.** No `TODO`, no `FIXME`, no `sorry`, no `panic!`, no `unreachable!`, no stub bodies. Every function compiles. Every value is real. Every endpoint is real. The file ships as-is to production.

6. **Provider inductive type.**
   ```
   inductive Provider where
     | Drift
     | Gains
     | Parcl
     | Poly
     deriving DecidableEq, Repr

   def Provider.toWire : Provider → String
     | .Drift => "drift"
     | .Gains => "gains"
     | .Parcl => "parcl"
     | .Poly  => "polymarket"
   ```

7. **HTTPS request type, declared in this file.**
   ```
   inductive HttpsMethod where
     | GET
     | POST
     deriving DecidableEq, Repr

   structure HttpsHeader where
     name  : String
     value : String
     deriving Repr

   structure HttpsQueryParam where
     key   : String
     value : String
     deriving Repr

   structure HttpsRequest where
     method  : HttpsMethod
     url     : String
     query   : List HttpsQueryParam := []
     headers : List HttpsHeader := []
     body?   : Option Lean.Json := none
     deriving Repr
   ```

   `body?` is `Option Lean.Json`, not `Option String`. JSON bodies stay structured until the curl invocation serializes them.

8. **Single curl execution function.** Implement one function:
   ```
   def httpsExecute (req : HttpsRequest) : IO String
   ```
   It builds curl argv from the `HttpsRequest`, calls `IO.Process.run` with `cmd := "curl"`, and returns stdout as a `String`. Use these curl flags every time: `--fail --silent --show-error --max-time 30`. Add `-X` for the method, `-H "name: value"` for each header, `--data` for the JSON body if present (serialized from `Lean.Json` to a string at this point), and the URL with the query string appended (URL-encode keys and values).

   Failures from curl (non-2xx HTTP, TLS errors, timeouts) become `IO` exceptions because `IO.Process.run` throws on non-zero exit codes when combined with `--fail`. That is the desired behavior.

9. **Parcl: solve discovery-then-fetch correctly.** Parcl requires two HTTPS calls: GET `/v1/market-ids` (discovery), then POST `/v1/markets` with the discovered IDs in the body. The Parcl ingestion function in `IO` performs step 1, decodes its response into `ParclMarketIdsResponse` (a structure containing a `List ParclMarketIdentifier`), uses that to construct step 2's request body, performs step 2, decodes into `ParclMarketsResponse`. The body fields for step 2 are exactly `exchange_id` and `market_ids`. Use a named typed constant `parclUsdcExchangeId : Nat := 0` with a comment stating it represents the Parcl USDC exchange.

10. **Polymarket: solve pagination correctly, in this file.** The Polymarket Gamma `/markets` endpoint is paginated via `limit` and `offset`. Define named constants in this file:
    ```
    def polymarketDefaultPageSize : Nat := 100  -- matches Polymarket docs examples
    def polymarketDefaultMaxPages : Nat := 50   -- 5000 markets cap, well above current active count
    ```
    The Polymarket ingestion function fetches pages in sequence, decodes each into `PolymarketMarketsResponse`, accumulates rows, stops either when a page returns fewer than `pageSize` results or when `maxPages` is reached.

11. **`getMarkets : IO (List MarketRow)`** is the file's public surface. It calls all four provider ingestion functions, normalizes each provider's decoded response into `MarketRow`s, concatenates the results, and returns the full list. It does not return `IO Unit`. It does not print to stdout. It returns real `MarketRow` values that the caller can render directly.

12. **No execution logic.** This file is read-only. No order placement, no wallet calls, no transaction signing, no write-side endpoints. Read-only.

## Verification Steps Before Writing

Verify each of the following in this task session and record the documentation URL as a comment in the file. If any step fails (documentation moved, endpoint changed, field names differ), stop and report; do not ship the file with stale information.

1. **Drift.** Fetch `https://docs.drift.trade/developers/ecosystem-builders/reading-data` (or the current equivalent). Confirm `https://data.api.drift.trade/stats/markets` is the documented endpoint for fetching all market stats. Record the response shape so you can write `DriftMarketsResponse` with real field names.

2. **Gains.** Fetch the Gains backend integrators documentation. Confirm `https://backend-arbitrum.gains.trade/trading-variables/all` is the documented endpoint. Record the response shape so you can write `GainsMarketsResponse` with real field names.

3. **Parcl.** Read `ref/parcl.html` and `ref/parcl.md` if present in the repo. If not, fetch the public Parcl v3 API documentation. Confirm: (a) `https://v3.parcl-api.com/v1/market-ids` is the discovery endpoint, (b) `https://v3.parcl-api.com/v1/markets` is the bulk-fetch endpoint, (c) request body field names are exactly `exchange_id` and `market_ids`, (d) USDC exchange ID is `0`. Record both response shapes.

4. **Polymarket.** Fetch `https://docs.polymarket.com/api-reference/markets/list-markets`. Confirm `https://gamma-api.polymarket.com/markets` is the endpoint. Confirm the supported query parameters include `active`, `closed`, `limit`, `offset`. Record the response shape.

## Normalization Rules

After decoding each provider's response, map to `MarketRow` as follows:

- **Drift:** `provider := "drift"`, `unit := "USDC"`, `asset_symbol := market base symbol`, `name := market display name`, `price := mark price as Float`, `info := leverage or expiration context`. Drift's prediction-market perpetuals (markets with names like `TRUMP_WIN_2024_BET`, `NBAFINALS25_OKC_BET`) are Drift markets and are normalized identically to other Drift markets.
- **Gains:** `provider := "gains"`, `unit := "USDC"`, `asset_symbol := pair base symbol`, `name := pair display name`, `price := current price as Float`, `info := leverage info`.
- **Parcl:** `provider := "parcl"`, `unit := "USDC"`, `asset_symbol := market symbol`, `name := market display name (city)`, `price := current index price as Float`, `info := relevant context`.
- **Polymarket:** `provider := "polymarket"`, `unit := "%"`, `asset_symbol := slug or short id`, `name := full question text`, `price := outcome probability * 100 as Float`, `info := expiration date string`.

If a single market within a provider's response cannot be normalized (missing required field, malformed price), drop that single market and continue. Do not fail the entire `getMarkets` call because of one bad row.

## What "Done" Looks Like

The file compiles. `getMarkets : IO (List MarketRow)` runs against live provider endpoints and returns a non-empty list of real `MarketRow` values from all four providers. Every endpoint URL has a documentation citation. Every type is first-class after decode. Parcl two-step sequencing is honest. Polymarket pagination is bounded and named. Provider wire strings are exactly `"drift"`, `"gains"`, `"parcl"`, `"polymarket"`. The file imports only `Lean` (for `Lean.Json` and `IO.Process`). The file contains no `TODO`, `FIXME`, `sorry`, `panic!`, or stub bodies. The file contains no execution logic.

If the file ships and `getMarkets` returns real data on first run against live endpoints, the task is done.

## Forbidden Patterns

- Adding any Lake `require` line for an HTTP package
- Using `axiomed/Http.lean`, `algebraic-dev/Http`, `JamesGallicchio/http`, or any other Lean HTTP library
- Attempting to import `Std.Http` (it is not merged)
- FFI / `@[extern]` declarations for HTTP
- Stopping at `HttpsRequest` without fetching
- Stopping at `IO String` without decoding
- Stopping at decoded responses without normalizing to `MarketRow`
- Returning `IO Unit` or printing instead of returning data
- `String` for closed-world identifiers after decode
- `Json` surviving in the data flow after decode
- `deriving ToJson` on `Provider`
- Single-page Polymarket adapter
- Caller-supplied Parcl IDs (the file does the discovery in `IO`)
- Hardcoded magic values without named typed constants
- `TODO`, `FIXME`, `sorry`, `panic!`, `unreachable!`, stub function bodies
- Endpoint URLs without documentation citations
- Importing from a parent `Coinchip` module
- Any execution, write, or order-placement logic

## When You Are Uncertain

If you encounter a question whose answer is not in the verification steps above and not in this document, stop and ask Zen one direct question. Do not guess. Do not default to "the reasonable choice." Name the question in one sentence and wait.

Do not propose alternatives Zen did not ask for. Do not suggest external packages. Do not suggest toolchain upgrades. The transport is curl via `IO.Process.run`; the file is self-contained; the types are first-class after decode; the data is real. Those are the rails. Stay on them.