import Lean
import Lean.Data.Json

open Lean

structure MarketRow where
  name : String
  asset_symbol : String
  provider : String
  price : Float
  unit : String
  info : String
  deriving Repr

inductive Provider where
  | Drift
  | Gains
  | Parcl
  | Poly
  deriving DecidableEq, Repr

def Provider.toWire : Provider → String
  | .Drift => "drift"
  | .Gains => "gains"
  | .Parcl => "parcl"
  | .Poly => "polymarket"

inductive HttpsMethod where
  | GET
  | POST
  deriving DecidableEq, Repr

structure HttpsHeader where
  name : String
  value : String
  deriving Repr

structure HttpsQueryParam where
  key : String
  value : String
  deriving Repr

structure HttpsRequest where
  method : HttpsMethod
  url : String
  query : List HttpsQueryParam := []
  headers : List HttpsHeader := []
  body? : Option Lean.Json := none

def parclUsdcExchangeId : Nat := 0
-- Parcl docs identify exchange ID 0 as the live USDC exchange.

def polymarketDefaultPageSize : Nat := 100
def polymarketDefaultMaxPages : Nat := 50

private def ioFail {α : Type} (message : String) : IO α :=
  throw <| IO.userError message

private def exceptToIO {α : Type} (value : Except String α) : IO α :=
  match value with
  | .ok result => pure result
  | .error message => ioFail message

private def parseJsonString (raw : String) : IO Json :=
  exceptToIO <| Json.parse raw

private def pow10 : Nat → Float
  | 0 => 1.0
  | n + 1 => 10.0 * pow10 n

private def parseFloatText (text : String) : Except String Float :=
  match Json.parse text with
  | .ok json =>
      match json.getNum? with
      | .ok number => .ok number.toFloat
      | .error _ => .error s!"expected numeric JSON text, got: {text}"
  | .error _ => .error s!"expected numeric JSON text, got: {text}"

private def parseNatText (text : String) : Except String Nat :=
  match text.toNat? with
  | some value => .ok value
  | none => .error s!"expected natural number text, got: {text}"

private def applyExponent (mantissa : Float) (expo : Int) : Float :=
  if expo < 0 then
    mantissa / pow10 expo.natAbs
  else
    mantissa * pow10 expo.toNat

private def asString (json : Json) : Except String String :=
  json.getStr?

private def asBool (json : Json) : Except String Bool :=
  json.getBool?

private def asNat (json : Json) : Except String Nat := do
  parseNatText json.compress

private def parseIntText (text : String) : Except String Int :=
  match text.toList with
  | [] => .error "expected integer text"
  | '-' :: rest =>
      match String.ofList rest |>.toNat? with
      | some value => .ok (- Int.ofNat value)
      | none => .error s!"expected integer text, got: {text}"
  | _ =>
      match text.toNat? with
      | some value => .ok (Int.ofNat value)
      | none => .error s!"expected integer text, got: {text}"

private def asInt (json : Json) : Except String Int := do
  parseIntText json.compress

private def asFloat (json : Json) : Except String Float := do
  let number <- json.getNum?
  .ok number.toFloat

private def asFloatTextField (json : Json) (field : String) : Except String Float := do
  let raw <- json.getObjVal? field >>= asString
  parseFloatText raw

private def asNatTextField (json : Json) (field : String) : Except String Nat := do
  let raw <- json.getObjVal? field >>= asString
  parseNatText raw

private def asOptionalStringField (json : Json) (field : String) : Except String (Option String) :=
  match json.getObjVal? field with
  | .ok value => do
      let text <- asString value
      .ok (some text)
  | .error _ => .ok none

private def asArray (json : Json) : Except String (Array Json) :=
  json.getArr?

private def decodeList {α : Type} (json : Json) (decode : Json → Except String α) : Except String (List α) := do
  let items <- asArray json
  items.toList.mapM decode

private def isAsciiAlphaNum (c : Char) : Bool :=
  let n := c.toNat
  (48 ≤ n && n ≤ 57) || (65 ≤ n && n ≤ 90) || (97 ≤ n && n ≤ 122)

private def isUnreserved (c : Char) : Bool :=
  isAsciiAlphaNum c || c = '-' || c = '_' || c = '.' || c = '~'

