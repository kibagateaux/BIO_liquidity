WITH auction_deposits AS (
    SELECT 
        to,
        block_time,
        amount,
        'from'
    FROM erc20_ethereum.evt_Transfer
    WHERE to = LOWER({{auction_address}}) AND address={{auction_token}}
    GROUP BY 3
),
new_wallets AS (
    SELECT COUNT(*) as new_wallets,
    DATE_TRUNC('day', block_time) as day
    FROM auction_deposits
    GROUP BY day
),
bio_availability AS (
    SELECT balance
    FROM ethereum.balances
    WHERE address = LOWER({{auction_address}})
    AND token = 0xb10
    AND block = x
),
prices as (
    SELECT
        avg(price) as price,
        DATE_TRUNC('minute', minute) as day 
    FROM ethereum.prices
    WHERE block >= x
    AND contract_address = lower('{{auction_token}}')
    GROUP BY 2
)

SELECT
    a.new_wallets as new_wallets_created,
    sum(a.new_wallets) OVER (ORDER BY a.day) as cum_new_wallets, a.day as day
-- , b.price as token_price 
FROM new_wallets AS a
left join prices AS b
on a.day = b.day
ORDER BY a.day DESC


