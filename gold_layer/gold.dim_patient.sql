USE Hospital_DB

-- gold.dim_patient table

CREATE VIEW gold.dim_patients AS 
	SELECT 
		ROW_NUMBER() OVER(ORDER BY patient_id) AS patient_key,
		patient_id,
		first_name,
		last_name,
		full_name,
		gender,
		age,
		age_band,
		date_of_birth,
		insurance_provider,
		insurance_number,
		registration_date,
		email,
		contact_number,
		address
	FROM silver.patients

	-- check view --
	select * from gold.dim_patients