private def hexDigit (n : Nat) : Char :=
  if n < 10 then
    Char.ofNat (48 + n)
  else
    Char.ofNat (55 + n)

private def percentEncodeByte (n : Nat) : String :=
  String.ofList ['%', hexDigit (n / 16), hexDigit (n % 16)]

private def urlEncode (text : String) : String :=
  text.toList.foldl
    (fun acc c =>
      if isUnreserved c then
        acc ++ String.singleton c
      else
        acc ++ percentEncodeByte c.toNat)
    ""

private def renderQuery (query : List HttpsQueryParam) : String :=
  match query with
  | [] => ""
  | _ =>
      "?" ++ String.intercalate "&" (query.map fun param => s!"{urlEncode param.key}={urlEncode param.value}")

private def renderMethod : HttpsMethod → String
  | .GET => "GET"
  | .POST => "POST"

private def buildCurlArgs (req : HttpsRequest) : Array String :=
  let base : List String :=
    ["--fail", "--silent", "--show-error", "--max-time", "30", "-X", renderMethod req.method]
  let headerArgs := req.headers.foldr (fun header acc => "-H" :: s!"{header.name}: {header.value}" :: acc) []
  let bodyArgs :=
    match req.body? with
    | some body => ["--data", body.compress]
    | none => []
  let finalUrl := req.url ++ renderQuery req.query
  (base ++ headerArgs ++ bodyArgs ++ [finalUrl]).toArray

def httpsExecute (req : HttpsRequest) : IO String :=
  IO.Process.run { cmd := "curl", args := buildCurlArgs req }

inductive DriftMarketKind where
  | perp
  | spot
  deriving DecidableEq, Repr

private def DriftMarketKind.ofWire (text : String) : Except String DriftMarketKind :=
  match text with
  | "perp" => .ok .perp
  | "spot" => .ok .spot
  | _ => .error s!"unknown Drift market kind: {text}"

private def DriftMarketKind.toInfo : DriftMarketKind → String
  | .perp => "perp"
  | .spot => "spot"

structure DriftPriceMarket where
  symbol : String
  currentPrice : String
  price24hAgo : String
  priceChange : String
  priceChangePercent : String
  marketIndex : Nat
  marketType : DriftMarketKind
  deriving Repr

structure DriftMarketsResponse where
  success : Bool
  markets : List DriftPriceMarket
  deriving Repr

structure DriftTradeRecord where
  symbol : String
  oraclePrice : String
  marketIndex : Nat
  marketType : DriftMarketKind
  deriving Repr

structure DriftTradesResponse where
  success : Bool
  records : List DriftTradeRecord
  deriving Repr

private def decodeDriftPriceMarket (json : Json) : Except String DriftPriceMarket := do
  let symbol <- json.getObjVal? "symbol" >>= asString
  let currentPrice <- json.getObjVal? "currentPrice" >>= asString
  let price24hAgo <- json.getObjVal? "price24hAgo" >>= asString
  let priceChange <- json.getObjVal? "priceChange" >>= asString
  let priceChangePercent <- json.getObjVal? "priceChangePercent" >>= asString
  let marketIndex <- json.getObjVal? "marketIndex" >>= asNat
  let marketTypeText <- json.getObjVal? "marketType" >>= asString
  let marketType <- DriftMarketKind.ofWire marketTypeText
  pure {
    symbol,
    currentPrice,
    price24hAgo,
    priceChange,
    priceChangePercent,
    marketIndex,
    marketType
  }

private def decodeDriftMarketsResponse (json : Json) : Except String DriftMarketsResponse := do
  let success <- json.getObjVal? "success" >>= asBool
  let marketsJson <- json.getObjVal? "markets"
  let markets <- decodeList marketsJson decodeDriftPriceMarket
  pure { success, markets }

private def decodeDriftTradeRecord (json : Json) : Except String DriftTradeRecord := do
  let symbol <- json.getObjVal? "symbol" >>= asString
  let oraclePrice <- json.getObjVal? "oraclePrice" >>= asString
  let marketIndex <- json.getObjVal? "marketIndex" >>= asNat
  let marketTypeText <- json.getObjVal? "marketType" >>= asString
  let marketType <- DriftMarketKind.ofWire marketTypeText
  pure { symbol, oraclePrice, marketIndex, marketType }

