-- use hospital DB
USE Hospital_DB

-- BULK INSERT TO bronze.appoinment_table
TRUNCATE TABLE bronze.appoinment_table;

PRINT '>> Inserting Data Into: bronze.appoinment_table';
BULK INSERT bronze.appoinment_table
FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\appointments.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
     );

-- BULK INSERT TO bronze.patients
TRUNCATE TABLE bronze.patients;

PRINT '>> Inserting Data Into: bronze.patients';
BULK INSERT bronze.patients
FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\patients.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
     );

-- BULK INSERT TO bronze.billing
TRUNCATE TABLE bronze.billing;

PRINT '>> Inserting Data Into: bronze.billing';
BULK INSERT bronze.billing
FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\billing.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
     );

-- BULK INSERT TO bronze.treatments
TRUNCATE TABLE bronze.treatments;

PRINT '>> Inserting Data Into: bronze.treatments';
BULK INSERT bronze.treatments
FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\treatments.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
     );


-- BULK INSERT TO bronze.doctors
TRUNCATE TABLE bronze.doctors;

PRINT '>> Inserting Data Into: bronze.doctors';
BULK INSERT bronze.doctors
FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\doctors.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
     );

-- check data -- 
SELECT * FROM bronze.appoinment_table
SELECT * FROM bronze.patients
SELECT * FROM bronze.billing
SELECT * FROM bronze.treatments
SELECT * FROM bronze.doctors