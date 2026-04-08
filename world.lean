-- world.lean
-- Foundational ontology: Asset → Provider → ProviderAsset → [DriftAsset | GainsAsset | ParclAsset | PolyAsset]

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

-- 4. Provider-specific category systems

inductive GainsCategory where
  | Crypto
  | Forex
  | Stocks
  | Commodities
  | Indices
  deriving DecidableEq, Repr

inductive PolyCategory where
  | Politics
  | Sports
  | Weather
  | Economics
  | Entertainment
  | Science
  deriving DecidableEq, Repr

-- 5. Universal parent — the deed
structure ProviderAsset where
  asset      : Asset
  provider   : Provider
  network    : Network
  quoteAsset : QuoteAsset
  leverage   : Option Leverage
  deriving DecidableEq, Repr

-- 6. Provider children — each signs the deed and adds only what it brings

structure DriftAsset extends ProviderAsset where
  marketIndex : Fin 86
  deriving DecidableEq, Repr

structure GainsAsset extends ProviderAsset where
  category : GainsCategory
  deriving DecidableEq, Repr

structure ParclAsset extends ProviderAsset where
  -- provider-specific fields TBD pending Parcl source data
  deriving DecidableEq, Repr

structure PolyAsset extends ProviderAsset where
  category : PolyCategory
  deriving DecidableEq, Repr
