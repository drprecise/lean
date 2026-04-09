  inductive Asset where
    | SOL | BTC | ETH | APT | ARB
    | DOGE | BNB | SUI | XRP | LINK

  inductive ActionableNetwork where
    | bitcoin | ethereum | solana | arbitrum | polygon | base

  inductive Venue where
    | Drift | Gains | Parcl | Poly

  def Venue.actionableNetwork : Venue → ActionableNetwork
    | .Drift => .solana
    | .Gains => .arbitrum
    | .Parcl => .solana
    | .Poly  => .polygon

  structure ActionableAsset where
    asset : Asset
    venue : Venue