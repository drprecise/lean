## Section 1: Locked decisions

Turn references in this extraction use the literal content of the turn for identification, for example `Turn: user "review claude's work"` or `Turn: user "You are performing lossless final-state extraction..."`. Where a decision was made implicitly, the extraction cites the proposal turn and the later turns that continued on top of it without challenge.

### D1. Claude’s original exercise submission was judged incorrect in two specific places and correct in one
- **Statement of the decision**
  - `Pos` solution: correct.
  - `Even` solution: core datatype and instances were correct, but the claimed Lean examples were invalid.
  - `HTTP` solution: incomplete relative to the prompt because it omitted the request representation and associated the action only with the method.
- **How it was reached**
  - Explicit.
  - Introduced in `Turn: user "review claude's work"` followed by assistant review findings.
  - Reinforced by the user-provided third-party review and the assistant response `Yes. It is substantially aligned with my review.`
- **Final form**
  - `Pos` was accepted as correct.
  - `Even` was accepted as correct in implementation but incorrect in example/output claims because no `OfNat Even` instance existed and `1 : Even` should not exist if the type represents only even numbers.
  - `HTTP` was accepted as incomplete because it did not model request data `method + URI + version`.
- **Prior versions**
  - None inside this conversation; this was the initial review result.
- **Cross-references**
  - Constrained D2, D3, D4.

### D2. The exact correction message to Claude was locked in substance
- **Statement of the decision**
  - The message to Claude had to say:
    1. `Pos` solution is correct.
    2. `Even` implementation is fine, but the Lean examples are invalid because the shown code has no `OfNat Even` instance, and `1 : Even` should not exist if the type represents only even numbers.
    3. `HTTP` is incomplete because the prompt describes request data as `method + URI + version`, but the code only defined methods and responses; the action must depend on the request, not only the method.
    4. Optional wording cleanup: replace “zero literal excluded by pattern” with “there is no `OfNat Pos 0` instance”.
- **How it was reached**
  - Explicit.
  - `Turn: user "im forwarding to claude"` pasted the exact message.
  - Assistant confirmed it was “accurate and fair to send” and supplied a tightened version.
- **Final form**
  - The message content above became the authoritative correction content.
- **Prior versions**
  - The assistant first proposed a slightly shorter version.
  - The user then requested a version with “complete outputs without added to dos”.
  - The assistant reformulated it as a direct correction note.
- **Cross-references**
  - Depends on D1.
  - Constrained D3.

### D3. Claude’s corrected exercises were validated as resolved after executable verification
- **Statement of the decision**
  - Claude’s later resolution of the exercise issues was accepted as valid after mechanical checking.
- **How it was reached**
  - Explicit.
  - `Turn: user "claude said resolved. please verify and invalidate/validate"`
  - Assistant reran Lean checks and then answered `Validated.`
- **Final form**
  - The corrected executable Lean file `test/positive/ch01_exercises.lean` was accepted as type-checking and running with the claimed outputs.
  - Prior defects were declared resolved:
    - `Pos`: wording corrected.
    - `Even`: no invalid numeral examples.
    - `HTTP`: request structure included and action depends on full request.
- **Prior versions**
  - Earlier, the markdown-only `claude-prover.md` was validated conceptually but required executable `.lean` evidence.
  - Then the `.lean` file was produced and validated.
- **Cross-references**
  - Depends on D1 and D2.
  - Produces artifact A1 in Section 2.

### D4. The user assigned the assistant the role `CHALLENGER`, and that role definition was accepted
- **Statement of the decision**
  - The assistant’s role changed to `CHALLENGER`.
- **How it was reached**
  - Explicit.
  - `Turn: user "okay. your role from now on is CHALLENGER..."`.
  - Assistant replied `Understood.` and restated the role in its own words.
- **Final form**
  - `CHALLENGER` must:
    - challenge every claim in `PROPOSAL.md`
    - treat the Lean reference and epistemic correctness for a high-stakes fintech/trading engine as the governing standard
    - write only markdown dialogue-style responses into the markdown file
    - not write code
    - only say `Concede` if the truth is aligned with “most correct / most strict” both at Lean-language abstraction level and higher-order formal-verification/trading-engine level
    - continue challenging until there is no real winnable challenge and no inference gap left
- **Prior versions**
  - Before this point, the assistant was doing review/verification work, not challenger-only work.
- **Cross-references**
  - Constrains D5 through D18.
  - Constrains artifacts in `PROPOSAL.md`.

### D5. The governing standard for challenge and acceptance was locked
- **Statement of the decision**
  - The governing standard is “the grounded truth is the Lean reference and epistemic correctness for a fintech with maximum rigor and high stakes.”
- **How it was reached**
  - Explicit.
  - Same turn as D4.
  - Assistant restated the standard in its own words without challenge.
- **Final form**
  - Acceptance/rejection is measured against:
    - Lean-grounded correctness
    - high-stakes fintech/trading-engine correctness
    - “most correct / most strict”
- **Prior versions**
  - None identified before the challenger assignment.
- **Cross-references**
  - Constrains D6–D18.
  - Constrains Section 5 rejected proposals.

### D6. Original `PROPOSAL.md` proposal was not conceded
- **Statement of the decision**
  - The initial `PROPOSAL.md` proposal was rejected by the challenger and was not conceded.
- **How it was reached**
  - Explicit.
  - `Turn: user "PROPOSAL.md"`
  - Assistant appended `## CHALLENGER` to the file, rejecting the proposal point-by-point.
- **Final form**
  - The initial proposal was not accepted because:
    - “exactly” was not established
    - one untagged `mantissa/expo` carrier erased semantic distinctions
    - canonical form was absent
    - “no precision loss” was unproven
    - “last open decision is price” understated other open ontology gaps
    - market losslessness was unproven
    - `normalizePoly : PolyCategory → Market` was unsound
- **Prior versions**
  - The proposal had claimed a single shared `Price` and single normalized `Market` shape without tagged price kinds or preserved Poly identity.
- **Cross-references**
  - Produces rejected proposals R1–R10 in Section 5.
  - Constrains D7 and D8.

### D7. Greenfield status did not justify overclaiming correctness
- **Statement of the decision**
  - Missing implementation due to greenfield status is not itself evidence against the proposal, but “can be built” does not justify treating unproven abstractions as already validated.
- **How it was reached**
  - Explicit.
  - `Turn: user "current repo is greenfield so not supported means not built yet and cans/should/will be built"`
  - Assistant replied that greenfield changes what is implemented, not what is justified.
- **Final form**
  - The challenge should target unjustified claims, not merely repo incompleteness.
- **Prior versions**
  - Earlier challenge text leaned heavily on current repo incompleteness.
  - This turn refined the reason for rejection: not lack of files, but unjustified abstraction claims.
- **Cross-references**
  - Constrains D8 and D9.

### D8. `REVISION 2` of `PROPOSAL.md` improved the proposal but was still not conceded
- **Statement of the decision**
  - `REVISION 2` was materially better than the original, but still not accepted as lossless or final.
- **How it was reached**
  - Explicit.
  - User pasted Claude’s `Revision 2` diff and asked to review the “fixes”.
  - Assistant appended `## CHALLENGER — Review of Revision 2`.
- **Final form**
  - `Revision 2` improved:
    - semantic tagging via `MarketPrice`
    - bounded Poly probability via `Fin 101`
    - rejection of `normalizePoly : PolyCategory → Market`
  - It remained not conceded because:
    - `Price` canonicality was only in prose/comments
    - zero canonical form was still incomplete
    - `provenance : Nat` weakened provider-specific invariants
    - `Market` dropped provider-specific semantic fields
    - `normalizePoly : PolyCategory → Probability → Market` still lacked concrete market identity
- **Prior versions**
  - Original proposal had one shared `Price` and one untagged notion of `price`.
  - `Revision 2` introduced `MarketPrice`, `Probability`, `provenance : Nat`, and corrected the Poly normalizer signature.
