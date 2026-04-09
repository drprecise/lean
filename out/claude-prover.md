# claude-prover

## Expressions — Chapter 1 Exercises

---

### 1. `42 + 19`

**By hand:**
```
42 + 19
===>
61
```

**Lean:**
```lean
#eval 42 + 19  -- 61
```

---

### 2. `String.append "A" (String.append "B" "C")`

**By hand:**
```
String.append "A" (String.append "B" "C")
===>
String.append "A" "BC"
===>
"ABC"
```

**Lean:**
```lean
#eval String.append "A" (String.append "B" "C")  -- "ABC"
```

---

### 3. `String.append (String.append "A" "B") "C"`

**By hand:**
```
String.append (String.append "A" "B") "C"
===>
String.append "AB" "C"
===>
"ABC"
```

**Lean:**
```lean
#eval String.append (String.append "A" "B") "C"  -- "ABC"
```

> **2 vs 3:** same result, different evaluation order — inner append resolves first in both cases, left-nested vs right-nested. `String.append` is associative over strings.

---

### 4. `if 3 == 3 then 5 else 7`

**By hand:**
```
if 3 == 3 then 5 else 7
===>
if true then 5 else 7
===>
5
```

**Lean:**
```lean
#eval if 3 == 3 then 5 else 7  -- 5
```

---

### 5. `if 3 == 4 then "equal" else "not equal"`

**By hand:**
```
if 3 == 4 then "equal" else "not equal"
===>
if false then "equal" else "not equal"
===>
"not equal"
```

**Lean:**
```lean
#eval if 3 == 4 then "equal" else "not equal"  -- "not equal"
```

---

## Summary

| expression | value |
|------------|-------|
| `42 + 19` | `61` |
| `String.append "A" (String.append "B" "C")` | `"ABC"` |
| `String.append (String.append "A" "B") "C"` | `"ABC"` |
| `if 3 == 3 then 5 else 7` | `5` |
| `if 3 == 4 then "equal" else "not equal"` | `"not equal"` |

---

## Positive Numbers — p. 117 Exercises

### Exercise 1: `Pos` as successor of `Nat`

**Problem:** Replace `Pos` with a structure whose constructor is `succ` containing a `Nat` called `pred`. Define `Add`, `Mul`, `ToString`, `OfNat`.

**Reasoning:**

`Pos` represents positive integers (1, 2, 3, ...).
If we store `pred : Nat`, then the actual value is `pred + 1`.
- `pred = 0` means the number is `1`
- `pred = 1` means the number is `2`
- `pred = n` means the number is `n + 1`

This guarantees positivity — there is no way to construct a zero or negative.

**Structure:**
```lean
structure Pos where
  succ ::
  pred : Nat
```

**Add:**
```
(a + 1) + (b + 1) = a + b + 2 = (a + b + 1) + 1
so pred of result = a.pred + b.pred + 1
```
```lean
instance : Add Pos where
  add x y := ⟨x.pred + y.pred + 1⟩
```

**Mul:**
```
(a + 1) * (b + 1) = ab + a + b + 1
so pred of result = a.pred * b.pred + a.pred + b.pred
```
```lean
instance : Mul Pos where
  mul x y := ⟨x.pred * y.pred + x.pred + y.pred⟩
```

**ToString:** display the actual value, not the pred
```lean
instance : ToString Pos where
  toString x := toString (x.pred + 1)
```

**OfNat:** literal `n + 1` maps to `pred = n` — there is no `OfNat Pos 0` instance
```lean
instance : OfNat Pos (n + 1) where
  ofNat := ⟨n⟩
```

**Verification by hand:**
```
1 + 1 = 2
⟨0⟩ + ⟨0⟩ = ⟨0 + 0 + 1⟩ = ⟨1⟩ = 2 ✓

2 * 3 = 6
⟨1⟩ * ⟨2⟩ = ⟨1*2 + 1 + 2⟩ = ⟨5⟩ = 6 ✓

toString 3 = "3"
⟨2⟩.pred + 1 = 3 → "3" ✓
```