private def decodeDriftTradesResponse (json : Json) : Except String DriftTradesResponse := do
  let success <- json.getObjVal? "success" >>= asBool
  let recordsJson <- json.getObjVal? "records"
  let records <- decodeList recordsJson decodeDriftTradeRecord
  pure { success, records }

structure GainsPair where
  baseSymbol : String
  quoteSymbol : String
  spreadP : Float
  groupIndex : Nat
  feeIndex : Nat
  deriving Repr

structure GainsGroup where
  name : String
  minLeverage : Float
  maxLeverage : Float
  deriving Repr

structure GainsFee where
  totalPositionSizeFeeP : Float
  totalLiqCollateralFeeP : Float
  oraclePositionSizeFeeP : Float
  minPositionSizeUsd : Float
  deriving Repr

structure GainsChartsResponse where
  time : Nat
  opens : List Float
  highs : List Float
  lows : List Float
  closes : List Float
  indexPrices : List Float
  deriving Repr

structure GainsMarketsResponse where
  pairs : List GainsPair
  groups : List GainsGroup
  fees : List GainsFee
  indexPrices : List Float
  deriving Repr

private def decodeGainsPair (json : Json) : Except String GainsPair := do
  let baseSymbol <- json.getObjVal? "from" >>= asString
  let quoteSymbol <- json.getObjVal? "to" >>= asString
  let spreadP <- asFloatTextField json "spreadP"
  let groupIndex <- asNatTextField json "groupIndex"
  let feeIndex <- asNatTextField json "feeIndex"
  pure { baseSymbol, quoteSymbol, spreadP, groupIndex, feeIndex }

private def decodeGainsGroup (json : Json) : Except String GainsGroup := do
  let name <- json.getObjVal? "name" >>= asString
  let minLeverage <- asFloatTextField json "minLeverage"
  let maxLeverage <- asFloatTextField json "maxLeverage"
  pure { name, minLeverage, maxLeverage }

private def decodeGainsFee (json : Json) : Except String GainsFee := do
  let totalPositionSizeFeeP <- asFloatTextField json "totalPositionSizeFeeP"
  let totalLiqCollateralFeeP <- asFloatTextField json "totalLiqCollateralFeeP"
  let oraclePositionSizeFeeP <- asFloatTextField json "oraclePositionSizeFeeP"
  let minPositionSizeUsd <- asFloatTextField json "minPositionSizeUsd"
  pure {
    totalPositionSizeFeeP,
    totalLiqCollateralFeeP,
    oraclePositionSizeFeeP,
    minPositionSizeUsd
  }

private def decodeFloatArrayField (json : Json) (field : String) : Except String (List Float) := do
  let value <- json.getObjVal? field
  decodeList value asFloat

private def decodeGainsTradingVariables (json : Json) : Except String (List GainsPair × List GainsGroup × List GainsFee) := do
  let pairs <- json.getObjVal? "pairs" >>= fun value => decodeList value decodeGainsPair
  let groups <- json.getObjVal? "groups" >>= fun value => decodeList value decodeGainsGroup
  let fees <- json.getObjVal? "fees" >>= fun value => decodeList value decodeGainsFee
  pure (pairs, groups, fees)

private def decodeGainsChartsResponse (json : Json) : Except String GainsChartsResponse := do
  let time <- json.getObjVal? "time" >>= asNat
  let opens <- decodeFloatArrayField json "opens"
  let highs <- decodeFloatArrayField json "highs"
  let lows <- decodeFloatArrayField json "lows"
  let closes <- decodeFloatArrayField json "closes"
  let indexPrices <- decodeFloatArrayField json "indexPrices"
  pure { time, opens, highs, lows, closes, indexPrices }

structure ParclMarketIdentifier where
  value : Nat
  deriving DecidableEq, Repr

structure ParclMarketIdsResponse where
  marketIds : List ParclMarketIdentifier
  deriving Repr

structure ParclPriceFeedInfo where
  price : String
  expo : Int
  deriving Repr

structure ParclMarketSettings where
  minInitialMarginRatio : Nat
  deriving Repr

