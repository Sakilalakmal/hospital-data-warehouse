USE Hospital_DB

-- gold.fact_treatment table
CREATE OR ALTER VIEW gold.fact_treatment AS 
	SELECT 
		treatment_id,
		gfa.appointment_id  AS appointment_id,
		dim_p.patient_key	AS patient_key,
		gd.doctor_key		AS doctor_key,
		st.treatment_type	AS treatment_type,
		st.description		AS treatment_description,
		st.cost AS treatment_cost,
		st.treatment_date	AS treatment_date,
		1					AS treatment_count
	FROM silver.treatments	AS st
	LEFT JOIN 
		gold.fact_appointment AS gfa
			ON st.appointment_id = gfa.appointment_id
	LEFT JOIN 
		gold.dim_patients AS dim_p
			ON gfa.patient_key = dim_p.patient_key
	LEFT JOIN 
		gold.dim_doctor AS gd
			ON gfa.doctor_key = gd.doctor_key


			-- check view --
SELECT * FROM gold.fact_treatment

