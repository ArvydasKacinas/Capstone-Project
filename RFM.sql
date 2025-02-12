WITH FreqMonet_calc AS (
  SELECT
    CustomerID,
    MAX(Transaction_Date) AS latest_purchase,
    COUNT(DISTINCT Transaction_ID) AS frequency,
    SUM(Quantity*Avg_Price+Delivery_Charges) AS monetary
  FROM `marketing_analysis.Online_sales`
  WHERE Quantity > 0
    AND Avg_Price > 0
    AND Delivery_Charges >= 0
  GROUP BY CustomerID
),

Recency_FreqMon_Calc AS (
  SELECT
    CustomerID,
    DATE_DIFF(reference_date, latest_purchase, DAY) AS recency,
    monetary,
    frequency
  FROM (SELECT
          *,
          MAX(latest_purchase)OVER()+1 AS reference_date
        FROM FreqMonet_calc) AS FM_calc
),

quantile_partition AS (
  SELECT
    *,
  PERCENTILE_DISC(RFM_calc.monetary,(0.25)) OVER() AS m25,
  PERCENTILE_DISC(RFM_calc.monetary,(0.50)) OVER() AS m50,
  PERCENTILE_DISC(RFM_calc.monetary,(0.75)) OVER() AS m75,
  CAST(PERCENTILE_DISC(RFM_calc.frequency,(0.25)) OVER()AS INT64) AS f25,
  CAST(PERCENTILE_DISC(RFM_calc.frequency,(0.50)) OVER()AS INT64) AS f50,
  CAST(PERCENTILE_DISC(RFM_calc.frequency,(0.75)) OVER()AS INT64) AS f75,
  CAST(PERCENTILE_DISC(RFM_calc.recency,(0.25)) OVER()AS INT64) AS r25,
  CAST(PERCENTILE_DISC(RFM_calc.recency,(0.50)) OVER()AS INT64) AS r50,
  CAST(PERCENTILE_DISC(RFM_calc.recency,(0.75)) OVER()AS INT64) AS r75,
  FROM Recency_FreqMon_Calc AS RFM_calc
),

RFM_score_CTE AS (
  SELECT
    *,
    CONCAT(CAST(r_score AS STRING), CAST(f_score AS STRING), CAST(m_score AS STRING)) AS RFM_score
  FROM (
      SELECT
        *,
        CASE
          WHEN monetary <= m25 THEN 1
          WHEN monetary > m25 AND Monetary <= m50 THEN 2
          WHEN monetary > m50 AND Monetary <= m75 THEN 3
          WHEN monetary > m75 THEN 4
        END AS m_score,
        CASE
          WHEN frequency <= f25 THEN 1
          WHEN frequency > f25 AND frequency <= f50 THEN 2
          WHEN frequency > f50 AND frequency <= f75 THEN 3
          WHEN frequency > f75 THEN 4
        END AS f_score,
        CASE
          WHEN recency <= r25 THEN 4
          WHEN recency > r25 AND recency <= r50 THEN 3
          WHEN recency > r50 AND recency <= r75 THEN 2
          WHEN recency > r75 THEN 1
        END AS r_score,
      FROM quantile_partition
      )
)

SELECT
  CustomerID,
  recency,
  frequency,
  ROUND(monetary,2) AS monetary,
  r_score,
  f_score,
  m_score,
  RFM_score,
  CASE
    WHEN RFM_score IN ("444") THEN "Champions"
    WHEN RFM_score IN ("344","434","443","333","334","433","343") THEN "Loyalists"
    WHEN RFM_score IN ("442","441","432","424","414","423","342","431","413") THEN "Potential loyalists"
    WHEN RFM_score IN ("411","412","421","422") THEN "Recent Customers"
    WHEN RFM_score IN ("341","332","331","324","323","322","311","314","313","312","321") THEN "Promising"
    WHEN RFM_score IN ("244","144","134","234","114","143") THEN "Can't Lose Them"
    WHEN RFM_score IN ("222","223","224","231","232","233","241","242","243") THEN "Customers Needing Attention"
    WHEN RFM_score IN ("211","212","213","214","221") THEN "About to Sleep"
    WHEN RFM_score IN ("112","113","121","122","123","124","131","132","133","141","142") THEN "Hibernating"
    WHEN RFM_SCORE IN ("111") THEN "Lost"
  END AS RFM_segment
FROM RFM_score_CTE