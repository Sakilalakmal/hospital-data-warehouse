USE Hospital_DB

-- Top revenue doctor in each hospital branch

SELECT * FROM (
SELECT
bill.doctor_key,
doc.hospital_branch,
doc.doct_full_name,
SUM(bill.paid_bill_amount) total_revenue,
RANK() OVER(PARTITION BY doc.hospital_branch ORDER BY SUM(bill.paid_bill_amount) DESC) AS rn
FROM gold.fact_billing bill
LEFT JOIN gold.dim_doctor AS doc
ON bill.doctor_key = doc.doctor_key
GROUP BY bill.doctor_key , doc.hospital_branch , doc.doct_full_name
)t WHERE rn = 1


-- Patients with more than one treatment type
SELECT 
gold.fact_treatment.patient_key,
pat.full_name,
COUNT(distinct treatment_type) AS counts
FROM gold.fact_treatment
LEFT JOIN gold.dim_patients AS pat
ON gold.fact_treatment.patient_key = pat.patient_key
GROUP BY gold.fact_treatment.patient_key , pat.full_name
having COUNT(distinct treatment_type) > 1

-- Running monthly revenue trend
SELECT 
monthly,
total_revenue,
SUM(total_revenue) OVER(ORDER BY monthly ASC) AS running_totoal
FROM (
SELECT
MONTH(billing_date) AS monthly,
SUM(paid_bill_amount) AS total_revenue
FROM gold.fact_billing
GROUP BY MONTH(billing_date)
) t

-- Doctors whose completed appointments are above the overall doctor average
WITH first_cte AS (
SELECT
doctor_key,
SUM(appointment_count) complete_total
FROM gold.fact_appointment
WHERE completed_flag = 1
GROUP BY doctor_key
)
SELECT
*
FROM first_cte
WHERE complete_total > (
	SELECT
	AVG(complete_total) avg_total
	FROM first_cte
)

-- Most frequent treatment for each specialization

SELECT * FROM (
SELECT 
	doc.specialization,
	trt.treatment_type,
	COUNT(trt.treatment_type) AS treatment_count,
	RANK() OVER(PARTITION BY doc.specialization ORDER BY COUNT(trt.treatment_type) DESC) rn 
FROM gold.fact_treatment AS trt
LEFT JOIN gold.dim_doctor AS doc
ON trt.doctor_key = doc.doctor_key
GROUP BY  doc.specialization , trt.treatment_type
) t WHERE rn = 1