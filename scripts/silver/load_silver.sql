/*
===========================================================
Stored Procedure: Load Silver Layer
============================================================
Script Purpose:
  Load data into tables from bronze tables
  - Truncate tables before loading data.
  - Loads data from bronze to silver layer
  - Includes transformation, error handling and timing

Parameters:
  None.

Usage Example:
  EXEC silver.load_silver
=============================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	-- Declare timing variables
	DECLARE @start_time DATETIME2 = SYSDATETIME();
	DECLARE @section_start DATETIME2;
	DECLARE @section_end DATETIME2;

	BEGIN TRY

		PRINT '=====================================';
		PRINT 'Loading Silver layer...';
		PRINT '=====================================';

		PRINT '------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------';

		-- =========================
		-- Load: silver.crm_cust_info
		-- =========================
		SET @section_start = SYSDATETIME();

		PRINT '>> Truncating table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT '>> Inserting data to table: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gender,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname),
			TRIM(cst_lastname),
			CASE 
				WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END,
			CASE 
				WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END,
			cst_create_date
		FROM (
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1;

		SET @section_end = SYSDATETIME();
		PRINT '>> Time taken for crm_cust_info: ' + CAST(DATEDIFF(MILLISECOND, @section_start, @section_end) AS VARCHAR) + ' ms';

		-- =========================
		-- Load: silver.crm_prd_info
		-- =========================
		SET @section_start = SYSDATETIME();

		PRINT '>> Truncating table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT '>> Inserting data to table: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
			SUBSTRING(prd_key, 7, LEN(prd_key)),
			prd_nm,
			ISNULL(prd_cost, 0),
			CASE UPPER(TRIM(prd_line)) 
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END,
			CAST(prd_start_dt AS DATE),
			CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE)
		FROM bronze.crm_prd_info;

		SET @section_end = SYSDATETIME();
		PRINT '>> Time taken for crm_prd_info: ' + CAST(DATEDIFF(MILLISECOND, @section_start, @section_end) AS VARCHAR) + ' ms';

		-- =============================
		-- Load: silver.crm_sales_details
		-- =============================
		SET @section_start = SYSDATETIME();

		PRINT '>> Truncating table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT '>> Inserting data to table: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END
		FROM bronze.crm_sales_details;

		SET @section_end = SYSDATETIME();
		PRINT '>> Time taken for crm_sales_details: ' + CAST(DATEDIFF(MILLISECOND, @section_start, @section_end) AS VARCHAR) + ' ms';

		PRINT '------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------';
		-- =========================
		-- Load: silver.erp_cust_az12
		-- =========================
		SET @section_start = SYSDATETIME();

		PRINT '>> Truncating table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT '>> Inserting data to table: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
			CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
			CASE 
				WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END
		FROM bronze.erp_cust_az12;

		SET @section_end = SYSDATETIME();
		PRINT '>> Time taken for erp_cust_az12: ' + CAST(DATEDIFF(MILLISECOND, @section_start, @section_end) AS VARCHAR) + ' ms';

		-- =========================
		-- Load: silver.erp_loc_a101
		-- =========================
		SET @section_start = SYSDATETIME();

		PRINT '>> Inserting data to table: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT	
			REPLACE(cid, '-', ''),
			CASE 
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END
		FROM bronze.erp_loc_a101;

		SET @section_end = SYSDATETIME();
		PRINT '>> Time taken for erp_loc_a101: ' + CAST(DATEDIFF(MILLISECOND, @section_start, @section_end) AS VARCHAR) + ' ms';

		-- ============================
		-- Load: silver.erp_px_cat_g1v2
		-- ============================
		SET @section_start = SYSDATETIME();

		PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT '>> Inserting data to table: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @section_end = SYSDATETIME();
		PRINT '>> Time taken for erp_px_cat_g1v2: ' + CAST(DATEDIFF(MILLISECOND, @section_start, @section_end) AS VARCHAR) + ' ms';

		-- ========================
		-- Total Duration
		-- ========================
		DECLARE @end_time DATETIME2 = SYSDATETIME();
		PRINT '>> Total procedure time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

	END TRY
	BEGIN CATCH
		PRINT '===============================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE:'+ ERROR_MESSAGE();
		PRINT 'ERROR NUMBER:'+ CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE:'+ CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '===============================================';
	END CATCH
END

--EXEC silver.load_silver;