- **Cross-references**
  - Depends on D6 and D7.
  - Leads to D9.

### D9. Final call on `REVISION 3` of `PROPOSAL.md` was also “not conceded”
- **Statement of the decision**
  - `REVISION 3 — Final` was still rejected and not conceded.
- **How it was reached**
  - Explicit.
  - `Turn: user "codex . final call (read AGENTS.md ) .. PROPOSAL.md"`
  - Assistant read `AGENTS.md` and `PROPOSAL.md`, then gave a final call and wrote it into `PROPOSAL.md` when the user said `WRITE TO PROPOSAL`.
- **Final form**
  - `REVISION 3` was rejected because:
    1. `Price` was still not canonical: `mantissa = 0 ∨ mantissa % 10 ≠ 0` does not uniquely encode zero.
    2. Poly dynamic market identity was not preserved in `Market`.
    3. `normalizePoly` inputs were inconsistent with the proposed `Provenance.poly`.
    4. The `String` justification for `PolyMarketId` did not satisfy the repo rule requiring the phrase `This is a closed world so normally...`.
    5. The proposal still overstated `No information lost` / round-trip claims.
- **Prior versions**
  - `Revision 2` had `provenance : Nat`.
  - `Revision 3` replaced that with `Provenance`, proof-carrying `Price`, removed duplicated `provider` field, and introduced `PolyMarketId : String`.
  - Despite those changes, it remained not conceded.
- **Cross-references**
  - Depends on D4, D5, D8.
  - Produces rejected proposals R11–R16.
  - Produces unresolved contradictions C1 and C2 in Section 7.

### D10. “Approved” subset of the proposal was explicitly enumerated
- **Statement of the decision**
  - The assistant explicitly classified a subset of the proposal as “Approved”.
- **How it was reached**
  - Explicit.
  - `Turn: user "So what is currently approved and what is currently not approved?"`
  - Assistant responded with `Approved` and `Not Approved`.
- **Final form**
  - The approved items were:
    ```lean
    abbrev Probability := Fin 101
    ```
    ```lean
    inductive MarketPrice where
      | perpetual   : Price       → MarketPrice
      | index       : Price       → MarketPrice
      | probability : Probability → MarketPrice
    ```
    ```lean
    inductive Provenance where
      | drift : Fin 86  → Provenance
      | gains : Fin 452 → GainsCategory     → Provenance
      | parcl : Fin 28  → ParclLocationType → Provenance
    ```
  - The approved ontology points attached to these were:
    - Poly probability is a distinct bounded kind.
    - Price kinds must be semantically tagged, not collapsed into one untagged carrier.
    - Drift/Gains/Parcl provenance must preserve typed provider bounds.
    - Gains and Parcl provider-specific semantics must not be erased.
- **Prior versions**
  - Earlier proposal versions had either no tagging or weaker provenance.
- **Cross-references**
  - Constrains D11–D14.
  - Artifact details recorded in A2, A3, A4.

### D11. “Not approved” subset of the proposal was explicitly enumerated
- **Statement of the decision**
  - The assistant explicitly classified a subset of the proposal as “Not Approved”.
- **How it was reached**
  - Explicit.
  - Same turn as D10.
- **Final form**
  - The not-approved items were:
    ```lean
    structure Price where
      mantissa : Nat
      expo     : Int
    ```
    ```lean
    structure Price where
      mantissa : Nat
      expo     : Int
      h        : mantissa = 0 ∨ mantissa % 10 ≠ 0
    ```
    ```lean
    inductive Provenance where
      | poly : PolyCategory → Provenance
    ```
    ```lean
    structure PolyMarketId where
      conditionId : String
    ```
    ```lean
    structure Market where
      asset      : Asset
      price      : MarketPrice
      leverage   : Option Leverage
      quote      : QuoteAsset
      network    : Network
      provenance : Provenance
    ```
    ```lean
    def normalizePoly : PolyMarketId → Probability → Market
    ```
  - The attached ontology statements were:
    - `Price` not approved as final because canonical zero and exponent admissibility were unresolved.
    - Poly identity not approved because current proposal loses market identity in `Market`.
    - `String`-based Poly identity not approved under current justification.
    - Final `Market` ontology not approved because Poly provenance/identity is unresolved, so losslessness is not established.
- **Prior versions**
  - These were presented as the current non-final or rejected versions.
- **Cross-references**
  - Depends on D9 and D10.
  - Reappears in Section 5.

### D12. The conversation explicitly locked that the intended deliverable still has one top-level normalized object named `Market`
- **Statement of the decision**
  - There is still one highest-level normalized object, and its name is `Market`.
- **How it was reached**
  - Explicit.
  - `Turn: user "I thought it was one high-level structure at the highest level..."`
  - Assistant replied: `The intended highest-level deliverable is still one top-level record: structure Market where ...`
  - The user continued the conversation on that basis without challenge.
- **Final form**
  - `Market` is the top-level normalized object conceptually.
  - Nested types under it exist to preserve meaning.
- **Prior versions**
  - Earlier proposal versions also had `Market` as the top-level structure, but with different fields and different confidence level.
- **Cross-references**
  - Depends on D10 and D11.
  - Constrains artifacts A5 and A6.

### D13. The conversation explicitly locked that the blocker is not whether there is one top-level shape, but the final strict shape of `Price` and Poly provenance inside it
- **Statement of the decision**
  - One top-level `Market` is acceptable in principle; the unresolved blockers are the final strict shape of `Price` and the final strict shape of Poly provenance/identity nested inside it.
- **How it was reached**
  - Explicit.
  - Same turn as D12.
  - Assistant wrote: `The blocker is “what is the final strict shape of Price and Poly provenance inside that top-level shape?”`
  - The next user turn moved into “granular mode” and requested the entire output, implicitly accepting that framing.
- **Final form**
  - Top-level `Market` is not the blocker.
  - `Price` finality and Poly provenance finality are the blockers.
- **Prior versions**
  - Earlier challenge text had broader blocking lists.
  - This turn reduced the conceptual blocker to nested ontology.
- **Cross-references**
  - Depends on D12.
  - Feeds into D20, D21, and Section 4 open questions O1 and O2.

### D14. The conversation explicitly locked that Polymarket uses the term `price` and also equates it with `probability`
- **Statement of the decision**
  - On Polymarket, the displayed number is called both `price` and `probability`, and the docs explicitly say the price directly represents the probability.
- **How it was reached**
  - Explicit.
  - `Turn: user "What, do you know what they actually call it on the polymarket site?"`
  - Assistant browsed and returned findings with links.
- **Final form**
  - `price` is valid Polymarket terminology.
  - `probability` is also valid Polymarket terminology.
  - Their own docs treat price as implied probability.
- **Prior versions**
  - Earlier in the conversation there was uncertainty whether `price` was the right term for Poly or whether a broader term like `value` might be needed.
- **Cross-references**
  - Constrains terminology T1, T2, T3.
  - Feeds D15 and D16.

### D15. The user explicitly committed that `price` works as a term because Polymarket itself uses `price`
- **Statement of the decision**
  - The user explicitly said that `price` works because Polymarket literally uses `price`.
- **How it was reached**
  - Explicit.
  - `Turn: user "So they do use price... I would definitely say that price works, because they're literally saying price works."`
- **Final form**
  - The term `price` was accepted by the user as workable, including for Poly, because of Polymarket’s own terminology.
- **Prior versions**
  - Earlier, the user had explored whether `value` might be the better term.
  - This later turn moved back toward `price`.
- **Cross-references**
  - Depends on D14.
  - Potentially conflicts with D17 and contradiction C3.

### D16. A shared numeric substrate across venues was accepted as plausible, but semantic meaning must be preserved
- **Statement of the decision**
  - One decimal-capable numbering system can cover Bitcoin-like large values, meme-coin-like small values, Parcl-style indices, and Poly prices/probabilities numerically, but the meaning of the number must be preserved.
