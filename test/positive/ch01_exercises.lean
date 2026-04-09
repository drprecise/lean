-- ch01_exercises.lean
-- Positive Numbers — p. 117 Exercises
-- Verified: lean test/positive/ch01_exercises.lean && lean --run test/positive/ch01_exercises.lean

-- ─────────────────────────────────────────────
-- Exercise 1: Pos as successor of Nat
-- ─────────────────────────────────────────────

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

-- There is no OfNat Pos 0 instance — zero is not positive.

#eval (1 : Pos)                        -- 1
#eval (1 : Pos) + (1 : Pos)           -- 2
#eval (2 : Pos) * (3 : Pos)           -- 6
#eval toString (5 : Pos)               -- "5"

-- ─────────────────────────────────────────────
-- Exercise 2: Even Numbers
-- ─────────────────────────────────────────────

structure Even where
  half : Nat

instance : ToString Even where
  toString x := toString (x.half * 2)

instance : Add Even where
  add x y := ⟨x.half + y.half⟩

instance : Mul Even where
  mul x y := ⟨x.half * y.half * 2⟩

-- No OfNat Even instance — requires features from the next section.
-- 1 : Even must not exist. Examples use struct syntax directly.

#eval toString ({ half := 3 } : Even)                              -- "6"
#eval toString (({ half := 1 } : Even) + { half := 2 })           -- "6"
#eval toString (({ half := 2 } : Even) * { half := 3 })           -- "24"

-- ─────────────────────────────────────────────
-- Exercise 3: HTTP Requests
-- ─────────────────────────────────────────────

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

instance : HTTPAction .GET where
  call req := pure ⟨200, s!"GET {req.uri}"⟩

instance : HTTPAction .POST where
  call req := pure ⟨201, s!"POST {req.uri}"⟩

instance : HTTPAction .PUT where
  call req := pure ⟨200, s!"PUT {req.uri}"⟩

instance : HTTPAction .DELETE where
  call req := pure ⟨204, s!"DELETE {req.uri}"⟩

def main : IO Unit := do
  let g ← HTTPAction.call (m := .GET)    { method := .GET,    uri := "/api/markets",   version := .HTTP1_1 }
  let p ← HTTPAction.call (m := .POST)   { method := .POST,   uri := "/api/markets",   version := .HTTP1_1 }
  let u ← HTTPAction.call (m := .PUT)    { method := .PUT,    uri := "/api/markets/1", version := .HTTP1_1 }
  let d ← HTTPAction.call (m := .DELETE) { method := .DELETE, uri := "/api/markets/1", version := .HTTP1_1 }
  IO.println (toString g)
  IO.println (toString p)
  IO.println (toString u)
  IO.println (toString d)
