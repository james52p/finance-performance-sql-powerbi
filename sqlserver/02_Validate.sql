USE FinancePortfolio2025;
GO
SET NOCOUNT ON;
IF (SELECT COUNT(*) FROM dbo.raw_sales) <> 6912 THROW 50002, 'Sales count mismatch', 1;
IF (SELECT COUNT(*) FROM dbo.raw_budget) <> 288 THROW 50003, 'Budget count mismatch', 1;
IF (SELECT COUNT(*) FROM dbo.fact_finance) <> 288 THROW 50004, 'Fact count mismatch', 1;
IF EXISTS(SELECT date,product_id,region_id FROM dbo.fact_finance GROUP BY date,product_id,region_id HAVING COUNT(*)>1) THROW 50005, 'Duplicate fact grain', 1;
IF EXISTS(SELECT 1 FROM dbo.fact_finance WHERE has_actual=0 OR has_budget=0) THROW 50006, 'Missing source combinations', 1;
IF (SELECT SUM(revenue) FROM dbo.fact_finance) <> (SELECT CAST(SUM(gross_cents-discount_cents)/100.0 AS decimal(19,2)) FROM dbo.raw_sales) THROW 50007, 'Revenue reconciliation failed', 1;
IF (SELECT SUM(budget_revenue) FROM dbo.fact_finance) <> (SELECT CAST(SUM(revenue_cents)/100.0 AS decimal(19,2)) FROM dbo.raw_budget) THROW 50008, 'Budget reconciliation failed', 1;
IF (SELECT SUM(transaction_count) FROM dbo.fact_finance) <> 6912 THROW 50009, 'Transaction count reconciliation failed', 1;
IF (SELECT COUNT(*) FROM dbo.dim_date) <> 731 OR DATEDIFF(day,(SELECT MIN(date) FROM dbo.dim_date),(SELECT MAX(date) FROM dbo.dim_date)) <> 730 THROW 50010, 'Incomplete calendar', 1;
SELECT 'PASS: all nine SQL Server checks' AS validation_status;
SELECT d.year,SUM(f.revenue) AS revenue,SUM(f.budget_revenue) AS budget_revenue,
SUM(f.revenue-f.budget_revenue) AS revenue_variance,SUM(f.revenue-f.cogs) AS gross_profit,
SUM(f.revenue-f.cogs)/NULLIF(SUM(f.revenue),0) AS gross_margin
FROM dbo.fact_finance f JOIN dbo.dim_date d ON d.date=f.date GROUP BY d.year ORDER BY d.year;
