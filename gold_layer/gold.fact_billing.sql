USE Hospital_DB

-- gold.fact_billing -- 

CREATE OR ALTER VIEW gold.fact_billing AS 
	SELECT 
		sb.bill_id AS bill_id,
		gdp.patient_id AS patient_id,
		gft.treatment_id AS treatment_id,
		gdd.doctor_key AS doctor_key,
		gfa.appointment_id AS appointment_id,
		sb.amount AS bill_amount,
		sb.payment_method AS payment_method,
		sb.payment_status AS payment_status,
		gft.treatment_type AS treatment_type,
		gdd.hospital_branch AS hospital_branch,
		gdd.specialization AS specialization,
		sb.bill_date AS billing_date,
		1 AS bill_count,
		CASE WHEN 
		sb.payment_status = 'Paid' 
			THEN sb.amount ELSE 0 
				END AS paid_bill_amount,
		CASE WHEN 
		sb.payment_status <> 'Paid' 
			THEN sb.amount ELSE 0 
				END AS unpaid_bill_amount,
		CASE WHEN sb.payment_status = 'Pending'
			THEN sb.amount ELSE 0 
				END AS billing_pending_amount,
		CASE WHEN 
		sb.payment_status = 'Paid' 
			THEN 1 ELSE 0 
				END AS paid_flag
	FROM silver.billing AS sb
	LEFT JOIN 
		gold.dim_patients AS gdp
			ON sb.patient_id = gdp.patient_id
	LEFT JOIN 
		gold.fact_treatment AS gft
			ON sb.treatment_id = gft.treatment_id
	LEFT JOIN 
		gold.dim_doctor AS gdd
			ON gft.doctor_key = gdd.doctor_key
	LEFT JOIN 
		gold.fact_appointment AS gfa
			ON gft.appointment_id = gfa.appointment_id;


select * from gold.fact_billing