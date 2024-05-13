
WITH vita_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0x81f8f0bb1cb2a06649e51913a151f0e7ef6fa321 AND value > 0
),rsc_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0xD101dCC414F310268c37eEb4cD376CcFA507F571 AND value > 0
), neuron_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0xab814ce69e15f6b9660a3b184c0b0c97b9394a6b  AND value > 0
), athena_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0xA4fFdf3208F46898CE063e25c1C43056FA754739  AND value > 0
), cryo_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0x31a6654bDE58bCe2B437396bA71A0E545198CAce AND value > 0
), grow_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0x761A3557184cbC07b7493da0661c41177b2f97fA AND value > 0
), hair_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0x9ce115f0341ae5dabc8b477b74e83db2018a6f42 AND value > 0
), vitafast_holders AS (
  SELECT DISTINCT "to" AS holder FROM erc20_ethereum.evt_Transfer
  WHERE contract_address = 0x6034e0d6999741f07cb6fb1162cbaa46a1d33d36 AND value > 0
),

combined_holders AS (
  SELECT holder, 1 AS token_count FROM vita_holders UNION ALL
  SELECT holder, 1 AS token_count FROM grow_holders UNION ALL
  SELECT holder, 1 AS token_count FROM vitafast_holders UNION ALL
  SELECT holder, 1 AS token_count FROM rsc_holders UNION ALL
  SELECT holder, 1 AS token_count FROM neuron_holders UNION ALL
  SELECT holder, 1 AS token_count FROM hair_holders UNION ALL
  SELECT holder, 1 AS token_count FROM cryo_holders UNION ALL
  SELECT holder, 1 AS token_count FROM athena_holders
), global_unique_holders AS (
SELECT COUNT(DISTINCT holder) AS unique_holders
FROM combined_holders
), summed_holders AS (
  SELECT
    holder,
    SUM(token_count) AS tokens_held FROM combined_holders
  GROUP BY holder
), holders_distribution AS (
  SELECT
    tokens_held,
    COUNT(*) AS number_of_holders
  FROM summed_holders
  GROUP BY tokens_held
)
SELECT
  tokens_held,
  unique_holders,
  number_of_holders
FROM holders_distribution
JOIN (SELECT unique_holders FROM global_unique_holders) 
ON tokens_held != 0
ORDER BY tokens_held
