-- This model is used to stage the fx rates data from the raw source.
SELECT
  fx_date,
  TRIM(UPPER(currency)) AS currency,
  SAFE_CAST(usd_rate AS FLOAT64) AS usd_rate
FROM `dbtproject-458420.Marketing_raw.fx_rates`
-- Filtering out any ros with missing or invalid data
WHERE usd_rate IS NOT NULL
  AND fx_date IS NOT NULL
  AND currency IS NOT NULL
