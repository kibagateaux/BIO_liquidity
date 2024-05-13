WITH token_trades AS (
  SELECT
    DATE_TRUNC('day', block_time) AS trade_day,
    token_bought_symbol AS token_bought,
    token_sold_symbol AS token_sold,
    token_bought_address,
    token_sold_address,
    token_bought_amount,
    token_sold_amount,
    amount_usd,
    token_pair as trading_pair,
    fee as fee_pct,
    CASE WHEN NOT fee IS NULL THEN amount_usd * fee / 1,000,000 ELSE 0 END AS fee_usd
  FROM uniswap_v3_ethereum.trades
  WHERE
    project = 'uniswap'
    AND block_time >= CAST('2023-12-01' AS TIMESTAMP)
    AND (
      token_bought_address IN (FROM_HEX('81f8f0bb1cb2a06649e51913a151f0e7ef6fa321'), FROM_HEX('A4fFdf3208F46898CE063e25c1C43056FA754739'), FROM_HEX('761A3557184cbC07b7493da0661c41177b2f97fA'))
      OR token_sold_address IN (FROM_HEX('81f8f0bb1cb2a06649e51913a151f0e7ef6fa321'), FROM_HEX('A4fFdf3208F46898CE063e25c1C43056FA754739'), FROM_HEX('761A3557184cbC07b7493da0661c41177b2f97fA'))
    )
)
, price_data AS (
  SELECT
    pt.trade_day,
    pt.token_bought,
    pt.token_sold,
    pt.token_bought_address,
    pt.token_sold_address,
    pt.token_bought_amount,
    pt.token_sold_amount,
    pt.amount_usd,
    pt.fee_pct,
    pt.fee_usd,
    pt.trading_pair,
    p.price AS weth_usd_price -- Add ETH/USD price at time of trade to each row
  FROM token_trades AS pt
  JOIN (
    SELECT
      MINUTE,
      price
    FROM prices.usd
    WHERE
      symbol = 'WETH' AND blockchain = 'ethereum'
      AND MINUTE >= CAST('2023-12-01' AS TIMESTAMP)
  ) AS p
    ON pt.trade_day = p.MINUTE
)
, individual_trades AS (
  SELECT
    pd.trade_day,
    pd.token_bought,
    pd.token_sold,
    pd.token_bought_address,
    pd.token_sold_address,
    pd.token_bought_amount,
    pd.token_sold_amount,
    pd.amount_usd,
    pd.fee_pct,
    pd.fee_usd,
    pd.trading_pair,
    pd.weth_usd_price,
    CASE
      WHEN pd.token_bought_address IN (FROM_HEX('81f8f0bb1cb2a06649e51913a151f0e7ef6fa321'), FROM_HEX('A4fFdf3208F46898CE063e25c1C43056FA754739'), FROM_HEX('761A3557184cbC07b7493da0661c41177b2f97fA'))
      THEN pd.amount_usd / pd.token_bought_amount
      ELSE pd.amount_usd / pd.token_sold_amount --- assumes we've already filtered all trades for bioDAO tokens
    END AS token_price_usd,
    CASE
      WHEN pd.token_bought_address IN (FROM_HEX('81f8f0bb1cb2a06649e51913a151f0e7ef6fa321'), FROM_HEX('A4fFdf3208F46898CE063e25c1C43056FA754739'), FROM_HEX('761A3557184cbC07b7493da0661c41177b2f97fA'))
      THEN (pd.amount_usd / pd.weth_usd_price) / pd.token_bought_amount
      ELSE (pd.amount_usd / pd.weth_usd_price) / pd.token_sold_amount --- assumes we've already filtered all trades for bioDAO tokens
    END AS token_price_weth
    
  FROM price_data AS pd
)
SELECT
  trade_day,
  trading_pair,
  amount_usd AS volume_usd,
  fee_usd AS fees_usd,
  fee_pct,
  token_price_usd,
  token_price_weth,
  weth_usd_price,
  token_bought,
  token_bought_amount,
  token_sold_amount
FROM individual_trades
ORDER BY trade_day DESC