structure ParclMarket where
  address : String
  priceFeedInfo : ParclPriceFeedInfo
  settings : ParclMarketSettings
  id : Nat
  exchange : String
  priceFeed : String
  status : Nat
  deriving Repr

structure ParclMarketsResponse where
  markets : List ParclMarket
  deriving Repr

private def decodeParclMarketIdentifier (json : Json) : Except String ParclMarketIdentifier := do
  let text <- asString json
  let value <- parseNatText text
  pure { value }

private def decodeParclMarketIdsResponse (json : Json) : Except String ParclMarketIdsResponse := do
  let marketIds <- decodeList json decodeParclMarketIdentifier
  pure { marketIds }

private def decodeParclPriceFeedInfo (json : Json) : Except String ParclPriceFeedInfo := do
  let price <- json.getObjVal? "price" >>= asString
  let expo <- json.getObjVal? "expo" >>= asInt
  pure { price, expo }

private def decodeParclMarketSettings (json : Json) : Except String ParclMarketSettings := do
  let minInitialMarginRatio <- json.getObjVal? "min_initial_margin_ratio" >>= asNat
  pure { minInitialMarginRatio }

private def decodeParclMarket (json : Json) : Except String ParclMarket := do
  let address <- json.getObjVal? "address" >>= asString
  let priceFeedInfo <- json.getObjVal? "price_feed_info" >>= decodeParclPriceFeedInfo
  let settings <- json.getObjVal? "settings" >>= decodeParclMarketSettings
  let id <- json.getObjVal? "id" >>= asNat
  let exchange <- json.getObjVal? "exchange" >>= asString
  let priceFeed <- json.getObjVal? "price_feed" >>= asString
  let status <- json.getObjVal? "status" >>= asNat
  pure { address, priceFeedInfo, settings, id, exchange, priceFeed, status }

private def decodeParclMarketsResponse (json : Json) : Except String ParclMarketsResponse := do
  let markets <- decodeList json decodeParclMarket
  pure { markets }

structure PolymarketMarket where
  id : String
  question : String
  slug : String
  outcomes : List String
  outcomePrices : List Float
  endDate : String
  active : Bool
  closed : Bool
  deriving Repr

structure PolymarketMarketsResponse where
  markets : List PolymarketMarket
  deriving Repr

private def decodeStringListJsonText (text : String) : Except String (List String) := do
  let json <- Json.parse text
  decodeList json asString

private def decodeFloatListJsonText (text : String) : Except String (List Float) := do
  let json <- Json.parse text
  let texts <- decodeList json asString
  texts.mapM parseFloatText

private def decodePolymarketMarket (json : Json) : Except String PolymarketMarket := do
  let id <- json.getObjVal? "id" >>= asString
  let question <- json.getObjVal? "question" >>= asString
  let slug <- json.getObjVal? "slug" >>= asString
  let outcomesText <- json.getObjVal? "outcomes" >>= asString
  let outcomePricesText <- json.getObjVal? "outcomePrices" >>= asString
  let endDate <- json.getObjVal? "endDate" >>= asString
  let active <- json.getObjVal? "active" >>= asBool
  let closed <- json.getObjVal? "closed" >>= asBool
  let outcomes <- decodeStringListJsonText outcomesText
  let outcomePrices <- decodeFloatListJsonText outcomePricesText
  pure { id, question, slug, outcomes, outcomePrices, endDate, active, closed }

private def decodePolymarketMarketsResponse (json : Json) : Except String PolymarketMarketsResponse := do
  let markets <- decodeList json decodePolymarketMarket
  pure { markets }

structure ParclCatalogEntry where
  marketId : Nat
  name : String
  deriving Repr

