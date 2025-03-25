/*
===========================================================================
Quality Checks
===========================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardization across the 'silver' schemas. It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields.

Usage Notes:
  - Run these checks after data loading Silver layer.
  - Investigate and resolve any discrepancies found during the checks.
============================================================================
*/

-- =========================================================================
-- Checking 'silver.crm_cust_info'
-- =========================================================================

-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT	cst_id,
		COUNT(*)
FROM	silver.crm_cust_info
GROUP BY cst_id
HAVING	 COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- Expectation: No Results

SELECT	cst_firstname
FROM	silver.crm_cust_info
WHERE	cst_firstname != TRIM(cst_firstname);

SELECT	cst_lastname
FROM	silver.crm_cust_info
WHERE	cst_lastname != TRIM(cst_lastname);

SELECT	cst_gndr
FROM	silver.crm_cust_info
WHERE	cst_gndr != TRIM(cst_gndr);

-- Data Standarzitation & Consistency 

SELECT	DISTINCT cst_gndr
FROM	silver.crm_cust_info;

SELECT	DISTINCT cst_marital_status
FROM	silver.crm_cust_info;


-- =========================================================================
-- Checking 'silver.crm_prd_info'
-- =========================================================================

-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT	prd_id,
		COUNT(*)
FROM	silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- Expectation - No Result

SELECT	prd_nm
FROM	silver.crm_prd_info
WHERE	prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative numbers
-- Expectation: No Result

SELECT	prd_cost
FROM	silver.crm_prd_info
WHERE	prd_cost < 0 OR prd_cost IS NULL;

-- Data Standarzitation & Consistency 

SELECT	DISTINCT prd_line
FROM	siver.crm_prd_info

-- Check for invalid Date Orders
-- end date must not be earlier than the start date

SELECT	*
FROM	silver.crm_prd_info
WHERE	prd_end_dt < prd_start_dt;


-- =========================================================================
-- Checking 'silver.crm_sales_details'
-- =========================================================================

-- Unwanted spaces in sls_ord_num
-- Expectation: No Result

SELECT	*
FROM	silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


-- Check integrity of the 'sls_prd_key'
-- Expectation: No Result

SELECT	*
FROM	silver.crm_sales_details
WHERE	sls_prd_key NOT IN  (
		SELECT	prd_key
		FROM	silver.crm_prd_info);


-- Check integrity of the 'sls_cust_id'
-- Expectation: No Result

SELECT	*
FROM	silver.crm_sales_details
WHERE	sls_cust_id NOT IN  (
		SELECT	cst_id
		FROM	silver.crm_cust_info);



-- Check for invalid dates
-- Checking for negative nunmbers

SELECT	*
FROM	silver.crm_sales_details
WHERE	sls_order_dt < 0;


-- Checking for Zero values

SELECT	*
FROM	silver.crm_sales_details
WHERE	sls_order_dt <= 0;

SELECT	NULLIF(sls_order_dt, 0) sls_order_dt
FROM	silver.crm_sales_details
WHERE	sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8  -- In this scenario, the length of the date must be 8
OR sls_order_dt > 20500101 -- Check for outliers by validating the boundaries of the date range
OR sls_order_dt < 19000101;


-- check for Invalid dates in 'sls_ship_dt'

SELECT	NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM	silver.crm_sales_details
WHERE	sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8  
OR sls_ship_dt > 20500101 
OR sls_ship_dt < 19000101;


-- check for Invalid dates in 'sls_due_dt'

SELECT	NULLIF(sls_due_dt, 0) sls_due_dt
FROM	silver.crm_sales_details
WHERE	sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8  
OR sls_due_dt > 20500101 
OR sls_due_dt < 19000101;


-- Check for Invalid Date Orders

SELECT	*
FROM	silver.crm_sales_details
WHERE	sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


-- =========================================================================
-- Checking 'silver.erp_cust_az12'
-- =========================================================================

-- Identify Out-of-Range Dates

SELECT	DISTINCT bdate
FROM	silver.erp_cust_az12
WHERE	bdate < '1924-01-01' OR bdate > GETDATE();


-- Data Standardization & Consistency

SELECT DISTINCT gen
FROM	silver.erp_cust_az12;


-- =========================================================================
-- Checking 'silver.erp_loc_a101'
-- =========================================================================

-- Data Standardization & Consistency

SELECT DISTINCT cntry
FROM	silver.erp_loc_a101
ORDER BY cntry;


-- =========================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =========================================================================

-- Check for unwanted spaces

SELECT	*
FROM	silver.erp_px_cat_g1v2
WHERE	cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data standardization & Consistency

SELECT DISTINCT
	cat
FROM	silver.erp_px_cat_g1v2;


SELECT DISTINCT
	subcat
FROM	silver.erp_px_cat_g1v2;	

SELECT DISTINCT
	maintenance
FROM	silver.erp_px_cat_g1v2;
