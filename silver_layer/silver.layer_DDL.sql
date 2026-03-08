-- use hospital db 
USE Hospital_DB;


-- create three schema

CREATE SCHEMA silver

-- CREATE APPOINTMENT TABLE DDL --
IF OBJECT_ID('silver.appoinment_table','U') IS NOT NULL
DROP TABLE silver.appoinment_table;

GO
CREATE TABLE silver.appoinment_table (
	appointment_id		NVARCHAR(50),
	patient_id		    NVARCHAR(50),
	doctor_id			NVARCHAR(50),
	appointment_date	DATE,
	appointment_time	NVARCHAR(50),
	reason_for_visit	NVARCHAR(50),
	status				NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

)

-- CREATE PATIENT TABLE DDL --
IF OBJECT_ID('silver.patients','U') IS NOT NULL
DROP TABLE silver.patients;

GO
CREATE TABLE silver.patients (
	
	patient_id			NVARCHAR(50),
	first_name			NVARCHAR(50),
	last_name			NVARCHAR(50),
	gender				NVARCHAR(10),
	date_of_birth		DATE,
	age INT,
	contact_number		NVARCHAR(30),
	address				NVARCHAR(50),
	insurance_provider	NVARCHAR(50),
	insurance_number	NVARCHAR(50),
	email				NVARCHAR(50),
	registration_date	DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

)

-- CREATE BILLING TABLE DDL --
IF OBJECT_ID('silver.billing','U') IS NOT NULL
DROP TABLE silver.billing;

GO

CREATE TABLE silver.billing (
	
	bill_id				NVARCHAR(50),
	patient_id			NVARCHAR(50),
	treatment_id		NVARCHAR(50),
	bill_date			DATE,
	amount				INT,
	payment_method		NVARCHAR(50),	
	payment_status		NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

)


-- CREATE TREATMENT TABLE DDL --
IF OBJECT_ID('silver.treatments','U') IS NOT NULL
DROP TABLE silver.treatments;

GO

CREATE TABLE silver.treatments (
	
	treatment_id	NVARCHAR(50),
	appointment_id	NVARCHAR(50),
	treatment_type	NVARCHAR(50),
	description		NVARCHAR(50),
	cost			INT,
	treatment_date  DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

)

-- CREATE TREATMENT TABLE DDL --
IF OBJECT_ID('silver.doctors','U') IS NOT NULL
DROP TABLE silver.doctors;

GO

CREATE TABLE silver.doctors (
	
	doctor_id	NVARCHAR(50),
	first_name	NVARCHAR(50),
	last_name	NVARCHAR(50),
	specialization	NVARCHAR(50),
	phone_number	NVARCHAR(30),
	years_experience	INT,
	hospital_branch	 NVARCHAR(50),
	email  NVARCHAR(80),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

)