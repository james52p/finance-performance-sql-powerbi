# Data dictionary and model

Raw sales: 6,912 simulated sale records; sale_id is unique; date is the transaction date. product_id and region_id reference dimensions. gross_cents, discount_cents and cogs_cents are nonnegative integer cents. Net revenue = gross minus discount. Each row represents a synthetic sale, without customer, quantity or invoice data.

Raw budget: 288 rows at month start × product × region; revenue_cents is planned net revenue and cogs_cents is planned cost. Composite primary key prevents duplicate budget rows.

fact_finance: 288 rows at month start × product × region. Currency columns are USD converted from cents: gross_revenue, discount, revenue, cogs, budget_revenue, budget_cogs. transaction_count is the count of contributing sales. has_actual and has_budget flag source coverage (0/1); zero-filling is not evidence of completeness. All flags are 1 in this dataset.

dim_date: continuous 731-day calendar for 2024–2025; date primary key, year, month_number, month_name, year_month, month_start. dim_product: three categories with product_id primary key. dim_region: four fictional regions with region_id primary key.

Relationships: dim_date[date] → fact_finance[date]; dim_product[product_id] → fact_finance[product_id]; dim_region[region_id] → fact_finance[region_id]. All one-to-many, active, single direction from dimension to fact. No fact-to-fact join. Filter monthly or higher because the fact is monthly; a day-level selection includes only month-start rows.

Positive revenue or profit variance is favorable. Margin variance is actual minus budget in percentage points; format as 0.00 followed by “pp”, not percent. The model uses calendar years and has no daily actual-versus-budget reporting.
