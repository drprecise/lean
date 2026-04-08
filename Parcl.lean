-- Parcl type definitions
-- Source: out/next-normalization-inputs/parcl/normalization.json
-- Source: out/next-normalization-inputs/parcl/exchange.json
-- Source: out/next-normalization-inputs/parcl/market-example-1.json
-- Chain: Solana. Collateral: USDC.

inductive ParcLocation where
  | newYork             -- marketId 1
  | miamiBeach          -- marketId 2
  | sanFrancisco        -- marketId 3
  | austin              -- marketId 4
  | lasVegas            -- marketId 5
  | brooklyn            -- marketId 6
  | losAngeles          -- marketId 7
  | chicago             -- marketId 8
  | atlanta             -- marketId 9
  | denver              -- marketId 10
  | washington          -- marketId 11
  | boston               -- marketId 12
  | unitedStates        -- marketId 13
  | sanDiego            -- marketId 14
  | miami               -- marketId 15
  | unitedStatesRental  -- marketId 16
  | chicagoRental       -- marketId 17
  | denverRental        -- marketId 18
  | pittsburgh          -- marketId 19
  | bostonRental        -- marketId 20
  | brooklynRental      -- marketId 21
  | charlotte           -- marketId 25
  | tampa               -- marketId 26
  | nashville           -- marketId 27
  -- upcoming (not yet on-chain)
  | dallas              -- parclId 5381001
  | dubai               -- parclId 5950324
  | houston             -- parclId 5381035
  | philadelphia        -- parclId 5378051
  | phoenix             -- parclId 5386820
  | portland            -- parclId 5408016
  | seattle             -- parclId 5384705
  | solanaBeach         -- parclId 5374219
  deriving DecidableEq, Repr

def ParcLocation.marketId : ParcLocation -> Option Nat
  | .newYork            => some 1
  | .miamiBeach         => some 2
  | .sanFrancisco       => some 3
  | .austin             => some 4
  | .lasVegas           => some 5
  | .brooklyn           => some 6
  | .losAngeles         => some 7
  | .chicago            => some 8
  | .atlanta            => some 9
  | .denver             => some 10
  | .washington         => some 11
  | .boston              => some 12
  | .unitedStates       => some 13
  | .sanDiego           => some 14
  | .miami              => some 15
  | .unitedStatesRental => some 16
  | .chicagoRental      => some 17
  | .denverRental       => some 18
  | .pittsburgh         => some 19
  | .bostonRental       => some 20
  | .brooklynRental     => some 21
  | .charlotte          => some 25
  | .tampa              => some 26
  | .nashville          => some 27
  | .dallas             => none
  | .dubai              => none
  | .houston            => none
  | .philadelphia       => none
  | .phoenix            => none
  | .portland           => none
  | .seattle            => none
  | .solanaBeach        => none

structure ParclExchangeSettings where
  collateralMint    : String   -- EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
  collateralExpo    : Int      -- -6
  protocolFeeRate   : Nat      -- 2000
  settlementDelay   : Nat      -- 86400 seconds
  minLpDuration     : Nat      -- 2592000 seconds
  lockedOiRatio     : Nat      -- 1500
  deriving Repr

structure ParclMarketSettings where
  initialMarginRatio          : Nat  -- 20000 (= 5x max leverage)
  minInitialMarginRatio       : Nat  -- 500
  maintenanceMarginProportion : Nat  -- 8000
  makerFeeRate                : Nat  -- 40 bps
  takerFeeRate                : Nat  -- 60 bps
  liquidationFeeRate          : Nat  -- 1
  minPositionMargin           : Nat  -- 500000 (0.50 USDC)
  maxSideSize                 : Nat  -- varies per market
  skewScale                   : Nat  -- varies per market
  deriving Repr

structure ParclOrder where
  marketId        : Nat
  marginAccount   : String
  sizeDelta       : Int      -- positive = long, negative = short
  acceptablePrice : Nat
  deriving Repr
