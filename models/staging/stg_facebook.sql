-- Standardizing and filtering of the raw Facebook campaign data
WITH base AS (
  SELECT
    -- Normalizing campaign_id to uppercase and remove extra whitespace
    UPPER(TRIM(campaign_id)) AS campaign_id,

    -- Casting of campaign_date to DATE type
    DATE(campaign_date) AS campaign_date,

    -- Ensure campaign_spend_gbp is in FLOAT64 for numerical operations
    SAFE_CAST(campaign_spend_gbp AS FLOAT64) AS campaign_spend_gbp,

    -- Normalize country field to uppercase and remove extra whitespace
    UPPER(TRIM(country)) AS country
  FROM `dbtproject-458420.Marketing_raw.facebook`
  WHERE campaign_id IS NOT NULL
    AND campaign_date IS NOT NULL
    AND campaign_spend_gbp IS NOT NULL
    AND country IS NOT NULL
),

-- Step 2: Remove duplicate rows based on campaign_id, campaign_date, and country
deduped AS (
  SELECT *,
         -- Assign a row number for each group to retain only the highest spend entry
         ROW_NUMBER() OVER (
           PARTITION BY campaign_id, campaign_date, country
           ORDER BY campaign_spend_gbp DESC
         ) AS row_num
  FROM base
)

-- Step 3: Selecting only the top (non-duplicate) entry per group
SELECT
  campaign_id,
  campaign_date,
  -- Round spend to 2 decimal places for consistency
  ROUND(campaign_spend_gbp, 2) AS campaign_spend_gbp,
  country
FROM deduped
WHERE row_num = 1