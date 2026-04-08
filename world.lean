-- world.lean
-- Foundational ontology: CanonicalAsset → Provider → ProviderAsset

-- 1. The thing itself
inductive Asset where
  | SOL | BTC | ETH | APT | ARB
  | DOGE | BNB | SUI | XRP | LINK
  deriving DecidableEq, Repr

-- 2. The source
inductive Provider where
  | Drift
  | Gains
  | Parcl
  | Poly
  deriving DecidableEq, Repr

-- 3. Supporting closed types

inductive Network where
  | Solana
  | Ethereum
  | Arbitrum
  | Polygon
  | BNBChain
  deriving DecidableEq, Repr

inductive QuoteAsset where
  | USDC
  | USD
  | USDT
  deriving DecidableEq, Repr

inductive Leverage where
  | x2 | x4 | x5 | x10 | x20
  deriving DecidableEq, Repr

-- 4. The thing as offered by the source
structure ProviderAsset where
  asset      : Asset
  provider   : Provider
  network    : Network
  quoteAsset : QuoteAsset
  leverage   : Option Leverage
  deriving DecidableEq, Repr
