## Section 1: Locked decisions

**D1: Three-layer architecture**
* **Statement:** The system will use a three-layer architecture: 1) Venue Adapters (ingress, parsing raw data), 2) Lean Core (strict, semantically tagged, proof-carrying), and 3) Frontend DTO (flat, dumb, view language).
* **How it was reached:** Implicitly accepted and built upon after the AI proposed it to solve the user's "integration-times-three" pushback.
* **Final form:** N venue adapters → 1 Lean core → 1 frontend DTO.
* **Prior versions:** AI initially suggested modeling the Lean core by exact venue encoding, which the user rejected because it would force the frontend to integrate multiple data shapes.

**D2: Dumb-Frontend Principle**
* **Statement:** The frontend is "LEAF DUMB DISPLAY ONLY." It does not parse venue-specific payloads, does not contain venue-specific routing logic, and does not branch rendering logic based on the provider. It only renders the fields it is handed.
* **How it was reached:** Explicitly stated by the user via a diagram and text, and confirmed by the AI.
* **Final form:** The frontend renders rows based strictly on the DTO and sends an `executionSignal` with raw context on click.

**D3: Asymmetric Data Pipes**
* **Statement:** The outbound data flow (Lean → frontend) is a single pipe (`getMarkets`) that returns all markets simultaneously for a unified view. The inbound data flow (frontend → Lean) is stratified, firing discrete signals for specific assets.
* **How it was reached:** Explicitly decided by the user: "we call get market and we return all the markets... When it comes to executing, it is singular or its univocal."

**D4: Frontend validation (Zod) is unnecessary**
* **Statement:** Schema validation libraries like Zod will not be used on the frontend to validate the shape of the data coming from the backend.
* **How it was reached:** Explicitly proposed by the user ("why Zod would even need to play an error handling role on a formally verified backend") and confirmed by the AI.
* **Final form:** Frontend relies on the mathematically proven shape of the Lean backend (via TypeScript types derived from Lean), with standard JSON deserialization handling wire integrity.

**D5: Dynamic Name for Polymarket**
* **Statement:** Polymarket rows will not be forced into a separate table or tab. The `name` field will dynamically hold the entire Polymarket question string (e.g., "Will Trump win NH?").
* **How it was reached:** Explicitly proposed by the user ("cant i just put dynamic for poly") and accepted by the AI.

**D6: Opaque `info` field**
* **Statement:** Venue-specific metadata like leverage limits (e.g., "10x max") or expirations (e.g., "expires Oct 10") will be passed as a single pre-formatted `info` string rather than typed, separate columns.
* **How it was reached:** Explicitly decided by the user ("you do info or asset info or data. That info will be for Drift and parcel and Gains, inclusive of leverage...").
* **Final form:** `info: string` in the DTO.
* **Prior versions:** AI previously assumed typed fields like `leverage: Leverage | null` and `expiration: Date | null`.

**D7: Separate display and blockchain data routes**
* **Statement:** Human-readable display prices will be sent as standard JavaScript floats. A completely separate backend route/endpoint will be created later for full-precision blockchain history/logs.
* **How it was reached:** Explicitly decided after the user pushed back against complex big-int payload structures for simple UI display. ("why don't we just send the numbers as they are... When it comes to giving people blockchain history logs... we can have a different route for that").
* **Final form:** `price: number` in the `getMarkets` DTO.

**D8: Execution Logic lives in Right-Lean**
* **Statement:** The frontend will not filter valid venues or construct execution payloads. It will send an `executionSignal` containing the user's intent (asset, leverage, page context). "Right-Lean" will perform the filtering, routing, and venue-specific parameter construction.
* **How it was reached:** Explicitly decided by the user ("I think the front end should just send the signal to initiate... lean decoding or the lean normalizer... knows that there should be gains").
* **Prior versions:** The row contract previously included an `<opaque blob>` payload that the frontend had to blind-return to the backend.

