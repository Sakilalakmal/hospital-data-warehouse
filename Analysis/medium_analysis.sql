use Hospital_DB

-- Top 5 doctors by completed appointments

SELECT TOP(5)
doctor_key,
SUM(completed_flag) AS completed_count
FROM gold.fact_appointment
GROUP BY doctor_key
ORDER BY SUM(completed_flag) DESC


-- Appointment completion rate by doctor

SELECT
	gfa.doctor_key,
	gdd.doct_full_name,
	SUM(gfa.appointment_count) AS total_appoinment,
	SUM(gfa.completed_flag) AS total_complete_appointment,
	CAST(SUM(gfa.completed_flag) * 100 / SUM(gfa.appointment_count) AS DECIMAL(18,2)) AS complete_ratio
FROM gold.fact_appointment AS gfa
LEFT JOIN gold.dim_doctor AS gdd
ON gfa.doctor_key = gdd.doctor_key
GROUP BY gfa.doctor_key , gdd.doct_full_name
ORDER BY complete_ratio DESC

-- Top 5 patients with most appointments

SELECT * FROM (
SELECT 
	pati.patient_key,
	pati.full_name,
	SUM(appointment_count) AS total_appoinments,
    DENSE_RANK() OVER(ORDER BY SUM(appointment_count) DESC)AS rn
FROM gold.fact_appointment AS apoint
LEFT JOIN gold.dim_patients AS pati
ON apoint.patient_key = pati.patient_key
GROUP BY pati.patient_key , pati.full_name
) t 
WHERE rn <= 5

--  Revenue by doctor specialization
SELECT 
doctor_key,
specialization,
SUM(paid_bill_amount) AS revenue_for_specialization
FROM gold.fact_billing
GROUP BY specialization , doctor_key
ORDER BY SUM(paid_bill_amount) DESC

-- Average treatment cost by treatment type
SELECT 
	treatment_type,
	AVG(treatment_cost) AS avg_treatment_cost
FROM gold.fact_treatment
GROUP BY treatment_type
ORDER BY AVG(treatment_cost)

-- Monthly revenue trend
SELECT 
	MONTH(billing_date) AS month,
	SUM(paid_bill_amount) AS total_amount
FROM gold.fact_billing
GROUP BY MONTH(billing_date)
ORDER BY MONTH(billing_date)

-- Doctor generating the highest billing revenue using window function

SELECT * FROM (
SELECT 
doc.doct_full_name,
SUM(bill.paid_bill_amount) total_revenue,
RANK() OVER(ORDER BY SUM(bill.paid_bill_amount) DESC) AS rn
FROM gold.fact_billing AS bill
LEFT JOIN gold.dim_doctor AS doc
ON bill.doctor_key = doc.doctor_key
GROUP BY doc.doct_full_name
) t 
WHERE rn = 1

-- Patients with unpaid or pending bills

SELECT 
	bill.patient_id,
	pat.full_name,
	SUM(unpaid_bill_amount) AS unpaid_bill_amount,
	SUM(billing_pending_amount) AS pending_bill_amount
FROM gold.fact_billing bill
LEFT JOIN gold.dim_patients pat
ON bill.patient_id = pat.patient_id
GROUP BY bill.patient_id , pat.full_name
HAVING SUM(unpaid_bill_amount) > 0 OR SUM(billing_pending_amount) > 0

-- Most common reason for visit
SELECT 
	reason_for_visit,
	COUNT(*) count
FROM gold.fact_appointment
GROUP BY reason_for_visit
ORDER BY COUNT(*) DESC

-- Revenue contribution by hospital branch and specialization

SELECT
	hospital_branch,
	specialization,
	SUM(paid_bill_amount) AS revenue
FROM gold.fact_billing
GROUP BY hospital_branch , specialization
ORDER BY SUM(paid_bill_amount) DESC