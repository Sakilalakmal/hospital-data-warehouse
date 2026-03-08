-- use hospital DB
USE Hospital_DB

CREATE OR ALTER PROCEDURE bronze.data_load_bronze 
AS
BEGIN
        DECLARE @start_time DATETIME, @end_time DATETIME, @row_count INT;

        SET @start_time = GETDATE();
        PRINT '================================================';
        PRINT '>> Loading Bronze Layer';
        PRINT '>> Start Time: ' + CONVERT(VARCHAR, @start_time, 121);
        PRINT '================================================';

        -- BULK INSERT TO bronze.appoinment_table
        BEGIN TRY
                TRUNCATE TABLE bronze.appoinment_table;

                PRINT '>> Inserting Data Into: bronze.appoinment_table';
                BULK INSERT bronze.appoinment_table
                FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\appointments.csv'
                WITH (
                        FIRSTROW = 2,
                        FIELDTERMINATOR = ',',
                        TABLOCK
                );

                SET @row_count = @@ROWCOUNT;
                PRINT '>> Rows Loaded: ' + CAST(@row_count AS VARCHAR);
        END TRY
        BEGIN CATCH
                PRINT '>> ERROR loading bronze.appoinment_table';
                PRINT '>> Error Message: ' + ERROR_MESSAGE();
                PRINT '>> Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        END CATCH;

        -- BULK INSERT TO bronze.patients
        BEGIN TRY
                TRUNCATE TABLE bronze.patients;

                PRINT '>> Inserting Data Into: bronze.patients';
                BULK INSERT bronze.patients
                FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\patients.csv'
                WITH (
                        FIRSTROW = 2,
                        FIELDTERMINATOR = ',',
                        TABLOCK
                );

                SET @row_count = @@ROWCOUNT;
                PRINT '>> Rows Loaded: ' + CAST(@row_count AS VARCHAR);
        END TRY
        BEGIN CATCH
                PRINT '>> ERROR loading bronze.patients';
                PRINT '>> Error Message: ' + ERROR_MESSAGE();
                PRINT '>> Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        END CATCH;

        -- BULK INSERT TO bronze.billing
        BEGIN TRY
                TRUNCATE TABLE bronze.billing;

                PRINT '>> Inserting Data Into: bronze.billing';
                BULK INSERT bronze.billing
                FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\billing.csv'
                WITH (
                        FIRSTROW = 2,
                        FIELDTERMINATOR = ',',
                        TABLOCK
                );

                SET @row_count = @@ROWCOUNT;
                PRINT '>> Rows Loaded: ' + CAST(@row_count AS VARCHAR);
        END TRY
        BEGIN CATCH
                PRINT '>> ERROR loading bronze.billing';
                PRINT '>> Error Message: ' + ERROR_MESSAGE();
                PRINT '>> Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        END CATCH;

        -- BULK INSERT TO bronze.treatments
        BEGIN TRY
                TRUNCATE TABLE bronze.treatments;

                PRINT '>> Inserting Data Into: bronze.treatments';
                BULK INSERT bronze.treatments
                FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\treatments.csv'
                WITH (
                        FIRSTROW = 2,
                        FIELDTERMINATOR = ',',
                        TABLOCK
                );

                SET @row_count = @@ROWCOUNT;
                PRINT '>> Rows Loaded: ' + CAST(@row_count AS VARCHAR);
        END TRY
        BEGIN CATCH
                PRINT '>> ERROR loading bronze.treatments';
                PRINT '>> Error Message: ' + ERROR_MESSAGE();
                PRINT '>> Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        END CATCH;


        -- BULK INSERT TO bronze.doctors
        BEGIN TRY
                TRUNCATE TABLE bronze.doctors;

                PRINT '>> Inserting Data Into: bronze.doctors';
                BULK INSERT bronze.doctors
                FROM 'D:\DE-DA\hospital_DB_Warehouse\data-set\doctors.csv'
                WITH (
                        FIRSTROW = 2,
                        FIELDTERMINATOR = ',',
                        TABLOCK
                );

                SET @row_count = @@ROWCOUNT;
                PRINT '>> Rows Loaded: ' + CAST(@row_count AS VARCHAR);
        END TRY
        BEGIN CATCH
                PRINT '>> ERROR loading bronze.doctors';
                PRINT '>> Error Message: ' + ERROR_MESSAGE();
                PRINT '>> Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        END CATCH;

        SET @end_time = GETDATE();
        PRINT '================================================';
        PRINT '>> Bronze Layer Load Completed';
        PRINT '>> End Time: ' + CONVERT(VARCHAR, @end_time, 121);
        PRINT '>> Total Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '================================================';
END;
GO

-- execute command for this procedure -- 
EXEC bronze.data_load_bronze
