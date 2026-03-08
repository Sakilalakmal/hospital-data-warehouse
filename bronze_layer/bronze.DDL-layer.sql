CREATE DATABASE Hospital_DB

-- use hospital db 
USE Hospital_DB;


-- create three schema
CREATE SCHEMA bronze
CREATE SCHEMA silver
CREATE SCHEMA gold

-- CREATE APPOINTMENT TABLE DDL --
IF OBJECT_ID('bronze.appoinment_table','U') IS NOT NULL
DROP TABLE bronze.appoinment_table;

GO
CREATE TABLE bronze.appoinment_table (
	appointment_id		NVARCHAR(50),
	patient_id		    NVARCHAR(50),
	doctor_id			NVARCHAR(50),
	appointment_date	DATE,
	appointment_time	NVARCHAR(50),
	reason_for_visit	NVARCHAR(50),
	status				NVARCHAR(50)

)

-- CREATE PATIENT TABLE DDL --
IF OBJECT_ID('bronze.patients','U') IS NOT NULL
DROP TABLE bronze.patients;

GO
CREATE TABLE bronze.patients (
	
	patient_id			NVARCHAR(50),
	first_name			NVARCHAR(50),
	last_name			NVARCHAR(50),
	gender				NVARCHAR(5),
	date_of_birth		DATE,
	contact_number		NVARCHAR(30),
	address				NVARCHAR(50),
	registration_date	DATE,
	insurance_provider	NVARCHAR(50),
	insurance_number	NVARCHAR(50),
	email				NVARCHAR(50)

)

-- CREATE BILLING TABLE DDL --
IF OBJECT_ID('bronze.billing','U') IS NOT NULL
DROP TABLE bronze.billing;

GO

CREATE TABLE bronze.billing (
	
	bill_id				NVARCHAR(50),
	patient_id			NVARCHAR(50),
	treatment_id		NVARCHAR(50),
	bill_date			DATE,
	amount				INT,
	payment_method		NVARCHAR(50),	
	payment_status		NVARCHAR(50)

)


-- CREATE TREATMENT TABLE DDL --
IF OBJECT_ID('bronze.treatments','U') IS NOT NULL
DROP TABLE bronze.treatments;

GO

CREATE TABLE bronze.treatments (
	
	treatment_id	NVARCHAR(50),
	appointment_id	NVARCHAR(50),
	treatment_type	NVARCHAR(50),
	description		NVARCHAR(50),
	cost			INT,
	treatment_date  DATE

)

-- CREATE TREATMENT TABLE DDL --
IF OBJECT_ID('bronze.doctors','U') IS NOT NULL
DROP TABLE bronze.doctors;

GO

CREATE TABLE bronze.doctors (
	
	doctor_id	NVARCHAR(50),
	first_name	NVARCHAR(50),
	last_name	NVARCHAR(50),
	specialization	NVARCHAR(50),
	phone_number	NVARCHAR(30),
	years_experience	INT,
	hospital_branch	 NVARCHAR(50),
	email  NVARCHAR(80)

)