**Lean output:**
```
(1 : Pos)          → 1
(1 : Pos) + 1      → 2
(2 : Pos) * 3      → 6
toString (5 : Pos) → "5"
```

---

### Exercise 2: Even Numbers

**Problem:** Define a datatype that represents only even numbers. Define `ToString`, `Add`, `Mul`.

**Reasoning:**

Store `half : Nat` — the actual value is `half * 2`. Zero is even and included.
- `half = 0` → 0
- `half = 1` → 2
- `half = 3` → 6

No `OfNat Even` instance — that requires features from the next section. Examples use struct syntax directly. `1 : Even` does not exist and must not.

Addition: `(2a) + (2b) = 2(a+b)` → halves add directly.
Multiplication: `(2a) * (2b) = 4ab = 2(2ab)` → half of result is `2ab`.

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

**Verification by hand:**
```
{ half := 3 }                              → "6"   (3*2=6) ✓
{ half := 1 } + { half := 2 } = { half := 3 } → "6" ✓
{ half := 2 } * { half := 3 } = { half := 12 } → "24" (2*2*3*2=24) ✓
```

**Lean output:**
```
toString { half := 3 }                         → "6"
{ half := 1 } + { half := 2 } (as Even)       → "6"
{ half := 2 } * { half := 3 } (as Even)       → "24"
```

---

### Exercise 3: HTTP Requests

**Problem:** Define an inductive for HTTP methods, a structure for responses with `ToString`, and a type class associating IO actions with each method. Write a test harness. An HTTP request includes method, URI, and HTTP version.

**Reasoning:**

`HTTPMethod` — closed inductive, finite known set.
`HTTPVersion` — closed inductive, finite known set.
`HTTPRequest` — carries method, URI (String — external input), version.
`HTTPResponse` — carries status and body.
Type class `HTTPAction (m : HTTPMethod)` — each method gets its own instance. Action takes the full request so it can depend on URI and version, not just method.

```lean
inductive HTTPMethod where
  | GET | POST | PUT | DELETE
  deriving Repr

inductive HTTPVersion where
  | HTTP1_0 | HTTP1_1 | HTTP2_0
  deriving Repr

structure HTTPRequest where
  method  : HTTPMethod
  uri     : String
  version : HTTPVersion

structure HTTPResponse where
  status : Nat
  body   : String

instance : ToString HTTPResponse where
  toString r := s!"HTTP {r.status}\n{r.body}"

class HTTPAction (m : HTTPMethod) where
  call : HTTPRequest → IO HTTPResponse

instance : HTTPAction .GET    where call req := pure ⟨200, s!"GET {req.uri}"⟩
instance : HTTPAction .POST   where call req := pure ⟨201, s!"POST {req.uri}"⟩
instance : HTTPAction .PUT    where call req := pure ⟨200, s!"PUT {req.uri}"⟩
instance : HTTPAction .DELETE where call req := pure ⟨204, s!"DELETE {req.uri}"⟩

def main : IO Unit := do
  let g ← HTTPAction.call (m := .GET)    { method := .GET,    uri := "/api/markets",   version := .HTTP1_1 }
  let p ← HTTPAction.call (m := .POST)   { method := .POST,   uri := "/api/markets",   version := .HTTP1_1 }
  let u ← HTTPAction.call (m := .PUT)    { method := .PUT,    uri := "/api/markets/1", version := .HTTP1_1 }
  let d ← HTTPAction.call (m := .DELETE) { method := .DELETE, uri := "/api/markets/1", version := .HTTP1_1 }
  IO.println (toString g)
  IO.println (toString p)
  IO.println (toString u)
  IO.println (toString d)
```

**Lean output:**
```
HTTP 200
GET /api/markets
HTTP 201
POST /api/markets
HTTP 200
PUT /api/markets/1
HTTP 204
DELETE /api/markets/1
```