def parclCatalog : List ParclCatalogEntry :=
  [
    { marketId := 1, name := "New York" },
    { marketId := 2, name := "Miami Beach" },
    { marketId := 3, name := "San Francisco" },
    { marketId := 4, name := "Austin" },
    { marketId := 5, name := "Las Vegas" },
    { marketId := 6, name := "Brooklyn" },
    { marketId := 7, name := "Los Angeles" },
    { marketId := 8, name := "Chicago" },
    { marketId := 9, name := "Atlanta" },
    { marketId := 10, name := "Denver" },
    { marketId := 11, name := "Washington DC" },
    { marketId := 12, name := "Boston" },
    { marketId := 13, name := "United States of America" },
    { marketId := 14, name := "San Diego" },
    { marketId := 15, name := "Miami" },
    { marketId := 16, name := "United States of America (rental)" },
    { marketId := 17, name := "Chicago (rental)" },
    { marketId := 18, name := "Denver (rental)" },
    { marketId := 19, name := "Pittsburgh" },
    { marketId := 20, name := "Boston (rental)" },
    { marketId := 21, name := "Brooklyn (rental)" },
    { marketId := 22, name := "Dubai" },
    { marketId := 23, name := "SOL" },
    { marketId := 24, name := "BTC" },
    { marketId := 25, name := "Charlotte" },
    { marketId := 26, name := "Tampa" },
    { marketId := 27, name := "Nashville" }
  ]

private def parclNameForId : Nat → Option String
  | marketId =>
      match parclCatalog.find? (fun entry => entry.marketId = marketId) with
      | some entry => some entry.name
      | none => none

private def canonicalizeSymbol (text : String) : String :=
  let pushUnderscore (acc : String) : String :=
    if acc.endsWith "_" || acc = "" then acc else acc ++ "_"
  let raw :=
    text.toList.foldl
      (fun acc c =>
        if isAsciiAlphaNum c then
          acc ++ String.singleton c.toUpper
        else
          pushUnderscore acc)
      ""
  if raw.endsWith "_" then (raw.dropEnd 1).toString else raw

private def formatLeverageFromScaledMillis (value : Float) : String :=
  let leverage := value / 1000.0
  s!"{leverage}x"

private def formatLeverageFromMarginRatioBps (ratio : Nat) : String :=
  if ratio = 0 then
    ""
  else
    s!"{10000.0 / ratio.toFloat}x"

private def listGet? : List α → Nat → Option α
  | [], _ => none
  | item :: _, 0 => some item
  | _ :: rest, n + 1 => listGet? rest n

private def stripDriftPerpSuffix (symbol : String) : String :=
  if symbol.endsWith "-PERP" then
    (symbol.dropEnd 5).toString
  else
    symbol

private def decodeDriftTradePrice (response : DriftTradesResponse) : Except String Float :=
  match response.records with
  | record :: _ => parseFloatText record.oraclePrice
  | [] => .error "expected at least one Drift trade record"

/-- Docs: https://docs.drift.trade/developers/ecosystem-builders/reading-data and https://docs.drift.trade/developers/data-api --/
private def driftMarketsRequest : HttpsRequest :=
  {
    method := .GET
    url := "https://data.api.drift.trade/stats/markets/prices"
  }

/-- Docs: https://docs.drift.trade/developers/ecosystem-builders/reading-data and https://docs.drift.trade/developers/data-api --/
private def driftTradesRequest (symbol : String) : HttpsRequest :=
  {
    method := .GET
    url := s!"https://data.api.drift.trade/market/{urlEncode symbol}/trades"
    query := [{ key := "limit", value := "1" }]
  }

/-- Docs: https://docs.gains.trade/developer/integrators/backend and https://docs.gains.trade/developer/integrators/guides/backend-endpoint-refactor --/
private def gainsMarketsRequest : HttpsRequest :=
  {
    method := .GET
    url := "https://backend-arbitrum.gains.trade/trading-variables/all"
  }

/-- Docs: https://docs.gains.trade/developer/integrators/price-feed and https://docs.gains.trade/developer/integrators/guides/mark-%2B-index-introduction --/
private def gainsChartsRequest : HttpsRequest :=
  {
    method := .GET
    url := "https://backend-pricing.eu.gains.trade/charts"
  }

/-- Docs: https://v3.parcl-api.com/docs/#/Accounts%20and%20Metadata/get_market_ids and local reference /Users/mo/.codex/worktrees/98a9/lean/ref/parcl.md --/
private def parclMarketIdsRequest : HttpsRequest :=
  {
    method := .GET
    url := "https://v3.parcl-api.com/v1/market-ids"
    query := [{ key := "response_kind", value := "ids" }]
  }