- **How it was reached**
  - Explicit.
  - In response to the user’s discussion of Bitcoin, meme coins, Poly cents, and other values, the assistant replied:
    - `Your argument is correct at the numeric layer`
    - `same numeric substrate, different preserved meaning`
  - The user then continued with questions about UI consequences and later restated the need for coupling between number and owner/provider.
- **Final form**
  - Numeric range/decimal precision is not the hard part.
  - The hard part is semantic correctness.
  - Same numeric substrate is acceptable only if semantic kind/unit is preserved.
- **Prior versions**
  - Earlier proposal versions attempted a single shared `Price` type without sufficient semantic tagging.
- **Cross-references**
  - Depends on D14 and D15.
  - Constrains D17 and D18.

### D17. The user explicitly committed that the frontend/UI must receive numbers coupled to their owner/provider and canonical unit
- **Statement of the decision**
  - The frontend does not need a universal semantic system; it needs values coupled to their owner/provider and canonical unit so the UI knows how to label/render them.
- **How it was reached**
  - Explicit.
  - `Turn: user "This isn't about normalizing everything into one system... we just need to make sure that the UI understands that any rows or any fields it's receiving are coupled to its owner like this. Just make sure you have units and labels, and we can easily enforce it such that all numbers on the front end have their provider and all providers have an unbreakable canonical unit."`
  - Assistant replied `Yes. That is the clearer formulation.`
- **Final form**
  - Frontend/UI requirement:
    - exact numeric representation
    - unbreakable coupling between number and meaning
    - provider-aware or kind-aware units/labels at render time
  - The core requirement became:
    - not one universal semantic `price`
    - but every numeric field arrives with enough canonical meaning that the UI cannot mislabel it
- **Prior versions**
  - Earlier conversation explored one generic price, broader “value”, and one universal numeric system.
  - This turn changed the emphasis to UI-safe coupling.
- **Cross-references**
  - Depends on D16.
  - Constrains D18, D19, D20, and implicit assumptions I4 and I5.

### D18. The exact simpler architecture explicitly accepted was “many exact internal types, one flat frontend projection”
- **Statement of the decision**
  - The simpler solution is architectural:
    - many exact internal types
    - one flat frontend projection / view language / DTO
- **How it was reached**
  - Explicit.
  - User pasted a candidate finding beginning `Yes. Make your own numbering system...`
  - Assistant answered:
    - `Approved simplification:`
    - `Core truth: multiple strict semantic/provider types.`
    - `UI/output: one normalized view DTO.`
    - `Unification happens at the boundary, not in the core.`
    - `So the simpler solution is architectural, not ontological: many exact internal types, one flat frontend projection`
- **Final form**
  - Core Lean truth = multiple exact semantic/provider types.
  - Frontend language / DTO = one canonical decimal/view language.
  - Unification happens at the view boundary, not in the core ontology.
- **Prior versions**
  - Earlier, the assistant had proposed Lean-generated HTML as a browser proof path when limited to Lean only.
  - Later, when React/TS/Vite became allowed, the architecture shifted to Lean core + frontend projection.
- **Cross-references**
  - Depends on D17.
  - Constrains terminology T4 (`DTO`) and assumptions I6.

### D19. `DTO` was defined explicitly
- **Statement of the decision**
  - `DTO` means `Data Transfer Object`.
- **How it was reached**
  - Explicit.
  - `Turn: user "What's a DTO?"`
  - Assistant answered with a direct definition.
- **Final form**
  - A `DTO` is:
    - a flat transport/view shape
    - used to move data between layers
    - not the deepest source-of-truth domain model
  - In this conversation:
    - Lean core types = strict ontology / proof-oriented truth
    - DTO = normalized UI/API-facing projection of that truth
- **Prior versions**
  - The term appeared before it was defined.
- **Cross-references**
  - Depends on D18.
  - Artifact A7 in Section 2.
  - Terminology T4 in Section 3.

### D20. React, TypeScript, and Vite were explicitly allowed
- **Statement of the decision**
  - The project is allowed to install and set up React, TypeScript, and Vite.
- **How it was reached**
  - Explicit.
  - `Turn: user "We can install and set up React, TypeScript, Vite."`
- **Final form**
  - React/TypeScript/Vite are permitted technologies for the browser proof and frontend layer.
- **Prior versions**
  - Earlier, the assistant had planned a Lean-only generated HTML approach because the user had initially asked for “using only lean”.
- **Cross-references**
  - Constrains D21–D24.
  - Produces implicit assumption I2.

### D21. The user explicitly selected the stronger `Price` direction: proof-carrying canonical `Price`
- **Statement of the decision**
  - For the unresolved `Price` question, the selected option was `Proof-carrying (Recommended)`.
- **How it was reached**
  - Explicit.
  - During the multiple-choice blocker questions, the user selected:
    - `Proof-carrying (Recommended)` for `Price`
    - with note `idk i thought that you said price was resolved ?`
- **Final form**
  - The chosen direction is:
    - canonical exact decimal
    - invariant enforced in the type
    - malformed values unconstructable
  - This locks direction, not the exact final Lean structure.
- **Prior versions**
  - Earlier options in the multiple-choice question were:
    - plain `mantissa/expo`
    - provider-scaled only
- **Cross-references**
  - Depends on D13.
  - Produces open question O1 because exact final shape was still not specified.

### D22. The user explicitly selected the stronger Poly provenance direction: preserve dynamic market ID
- **Statement of the decision**
  - For Poly provenance/identity, the selected option was `Dynamic market ID (Recommended)`.
- **How it was reached**
  - Explicit.
  - Same multiple-choice blocker turn as D21.
  - User selected `Dynamic market ID (Recommended)`.
- **Final form**
  - The required preserved Poly provenance is the specific dynamic Poly market/question identifier, because category alone is lossy and not reconstructible.
- **Prior versions**
  - Earlier options presented in the multiple-choice question:
    - `Category only`
    - `Category + side`
  - Earlier proposal revisions had used `PolyCategory` only or `PolyMarketId : String` without sufficient preservation.
- **Cross-references**
  - Depends on D13.
  - Produces open question O2 because the exact final representation of that ID remained unresolved.

### D23. The user explicitly committed that Lean handles decoding, normalization, and construction, and React consumes a stable mature API
- **Statement of the decision**
  - React should import and consume a stable, canonical API surface whose result is already decoded, normalized, and constructed by Lean.
- **How it was reached**
  - Explicit.
  - In response to the question about what exact Lean artifact React should consume, the user wrote:
    - `react is importing a 1 liner mature api that is the result of decoding, normalization and construction handled by the lean file`
    - `this is the canonical api that will render markets for any website visitor - always . it is the core of our data . its our portfolio . its our engine in plain sight.`
- **Final form**
  - Lean owns:
    - decoding
    - normalization
    - construction
  - React/browser consumes:
    - one stable canonical API
- **Prior versions**
  - Earlier options considered included:
    - Lean-generated HTML
    - static JSON file
    - HTTP endpoint consumed by React
    - frontend mock only
  - The user rejected the framing of some of those options as not capturing what they meant.
- **Cross-references**
  - Depends on D17, D18, and D20.
  - Produces open question O3 because the exact route/function/component naming was not finalized.

### D24. The frontend/display layer was explicitly described as “just displaying”
- **Statement of the decision**
  - The frontend’s role is display, while the canonical API is the core data surface.
- **How it was reached**
  - Explicit.
  - `Turn: user "if the front end is just displaying it then the name for frontend is just display or show markets right ?"`
  - Although the naming answer was not finalized, the role assumption `front end is just displaying it` was stated directly by the user and used to question the naming scheme.
- **Final form**
  - Frontend is display-oriented.
  - Data/canonical API is separate and upstream.
- **Prior versions**
  - Earlier the assistant had distinguished:
    - frontend client/browser-side API function
    - React display/component
  - The user questioned that distinction but did not reject the underlying split of concerns.
