USE Hospital_DB

-- check data quality -- 
-- bronze.patient table
select * from bronze.patients

-- clean silver patient data -- 

PRINT '>> Cleaning and Loading silver.patients...';
TRUNCATE TABLE silver.patients;
INSERT INTO silver.patients
	(
			patient_id	,		
	first_name			,
	last_name			,
	full_name,
	gender				,
	date_of_birth		,
	age,
	age_band,
	contact_number	,
	address			,
	insurance_provider,
	insurance_number,
	email			,
	registration_date
	)
SELECT 
patient_id,
TRIM(first_name) AS first_name,
TRIM(last_name) AS last_name,
CONCAT(TRIM(first_name),' ',TRIM(last_name)) AS full_name,
CASE WHEN UPPER(gender) = 'F' THEN 'Female'
     WHEN UPPER(gender) = 'M' THEN 'Male'
	 ELSE 'N/A'
END gender,
date_of_birth,
DATEDIFF(YEAR,date_of_birth,GETDATE()) AS age,
CASE WHEN DATEDIFF(YEAR,date_of_birth,GETDATE()) BETWEEN 0 AND 12 THEN 'Child'
     WHEN DATEDIFF(YEAR,date_of_birth,GETDATE()) BETWEEN 13 AND 19 THEN 'Teen'
	 WHEN DATEDIFF(YEAR,date_of_birth,GETDATE()) BETWEEN 20 AND 35 THEN 'Young Adult'
	 WHEN DATEDIFF(YEAR,date_of_birth,GETDATE()) BETWEEN 36 AND 55 THEN 'Adult'
     WHEN DATEDIFF(YEAR,date_of_birth,GETDATE()) BETWEEN 56 AND 75 THEN 'Senior'
	 ELSE 'Elderly'
END AS age_band,
CONCAT('+',contact_number) AS contact_number,
TRIM(address) AS address,
TRIM(insurance_provider) AS insurance_provider,
insurance_number,
email,
registration_date
FROM (
   SELECT *,
   ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY registration_date ASC) AS rn
   FROM bronze.patients
)t 
WHERE rn = 1


-- check is there any patient_id null or duplicate

select 
	patient_id
from bronze.patients
group by patient_id
having count(*) > 1 or patient_id IS NULL

-- check where we have blank spaces 
select 
	first_name,
	last_name,
	gender,
	contact_number,
	address,
	insurance_provider,
	email
from bronze.patients
where first_name != TRIM(first_name) 
	or last_name != TRIM(last_name) 
	or gender != trim(gender) 
	or contact_number != TRIM(contact_number) 
	or address != TRIM(address) 
	or insurance_provider != TRIM(insurance_provider)
	or email != TRIM(email)

-- checking gender 
select 
	gender
from bronze.patients
where gender is null

-- check email address quality
select 
replace(email,'.','') email
from bronze.patients
group by replace(email,'.','')
having count(*) > 1

select * from bronze.patients where email = 'alex.moore@mail.com'

SELECT distinct email
from bronze.patients

-- check data silver.patients

select * from silver.patients

-- check data quality again
select 
	patient_id
from silver.patients
group by patient_id
having count(*) > 1 or patient_id IS NULL

select 
	first_name,
	last_name,
	gender,
	contact_number,
	address,
	insurance_provider,
	email
from silver.patients
where first_name != TRIM(first_name) 
	or last_name != TRIM(last_name) 
	or gender != trim(gender) 
	or contact_number != TRIM(contact_number) 
	or address != TRIM(address) 
	or insurance_provider != TRIM(insurance_provider)
	or email != TRIM(email)

select 
	gender
from silver.patients
where gender is null

select email from silver.patients group by email having count(*) > 1