USE Hospital_DB

-- check data quality

select * from bronze.billing

-- check duplicate bill_id and treatment_id
select bill_id , treatment_id from bronze.billing group by bill_id,treatment_id having count(*) > 1

-- checking invalid bill dates 

select * from bronze.billing where bill_date > GETDATE() 

-- checking negative amount
select * from bronze.billing where amount <= 0

-- check distinct methods 
select distinct payment_method from bronze.billing

-- check distinct payment status
select distinct payment_status from bronze.billing

-- check is there any treatment_id or patient_id that didn't exist treatment or patient tabless
select * 
from bronze.billing
where not exists(
	select 1
	from bronze.treatments
	where bronze.billing.treatment_id = bronze.treatments.treatment_id
)

select * 
from bronze.billing
where not exists(
	select 1
	from bronze.patients
	where bronze.billing.patient_id = bronze.patients.patient_id
)


-- load data into silver billing table
PRINT 'Cleaned silver.billing (SILVER) --'
TRUNCATE TABLE silver.billing
PRINT 'Loading data into silver.billing...'
INSERT INTO silver.billing(
	bill_id				,
	patient_id			,
	treatment_id		,
	bill_date			,
	amount				,
	payment_method		,	
	payment_status	
)
SELECT
bill_id,
patient_id,
treatment_id,
bill_date,
amount,
COALESCE(TRIM(payment_method),'Unknown') AS payment_method,
COALESCE(TRIM(payment_status),'Unknown') AS payment_status
FROM bronze.billing