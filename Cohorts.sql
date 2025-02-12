WITH main_info AS (
  SELECT
    online.CustomerID,
    DATE_TRUNC(MIN(Transaction_Date) OVER (PARTITION BY Online.CustomerID),MONTH) AS first_purchase_month,
    DATE_TRUNC(Transaction_Date, MONTH) AS purchase_month,
    Tenure_Months,
  FROM `marketing_analysis.Online_sales` AS online
  INNER JOIN `marketing_analysis.customers_data` AS cust_data
  ON cust_data.customerID = online.customerID
),

marketing_costs AS (
  SELECT
    DATE_TRUNC(Date,MONTH) AS Month,
    SUM(Offline_Spend+Online_Spend) AS Marketing_spendings
  FROM `spherical-proxy-444314-v3.marketing_analysis.marketing_spend`
  GROUP BY Month 
  ORDER BY Month
)
SELECT
  first_purchase_month,
  COUNT(DISTINCT CustomerID) AS cohort_size,
  ROUND(marketing_spendings,2) AS marketing_expenses,
  ROUND(marketing_spendings/COUNT(DISTINCT CustomerID),2) AS avg_spend_per_cust,
  CAST(AVG(tenure_months)AS INT64) AS average_tenure_months,
  COUNT(DISTINCT CASE WHEN purchase_month = first_purchase_month THEN CustomerID END) AS Month_0,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 1 MONTH) THEN CustomerID END) AS Month_1,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 2 MONTH) THEN CustomerID END) AS Month_2,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 3 MONTH) THEN CustomerID END) AS Month_3,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 4 MONTH) THEN CustomerID END) AS Month_4,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 5 MONTH) THEN CustomerID END) AS Month_5,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 6 MONTH) THEN CustomerID END) AS Month_6,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 7 MONTH) THEN CustomerID END) AS Month_7,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 8 MONTH) THEN CustomerID END) AS Month_8,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 9 MONTH) THEN CustomerID END) AS Month_9,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 10 MONTH) THEN CustomerID END) AS Month_10,
  COUNT(DISTINCT CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 11 MONTH) THEN CustomerID END) AS Month_11,
FROM main_info
JOIN marketing_costs
ON marketing_costs.Month = main_info.first_purchase_month
GROUP BY first_purchase_month,marketing_spendings
ORDER BY first_purchase_month