-- ==============================================================================
-- 3. FREQUENCY ANALYSIS AND CONSISTENCY PROFILING SCRIPT
-- Profiles the Top N most frequent values for all columns to discover patterns, 
-- inconsistencies, and implicit business rules.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- A. Setup: Create Permanent Results Table
-- ------------------------------------------------------------------------------

-- Drop the table if it already exists (for reruns)
IF OBJECT_ID('dbo.DataProfile_FrequencyStats') IS NOT NULL 
    DROP TABLE dbo.DataProfile_FrequencyStats;

CREATE TABLE dbo.DataProfile_FrequencyStats (
    ProfileDate DATETIME DEFAULT GETDATE(),
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    ColumnName sysname NOT NULL,
    Rank INT NOT NULL,
    Value NVARCHAR(4000) NULL, -- Stores the actual value
    ValueCount INT NOT NULL,    -- Count of occurrences
    ValuePercentage DECIMAL(5,2) NOT NULL, -- Percentage of total rows
    PRIMARY KEY (SchemaName, TableName, ColumnName, Rank)
);

-- ------------------------------------------------------------------------------
-- B. Dynamic SQL Generation and Execution
-- ------------------------------------------------------------------------------

-- Configuration: Set the number of top values to profile
DECLARE @TopN INT = 10; 
-- Variables for the dynamic execution
DECLARE @TSQL NVARCHAR(MAX);
DECLARE @TableList TABLE (SchemaName sysname, TableName sysname);
DECLARE @Schema sysname;
DECLARE @Table sysname;
DECLARE @ColName sysname;
DECLARE @ColDataType sysname;

-- Populate list of all user tables
INSERT INTO @TableList (SchemaName, TableName)
SELECT s.name, t.name
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;

-- Outer Cursor: Iterate through all tables
DECLARE TableCursor CURSOR FOR 
    SELECT SchemaName, TableName FROM @TableList;

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @Schema, @Table;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Processing Frequencies for Table: ' + @Schema + '.' + @Table;

    -- Inner Cursor: Iterate through all columns of the current table
    DECLARE ColumnCursor CURSOR FOR
        SELECT 
            c.name, 
            t.name
        FROM sys.columns c
        INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
        WHERE c.object_id = OBJECT_ID(QUOTENAME(@Schema) + '.' + QUENAME(@Table))
        -- Exclude binary, XML, spatial, and large text types for performance/storage reasons
        AND t.name NOT IN ('xml', 'hierarchyid', 'geometry', 'geography', 'image', 'text', 'ntext', 'varbinary', 'sql_variant')
        ORDER BY c.column_id;

    OPEN ColumnCursor;
    FETCH NEXT FROM ColumnCursor INTO @ColName, @ColDataType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        -- Build the dynamic T-SQL query for frequency analysis
        SET @TSQL = N'
            WITH ValueCounts AS (
                SELECT TOP ' + CAST(@TopN AS NVARCHAR(10)) + N' 
                    CAST([' + @ColName + '] AS NVARCHAR(4000)) AS ColumnValue, 
                    COUNT(*) AS ValueCount,
                    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS RankNum
                FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table) + '
                GROUP BY [' + @ColName + ']
                ORDER BY ValueCount DESC
            ),
            TotalRows AS (
                SELECT COUNT(*) AS Total FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table) + '
            )
            INSERT INTO dbo.DataProfile_FrequencyStats
            SELECT 
                GETDATE(),
                ''' + @Schema + ''', 
                ''' + @Table + ''', 
                ''' + @ColName + ''',
                vc.RankNum,
                vc.ColumnValue,
                vc.ValueCount,
                CAST(vc.ValueCount * 100.0 / tr.Total * 1.0 AS DECIMAL(5,2))
            FROM ValueCounts vc, TotalRows tr;
        ';

        -- Execute the dynamic statement
        EXEC sp_executesql @TSQL;

        FETCH NEXT FROM ColumnCursor INTO @ColName, @ColDataType;
    END

    CLOSE ColumnCursor;
    DEALLOCATE ColumnCursor;

    FETCH NEXT FROM TableCursor INTO @Schema, @Table;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;

-- ------------------------------------------------------------------------------
-- C. Final Output (The Frequency Profile Report)
-- ------------------------------------------------------------------------------
SELECT *
FROM dbo.DataProfile_FrequencyStats
ORDER BY SchemaName, TableName, ColumnName, Rank;
