-- This model brings together campaign spend, signups, and revenue data into one unified campaign performance table, suitable for KPI analysis.

WITH combined_campaigns AS (
  SELECT 
    campaign_id,
    campaign_date,
    social_media,
    country,
    -- Round spend values to 2 decimal places for consistency
    ROUND(spend_gbp, 2) AS spend_gbp
  FROM {{ ref('int_campaign_spend') }}
),

combined_signups AS (
  SELECT 
    campaign_id, 
    campaign_date,
    -- Aggregate total signups per campaign per day
    SUM(signups) AS signups
  FROM {{ ref('int_signup') }}
  GROUP BY campaign_id, campaign_date
),

combined_transactions AS (
  SELECT
    campaign_id,
    campaign_date,
    -- Aggregate transaction values in GBP per campaign per day
    SUM(transaction_value_gbp) AS total_revenue_gbp
  FROM {{ ref('int_transactions_gbp') }}
  GROUP BY campaign_id, campaign_date
),

joined AS (
  SELECT
    c.campaign_id,
    c.campaign_date,
    c.social_media,
    c.country,
    c.spend_gbp,
    -- Use IFNULL to default to 0 where no signup data exists
    IFNULL(s.signups, 0) AS signups,
    -- Use IFNULL to default to 0 where no revenue data exists
    IFNULL(t.total_revenue_gbp, 0) AS total_revenue_gbp
  FROM combined_campaigns c
  -- Join with signup data by campaign ID and date
  LEFT JOIN combined_signups s
    ON c.campaign_id = s.campaign_id
    AND c.campaign_date = s.campaign_date
  -- Join with transaction data by campaign ID and date
  LEFT JOIN combined_transactions t
    ON c.campaign_id = t.campaign_id
    AND c.campaign_date = t.campaign_date
)

-- Final selection of KPIs for dashboarding and performance analysis
SELECT
  campaign_id,
  campaign_date,
  social_media,
  country,
  spend_gbp,
  signups,
  total_revenue_gbp,
  -- Cost per acquisition: how much is spent per signup
  ROUND(SAFE_DIVIDE(spend_gbp, signups), 2) AS cost_per_acquisition_gbp,
  -- Return on ad spend: revenue generated per £1 spent
  ROUND(SAFE_DIVIDE(total_revenue_gbp, spend_gbp), 2) AS roas
FROM joined
