USE Hospital_DB 

CREATE OR ALTER PROCEDURE silver.load_silver
AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start DATETIME;
	SET @start_time = GETDATE();
	PRINT '================================================';
	PRINT 'Silver Layer Load - Started at: ' + CONVERT(VARCHAR, @start_time, 120);
	PRINT '================================================';

	BEGIN TRY

	SET @batch_start = GETDATE();
	PRINT '>> Cleaning and Loading silver.patients...';

	TRUNCATE TABLE silver.patients;

	INSERT INTO
		silver.patients (
			patient_id,
			first_name,
			last_name,
			gender,
			date_of_birth,
			age,
			contact_number,
			address,
			insurance_provider,
			insurance_number,
			email,
			registration_date
		)
	SELECT
		patient_id,
		TRIM(first_name) AS first_name,
		TRIM(last_name) AS last_name,
		CASE
			WHEN UPPER(gender) = 'F' THEN 'Female'
			WHEN UPPER(gender) = 'M' THEN 'Male'
			ELSE 'N/A'
		END gender,
		date_of_birth,
		DATEDIFF(YEAR, date_of_birth, GETDATE()) AS age,
		CONCAT('+', contact_number) AS contact_number,
		TRIM(address) AS address,
		TRIM(insurance_provider) AS insurance_provider,
		insurance_number,
		email,
		registration_date
	FROM
		(
			SELECT
				*,
				ROW_NUMBER() OVER(
					PARTITION BY patient_id
					ORDER BY
						registration_date ASC
				) AS rn
			FROM
				bronze.patients
		) t
	WHERE
		rn = 1

	PRINT '>> silver.patients loaded in ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' seconds.';

		--- load data into silver.doctors
		SET @batch_start = GETDATE();
		PRINT 'Cleaned silver.doctors--' 
		TRUNCATE TABLE silver.doctors PRINT 'Loading data into silver.doctors...'
	INSERT INTO
		silver.doctors(
			doctor_id,
			first_name,
			last_name,
			specialization,
			phone_number,
			years_experience,
			hospital_branch,
			email
		)
	SELECT
		doctor_id,
		first_name,
		last_name,
		specialization,
		CONCAT('+', phone_number) AS phone_number,
		years_experience,
		hospital_branch,
		email
	FROM
		bronze.doctors

	PRINT '>> silver.doctors loaded in ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' seconds.';

		SET @batch_start = GETDATE();
		PRINT 'Cleaned silver.appoinment_table --' 
		TRUNCATE TABLE silver.appoinment_table PRINT 'Loading data into silver.appoinment_table...'
	INSERT INTO
		silver.appoinment_table(
			appointment_id,
			patient_id,
			doctor_id,
			reason_for_visit,
			status,
			appointment_time,
			appointment_date
		)
	SELECT
		appointment_id,
		patient_id,
		doctor_id,
		TRIM(reason_for_visit) AS reason_for_visit,
		TRIM(status) AS status,
		appointment_time,
		appointment_date
	FROM
		bronze.appoinment_table

	PRINT '>> silver.appoinment_table loaded in ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' seconds.';

	-- loadt data into silver layer
	SET @batch_start = GETDATE();
	PRINT 'Cleaned silver.treatments (SILVER) --' 
	TRUNCATE TABLE silver.treatments PRINT 'Loading data into silver.treatments...'
	INSERT INTO
		silver.treatments(
			treatment_id,
			appointment_id,
			treatment_type,
			description,
			cost,
			treatment_date
		)
	SELECT
		treatment_id,
		appointment_id,
		COALESCE(TRIM(treatment_type), 'Unknown') AS treatment_type,
		COALESCE(TRIM(description), 'Unknown') AS description,
		cost,
		treatment_date
	FROM
		bronze.treatments

	PRINT '>> silver.treatments loaded in ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' seconds.';

	-- load data into silver billing table
	SET @batch_start = GETDATE();
	PRINT 'Cleaned silver.billing (SILVER) --' 
	TRUNCATE TABLE silver.billing PRINT 'Loading data into silver.billing...'
	INSERT INTO
		silver.billing(
			bill_id,
			patient_id,
			treatment_id,
			bill_date,
			amount,
			payment_method,
			payment_status
		)
	SELECT
		bill_id,
		patient_id,
		treatment_id,
		bill_date,
		amount,
		COALESCE(TRIM(payment_method), 'Unknown') AS payment_method,
		COALESCE(TRIM(payment_status), 'Unknown') AS payment_status
	FROM
		bronze.billing

	PRINT '>> silver.billing loaded in ' + CAST(DATEDIFF(SECOND, @batch_start, GETDATE()) AS VARCHAR) + ' seconds.';

	SET @end_time = GETDATE();
	PRINT '================================================';
	PRINT 'Silver Layer Load - Completed at: ' + CONVERT(VARCHAR, @end_time, 120);
	PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';
	PRINT '================================================';

	END TRY
	BEGIN CATCH
		PRINT '================================================';
		PRINT 'ERROR occurred during Silver Layer Load!';
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
		PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
		PRINT '================================================';
	END CATCH
END;
go