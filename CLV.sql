WITH main_info AS (
  SELECT
    online.CustomerID,
    DATE_TRUNC(MIN(Transaction_Date) OVER (PARTITION BY Online.CustomerID),MONTH) AS first_purchase_month,
    DATE_TRUNC(Transaction_Date, MONTH) AS purchase_month,
    Quantity*Avg_Price+Delivery_Charges AS Revenue,
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
  ROUND(SUM(CASE WHEN purchase_month = first_purchase_month THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_0,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 1 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_1,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 2 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_2,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 3 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_3,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 4 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_4,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 5 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_5,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 6 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_6,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 7 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_7,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 8 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_8,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 9 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_9,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 10 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_10,
  ROUND(SUM(CASE WHEN purchase_month = DATE_ADD(first_purchase_month, INTERVAL 11 MONTH) THEN Revenue END)/COUNT(DISTINCT CustomerID),2) AS Month_11,
FROM main_info
JOIN marketing_costs
ON marketing_costs.Month = main_info.first_purchase_month
GROUP BY first_purchase_month,marketing_spendings
ORDER BY first_purchase_month