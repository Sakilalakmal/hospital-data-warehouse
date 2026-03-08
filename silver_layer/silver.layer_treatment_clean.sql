USE Hospital_DB

-- check data quality in treatment table

select * from bronze.treatments

select 
treatment_id,
appointment_id
from bronze.treatments
group by treatment_id , appointment_id
having count(*) > 1 

select distinct treatment_type from bronze.treatments

-- checking for unwanted spaces or null values
select * from bronze.treatments where description != TRIM(description) or description IS NULL

-- check where the cost small than 0 and equal to 0
select * from bronze.treatments where cost <= 0

-- check treatment date quality
select * from bronze.treatments where treatment_date > GETDATE()

-- checking invalid appoinment id
select 
* 
from bronze.treatments
where not exists (
	select 1
	from silver.appoinment_table
	where bronze.treatments.appointment_id = silver.appoinment_table.appointment_id
)

-- loadt data into silver layer

PRINT 'Cleaned silver.treatments (SILVER) --'
TRUNCATE TABLE silver.treatments
PRINT 'Loading data into silver.treatments...'
INSERT INTO silver.treatments(
	treatment_id	,
	appointment_id	,
	treatment_type	,
	description		,
	cost			,
	treatment_date  
)
SELECT
treatment_id,
appointment_id,
COALESCE(TRIM(treatment_type),'Unknown') AS treatment_type,
COALESCE(TRIM(description),'Unknown') AS description,
cost,
treatment_date
FROM bronze.treatments

-- check data --
select * from silver.treatments