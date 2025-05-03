-- Clean and deduplicating the signupdata while extracting campaign identifiers
WITH base AS (
  SELECT
    account_id,
    DATE(signup_date) AS signup_date,
    -- Normalizing and extracting campaign ID from attribution_source and renaming it to campaign_id for uniformitiy
    IF(
      STRPOS(attribution_source, '|') > 0,
      SPLIT(UPPER(TRIM(attribution_source)), '|')[SAFE_OFFSET(0)],
      UPPER(TRIM(attribution_source))
    ) AS campaign_id
  FROM `dbtproject-458420.Marketing_raw.signups`
  WHERE 
    account_id IS NOT NULL
    AND signup_date IS NOT NULL
    AND attribution_source IS NOT NULL
),
-- Deduplicating the data by account_id and keeping the latest signup-date using window function.
deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY account_id
           ORDER BY signup_date DESC
         ) AS row_num
  FROM base
)
-- Selection of one signup record per account
SELECT
  account_id,
  signup_date,
  campaign_id
FROM deduped
WHERE row_num = 1