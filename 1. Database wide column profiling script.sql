-- ==============================================================================
-- 1. DATABASE-WIDE COLUMN PROFILING SCRIPT
-- Profiles all user tables and all columns for completeness, uniqueness, and range.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- A. Setup: Create Permanent Results Table
-- ------------------------------------------------------------------------------

-- Drop the table if it already exists (for reruns)
--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DataProfile_ColumnStats]') AND type in (N'U'))
--DROP TABLE [dbo].[DataProfile_ColumnStats]
--;

--DROP TABLE #DataProfile_ColumnStats


CREATE TABLE #DataProfile_ColumnStats --dbo.DataProfile_ColumnStats 
 
 (
    ProfileDate DATETIME DEFAULT GETDATE(),
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    ColumnName sysname NOT NULL,
    DataType sysname NOT NULL,
    IsNullable CHAR(1) NOT NULL,
    TotalRows INT NOT NULL, 
    NonNullCount INT NULL,
    NullCount INT NULL,
    NullPercentage DECIMAL(5,2) NOT NULL,
    DistinctCount INT NOT NULL,
    DistinctPercentage DECIMAL(5,2) NOT NULL,
    MinLength INT NULL,
    MaxLength INT NULL,
    AverageLength DECIMAL(10,2) NULL,
    MinValue NVARCHAR(4000) NULL,
    MaxValue NVARCHAR(4000) NULL,
    PRIMARY KEY (SchemaName, TableName, ColumnName)
);

-- ------------------------------------------------------------------------------
-- B. Dynamic SQL Generation and Execution
-- ------------------------------------------------------------------------------

-- Variables for the dynamic execution
DECLARE @TSQL NVARCHAR(MAX);
DECLARE @TableList TABLE (SchemaName sysname, TableName sysname);
DECLARE @Schema sysname;
DECLARE @Table sysname;
DECLARE @ColName sysname;
DECLARE @ColDataType sysname;
DECLARE @IsNullable CHAR(1);

-- Populate list of all user tables
INSERT INTO @TableList (SchemaName, TableName)
SELECT s.name, t.name
FROM DEV_EV_Data.sys.tables t
INNER JOIN DEV_EV_Data.sys.schemas s ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;

