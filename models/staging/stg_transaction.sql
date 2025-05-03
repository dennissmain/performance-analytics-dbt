WITH base AS (
  SELECT
    account_id,
    DATE(transaction_date) AS transaction_date,
    ROUND(SAFE_CAST(price AS FLOAT64), 2) AS price,
    UPPER(TRIM(currency)) AS currency
  FROM `dbtproject-458420.Marketing_raw.transactions`
  WHERE account_id IS NOT NULL
    AND transaction_date IS NOT NULL
    AND SAFE_CAST(price AS FLOAT64) IS NOT NULL
    AND currency IS NOT NULL
),

ranked_txns AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY account_id, transaction_date
           ORDER BY price DESC
         ) AS row_num
  FROM base
)

SELECT
  account_id,
  transaction_date,
  price,
  currency
FROM ranked_txns
WHERE row_num = 1