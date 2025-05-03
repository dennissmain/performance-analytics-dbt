-- Final fact table query selecting key metrics from the intermediate campaign performance model

SELECT
  campaign_id,                          -- Unique identifier for the marketing campaign
  campaign_date,                        -- Date the campaign activity occurred
  social_media,                         -- Platform where the campaign was run (e.g., Facebook, TikTok)
  country,                              -- Country where the campaign was targeted
  spend_gbp,                            -- Amount spent on the campaign (in GBP)
  signups,                              -- Number of user signups attributed to the campaign
  total_revenue_gbp,                    -- Total revenue generated from attributed transactions (in GBP)
  
  -- Cost per Acquisition (CPA): spend per signup. Safe divide handles division by zero.
  ROUND(SAFE_DIVIDE(spend_gbp, signups), 2) AS cost_per_acquisition_gbp,
  
  -- Return on Ad Spend (ROAS): revenue per pound spent. Also protected against divide-by-zero.
  ROUND(SAFE_DIVIDE(total_revenue_gbp, spend_gbp), 2) AS roas

FROM {{ ref('int_campaign_performance') }}  -- Reference to the intermediate campaign performance table