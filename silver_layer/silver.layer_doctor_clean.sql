use Hospital_DB

-- cleaning doctors table--

select * from bronze.doctors

-- check duplicate doctors

select doctor_id from bronze.doctors group by doctor_id having count(*) > 1

-- check if there negative value in years of experience
select * from bronze.doctors where years_experience <= 0 

-- looking for unwanted spaces

select
doctor_id,
first_name,
last_name,
specialization,
phone_number,
years_experience,
hospital_branch,
email
from 
bronze.doctors
where first_name != TRIM(first_name)
or last_name != TRIM(last_name)
or specialization != TRIM(specialization)
or phone_number != trim(phone_number)
or hospital_branch != TRIM(hospital_branch)
or email != TRIM(email)

-- looking for duplicate email addresses
select email from bronze.doctors group by email having COUNT(*) > 1 


--- load data into silver.doctors
PRINT 'Cleaned silver.doctors--'
TRUNCATE TABLE silver.doctors
PRINT 'Loading data into silver.doctors...'
INSERT INTO silver.doctors(
	
	doctor_id	,
	first_name	,
	last_name	,
	specialization	,
	phone_number	,
	years_experience	,
	hospital_branch	 ,
	email
)
SELECT
doctor_id,
first_name,
last_name,
specialization,
CONCAT('+',phone_number) AS phone_number,
years_experience,
hospital_branch,
email
FROM bronze.doctors