- **Cross-references**
  - Depends on D23.
  - Produces open question O3 and assumption I7.

## Section 2: Locked artifacts

### A1. `test/positive/ch01_exercises.lean` — executable Lean file validating Claude’s corrections
- **Artifact name and type**
  - `test/positive/ch01_exercises.lean`
  - Type: executable Lean source file / verification artifact
- **Final form in conversation notation**
  - The file contains:
    - `Pos` structure with `succ :: pred : Nat`
    - `Add`, `Mul`, `ToString`, `OfNat` for `Pos`
    - `Even` structure with `half : Nat`
    - `ToString`, `Add`, `Mul` for `Even`
    - `HTTPMethod`
    - `HTTPVersion`
    - `HTTPRequest`
    - `HTTPResponse`
    - `HTTPAction`
    - `main`
    - `#eval` lines verifying `Pos` and `Even`
  - The assistant showed the concrete content by printing the file with line numbers. Key excerpt:
    ```lean
    structure Pos where
      succ ::
      pred : Nat

    instance : Add Pos where
      add x y := ⟨x.pred + y.pred + 1⟩

    instance : Mul Pos where
      mul x y := ⟨x.pred * y.pred + x.pred + y.pred⟩

    instance : ToString Pos where
      toString x := toString (x.pred + 1)

    instance : OfNat Pos (n + 1) where
      ofNat := ⟨n⟩
    ```
    ```lean
    structure Even where
      half : Nat

    instance : ToString Even where
      toString x := toString (x.half * 2)

    instance : Add Even where
      add x y := ⟨x.half + y.half⟩

    instance : Mul Even where
      mul x y := ⟨x.half * y.half * 2⟩
    ```
    ```lean
    structure HTTPRequest where
      method  : HTTPMethod
      uri     : String
      version : HTTPVersion
    ```
- **Every field, type, constraint, and comment attached to it**
  - `Pos`
    - `succ ::` — in the final version
    - `pred : Nat` — in the final version
    - comment `There is no OfNat Pos 0 instance — zero is not positive.` — in the final version
  - `Even`
    - `half : Nat` — in the final version
    - comment `No OfNat Even instance — requires features from the next section.` — in the final version
    - comment `1 : Even must not exist. Examples use struct syntax directly.` — in the final version
  - `HTTPRequest`
    - `method : HTTPMethod` — in the final version
    - `uri : String` — in the final version
    - `version : HTTPVersion` — in the final version
  - `HTTPResponse`
    - `status : Nat` — in the final version
    - `body : String` — in the final version
- **Provenance**
  - Introduced when the user asked Claude to convert the markdown solutions into `.lean` and execute them.
  - Finalized when the assistant reran:
    - `lean test/positive/ch01_exercises.lean`
    - `lean --run test/positive/ch01_exercises.lean`
    and validated the outputs.

### A2. Approved artifact subset: `Probability`
- **Artifact name and type**
  - `Probability`
  - Type: Lean abbreviation / bounded type
- **Final form in conversation notation**
  ```lean
  abbrev Probability := Fin 101
  ```
- **Every field, type, constraint, and comment attached to it**
  - `Fin 101` — in the final approved subset
  - semantic comment from multiple places:
    - `Poly probability is a distinct bounded kind` — approved ontology statement
    - in earlier proposal revisions: `0–100 cents represents 0%–100% probability` — earlier version attached to proposal text
- **Provenance**
  - Introduced in `PROPOSAL.md Revision 2`.
  - Classified as `Approved` in the assistant’s “currently approved / not approved” answer.
- **Status across versions**
  - Proposed in `Revision 2`
  - Retained in `Revision 3`
  - Explicitly approved in the later “Approved” list

### A3. Approved artifact subset: `MarketPrice`
- **Artifact name and type**
  - `MarketPrice`
  - Type: Lean inductive/tagged sum
- **Final form in conversation notation**
  ```lean
  inductive MarketPrice where
    | perpetual   : Price       → MarketPrice
    | index       : Price       → MarketPrice
    | probability : Probability → MarketPrice
  ```
- **Every field, type, constraint, and comment attached to it**
  - `perpetual : Price → MarketPrice` — in the final approved subset
  - `index : Price → MarketPrice` — in the final approved subset
  - `probability : Probability → MarketPrice` — in the final approved subset
  - earlier proposal comments:
    - `Drift, Gains: mark price` — earlier version attached to constructor comments
    - `Parcl: real estate index level` — earlier version attached to constructor comments
    - `Poly: YES share, bounded` — earlier version attached to constructor comments
  - ontology statement:
    - `Price kinds must be semantically tagged, not collapsed into one untagged carrier.` — approved
- **Provenance**
  - Introduced in `PROPOSAL.md Revision 2`.
  - Explicitly approved later in the “Approved” list.

### A4. Approved artifact subset: `Provenance` (partial, without final Poly form)
- **Artifact name and type**
  - `Provenance`
  - Type: Lean inductive/tagged provenance carrier
- **Final form in conversation notation**
  - Approved constructors:
    ```lean
    inductive Provenance where
      | drift : Fin 86  → Provenance
      | gains : Fin 452 → GainsCategory     → Provenance
      | parcl : Fin 28  → ParclLocationType → Provenance
    ```
  - Poly constructor was not approved in any final form.
- **Every field, type, constraint, and comment attached to it**
  - `drift : Fin 86 → Provenance` — in the approved subset
  - `gains : Fin 452 → GainsCategory → Provenance` — in the approved subset
  - `parcl : Fin 28 → ParclLocationType → Provenance` — in the approved subset
  - `poly : PolyCategory → Provenance` — earlier version in `Revision 3`, explicitly not approved
  - `poly : PolyProvenance → Provenance` — proposed in the assistant’s “complete expected entire output”, proposed but never adopted
  - ontology statements attached:
    - typed provider bounds must be preserved
    - Gains and Parcl provider-specific semantics must not be erased
- **Provenance**
  - Earlier proposal versions used `provenance : Nat` inside `Market`.
  - `Revision 3` introduced `Provenance`.
  - Later the assistant split out the approved and not-approved parts, leaving Poly unresolved.

### A5. Top-level normalized structure candidate: `Market`
- **Artifact name and type**
  - `Market`
  - Type: Lean structure / top-level normalized object
- **Final form in whatever notation the conversation used**
  - There were multiple versions. No final fully approved version was reached.
  - Approved-in-principle top-level concept:
    ```lean
    structure Market where
      asset      : Asset
      price      : MarketPrice
      leverage   : Option Leverage
      quote      : QuoteAsset
      network    : Network
      provenance : Provenance
    ```
    This exact version was output by the assistant in “complete expected entire output” but had not been approved as final.
- **Every field, type, constraint, and comment attached to it**
  - `provider : Provider` — in earlier versions, removed later as duplicate/derivable
  - `asset : Asset` — in multiple versions
  - `price : Price` — in earlier versions, removed/replaced by `MarketPrice`
  - `price : MarketPrice` — in later versions
  - `leverage : Option Leverage` — in multiple versions
  - `quote : QuoteAsset` — in multiple versions
  - `network : Network` — in multiple versions
  - `provenance : Nat` — in `Revision 2`, removed/rejected later
  - `provenance : Provenance` — in `Revision 3` and later candidate outputs
  - comment `provider removed as field — it is fully determined by provenance` — in `Revision 3`
- **Provenance**
  - Introduced in the original `PROPOSAL.md`
  - Revised in `Revision 2`
  - Revised again in `Revision 3`
  - Not approved as final non-lossy shape in the “Not Approved” list
  - Still described conceptually as the one top-level normalized object later in the conversation
- **Status**
  - Top-level `Market` concept: implicitly accepted / locked in principle
  - Exact final field set: not finalized

### A6. `Price`
- **Artifact name and type**
  - `Price`
  - Type: Lean structure / numeric carrier