**D9: V1 uses Manual Routing (No Auto-Routing)**
* **Statement:** For version 1, assets available on multiple venues (e.g., BTC on Drift and BTC on Gains) will be displayed as two separate rows. The user explicitly picks the venue by clicking the specific row.
* **How it was reached:** Explicitly decided by the user via diagram notes ("just add a BTC.Drift and BTC.Gains, better is BTC.SOL BTC.ARB") and confirmed as the V1 strategy to defer the complexity of an orchestrator/context-resolver.
* **Final form:** Manual row selection triggers execution based strictly on `asset_symbol` and `provider`.

**D10: Provider and Network Split (Foreign Key relationship)**
* **Statement:** The `getMarkets` row will not restate the provider's chain. Instead, it will contain a `provider` ID. The frontend will look up the chain/network details from a static `Provider` table.
* **How it was reached:** Explicitly proposed by the user ("we could just keep the Provider as its own structure that includes where they operate so we dont need to restate it") and accepted by the AI.
* **Prior versions:** The DTO previously contained a `providers_chain` string field directly in the row.

**D11: Visual composition of Chain/Provider Glyph**
* **Statement:** The visual representation of the network/chain (e.g., a Solana icon) will be rendered as a separate visual element next to the asset symbol, not baked into the symbol string itself.
* **How it was reached:** Explicitly proposed by the user ("just a seperate icon/column or thing to add ?") and accepted by the AI.

**D12: Hardcoded Provider Table for V1**
* **Statement:** The frontend will ship with the `Provider` lookup table hardcoded as a constant, rather than fetching it dynamically at app load.
* **How it was reached:** Implicitly accepted after the AI recommended it for V1 to reduce network calls.

---

## Section 2: Locked artifacts

**A1: `getMarkets` Display Row Contract (DTO)**
* **Type:** JSON Object Schema / Array of Objects
* **Final form:**
    ```json
    [
      {
        "id":           "string",
        "name":         "string",
        "asset_symbol": "string",
        "provider":     "string",
        "price":        "number",
        "unit":         "string",
        "info":         "string"
      }
    ]
    ```
* **Fields:**
    * `id`: (Final) Unique within response, used for React key.
    * `name`: (Final) Display name (e.g., "Bitcoin", "Will Trump win NH?").
    * `asset_symbol`: (Final) Canonical short label, no suffixes (e.g., "BTC"). (Revised from earlier `symbol`).
    * `provider`: (Final) Foreign key into the `Provider` table (e.g., "drift"). (Revised from `providers_chain`).
    * `price`: (Final) Plain JS number. (Revised from Pyth shape, string-coefficient DTO, pre-formatted string `"$78,343.03"`, and `{mantissa, scale, unit}`).
    * `unit`: (Final) Unit string used by the frontend formatter (e.g., "USDC", "%").
    * `info`: (Final) Pre-formatted human-readable display text (e.g., "10x max").
    * `execution`: (Removed) Opaque venue payload. Dropped because execution logic moved entirely to the backend.
    * `capabilities`: (Proposed, never adopted) Structured field for frontend filtering.
    * `priceNumeric`: (Proposed, removed) Parallel numeric field for sorting alongside a pre-formatted string.

**A2: `Provider` Table**
* **Type:** Hardcoded Constant (JSON Object/Dictionary)
* **Final form:**
    ```json
    {
      "drift":      { "display_name": "Drift", "network": "solana", "network_display": "Solana", "glyph": "/icons/solana.svg" },
      "gains":      { "display_name": "Gains", "network": "arbitrum", "network_display": "Arbitrum", "glyph": "/icons/arbitrum.svg" },
      "parcl":      { "display_name": "Parcl", "network": "solana", "network_display": "Solana", "glyph": "/icons/solana.svg" },
      "polymarket": { "display_name": "Polymarket", "network": "polygon", "network_display": "Polygon", "glyph": "/icons/polygon.svg" }
    }
    ```
* **Provenance:** Introduced in Turn 26, finalized in Turn 28.