/-- Docs: https://v3.parcl-api.com/docs/#/Accounts%20and%20Metadata/get_markets and local reference /Users/mo/.codex/worktrees/98a9/lean/ref/parcl.md --/
private def parclMarketsRequest (marketIds : List ParclMarketIdentifier) : HttpsRequest :=
  {
    method := .POST
    url := "https://v3.parcl-api.com/v1/markets"
    headers := [{ name := "Content-Type", value := "application/json" }]
    body? := some <|
      Json.mkObj
        [
          ("exchange_id", Json.str (toString parclUsdcExchangeId)),
          ("market_ids", Json.arr (marketIds.toArray.map fun marketId => Json.str (toString marketId.value)))
        ]
  }

/-- Docs: https://docs.polymarket.com/api-reference/markets/list-markets --/
private def polymarketMarketsRequest (limit offset : Nat) : HttpsRequest :=
  {
    method := .GET
    url := "https://gamma-api.polymarket.com/markets"
    query :=
      [
        { key := "active", value := "true" },
        { key := "closed", value := "false" },
        { key := "limit", value := toString limit },
        { key := "offset", value := toString offset }
      ]
  }

private def fetchDriftMarketsResponse : IO DriftMarketsResponse := do
  let raw <- httpsExecute driftMarketsRequest
  let json <- parseJsonString raw
  exceptToIO <| decodeDriftMarketsResponse json

private def fetchDriftTradeResponse (symbol : String) : IO DriftTradesResponse := do
  let raw <- httpsExecute (driftTradesRequest symbol)
  let json <- parseJsonString raw
  exceptToIO <| decodeDriftTradesResponse json

private def fetchGainsMarketsResponse : IO GainsMarketsResponse := do
  let tradingVariablesRaw <- httpsExecute gainsMarketsRequest
  let tradingVariablesJson <- parseJsonString tradingVariablesRaw
  let (pairs, groups, fees) <- exceptToIO <| decodeGainsTradingVariables tradingVariablesJson
  let chartsRaw <- httpsExecute gainsChartsRequest
  let chartsJson <- parseJsonString chartsRaw
  let charts <- exceptToIO <| decodeGainsChartsResponse chartsJson
  pure { pairs, groups, fees, indexPrices := charts.indexPrices }

private def fetchParclMarketsResponse : IO ParclMarketsResponse := do
  let idsRaw <- httpsExecute parclMarketIdsRequest
  let idsJson <- parseJsonString idsRaw
  let ids <- exceptToIO <| decodeParclMarketIdsResponse idsJson
  let marketsRaw <- httpsExecute (parclMarketsRequest ids.marketIds)
  let marketsJson <- parseJsonString marketsRaw
  exceptToIO <| decodeParclMarketsResponse marketsJson

private def fetchPolymarketPage (limit offset : Nat) : IO PolymarketMarketsResponse := do
  let raw <- httpsExecute (polymarketMarketsRequest limit offset)
  let json <- parseJsonString raw
  exceptToIO <| decodePolymarketMarketsResponse json

private def normalizeDriftMarket (market : DriftPriceMarket) : IO (Option MarketRow) := do
  try
    let tradeResponse <- fetchDriftTradeResponse market.symbol
    let price <- exceptToIO <| decodeDriftTradePrice tradeResponse
    pure <| some
      {
        name := market.symbol
        asset_symbol := stripDriftPerpSuffix market.symbol
        provider := Provider.toWire .Drift
        price := price
        unit := "USDC"
        info := s!"{market.marketType.toInfo}; marketIndex={market.marketIndex}"
      }
  catch _ =>
    pure none

private def normalizeDriftMarkets (markets : List DriftPriceMarket) : IO (List MarketRow) := do
  let rec loop (remaining : List DriftPriceMarket) (acc : List MarketRow) : IO (List MarketRow) := do
    match remaining with
    | [] => pure acc.reverse
    | market :: rest =>
        let row? <- normalizeDriftMarket market
        match row? with
        | some row => loop rest (row :: acc)
        | none => loop rest acc
  loop markets []