- **Final form in whatever notation the conversation used**
  - No final approved form.
  - Versions discussed:
    1. Original:
       ```lean
       structure Price where
         mantissa : Nat
         expo     : Int
       ```
    2. `Revision 3`:
       ```lean
       structure Price where
         mantissa : Nat
         expo     : Int
         h        : mantissa = 0 ∨ mantissa % 10 ≠ 0
       ```
    3. Assistant’s “complete expected entire output” later reverted to:
       ```lean
       structure Price where
         mantissa : Nat
         expo     : Int
       ```
       but that was not an adoption; it was a proposed current expected output.
- **Every field, type, constraint, and comment attached to it**
  - `mantissa : Nat` — in all versions
  - `expo : Int` — in all versions
  - `h : mantissa = 0 ∨ mantissa % 10 ≠ 0` — in `Revision 3`, explicitly rejected as insufficient for canonicality
  - comment `Canonical form invariant: mantissa % 10 ≠ 0, OR expo = 0.` — in `Revision 2`, earlier version in prose only, removed in `Revision 3` in favor of the proof field
- **Provenance**
  - Original proposal.
  - Challenged in original `CHALLENGER` section.
  - Revised in `Revision 3`.
  - Not approved as final in the approved/not-approved classification.
  - Direction later selected by user as `Proof-carrying`.
- **Status**
  - Exact final artifact unresolved.
  - Direction locked toward proof-carrying canonicality (see D21).

### A7. `DTO` / frontend projection concept
- **Artifact name and type**
  - `DTO`
  - Type: named architectural artifact / transport/view shape concept
- **Final form in conversation notation**
  - User-provided candidate text:
    ```text
    kind   = price | probability | index | qty | amt | pct
    value  = { coeff: "digits", scale: Nat }
    tick   = { coeff: "digits", scale: Nat }?
    unit   = quoteAsset | outcome | indexUnit
    id     = stable market identifier
    meta   = venue / symbol / side / status / display fields
    ```
  - Assistant did **not** adopt this exact DTO as final. The assistant approved the architectural direction `many exact internal types, one normalized view DTO`, but not this exact wire shape.
- **Every field, type, constraint, and comment attached to it**
  - `kind` — proposed, never adopted exactly
  - `value = { coeff: "digits", scale: Nat }` — proposed, not adopted as core truth; assistant rejected `coeff: "digits"` as core truth
  - `tick` — proposed, never adopted
  - `unit` — proposed, conceptually aligned with later UI/unit coupling, but not formally adopted as exact schema
  - `id` — proposed, aligned with the requirement to preserve identity, but not finalized as exact field
  - `meta` — proposed, never adopted
- **Provenance**
  - Introduced by the user in the “Is there a simpler solution?” turn.
  - Assistant approved the architectural direction, not the exact field list.
- **Status**
  - Architectural concept accepted.
  - Exact DTO schema not finalized.

### A8. Browser/API architecture artifact (non-final)
- **Artifact name and type**
  - “1 liner mature api”
  - Type: architectural interface concept
- **Final form in conversation notation**
  - User wording:
    - `react is importing a 1 liner mature api that is the result of decoding, normalization and construction handled by the lean file`
    - `this is the canonical api that will render markets for any website visitor - always . it is the core of our data . its our portfolio . its our engine in plain sight.`
- **Every field, type, constraint, and comment attached to it**
  - No exact route name, function name, or schema were finalized.
  - Constraints attached:
    - Lean owns decoding, normalization, and construction.
    - React consumes the result.
    - Frontend is display-oriented.
- **Provenance**
  - Introduced during blocker-question discussion after the user allowed React/TS/Vite.
- **Status**
  - Architectural commitment locked.
  - Concrete naming/interface details unresolved.

## Section 3: Locked terminology

### T1. `price`
- **Definition as stated in the conversation**
  - For Polymarket, `price` is a valid term because Polymarket itself uses `price`, and that price directly represents implied probability.
  - For the broader design, the user explicitly said `price works`.
- **Synonyms or near-synonyms used**
  - `probability` — treated as semantically related but not identical in wording; Polymarket uses both.
  - `value` — raised by the user as a possible broader word, not finalized.
  - `valuation`, `quote` — suggested by the assistant as possible broader names, never adopted.
- **First and last appearance**
  - First major contested appearance: original `PROPOSAL.md` and later discussion about Poly terminology.
  - Last major appearance: user insistence that `price works` and later UI/unit-coupling discussion.

### T2. `probability`
- **Definition as stated in the conversation**
  - For Polymarket, the price directly represents the market’s implied probability.
  - In the type system, `Probability := Fin 101` was the approved bounded representation for Poly’s distinct price kind.
- **Synonyms or near-synonyms used**
  - `YES share`
  - `75%`
  - `75 cents`
  - `bounded probability`
- **First and last appearance**
  - First significant appearance: Polymarket discussion and proposal revisions.
  - Last significant appearance: approved artifact subset and later architecture discussion.

### T3. `value`
- **Definition as stated in the conversation**
  - The user explored `value` as a broader category than `price`, using analogies like cash, gift cards, coupons, and services.
  - No final definition was locked.
- **Synonyms or near-synonyms used**
  - `price`
  - `valuation`
  - `quote`
- **First and last appearance**
  - First appearance: `maybe value is the right word and price is a different word`
  - Last appearance: assistant explanation that the “safe shape” could be one top-level broader field, but user later returned to `price`.

### T4. `DTO`
- **Definition as stated in the conversation**
  - `DTO = Data Transfer Object`
  - `a flat transport/view shape`
  - `used to move data between layers`
  - `not the deepest source-of-truth domain model`
- **Synonyms or near-synonyms used**
  - `frontend language`
  - `view language`
  - `normalized UI/API-facing projection`
  - `transport/view shape`
- **First and last appearance**
  - First appearance: user’s pasted “Canonical language / DTO” block.
  - Last appearance: assistant definition in response to `What's a DTO?`

### T5. `lossless`
- **Definition as stated in the conversation**
  - In the challenger/proposal context, `lossless` meant that no information required for correctness, semantics, provenance, or reconstruction is erased by normalization.
  - In the final extraction request, `lossless` was defined even more strictly: a reader should be able to reconstruct every committed decision and every open question from the extraction without revisiting the original conversation.
- **Synonyms or near-synonyms used**
  - `non-lossy`
  - `no information lost`
  - `round-trip possible`
  - `preserve meaning`
- **First and last appearance**
  - First major appearance: challenger critique of `PROPOSAL.md`.
  - Last appearance: user’s final extraction instruction.

### T6. `provenance`
- **Definition as stated in the conversation**
  - Source identity / provider-specific identifier and semantics preserved through normalization.
- **Synonyms or near-synonyms used**
  - `source ID`
  - `provider-internal ID`
  - `marketIndex / pairIndex / marketId`
  - `typed, bounded, semantic-preserving`
- **First and last appearance**
  - First major appearance: `Revision 2` proposal (`provenance : Nat`)
  - Last major appearance: `Revision 3` and subsequent approval/not-approval discussion.

### T7. `canonical`
- **Definition as stated in the conversation**
  - A representation with no multiple encodings for the same semantic value.
  - For `Price`, the main contested canonicality issue was trailing-zero normalization and the canonical zero representation.
- **Synonyms or near-synonyms used**
  - `normalization invariant`
  - `proof-carrying canonical`
  - `exact decimal with invariant enforced in the type`
- **First and last appearance**
  - First major appearance: original challenge to `mantissa/expo`.
  - Last major appearance: the user’s selection of `Proof-carrying` `Price` and final proposal critique.

### T8. `frontend client`
- **Definition as stated in the conversation**
  - Browser-side code that performs the HTTP/data fetch from Lean.
- **Synonyms or near-synonyms used**
  - `browser-side API function`
  - `data access`
  - contrasted with `React display`
- **First and last appearance**
  - Introduced by assistant during naming/layer clarification.
  - Last appearance: user asked whether assistant was naming for both frontend client and React display.

