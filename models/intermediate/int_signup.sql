-- Aggregate signups by campaign and signup date
SELECT
  -- Normalize campaign_id to ensure consistent casing and spacing
  UPPER(TRIM(campaign_id)) AS campaign_id,

  -- Rename signup_date to campaign_date for consistency across models
  signup_date AS campaign_date,

  -- Count the number of signups per campaign per day
  COUNT(*) AS signups
FROM {{ ref('stg_signups') }}

-- Filter out any rows without a campaign_id to ensure attribution integrity
WHERE campaign_id IS NOT NULL

-- Group by the normalized campaign_id and signup date
GROUP BY campaign_id, campaign_date