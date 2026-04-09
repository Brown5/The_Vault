-- ==============================================================================
-- 2. RELATIONSHIP DISCOVERY SCRIPT (UCC & IND Candidates)
-- Identifies Unique Column Combinations (Keys) and potential Inclusion Dependencies (FKs).
-- NOTE: Requires DataProfile_ColumnStats from Script 1 to be populated.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- A. Unique Column Combination (UCC) Candidates (Internal Structure)
-- ------------------------------------------------------------------------------
PRINT '--- 1. Unique Column Combination (UCC) Candidates ---';

-- 1a. Report Existing Primary and Unique Keys (Confirmed UCCs)
SELECT 
    'Confirmed UCC (PK/Unique Constraint)' AS UCC_Type,
    OBJECT_SCHEMA_NAME(ic.object_id) AS SchemaName,
    OBJECT_NAME(ic.object_id) AS TableName,
    c.name AS ColumnName,
    i.is_primary_key AS IsPrimaryKey
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.is_unique_constraint = 1 OR i.is_primary_key = 1
ORDER BY SchemaName, TableName, i.name, ic.key_ordinal;


-- 1b. Report Suggested UCC Candidates (Based on 100% Uniqueness from Script 1)
-- This suggests columns that *could* be unique keys but currently are not constrained.
PRINT CHAR(13) + 'Suggested UCC Candidates (Columns with 100% Distinctness):';

SELECT 
    'Suggested UCC Candidate' AS UCC_Type,
    c.SchemaName, 
    c.TableName, 
    c.ColumnName,
    c.DistinctPercentage,
    'Review this column for a UNIQUE or PRIMARY KEY constraint.' AS Recommendation
FROM dbo.DataProfile_ColumnStats c
WHERE c.DistinctPercentage = 100.00
AND c.NullCount = 0 -- Should be non-null to be a good PK candidate
-- Exclude columns that are already primary keys (to avoid redundancy)
AND NOT EXISTS (
    SELECT 1 
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns sc ON ic.object_id = sc.object_id AND ic.column_id = sc.column_id
    WHERE i.is_primary_key = 1
    AND OBJECT_SCHEMA_NAME(i.object_id) = c.SchemaName
    AND OBJECT_NAME(i.object_id) = c.TableName
    AND sc.name = c.ColumnName
)
ORDER BY c.SchemaName, c.TableName, c.ColumnName;

-- ------------------------------------------------------------------------------
-- B. Inclusion Dependency (IND) Candidates (Cross-Table Structure)
-- ------------------------------------------------------------------------------
PRINT CHAR(13) + '--- 2. Inclusion Dependency (IND) Candidates (Potential FKs) ---';

-- Identify potential Foreign Key relationships based on shared attributes (name/data type).
-- This is a HEURISTIC-BASED approach to discover INDs (where Table A values are IN Table B values).

SELECT 
    'IND Candidate' AS Indication,
    T1.SchemaName + '.' + T1.TableName AS Potential_Foreign_Table,
    T1.ColumnName AS Potential_Foreign_Column,
    T2.SchemaName + '.' + T2.TableName AS Potential_Primary_Table,
    T2.ColumnName AS Potential_Primary_Column,
    T1.DataType,
    T1.DistinctCount AS Foreign_Distinct_Count,
    T2.DistinctCount AS Primary_Distinct_Count,
    'A good candidate is when Foreign_Distinct_Count <= Primary_Distinct_Count and the names match.' AS Heuristic
FROM dbo.DataProfile_ColumnStats T1 -- Potential Foreign Key Column
JOIN dbo.DataProfile_ColumnStats T2 -- Potential Primary Key Column
    ON T1.ColumnName = T2.ColumnName -- Match based on Name (Primary Heuristic)
    AND T1.DataType = T2.DataType      -- Match based on Data Type
    AND T1.TableName <> T2.TableName   -- Ensure they are in different tables
    AND T1.SchemaName = T2.SchemaName  -- Optional: Limit to same schema
WHERE T2.DistinctPercentage >= 95.00 -- The potential primary key column should be highly unique
ORDER BY Potential_Foreign_Table, Potential_Foreign_Column;


-- ------------------------------------------------------------------------------
-- C. Simple Value Overlap Check (Manual Spot Check)
-- ------------------------------------------------------------------------------
-- This section demonstrates how to build the dynamic query needed for a true 
-- value check (which is why dedicated tools exist). This MUST be run manually 
-- for specific candidates due to high execution cost.

/*
-- Example: Check if all values in Sales.Customers.City are present in HumanResources.Employees.City
DECLARE @CheckCol sysname = 'City';
DECLARE @ForeignTable sysname = 'Sales.Customers';
DECLARE @PrimaryTable sysname = 'HumanResources.Employees';

DECLARE @CheckTSQL NVARCHAR(MAX) = N'
    SELECT TOP 1 
        ''Value exists in ' + @ForeignTable + ' but NOT in ' + @PrimaryTable + ''' AS Issue
    FROM ' + @ForeignTable + ' AS F
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ' + @PrimaryTable + ' AS P
        WHERE F.[' + @CheckCol + '] = P.[' + @CheckCol + ']
    )
    AND F.[' + @CheckCol + '] IS NOT NULL;
';

PRINT CHAR(13) + '--- 3. Example Value Inclusion Check (Manual Execution Required) ---';
EXEC sp_executesql @CheckTSQL; 
*/
