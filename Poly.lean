-- Polymarket type definitions
-- Source: out/next-normalization-inputs/polymarket/normalization.json
-- Source: out/next-normalization-inputs/polymarket/markets-sample.json
-- Polymarket is a prediction market, not a derivatives exchange.
-- No leverage, no margin, no funding. Positions are outcome shares.

structure PolyMarket where
  id                  : String
  question            : String
  slug                : String
  conditionId         : String
  outcomes            : String   -- JSON array e.g. "[\"Yes\",\"No\"]"
  outcomePrices       : String   -- JSON array e.g. "[\"0.65\",\"0.35\"]"
  clobTokenIds        : String   -- JSON array of CLOB token IDs
  active              : Bool
  closed              : Bool
  archived            : Bool
  acceptingOrders     : Bool
  enableOrderBook     : Bool
  orderPriceMinTickSize : Float
  orderMinSize        : Float
  negRisk             : Bool
  endDate             : String
  volume              : String
  liquidity           : String
  deriving Repr

inductive PolySide where
  | buy
  | sell
  deriving DecidableEq, Repr

inductive PolyOrderType where
  | gtc   -- good til cancelled
  | fok   -- fill or kill
  | gtd   -- good til date
  deriving DecidableEq, Repr

structure PolyOrder where
  tokenId       : String    -- from market.clobTokenIds
  price         : Float     -- 0.00 to 1.00
  size          : Float     -- number of shares
  side          : PolySide
  orderType     : PolyOrderType
  signatureType : Nat       -- 0 = EOA, 1 = Magic/Email
  deriving Repr