**A3: `Asset` Table (Optional)**
* **Type:** Constant (JSON Object/Dictionary)
* **Final form:**
    ```json
    {
      "BTC": { "display_name": "Bitcoin", "native_network": "bitcoin", "glyph": "..." },
      "ETH": { "display_name": "Ethereum", "native_network": "ethereum", "glyph": "..." }
    }
    ```
* **Provenance:** Introduced in Turn 26 as an optional lookup for native asset rendering.

**A4: `executionSignal` Outbound Payload**
* **Type:** API Request Schema
* **Final form:**
    ```javascript
    executionSignal({
      asset_symbol: string,
      provider:     string,
      amount:       number,
      // optional supporters: leverage, side, walletPreference, page context, etc.
    })
    ```
* **Provenance:** Introduced in Turn 22 by the user, refined and locked in Turn 26.
* **Fields:**
    * `asset_symbol` and `provider` act as the "two resolvers" (primary key for routing).

**A5: `executionSignal` Inbound Response**
* **Type:** API Response Schema
* **Final form:**
    ```javascript
    // Success
    { kind: "executed", txHash: "0x...", ... }
    // Rejected
    { kind: "rejected", reason: "..." }
    ```
* **Provenance:** Turn 22 (AI proposed), Turn 24 (Locked, dropping the disambiguation branch for V1).
* **Prior versions:** Included a `{ kind: "disambiguate", options: [...] }` branch, which was deferred to V2.

---

## Section 3: Locked terminology

* **Asset Symbol / Symbol:** The canonical unique-within-COINCHIP identifier for the asset (e.g., "BTC", "ATL", Polymarket slug). Noted as the "core identity" for machine/system use. Finalized as `asset_symbol` in the DTO.
* **Name:** The human-readable string for display purposes, ensuring completeness for the user (e.g., "Bitcoin", "Will Donald Trump win the 2024 New Hampshire primary?").
* **Native Network:** Where the asset natively lives (e.g., BTC natively lives on the Bitcoin network). Explicitly distinct from the Provider Network.
* **Provider's Chain / Provider Network:** The blockchain where the venue/provider actually operates and executes trades (e.g., Solana for Drift, Arbitrum for Gains).
* **Provider:** The venue itself (Drift, Gains, Parcl, Polymarket) holding the order book or AMM.
* **Resolvers:** The minimal required fields to identify what to execute. Locked as exactly two fields: `asset_symbol` and `provider` (which implies `providers_chain`).
* **Supporters:** Optional contextual data sent from the frontend (e.g., wallet context, settings, leverage) used by the backend to make smarter routing decisions.

---

## Section 4: Open questions and deferred decisions

* **Smart Context Resolver / Auto-Routing (V2):**
    * *Deferred item:* The ability for the system to automatically route a generic "BTC" trade to Drift vs. Gains based on user wallet balances, leverage limits, or previous trade history.
    * *Why deferred:* User requested the simplest, most straightforward option for V1 to avoid orchestrator complexity.
    * *Default behavior:* Manual routing. Both BTC (Drift) and BTC (Gains) are shown as separate rows.
* **Disambiguation Modal (V2):**
    * *Deferred item:* A UI modal prompting the user to pick a chain/venue when auto-routing yields multiple valid options (e.g., user has balances on both Solana and Arbitrum).
    * *Why deferred:* Irrelevant in V1 since routing is strictly manual.
* **Unified BTC Row (V2):**
    * *Deferred item:* Merging multi-venue assets into a single row in the UI.
    * *Why deferred:* Requires auto-routing to function properly.
* **Blockchain-Native History Route:**
    * *Deferred item:* An API route providing high-precision, big-integer values for raw on-chain token quantities (wei, lamports).
    * *Why deferred:* Not needed for the current human-readable display scope. Will be defined when the feature is built.

---

## Section 5: Rejected proposals

* **R1: Keep core price shapes separate through to the frontend.**
    * *Proposed by:* ChatGPT (referenced in user prompt).
    * *Why rejected:* User argued it causes "integration-times-three" duplication in the UI/wallet layers.
    * *Replaced by:* A unified DTO layer serving a flat UI language.
