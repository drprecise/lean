import CoinchipLiveMarkets

def countProvider (rows : List MarketRow) (provider : String) : Nat :=
  rows.foldl (fun acc row => if row.provider = provider then acc + 1 else acc) 0

def main : IO Unit := do
  let rows <- getMarkets
  IO.println s!"total={rows.length}"
  IO.println s!"drift={countProvider rows "drift"}"
  IO.println s!"gains={countProvider rows "gains"}"
  IO.println s!"parcl={countProvider rows "parcl"}"
  IO.println s!"polymarket={countProvider rows "polymarket"}"
  IO.println s!"sample={rows.take 5}"