### T9. `React display` / `display layer`
- **Definition as stated in the conversation**
  - The portion of the frontend that only renders the fetched data into the UI/table.
- **Synonyms or near-synonyms used**
  - `React component`
  - `display`
  - `show markets`
- **First and last appearance**
  - Introduced by assistant during naming/layer clarification.
  - Last appearance: user `if the front end is just displaying it...`

### T10. `one-liner mature API`
- **Definition as stated in the conversation**
  - A stable canonical API surface, imported/consumed by React, whose result is already decoded, normalized, and constructed by Lean.
- **Synonyms or near-synonyms used**
  - `canonical api`
  - `core of our data`
  - `our portfolio`
  - `our engine in plain sight`
- **First and last appearance**
  - Introduced by the user during the blocker-questions phase.
  - Last appearance: same exchange and later frontend-display clarification.

### T11. `owner`
- **Definition as stated in the conversation**
  - The contextual source / coupling partner for a numeric field; the user said rows/fields should be “coupled to its owner”.
- **Synonyms or near-synonyms used**
  - `provider`
  - `source`
  - `owner like this`
- **First and last appearance**
  - Introduced in the user’s turn about not normalizing everything into one system.
  - Not formally defined elsewhere.

### T12. `unbreakable canonical unit`
- **Definition as stated in the conversation**
  - For frontend-displayed numbers, every provider should have a canonical unit that remains attached so the UI cannot mislabel the value.
- **Synonyms or near-synonyms used**
  - `units and labels`
  - `provider-aware or kind-aware units/labels`
  - `enough canonical meaning`
- **First and last appearance**
  - Introduced in the same user turn as `owner`.
  - Reinforced by assistant in the subsequent reply.

### T13. `CHALLENGER`
- **Definition as stated in the conversation**
  - A role that challenges every claim in `PROPOSAL.md`, does not write code, writes markdown dialogue, and only concedes when there is no remaining winnable challenge and the proposal is aligned with the strictest truth standard.
- **Synonyms or near-synonyms used**
  - None treated as equivalent.
- **First and last appearance**
  - Introduced by the user when assigning the role.
  - Continued through all `PROPOSAL.md` review turns.

## Section 4: Open questions and deferred decisions

### O1. Exact final `Price` structure
- **Question or deferred item**
  - What is the exact final Lean structure for `Price`?
- **Why it was deferred**
  - Multiple versions were discussed and none was finalized:
    - plain `mantissa : Nat, expo : Int`
    - proof-carrying version with `h : mantissa = 0 ∨ mantissa % 10 ≠ 0`
    - user later selected proof-carrying direction, but exact final shape was not fully specified
  - Specific unresolved details remained:
    - canonical zero representation
    - admissible exponent domain
    - whether the invariant is encoded exactly as a proof field or via some other mechanism
- **What would need to happen for it to become a locked decision**
  - A final exact structure would need to be specified and accepted without later challenge.
- **Default behavior proposed in the meantime**
  - Directional default only: `Proof-carrying (Recommended)` was selected by the user.

### O2. Exact final Poly provenance / market identity representation
- **Question or deferred item**
  - What exact type and field set should preserve Poly’s dynamic market identity?
- **Why it was deferred**
  - The user selected `Dynamic market ID`, but the exact representation remained unsettled.
  - Earlier candidates included:
    - `poly : PolyCategory → Provenance`
    - `structure PolyMarketId where conditionId : String`
    - `poly : PolyProvenance → Provenance`
  - None was finalized.
- **What would need to happen for it to become a locked decision**
  - The final exact type would need to be specified, including whether it carries:
    - question/market ID
    - outcome side
    - category
    - any boundary `String`
- **Default behavior proposed in the meantime**
  - The only locked directional default is “preserve the specific dynamic market/question identifier.”

### O3. Exact public API/interface naming and layer naming
- **Question or deferred item**
  - What are the exact names of:
    - the public HTTP route
    - the browser/client retrieval function
    - the React display component
- **Why it was deferred**
  - The assistant tried to force choices such as:
    - `getMarkets`
    - `viewMarkets`
    - `showMarkets`
    - separate naming across layers
  - The user rejected the framing several times and asked what basis naming was being chosen from.
  - The final clarification question about whether data access and rendering should be separated was aborted.
- **What would need to happen for it to become a locked decision**
  - Exact names for each layer must be chosen.
- **Default behavior proposed in the meantime**
  - Assistant recommendation existed (`/markets`, `getMarkets`, `MarketsTable`), but user did not accept it.

### O4. Whether frontend data-access and rendering are separate explicit layers
- **Question or deferred item**
  - Should browser code separate data-access (client/fetch helper) from rendering (React component), or collapse them?
- **Why it was deferred**
  - The assistant asked a final yes/no question about this.
  - The turn was aborted before the user answered.
- **What would need to happen for it to become a locked decision**
  - The user would need to choose between:
    - separate browser-side API function + React table component
    - one component that does both
- **Default behavior proposed in the meantime**
  - Assistant recommendation: separate them.
  - User did not accept or reject because the turn aborted.

### O5. Exact final top-level `Market` field set
- **Question or deferred item**
  - What exact fields belong in the final top-level `Market` structure?
- **Why it was deferred**
  - `Market` as one top-level normalized object was accepted in principle, but its exact field set changed repeatedly:
    - with `provider`
    - without `provider`
    - with `price : Price`
    - with `price : MarketPrice`
    - with `provenance : Nat`
    - with `provenance : Provenance`
  - Because `Price` and Poly provenance remained unresolved, the final `Market` field set was not locked.
- **What would need to happen for it to become a locked decision**
  - Finalize `Price` and Poly provenance, then finalize `Market` without challenge.
- **Default behavior proposed in the meantime**
  - None beyond “one top-level `Market` exists conceptually.”

### O6. Exact UI DTO / frontend projection schema
- **Question or deferred item**
  - What exact schema is emitted from Lean to the browser?
- **Why it was deferred**
  - The user’s DTO proposal had explicit fields (`kind`, `value`, `tick`, `unit`, `id`, `meta`) but was not adopted as final.
  - The assistant approved the architecture, not the exact schema.
- **What would need to happen for it to become a locked decision**
  - A final DTO shape would need to be specified exactly and accepted.
- **Default behavior proposed in the meantime**
  - Architectural default only: one frontend projection / DTO exists.

### O7. Exact browser proof mechanism
- **Question or deferred item**
  - What exact mechanism is used to show the data in the browser now?
- **Why it was deferred**
  - Multiple paths were discussed:
    - Lean-generated HTML
    - Lean JSON + React table
    - HTTP endpoint + React
    - static JSON file
  - The user later allowed React/TypeScript/Vite and then described the desired architecture as Lean-decoded/normalized data consumed by React.
  - Exact artifact/transport remained unresolved.
- **What would need to happen for it to become a locked decision**
  - Choose exact transport:
    - HTTP endpoint
    - generated JSON
    - generated module
    - other exact artifact
- **Default behavior proposed in the meantime**
  - Assistant repeatedly recommended variations, but no final explicit acceptance was recorded.

## Section 5: Rejected proposals

### R1. One untagged shared `Price` type across all venues as the complete normalization answer
- **Proposal**
  - A single shared `Price` based on `mantissa : Nat` and `expo : Int` covers all four providers and is the correct common representation.
- **Who proposed it**
  - Assistant/Claude via `PROPOSAL.md` original text.
- **Why it was rejected**
  - It erased semantic distinctions between perpetual price, index value, and probability-like Poly value.
  - It lacked canonical form.
  - It overstated exactness/precision claims.
- **What replaced it**
  - Semantic tagging via `MarketPrice` (approved subset), plus unresolved stronger internal typing and frontend projection architecture.

### R2. `No floating point. No precision loss. Covers all four cases.` as sufficient justification
- **Proposal**
  - Avoiding floating point was treated as enough to prove exactness and coverage.
