USE Hospital_DB

-- gold.fact_appointment table

CREATE OR ALTER VIEW gold.fact_appointment AS 
	SELECT
		appointment_id,
		dp.patient_key AS patient_key,
		dd.doctor_key AS doctor_key,
		apt.appointment_date AS appointment_date,
		apt.appointment_time AS appointment_time,
		apt.reason_for_visit AS reason_for_visit,
		apt.status AS appointment_status,
		1 AS appointment_count ,
		CASE 
			WHEN apt.status = 'Completed' THEN 1 
				ELSE 0 END AS completed_flag,
		CASE 
			WHEN apt.status = 'Cancelled' THEN 1 
				ELSE 0 END AS cancelled_flag
	FROM silver.appoinment_table AS apt
	LEFT JOIN gold.dim_patients AS dp
	ON apt.patient_id = dp.patient_id
	LEFT JOIN gold.dim_doctor AS dd
	ON apt.doctor_id = dd.doctor_id;


-- check view 

select * from gold.fact_appointment