USE Hospital_DB

-- gold.dim_doctor table --

CREATE OR ALTER VIEW gold.dim_doctor AS
	SELECT 
		ROW_NUMBER() OVER (ORDER BY doctor_id) AS doctor_key,
		doctor_id,
		first_name,
		last_name,
		doct_full_name,
		specialization,
		years_experience,
		hospital_branch,
		email,
		phone_number
	FROM silver.doctors

	-- check view -- 
SELECT * from gold.dim_doctor