- **Who proposed it**
  - Assistant/Claude via original `PROPOSAL.md`.
- **Why it was rejected**
  - Avoiding floating point does not prove semantic preservation, round-trip correctness, or coverage over all provider payloads.
- **What replaced it**
  - No replacement slogan was adopted; the challenge demanded actual invariants and preserved semantics.

### R3. `The last open decision is price`
- **Proposal**
  - `world.lean` defines the provider ontology and the only remaining open decision is the `price` type.
- **Who proposed it**
  - Assistant/Claude via original `PROPOSAL.md`.
- **Why it was rejected**
  - The repo still had other unresolved ontology questions (`Asset`, `Network`, Parcl fields, provider files, Poly identity, etc.).
- **What replaced it**
  - A broader blocked list in later proposal revisions and later narrower blocker framing around nested ontology.

### R4. `normalizePoly : PolyCategory → Market`
- **Proposal**
  - A Poly normalizer can construct a `Market` from `PolyCategory` alone.
- **Who proposed it**
  - Assistant/Claude via original `PROPOSAL.md`.
- **Why it was rejected**
  - `PolyCategory` does not contain market identity, side, or runtime price payload.
- **What replaced it**
  - In `Revision 2`, `normalizePoly : PolyCategory → Probability → Market`.
  - Later that was also rejected as insufficient.

### R5. `provenance : Nat`
- **Proposal**
  - `Market` can preserve traceability with `provenance : Nat`.
- **Who proposed it**
  - Assistant/Claude in `Revision 2`.
- **Why it was rejected**
  - It widened bounded provider-specific identifiers to raw `Nat`, weakening type-level invariants and not preserving the strongest known semantics.
- **What replaced it**
  - `Provenance` tagged inductive in `Revision 3`, though Poly form remained unresolved.

### R6. `poly : PolyCategory → Provenance`
- **Proposal**
  - Poly provenance can be represented by category alone.
- **Who proposed it**
  - Assistant/Claude in `Revision 3`.
- **Why it was rejected**
  - Category alone loses dynamic market identity and is not reconstructible/lossless.
- **What replaced it**
  - Directional replacement: preserve dynamic market ID.
  - Exact final replacement not finalized.

### R7. `structure PolyMarketId where conditionId : String` as an approved final answer
- **Proposal**
  - Poly market identity is a `String` field `conditionId`.
- **Who proposed it**
  - Assistant/Claude in `Revision 3`.
- **Why it was rejected**
  - The `String` justification did not satisfy the repo rule requiring the phrase `This is a closed world so normally...`.
  - It also was not preserved in the final `Market`, so losslessness was still broken.
- **What replaced it**
  - No exact final replacement; only the direction “dynamic market ID must be preserved” was locked.

### R8. `Price` proof field `h : mantissa = 0 ∨ mantissa % 10 ≠ 0` as sufficient canonicalization
- **Proposal**
  - This proof field makes `Price` canonical.
- **Who proposed it**
  - Assistant/Claude in `Revision 3`.
- **Why it was rejected**
  - It permits multiple zero encodings because `mantissa = 0` does not fix `expo`.
- **What replaced it**
  - No exact replacement was finalized.
  - The user later selected proof-carrying `Price` direction, but not this exact invariant.

### R9. `provider` as an explicit top-level `Market` field in the final non-lossy shape
- **Proposal**
  - `Market` includes `provider : Provider`.
- **Who proposed it**
  - Early `Market` versions in the proposal.
- **Why it was rejected**
  - In `Revision 3`, it was explicitly said to be removed because it is determined by provenance.
- **What replaced it**
  - `def Market.provider : Market → Provider` in `Revision 3`
  - However, the final exact `Market` remained unresolved.

### R10. Lean-generated HTML as the only browser proof path
- **Proposal**
  - Under the earlier “using only lean” framing, the assistant proposed generating `out/index.html` directly from Lean.
- **Who proposed it**
  - Assistant.
- **Why it was rejected**
  - Not explicitly rejected at the moment, but superseded after the user said React/TypeScript/Vite can be installed and after the user described the desired architecture as React consuming a canonical Lean API.
- **What replaced it**
  - Lean-decoded/normalized canonical API consumed by React.

### R11. Original `PROPOSAL.md Revision 1` as final
- **Proposal**
  - The original proposal with one shared `Price`, one generic `Market`, and the original normalizer signatures.
- **Who proposed it**
  - Assistant/Claude via `PROPOSAL.md`.
- **Why it was rejected**
  - See D6 and R1–R4.
- **What replaced it**
  - `Revision 2`, then `Revision 3`, neither of which was conceded.

### R12. `Revision 2` as final
- **Proposal**
  - `Revision 2` claimed to fix the original challenger objections.
- **Who proposed it**
  - Assistant/Claude via pasted diff and file rewrite.
- **Why it was rejected**
  - See D8:
    - canonicality still not in the type
    - zero case incomplete
    - `provenance : Nat` too weak
    - Poly identity still missing
    - `normalizePoly` still insufficient
- **What replaced it**
  - `Revision 3`, later also rejected.

### R13. `Revision 3 — Final` as final
- **Proposal**
  - `Revision 3` claimed to fix all remaining challenger rejections.
- **Who proposed it**
  - Assistant/Claude via `PROPOSAL.md`.
- **Why it was rejected**
  - See D9:
    - `Price` still not canonical
    - Poly identity still lost
    - `normalizePoly` inconsistent with `Provenance.poly`
    - `String` justification non-compliant
- **What replaced it**
  - No final conceded proposal; state remained unresolved.

### R14. `Category only` for Poly identity
- **Proposal**
  - Preserve only `PolyCategory`.
- **Who proposed it**
  - Presented by assistant in multiple-choice options.
- **Why it was rejected**
  - User selected `Dynamic market ID` instead.
- **What replaced it**
  - Directional requirement to preserve dynamic market ID.

### R15. `Category + side` for Poly identity
- **Proposal**
  - Preserve category and side but not the specific market/question identifier.
- **Who proposed it**
  - Presented by assistant in multiple-choice options.
- **Why it was rejected**
  - User selected `Dynamic market ID` instead.
- **What replaced it**
  - Directional requirement to preserve dynamic market ID.

### R16. `Plain mantissa/expo` and `Provider-scaled only` as the selected `Price` direction
- **Proposal**
  - Use either a plain `mantissa/expo` by convention, or avoid a shared `Price` entirely and keep only provider-specific fixed-scale types.
- **Who proposed it**
  - Presented by assistant in multiple-choice options.
- **Why it was rejected**
  - User selected `Proof-carrying (Recommended)`.
- **What replaced it**
  - Directional choice of proof-carrying `Price` (exact final structure unresolved).

### R17. `getMarkets`, `viewMarkets`, `showMarkets`, separate-layer naming, or display-first naming as finalized names
- **Proposal**
  - Various naming options for API surface and UI layers.
- **Who proposed it**
  - Assistant in the blocker-question phase.
- **Why it was rejected**
  - The user repeatedly rejected the framing and asked what basis the naming choice was being made on.
  - No option was accepted.
- **What replaced it**
  - Nothing finalized.

## Section 6: Implicit assumptions

### I1. The target output is for a browser-visible table
- **Implicit assumption**
  - The immediate proof target is something viewable “right now in my browser.”
- **Evidence**
  - User asked how to “render a table to prove that we can render a table of all these assets”
  - User later allowed React/TypeScript/Vite.
- **Was it ever explicitly committed to?**
  - The browser target was explicit.
  - The exact transport and rendering architecture were not fully explicit/finalized.

### I2. Lean remains the authoritative source of truth/backend layer
- **Implicit assumption**
  - Lean owns domain truth and upstream processing.
- **Evidence**
  - README says backend service built with Lean.
  - User later explicitly said Lean handles decoding, normalization, and construction.
  - React is downstream.
- **Was it ever explicitly committed to?**
  - Yes in architectural phrasing, though the exact HTTP/static artifact was not finalized.

