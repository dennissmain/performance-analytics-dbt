# performance-analytics-dbt
This project analyses marketing campaign performance using BigQuery, dbt, and ThoughtSpot.

## 🛠 Tech Stack
- dbt (v1.9.4)
- BigQuery
- ThoughtSpot
- GitHub

## 📊 KPIs Tracked
- Total Spend (GBP)
- Total Revenue (GBP)
- Signups
- CPA (Cost Per Acquisition)
- ROAS (Return on Ad Spend)

## 📁 Project Structure
- `models/staging/` – cleans raw data
- `models/intermediate/` – joins and applies logic
- `models/final/` – final fact table
- `schema.yml` – column-level and uniqueness tests

## ✅ How to Run
```bash
dbt deps
dbt run
dbt test
