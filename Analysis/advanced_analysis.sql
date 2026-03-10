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

-- Patients whose total paid billing is above the average patient billing

WITH total_paid AS (
select 
bill.patient_id AS patient_id,
SUM(paid_bill_amount) AS total_paid
from gold.fact_billing AS bill
GROUP BY bill.patient_id
)
SELECT 
total_paid.patient_id,
gp.full_name
FROM total_paid
LEFT JOIN gold.dim_patients AS gp
ON total_paid.patient_id = gp.patient_id
WHERE total_paid.total_paid > (SELECT AVG(total_paid) from total_paid)

-- Specializations with cancellation rate higher than overall cancellation rate
WITH appointment_count AS (
    SELECT 
        doc.specialization AS spec,
        SUM(apo.appointment_count) AS total_appointment,
        SUM(CASE 
                WHEN apo.cancelled_flag = 1 
                THEN apo.appointment_count 
                ELSE 0 
            END) AS cancel_appointment
    FROM gold.fact_appointment AS apo
    LEFT JOIN gold.dim_doctor AS doc
        ON apo.doctor_key = doc.doctor_key
    GROUP BY doc.specialization
)

SELECT 
    spec,
    cancel_appointment,
    total_appointment,
    CAST(cancel_appointment * 100.0 / total_appointment AS DECIMAL(18,2)) AS cancel_ratio
FROM appointment_count
WHERE cancel_appointment * 100.0 / total_appointment >
(
    SELECT 
        SUM(CASE 
                WHEN cancelled_flag = 1 
                THEN appointment_count 
                ELSE 0 
            END) * 100.0 
        / SUM(appointment_count)
    FROM gold.fact_appointment
);

-- return doctors whose completed appointments are above average (using where clause)

SELECT 
    doc.doctor_key,
    doc.doct_full_name,
    doc.email,
    doc.specialization,
    doc.hospital_branch,
    doc.phone_number
FROM gold.dim_doctor AS doc
WHERE EXISTS (
    
    SELECT 1
    FROM gold.fact_appointment AS apo
    WHERE apo.doctor_key = doc.doctor_key AND completed_flag = 1
    HAVING SUM(apo.appointment_count) > (
        SELECT AVG(total_com_appointment) FROM (
                SELECT
                    SUM(appointment_count) AS total_com_appointment
                FROM gold.fact_appointment
                WHERE completed_flag = 1 
                GROUP BY doctor_key
        ) AS avg_complete_appoinment
    )
    
);
              -- with cte but u should use where clause --
              
              WITH completed_count AS (
              SELECT
              apo.doctor_key,
              SUM(apo.appointment_count) AS completed_appoinments
              FROM gold.fact_appointment AS apo
              WHERE apo.completed_flag = 1
              GROUP BY apo.doctor_key
              )
              SELECT
              doctor_key,
              doct_full_name,
              hospital_branch,
              specialization
              FROM gold.dim_doctor
              WHERE EXISTS (
                SELECT 1
                FROM completed_count
                WHERE gold.dim_doctor.doctor_key = completed_count.doctor_key AND completed_appoinments > (
                    SELECT 
                    AVG(completed_appoinments * 1.0)
                    FROM completed_count
                )
              );

-- which specializations have most completed appoinments

WITH spec_count AS (
    SELECT 
        doc.specialization AS spec,
        SUM(appointment_count) AS total_appoinment
    FROM gold.fact_appointment AS apo
    LEFT JOIN gold.dim_doctor AS doc
    ON apo.doctor_key = doc.doctor_key
    WHERE apo.completed_flag = 1
    GROUP BY doc.specialization
    )
    ,
    rank_one AS (
    SELECT
        spec,
        total_appoinment,
        RANK() OVER(ORDER BY total_appoinment DESC) AS rn
    FROM spec_count
    )
    SELECT 
        spec AS specialization,
        total_appoinment
    from rank_one
    WHERE rn = 1

-- Doctors whose cancellation rate is above hospital average
WITH doctors_total AS (
SELECT
apo.doctor_key AS doctor_key,
SUM(appointment_count) AS total_appoinment
FROM gold.fact_appointment AS apo
GROUP BY apo.doctor_key
),
cancel_appoinment AS (
SELECT
doctor_key,
SUM(appointment_count) AS total_cancel_appoinment
FROM gold.fact_appointment
WHERE cancelled_flag = 1
GROUP BY doctor_key
),
cancel_ration AS (
SELECT
dt.doctor_key AS doc_key,
ca.total_cancel_appoinment * 100 / dt.total_appoinment AS cancellation_rate
FROM doctors_total AS dt
LEFT JOIN cancel_appoinment AS ca
ON dt.doctor_key = ca.doctor_key
)
SELECT
cr.doc_key,
gdd.doct_full_name,
gdd.specialization
FROM cancel_ration AS cr
LEFT JOIN gold.dim_doctor AS gdd
ON cr.doc_key = gdd.doctor_key
WHERE cr.cancellation_rate > (

    SELECT
    SUM(cancelled_flag) * 100 / SUM(appointment_count)
    FROM gold.fact_appointment
)

-- Rank the most common treatment inside each specialization
WITH details_query AS (
	select
		treat.treatment_id as treat_id,
		doc.doctor_key AS doct_key,
		doc.specialization AS doc_spec,
		treat.treatment_type AS treatment_type,
		treat.treatment_description
	from gold.fact_treatment AS treat
	LEFT JOIN 
		gold.dim_doctor AS doc
	ON treat.doctor_key	=
				doc.doctor_key
	),
	count_treatment AS (
	select
		doc_spec,
		treatment_type,
		COUNT(treatment_type) AS count
	from details_query
	group by doc_spec 
			, treatment_type
	),
	rank_cte AS (
	SELECT
		doc_spec,
		treatment_type,
		count,
		RANK() OVER(PARTITION BY doc_spec 
			ORDER BY count DESC) AS rn
	from count_treatment
	)
	select
	*
	from rank_cte
	WHERE rn <= 3;


-- Find month-over-month growth in completed appointments for each doctor

WITH calc_query AS (
	SELECT
		doctor_key,
		MONTH(appointment_date) AS monthly,
		sum(appointment_count) AS completed_appointments,
		LAG(sum(appointment_count)) 
			OVER(PARTITION BY doctor_key 
				ORDER BY doctor_key ASC) AS lag_count
	FROM gold.fact_appointment
	WHERE completed_flag = 1
	group by 
		doctor_key , MONTH(appointment_date)
	)
	select * , 
		completed_appointments - lag_count AS growth_difference,
		CASE WHEN lag_count IS NULL OR lag_count = 0 THEN NULL
			ELSE CONCAT((completed_appointments - lag_count) * 100 / lag_count ,'%') 
		END	AS percentage
		
	from calc_query
	ORDER BY 
		doctor_key , monthly