### I3. React/TypeScript/Vite are the frontend technology stack once browser proof moves beyond Lean-only
- **Implicit assumption**
  - Frontend will be built with React/TypeScript/Vite, matching README intent and user permission.
- **Evidence**
  - README: `Frontend planned as TypeScript with React, Vite, Zustand, and Zod.`
  - User: `We can install and set up React, TypeScript, Vite.`
- **Was it ever explicitly committed to?**
  - React, TypeScript, Vite: explicit.
  - Zustand and Zod: implicit from README only, never explicitly recommitted in the conversation.

### I4. The frontend must not infer semantics from raw digits alone
- **Implicit assumption**
  - UI bugs arise if the frontend only sees `0.57` without kind/unit/provider meaning.
- **Evidence**
  - Discussion of mislabeling Poly `0.57` as `$0.57`, or treating probabilities, index levels, and quote prices as the same.
  - User’s later statement about coupling every displayed number to provider and canonical unit.
- **Was it ever explicitly committed to?**
  - Yes in outcome terms, though not formalized as code.

### I5. Provider/kind-aware units and labels are part of the canonical meaning attached to displayed values
- **Implicit assumption**
  - Every displayed value needs enough attached information that the UI cannot mislabel it.
- **Evidence**
  - User’s explicit statement about units, labels, provider, and canonical unit.
- **Was it ever explicitly committed to?**
  - Yes, explicitly by the user and confirmed by the assistant.

### I6. The frontend projection is flatter and less ontologically strict than the Lean core
- **Implicit assumption**
  - There is a distinction between the proof-oriented core model and the UI/API-facing transport/view model.
- **Evidence**
  - Assistant’s definition of `DTO`.
  - Assistant’s approval of “many exact internal types, one flat frontend projection.”
- **Was it ever explicitly committed to?**
  - Yes as architecture, though exact DTO schema remained unresolved.

### I7. The frontend/display layer is not responsible for venue-specific decoding/normalization logic
- **Implicit assumption**
  - React/browser should render already-normalized data, not parse venue-specific execution payloads or source representations.
- **Evidence**
  - User’s statement that Lean handles decoding, normalization, and construction, and React imports the result.
  - User’s statement that frontend is “just displaying.”
- **Was it ever explicitly committed to?**
  - Yes in broad responsibility terms.
  - Exact browser/client split remained unresolved.

### I8. The work is being treated as permanent architecture, not a demo/happy-path proof
- **Implicit assumption**
  - The user wants “permanence,” “hierarchical and ontological finality,” “no happy path,” and “zero chance of moving forward when there is an incomplete decision or implementation inference.”
- **Evidence**
  - User’s turn asking how to turn this into code and render a table, emphasizing permanence and zero inference tolerance.
- **Was it ever explicitly committed to?**
  - Yes, explicitly.

### I9. There is no active authentication/session/user-model scope in the current design conversation
- **Implicit assumption**
  - The browser/API architecture under discussion is public data rendering for “any website visitor”.
- **Evidence**
  - User called it the canonical API that will render markets for any website visitor.
- **Was it ever explicitly committed to?**
  - Public-visitor phrasing was explicit.
  - No auth model was discussed.

## Section 7: Unresolved contradictions

### C1. `Revision 3` claimed all remaining challenger rejections were fixed, but the later final challenger call explicitly rejected it
- **Conflicting statements**
  - In `PROPOSAL.md Revision 3`: `### Fixes addressing all remaining challenger rejections`
  - Later final challenger call written into `PROPOSAL.md`: `Rejected. Not conceded.`
- **Conflict**
  - The proposal text claims completion; the final review says completion was not reached.
- **Status**
  - Unresolved inside the conversation; the challenger judgment is later in time but the contradiction remains in the file history.

### C2. `Price` was said to be “resolved” in one place and unresolved in another
- **Conflicting statements**
  - User during blocker MCQ answer: `idk i thought that you said price was resolved ?`
  - Assistant clarified: `Price was not fully resolved before; the unresolved part was whether canonicality is enforced in the type or only by convention.`
  - Earlier assistant had also output a “complete expected entire output” that included a concrete `Price` shape.
- **Conflict**
  - The conversation contains both a concrete output shape for `Price` and repeated statements that `Price` is still not finalized.
- **Status**
  - Unresolved; exact final `Price` remained open.

### C3. The user said both that `price works` and that the design may really be about `value`
- **Conflicting statements**
  - User: `maybe value is the right word and price is a different word`
  - Later user: `I would definitely say that price works, because they're literally saying price works.`
- **Conflict**
  - The user explored a broader term and later accepted `price`.
- **Status**
  - Partially resolved in practice toward `price`, but the conversation never explicitly retired the broader `value` exploration. This remains a vocabulary tension.

### C4. The user said “I do want one generic price” and later “This isn't about normalizing everything into one system”
- **Conflicting statements**
  - User: `Well, no, I do want one generic price...`
  - Later user: `This isn't about normalizing everything into one system; then it sounds like we don't have to do that at all.`
- **Conflict**
  - One statement pushes toward a generic price; the later one rejects full normalization into one system.
- **Status**
  - The later UI-coupling formulation superseded the earlier push, but the contradiction itself was never explicitly reconciled by the user.

### C5. The assistant stated some code shapes as “approved/not approved” and later printed a “complete expected entire output” that included unresolved pieces
- **Conflicting statements**
  - Approved/not-approved answer said:
    - `Price` not approved as final
    - `Market` not approved as final
    - `Provenance.poly` unresolved
  - Later assistant output:
    ```lean
    structure Market where ...
    structure Price where ...
    inductive Provenance where
      ...
      | poly  : PolyProvenance              → Provenance
    ```
- **Conflict**
  - The later “complete expected entire output” reads like a complete artifact despite earlier statements that those exact pieces were unresolved.
- **Status**
  - Unresolved; the later output was not explicitly accepted by the user as a final ontology lock.

## Section 8: Out-of-scope mentions

### OOS1. GitHub commit/authorship/attestation requirements from `AGENTS.md`
- **What was mentioned**
  - `GH commits require authorship and attestation... MUST sign model name and provider.`
- **Why it is out of scope**
  - These repo instructions were read and cited for formal rigor, but no GitHub commit or attestation workflow was part of the architecture decisions being extracted.

### OOS2. UI color / URL / display-only concerns from repo notes
- **What was mentioned**
  - In `LOCKED.md` / `OPEN.md`, color and URL were described as UI concerns / out of scope.
- **Why it is out of scope**
  - They were repo facts, not current design decisions in the conversation.

### OOS3. External systems used for comparison only
- **What was mentioned**
  - Ethereum / Solidity / Dafny
  - Hyperliquid
  - public exchanges
  - FIX
  - Chainlink / Pyth / Binance / Bybit / Kraken context
- **Why it is out of scope**
  - These were consulted for evidence/comparison on numeric representation and semantics, not adopted as direct implementation artifacts in this project.

### OOS4. Zustand and Zod
- **What was mentioned**
  - README says frontend planned as TypeScript with React, Vite, Zustand, and Zod.
- **Why it is out of scope**
  - The user later explicitly allowed React/TypeScript/Vite, but no design decision in the conversation adopted Zustand or Zod.

### OOS5. Lean-generated HTML proof path after React/TypeScript/Vite became allowed
- **What was mentioned**
  - Assistant proposed a Lean-only generated HTML output path when the user had asked for “using only lean.”
- **Why it is out of scope**
  - Later conversation shifted to a React frontend consuming Lean’s canonical API; the Lean-generated HTML path became superseded rather than pursued.

### OOS6. Implementation spec itself
- **What was mentioned**
  - The final user instruction explicitly said: a separate process will produce the implementation spec; the current task is extraction only.
- **Why it is out of scope**
  - This extraction is upstream of synthesis/recommendation/spec-writing and does not itself define the implementation plan.
