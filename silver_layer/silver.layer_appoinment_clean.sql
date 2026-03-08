USE Hospital_DB

select * from bronze.appoinment_table

-- check data quality

select appointment_id from bronze.appoinment_table group by appointment_id having count(*) > 1

select distinct status from bronze.appoinment_table

select distinct reason_for_visit from bronze.appoinment_table

-- integrity testing --

select 
apt.patient_id
from bronze.appoinment_table AS apt 
LEFT JOIN bronze.patients AS pt
ON apt.patient_id = pt.patient_id
where pt.patient_id IS NULL

-- (alternative)
SELECT *
FROM bronze.appoinment_table
WHERE NOT EXISTS (
	SELECT 1
	FROM bronze.patients AS pt
	WHERE bronze.appoinment_table.patient_id = pt.patient_id
)

-- check is there any doctors in appoinmnt but not in doctors table
SELECT
	* 
FROM bronze.appoinment_table
WHERE NOT EXISTS(
	SELECT 1
	FROM bronze.doctors
	WHERE bronze.appoinment_table.doctor_id = bronze.doctors.doctor_id
)


PRINT 'Cleaned silver.appoinment_table --'
TRUNCATE TABLE silver.appoinment_table
PRINT 'Loading data into silver.appoinment_table...'
INSERT INTO silver.appoinment_table(
	appointment_id		,
	patient_id		   ,
	doctor_id			,
	reason_for_visit	,
	status,
	appointment_time	,
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
FROM bronze.appoinment_table

-- check data
select * from silver.appoinment_table