private def normalizeGainsMarkets (response : GainsMarketsResponse) : List MarketRow :=
  let rec loop
      (pairs : List GainsPair)
      (index : Nat)
      (acc : List MarketRow) : List MarketRow :=
    match pairs with
    | [] => acc.reverse
    | pair :: rest =>
        let price? := listGet? response.indexPrices index
        let group? := listGet? response.groups pair.groupIndex
        let fee? := listGet? response.fees pair.feeIndex
        match price?, group?, fee? with
        | some price, some group, some fee =>
            let leverageText := formatLeverageFromScaledMillis group.maxLeverage
            let spreadText := pair.spreadP / pow10 10
            let row : MarketRow :=
              {
                name := s!"{pair.baseSymbol}/{pair.quoteSymbol}"
                asset_symbol := pair.baseSymbol
                provider := Provider.toWire .Gains
                price := price
                unit := "USDC"
                info := s!"maxLev={leverageText}; spreadP={spreadText}; minSizeUsd={fee.minPositionSizeUsd / 1000.0}"
              }
            loop rest (index + 1) (row :: acc)
        | _, _, _ =>
            loop rest (index + 1) acc
  loop response.pairs 0 []

private def normalizeParclMarkets (response : ParclMarketsResponse) : List MarketRow :=
  let rec loop (markets : List ParclMarket) (acc : List MarketRow) : List MarketRow :=
    match markets with
    | [] => acc.reverse
    | market :: rest =>
        let row? :=
          match parclNameForId market.id, parseFloatText market.priceFeedInfo.price with
          | some name, .ok mantissa =>
              let price := applyExponent mantissa market.priceFeedInfo.expo
              let leverageText := formatLeverageFromMarginRatioBps market.settings.minInitialMarginRatio
              some
                {
                  name := name
                  asset_symbol := canonicalizeSymbol name
                  provider := Provider.toWire .Parcl
                  price := price
                  unit := "USDC"
                  info := s!"maxLev={leverageText}; marketId={market.id}"
                }
          | _, _ => none
        match row? with
        | some row => loop rest (row :: acc)
        | none => loop rest acc
  loop response.markets []

private def firstOutcomePrice? (prices : List Float) : Option Float :=
  match prices with
  | price :: _ => some (price * 100.0)
  | [] => none

private def normalizePolymarketMarkets (response : PolymarketMarketsResponse) : List MarketRow :=
  let rec loop (markets : List PolymarketMarket) (acc : List MarketRow) : List MarketRow :=
    match markets with
    | [] => acc.reverse
    | market :: rest =>
        let row? :=
          match firstOutcomePrice? market.outcomePrices with
          | some price =>
              some
                {
                  name := market.question
                  asset_symbol := if market.slug = "" then market.id else market.slug
                  provider := Provider.toWire .Poly
                  price := price
                  unit := "%"
                  info := market.endDate
                }
          | none => none
        match row? with
        | some row => loop rest (row :: acc)
        | none => loop rest acc
  loop response.markets []

private def fetchAllPolymarketMarkets : IO (List MarketRow) := do
  let rec loop (page : Nat) (offset : Nat) (acc : List MarketRow) : IO (List MarketRow) := do
    if page ≥ polymarketDefaultMaxPages then
      pure acc
    else
      let response <- fetchPolymarketPage polymarketDefaultPageSize offset
      let rows := normalizePolymarketMarkets response
      let count := response.markets.length
      let nextAcc := acc ++ rows
      if count < polymarketDefaultPageSize then
        pure nextAcc
      else
        loop (page + 1) (offset + polymarketDefaultPageSize) nextAcc
  loop 0 0 []

private def fetchAllDriftMarkets : IO (List MarketRow) := do
  let response <- fetchDriftMarketsResponse
  normalizeDriftMarkets response.markets

private def fetchAllGainsMarkets : IO (List MarketRow) := do
  let response <- fetchGainsMarketsResponse
  pure <| normalizeGainsMarkets response

private def fetchAllParclMarkets : IO (List MarketRow) := do
  let response <- fetchParclMarketsResponse
  pure <| normalizeParclMarkets response

def getMarkets : IO (List MarketRow) := do
  let driftRows <- fetchAllDriftMarkets
  let gainsRows <- fetchAllGainsMarkets
  let parclRows <- fetchAllParclMarkets
  let polymarketRows <- fetchAllPolymarketMarkets
  pure (driftRows ++ gainsRows ++ parclRows ++ polymarketRows)
