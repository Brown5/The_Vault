-- ==============================================================================
-- T-SQL Data Profiling Script
-- Calculates key statistics for all columns in a target table.
-- WARNING: Running this script on very large tables may take significant time 
--          and resources.
-- ==============================================================================

-- 1. Configuration: Set the Schema and Table Name
DECLARE @SchemaName sysname = 'dbo'; -- << CHANGE SCHEMA NAME HERE
DECLARE @TableName sysname = 'CareerPanelDiscussion'; -- << CHANGE TABLE NAME HERE

-- 2. Variables for Iteration
DECLARE @ColumnName sysname;
DECLARE @DataType sysname;
DECLARE @TSQL NVARCHAR(MAX);

-- 3. Results Table
IF OBJECT_ID('tempdb..#DataProfilingResults') IS NOT NULL DROP TABLE #DataProfilingResults;

CREATE TABLE #DataProfilingResults (
    TableName sysname,
    ColumnName sysname,
    DataType sysname,
    TotalRows INT,
    NonNullCount INT,
    NullCount INT,
    NullPercentage DECIMAL(5,2),
    DistinctCount INT,
    DistinctPercentage DECIMAL(5,2),
    MinLength INT,
    MaxLength INT,
    MinValue NVARCHAR(MAX),
    MaxValue NVARCHAR(MAX),
    AverageLength DECIMAL(10,2)
);

-- 4. Cursor to iterate through all columns in the target table
DECLARE ColumnCursor CURSOR FOR
    SELECT c.name, t.name
    FROM sys.columns c
    INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
    WHERE c.object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
    ORDER BY c.column_id;

OPEN ColumnCursor;
FETCH NEXT FROM ColumnCursor INTO @ColumnName, @DataType;

-- 5. Main Profiling Loop
WHILE @@FETCH_STATUS = 0
BEGIN
    
    -- Base calculation for all data types
    SET @TSQL = N'
        SELECT 
            @TableName, 
            @ColumnName, 
            @DataType,
            COUNT(*), 
            SUM(CASE WHEN [' + @ColumnName + '] IS NOT NULL THEN 1 ELSE 0 END), 
            SUM(CASE WHEN [' + @ColumnName + '] IS NULL THEN 1 ELSE 0 END), 
            CAST(SUM(CASE WHEN [' + @ColumnName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
            COUNT(DISTINCT [' + @ColumnName + ']), 
            CAST(COUNT(DISTINCT [' + @ColumnName + ']) * 100.0 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
            NULL, -- MinLength placeholder
            NULL, -- MaxLength placeholder
            NULL, -- MinValue placeholder
            NULL, -- MaxValue placeholder
            NULL  -- AverageLength placeholder
        FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ';';

    -- Specialized calculations for string/variable length types
    IF @DataType IN ('char', 'varchar', 'nchar', 'nvarchar')
    BEGIN
        SET @TSQL = N'
            SELECT 
                @TableName, 
                @ColumnName, 
                @DataType,
                COUNT(*), 
                SUM(CASE WHEN [' + @ColumnName + '] IS NOT NULL THEN 1 ELSE 0 END), 
                SUM(CASE WHEN [' + @ColumnName + '] IS NULL THEN 1 ELSE 0 END), 
                CAST(SUM(CASE WHEN [' + @ColumnName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
                COUNT(DISTINCT [' + @ColumnName + ']), 
                CAST(COUNT(DISTINCT [' + @ColumnName + ']) * 100.0 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
                MIN(LEN([' + @ColumnName + '])), 
                MAX(LEN([' + @ColumnName + '])),
                CAST(MIN([' + @ColumnName + ']) AS NVARCHAR(MAX)), 
                CAST(MAX([' + @ColumnName + ']) AS NVARCHAR(MAX)),
                AVG(CAST(LEN([' + @ColumnName + ']) AS DECIMAL(10,2)))
            FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ';';
    END

    -- Specialized calculations for numeric and date/time types
    IF @DataType IN ('int', 'bigint', 'smallint', 'tinyint', 'decimal', 'numeric', 'float', 'money', 'date', 'datetime', 'datetime2')
    BEGIN
        SET @TSQL = N'
            SELECT 
                @TableName, 
                @ColumnName, 
                @DataType,
                COUNT(*), 
                SUM(CASE WHEN [' + @ColumnName + '] IS NOT NULL THEN 1 ELSE 0 END), 
                SUM(CASE WHEN [' + @ColumnName + '] IS NULL THEN 1 ELSE 0 END), 
                CAST(SUM(CASE WHEN [' + @ColumnName + '] IS NULL THEN 1.0 ELSE 0.0 END) * 100 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
                COUNT(DISTINCT [' + @ColumnName + ']), 
                CAST(COUNT(DISTINCT [' + @ColumnName + ']) * 100.0 / COUNT(*)* 1.0 AS DECIMAL(5,2)),
                NULL, 
                NULL,
                CAST(MIN([' + @ColumnName + ']) AS NVARCHAR(MAX)), 
                CAST(MAX([' + @ColumnName + ']) AS NVARCHAR(MAX)),
                NULL
            FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ';';
    END

    -- Execute the dynamically built T-SQL and insert results
    INSERT INTO #DataProfilingResults
    EXEC sp_executesql @TSQL, 
        N'@TableName sysname, @ColumnName sysname, @DataType sysname',
        @TableName, @ColumnName, @DataType;

    FETCH NEXT FROM ColumnCursor INTO @ColumnName, @DataType;
END

-- 6. Clean up and Final Output
CLOSE ColumnCursor;
DEALLOCATE ColumnCursor;

SELECT * FROM #DataProfilingResults
ORDER BY TableName, ColumnName;