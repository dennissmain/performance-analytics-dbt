-- Cleaning of the tiktok campaign data 
WITH base AS (
  SELECT
    -- Extract and clean campaign_id before the pipe
    UPPER(TRIM(SPLIT(campaign_id, '|')[SAFE_OFFSET(0)])) AS campaign_id,

    -- Extract and clean country after the pipe
    UPPER(TRIM(SPLIT(campaign_id, '|')[SAFE_OFFSET(1)])) AS country,

    -- Format campaign date as DATE
    DATE(campaign_date) AS campaign_date,

    -- Cast spend to float and round to two decimal places
    ROUND(SAFE_CAST(campaign_spend_usd AS FLOAT64), 2) AS campaign_spend_usd
  FROM `dbtproject-458420.Marketing_raw.tiktok`
  WHERE campaign_id IS NOT NULL
    AND campaign_date IS NOT NULL
    AND campaign_spend_usd IS NOT NULL
    AND CONTAINS_SUBSTR(campaign_id, '|')  -- ensures clean split
),
-- Deduplicate to keep only the highest spend for campaign_id, date, and country and using row_number to rank records
deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY campaign_id, campaign_date, country
           ORDER BY campaign_spend_usd DESC
         ) AS row_num
  FROM base
)

SELECT
  campaign_id,
  campaign_date,
  country,
  campaign_spend_usd  
FROM deduped
WHERE row_num = 1