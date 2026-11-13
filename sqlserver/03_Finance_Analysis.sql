USE FinancePortfolio2025;
GO
-- Category gross-profit variance: aggregate amounts before calculating ratios.
SELECT p.category,SUM(f.revenue) revenue,SUM(f.revenue-f.budget_revenue) revenue_variance,
 SUM((f.revenue-f.cogs)-(f.budget_revenue-f.budget_cogs)) gross_profit_variance,
 SUM(f.discount)/NULLIF(SUM(f.gross_revenue),0) discount_rate
FROM dbo.fact_finance f JOIN dbo.dim_product p ON p.product_id=f.product_id
WHERE f.date >= '20250101' AND f.date < '20260101'
GROUP BY p.category ORDER BY gross_profit_variance;

-- Window function: rank regions by revenue shortfall.
WITH regional AS (
 SELECT r.region,SUM(f.revenue-f.budget_revenue) variance
 FROM dbo.fact_finance f JOIN dbo.dim_region r ON r.region_id=f.region_id
 WHERE f.date >= '20250101' AND f.date < '20260101' GROUP BY r.region
)
SELECT *,DENSE_RANK() OVER(ORDER BY variance) AS shortfall_rank FROM regional;

-- Monthly trend and comparable prior-year month.
WITH monthly AS (
 SELECT date,SUM(revenue) revenue,SUM(budget_revenue) budget,SUM(revenue-cogs) gross_profit
 FROM dbo.fact_finance GROUP BY date
), comparison AS (
 SELECT *,LAG(revenue,12) OVER(ORDER BY date) AS prior_year_revenue FROM monthly
)
SELECT *,(revenue-prior_year_revenue)/NULLIF(prior_year_revenue,0) AS yoy_growth
FROM comparison ORDER BY date;
