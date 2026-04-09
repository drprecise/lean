-- world.lean
-- Foundational ontology: Asset → Provider → ProviderAsset → [DriftAsset | GainsAsset | ParclAsset | PolyAsset]


----#######################################################################################################
----#######################################################################################################
----- GLOBAL SECTION ------------------------------------------------------------------------------------------------
----#######################################################################################################
----#######################################################################################################


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

-- 4. Universal parent — the deed
structure ProviderAsset where
  asset      : Asset
  provider   : Provider
  network    : Network
  quoteAsset : QuoteAsset
  leverage   : Option Leverage
  deriving DecidableEq, Repr


----#######################################################################################################
----#######################################################################################################
----- PARCL SECTION ------------------------------------------------------------------------------------------------
----#######################################################################################################
----#######################################################################################################

inductive ParclLocationType where
  | City | County | Country | NA
  deriving DecidableEq, Repr

structure ParclAsset extends ProviderAsset where
  marketId     : Fin 28
  locationType : ParclLocationType
  deriving DecidableEq, Repr


----#######################################################################################################
----#######################################################################################################
----- DRIFT SECTION ------------------------------------------------------------------------------------------------
----#######################################################################################################
----#######################################################################################################

structure DriftAsset extends ProviderAsset where
  marketIndex : Fin 86
  deriving DecidableEq, Repr


----#######################################################################################################
----#######################################################################################################
----- GAINS SECTION ------------------------------------------------------------------------------------------------
----#######################################################################################################
----#######################################################################################################

inductive GainsCategory where
  | Crypto
  | Forex
  | Stocks
  | Commodities
  | Indices
  deriving DecidableEq, Repr

structure GainsAsset extends ProviderAsset where
  pairIndex : Fin 452
  category  : GainsCategory
  deriving DecidableEq, Repr


----#######################################################################################################
----#######################################################################################################
----- POLY SECTION ------------------------------------------------------------------------------------------------
----#######################################################################################################
----#######################################################################################################

inductive PolyCategory where
  | Politics
  | Sports
  | Weather
  | Economics
  | Entertainment
  | Science
  deriving DecidableEq, Repr

structure PolyAsset extends ProviderAsset where
  category : PolyCategory
  deriving DecidableEq, Repr