* **R2: Typed fields for leverage/expiration in the contract.**
    * *Proposed by:* AI (implicit in early turns, explicit in Turn 14).
    * *Why rejected:* User wanted an agnostic design where the table component doesn't need to know the difference between "leverage" and "expiration dates".
    * *Replaced by:* A single freeform `info` string formatted by the backend.
* **R3: Pre-formatted strings for the `price` field (e.g., `"$78,343.03"`).**
    * *Proposed by:* AI.
    * *Why rejected:* User pointed out that sending strings breaks sorting functionality on the frontend.
    * *Replaced by:* Plain JS `number` + `unit` string.
* **R4: Structured `{ mantissa, scale, unit }` payload for price.**
    * *Proposed by:* AI (to protect against JS float64 precision limits for wei-scale amounts).
    * *Why rejected:* User pushed back on transforming regular numbers unnecessarily ("Why can't I say, 'Here, this is 70,000'").
    * *Replaced by:* Plain JS `number` (with the acknowledgment that a separate blockchain-log route handles wei).
* **R5: Opaque execution blob in the row.**
    * *Proposed by:* AI (to safely round-trip venue-specific parameters).
    * *Why rejected:* User proposed an `executionSignal` where the frontend sends contextual signals (asset, leverage, page context) and the backend dynamically decodes/filters the target.
    * *Replaced by:* `executionSignal` taking `asset_symbol`, `provider`, and supporters. The blob was removed from the DTO.
* **R6: Suffix strings for execution routing (e.g., sending `"BTC.drift"`).**
    * *Proposed by:* User (initially as an idea for "less split brain naming").
    * *Why rejected:* AI explained it requires re-inventing JSON inside strings, which is brittle (especially for Polymarket which requires condition IDs and token IDs).
    * *Replaced by:* Separate structural fields (`asset_symbol` + `provider`) in the signal.
* **R7: Database ID for execution lookup (e.g., `"market_8472"`).**
    * *Proposed by:* AI (as an option to consider).
    * *Why rejected:* AI noted it causes cache sync and race conditions in real-time streaming market data.
    * *Replaced by:* Real-time resolver parameters.
* **R8: Confirmation modal on every trade ("Are you sure?").**
    * *Proposed by:* AI.
    * *Why rejected:* Implicitly rejected by the user focusing purely on a frictionless experience and a "disambiguation" modal.

---

## Section 6: Implicit assumptions

* **React ecosystem:** The conversation heavily assumes a React-based frontend. Specific mentions of `TanStack Table`, `Zustand`, `JSX`, and "React keys" are treated as the definitive implementation targets.
* **Lean 4 as the authoritative backend:** The system assumes Lean 4 is the backend environment, processing data and guaranteeing type safety/formal verification.
* **Privy integration:** The frontend assumes the use of Privy for authentication and reading embedded wallet balances (ETH, Solana).
* **JSON transport:** Communication between the frontend and the Lean backend implicitly assumes standard JSON over HTTP/WebSockets (the DTO schemas are all JSON-compatible).
* **Decimals scale:** Assumes the user will not be trading in denominations requiring > 53 bits of precision in the UI (e.g., raw wei), validating the use of standard IEEE 754 floats for the UI `price` field.

---

## Section 7: Unresolved contradictions

* *None identified.* The conversation explicitly surfaced and resolved apparent contradictions (e.g., the conflict between dumb frontend / pre-formatted strings vs. the need for client-side sorting; the conflict between opaque execution blobs vs. the frontend sending generic routing signals). The final locked state is internally consistent.

---

## Section 8: Out-of-scope mentions

* **Cross-chain orchestrator backend:** The user mentioned an intent to use an orchestrator that could automatically swap Solana funds, bridge them to Arbitrum, and execute a trade on Gains. This was explicitly deemed "beyond the point" and "diving into the deeper layers" not required for the immediate frontend/backend API contract.
* **Global translation/theme layer:** The user mentioned the ability to add a "thin lean to sit on top" for translating currencies (e.g., USDC to JPY) or handling themes. This was validated as a compatible architectural pattern but no specific fields or structures were designed for it in this conversation.