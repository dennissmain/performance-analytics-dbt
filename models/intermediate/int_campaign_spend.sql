WITH combined_spend AS (
    SELECT 
      -- Standardize campaign_id formatting for reliable joins
      UPPER(TRIM(campaign_id)) AS campaign_id,
      campaign_date,
      -- Ensure spend is rounded to 2 decimal places
      ROUND(campaign_spend_gbp, 2) AS spend_gbp,
      'facebook' AS social_media,
      country                         
    FROM {{ ref('stg_facebook') }}

    UNION ALL

    SELECT 
      -- Standardize TikTok campaign_id as well
      UPPER(TRIM(campaign_id)) AS campaign_id,
      campaign_date,
      -- Converting TikTok spend from USD to GBP using daily FX rate
      ROUND(campaign_spend_usd / fx_gbp.usd_rate, 2) AS spend_gbp,
      'tiktok' AS social_media,
      country                   
    FROM {{ ref('stg_tiktok') }} tt
    LEFT JOIN {{ ref('stg_fx_rates') }} fx_gbp
      ON tt.campaign_date = fx_gbp.fx_date AND fx_gbp.currency = 'GBP'
    -- Ensure both spend and FX data exist before including the row
    WHERE 
      tt.campaign_spend_usd IS NOT NULL AND 
      fx_gbp.usd_rate IS NOT NULL
),

deduplicated AS (
    -- Remove any potential duplicates per campaign-date-platform
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY campaign_id, campaign_date, social_media
               ORDER BY spend_gbp DESC
           ) AS row_num
    FROM combined_spend
)

-- Selection of unique campaign records per platform and day
SELECT
  campaign_id,
  campaign_date,
  spend_gbp,
  social_media,
  country
FROM deduplicated
WHERE row_num = 1