-- Outer Cursor: Iterate through all tables
DECLARE TableCursor CURSOR FOR 
    SELECT SchemaName, TableName FROM @TableList;

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @Schema, @Table;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Processing Table: ' + @Schema + '.' + @Table;

    -- Inner Cursor: Iterate through all columns of the current table
    DECLARE ColumnCursor CURSOR FOR
        SELECT 
            c.name, 
            t.name,
            CASE WHEN c.is_nullable = 1 THEN 'Y' ELSE 'N' END
        FROM DEV_EV_Data.sys.columns c
        INNER JOIN DEV_EV_Data.sys.types t ON c.system_type_id = t.system_type_id
        WHERE c.object_id = OBJECT_ID(QUOTENAME(@Schema) + '.' + (@Table)) --QUENAME(@Table))
        ORDER BY c.column_id;

    OPEN ColumnCursor;
    FETCH NEXT FROM ColumnCursor INTO @ColName, @ColDataType, @IsNullable;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        -- Default (Numeric/Date/Other) Profile Query
        SET @TSQL = N'
            INSERT INTO #DataProfile_ColumnStats --dbo.DataProfile_ColumnStats
            SELECT 
                GETDATE(),
                ''' + @Schema + ''', 
                ''' + @Table + ''', 
                ''' + @ColName + ''',
                ''' + @ColDataType + ''',
                ''' + @IsNullable + ''',
                COUNT(*), 
                SUM(CASE WHEN [' + @ColName + '] IS NOT NULL THEN 1 ELSE 0 END), 
                SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1 ELSE 0 END), 
                CASE WHEN (CAST(SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2))) IS NULL THEN 0 ELSE (CAST(SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2))) END,
                COUNT(DISTINCT [' + @ColName + ']), 
                CAST(COUNT(DISTINCT [' + @ColName + ']) * 100.0 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
                NULL, NULL, NULL, -- Length metrics are NULL by default
                CAST(MIN([' + @ColName + ']) AS NVARCHAR(4000)), 
                CAST(MAX([' + @ColName + ']) AS NVARCHAR(4000))
            FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table) + ';';

        ---- Overwrite for String/Variable Length Profile Query
        IF @ColDataType IN ('char', 'varchar', 'nchar', 'nvarchar')
        BEGIN
            SET @TSQL = N'
                INSERT INTO #DataProfile_ColumnStats --dbo.DataProfile_ColumnStats
                SELECT 
                    GETDATE(),
                    ''' + @Schema + ''', 
                    ''' + @Table + ''', 
                    ''' + @ColName + ''',
                    ''' + @ColDataType + ''',
                    ''' + @IsNullable + ''',
                    COUNT(*), 
                    SUM(CASE WHEN [' + @ColName + '] IS NOT NULL THEN 1 ELSE 0 END), 
                    SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1 ELSE 0 END), 
                    CASE WHEN (CAST(SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2))) IS NULL THEN 0 ELSE (CAST(SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2))),
                    COUNT(DISTINCT [' + @ColName + ']), 
                    CAST(COUNT(DISTINCT [' + @ColName + ']) * 100.0 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
                    MIN(LEN([' + @ColName + '])), 
                    MAX(LEN([' + @ColName + '])),
                    AVG(CAST(LEN([' + @ColName + ']) AS DECIMAL(10,2))),
                    CAST(MIN([' + @ColName + ']) AS NVARCHAR(4000)), 
                    CAST(MAX([' + @ColName + ']) AS NVARCHAR(4000))
                FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table) + ';';
        END

        -- Handle unsupported types (e.g., binary, XML, spatial) to prevent errors
        IF @ColDataType IN ('xml', 'hierarchyid', 'geometry', 'geography', 'image', 'text', 'ntext', 'varbinary', 'sql_variant')
        BEGIN
            -- Insert placeholder results
            SET @TSQL = N'
                INSERT INTO #DataProfile_ColumnStats --dbo.DataProfile_ColumnStats 
                (SchemaName, TableName, ColumnName, DataType, IsNullable, TotalRows, NonNullCount, NullCount, NullPercentage, DistinctCount, DistinctPercentage)
                SELECT 
                    ''' + @Schema + ''', 
                    ''' + @Table + ''', 
                    ''' + @ColName + ''',
                    ''' + @ColDataType + ''',
                    ''' + @IsNullable + ''',
                    COUNT(*), 
                    SUM(CASE WHEN [' + @ColName + '] IS NOT NULL THEN 1 ELSE 0 END), 
                    SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1 ELSE 0 END), 
                    CASE WHEN (CAST(SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2))) IS NULL THEN 0 ELSE (CAST(SUM(CASE WHEN [' + @ColName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2))),
                    COUNT(DISTINCT [' + @ColName + ']), 
                    CAST(COUNT(DISTINCT [' + @ColName + ']) * 100.0 / COUNT(*)* 1.0 AS DECIMAL(5,2))
                FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table) + ';';

        END

        -- Execute the dynamic statement
        EXEC sp_executesql @TSQL;

        FETCH NEXT FROM ColumnCursor INTO @ColName, @ColDataType, @IsNullable;
    END

    CLOSE ColumnCursor;
    DEALLOCATE ColumnCursor;

    FETCH NEXT FROM TableCursor INTO @Schema, @Table;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;

-- ------------------------------------------------------------------------------
-- C. Final Output (The Column Profile Report)
-- ------------------------------------------------------------------------------
  SELECT *
    FROM #DataProfile_ColumnStats --dbo.DataProfile_ColumnStats
ORDER BY SchemaName, TableName, ColumnName;



