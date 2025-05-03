-- Applying FX rates to transaction prices and aggregate revenue per campaign per date
WITH fx_applied AS (
  SELECT
    -- Normalize campaign_id by trimming and uppercasing
    UPPER(TRIM(su.campaign_id)) AS campaign_id,

    -- Normalize transaction date
    DATE(txn.transaction_date) AS campaign_date,

    -- Convert transaction price to GBP using USD and GBP exchange rates
    ROUND((txn.price * fx.usd_rate) / gbp.usd_rate, 2) AS revenue_gbp
  FROM {{ ref('stg_transaction') }} txn

  -- Join with signups to get campaign_id per transaction
  LEFT JOIN {{ ref('stg_signups') }} su
    ON txn.account_id = su.account_id

  -- Join with FX rates for the transaction currency
  LEFT JOIN {{ ref('stg_fx_rates') }} fx
    ON txn.transaction_date = fx.fx_date AND txn.currency = fx.currency

  -- Join again with FX rates to convert into GBP
  LEFT JOIN {{ ref('stg_fx_rates') }} gbp
    ON txn.transaction_date = gbp.fx_date AND gbp.currency = 'GBP'

  -- Exclude unmatched campaign_ids (unattributed transactions)
  WHERE su.campaign_id IS NOT NULL
)

-- Aggregate the revenue per campaign and date
SELECT
  campaign_id,
  campaign_date,
  SUM(revenue_gbp) AS transaction_value_gbp
FROM fx_applied
GROUP BY campaign_id, campaign_date