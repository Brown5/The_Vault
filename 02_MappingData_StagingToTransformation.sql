-- Updated Transformation Tables query showing the stored procedures used
-- and the tables in Transformation (Target) and other schemas used (Source)
-- along with potential mappings between source and target fields

-- The Dim tables do contribute to the Fact tables in Transformation.
-- The Fact tables do not contribute to the Dim tables in Transformation.

-- There is typically a 1-1 mapping between the stored procedure and the target table ('prc' + tableName = spName)

-- There is not need to compare the data with the source databases, as this is read internally.

USE RMADW;

drop table if exists #TransformationTBLs

SELECT /*TGT.object_id, */TGT.ProcSchemaName, TGT.ProcName, TGT.tableSchema, TGT.tableName, TGT.columnName, TGT.column_id, TGT.datatype, TGT.max_length, TGT.is_nullable, TGT.PrimaryKey,
		SRC.tableSchema sourceSchema, SRC.tableName sourceTable, SRC.columnName sourceColumn, SRC.column_id source_id, SRC.datatype sourceType, SRC.max_length source_length, SRC.is_nullable source_is_nullable, SRC.PrimaryKey source_PrimaryKey
INTO #TransformationTBLs
FROM
(
SELECT o.object_id, s.name ProcSchemaName, o.name ProcName, st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey'
FROM sys.sql_dependencies d
	     JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (6) AND o.[type] = 'P' --(1,5,6,7,8)
         JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     JOIN sys.tables t  ON c.object_id = t.object_id and t.schema_id = 6
		 JOIN sys.schemas s ON s.schema_id = o.schema_id
		 JOIN sys.schemas st ON st.schema_id = t.schema_id
         JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE t.name NOT LIKE '%Audit'
AND 'prc' + t.name = o.name
) TGT
LEFT JOIN
(
SELECT o.object_id, s.name ProcSchemaName, o.name ProcName, st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey'
FROM sys.sql_dependencies d
	     JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (6) AND o.[type] = 'P' --(1,5,6,7,8)
         JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     JOIN sys.tables t  ON c.object_id = t.object_id-- and t.schema_id != 6
		 JOIN sys.schemas s ON s.schema_id = o.schema_id
		 JOIN sys.schemas st ON st.schema_id = t.schema_id
         JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE t.name NOT LIKE '%Audit'
) SRC
ON TGT.object_id = SRC.object_id AND TGT.columnName LIKE SRC.columnName + '%' AND TGT.tableName != SRC.tableName --AND REPLACE(TGT.tableName,'Dim','') LIKE '%' + SRC.tableName + '%' --AND ((TGT.max_length >= SRC.max_length AND TGT.datatype = SRC.datatype) OR TGT.datatype LIKE '%' + SRC.datatype) --AND TGT.max_length >= SRC.max_length-- 
ORDER BY TGT.ProcName, TGT.tableName, TGT.column_id



-- This should not affect any rows:
--UPDATE #TransformationTBLs
--SET sourceSchema = NULL,
--	sourceTable = NULL,
--	sourceColumn = NULL,
--	source_id = NULL,
--	sourceType = NULL,
--	source_length = NULL,
--	source_is_nullable = NULL,
--	source_PrimaryKey = NULL
--WHERE SUBSTRING(tableName,1,3) = 'Dim' AND SUBSTRING(sourceTable,1,4) = 'Fact'

SELECT * FROM #TransformationTBLs
--WHERE SUBSTRING(tableName,1,3) = 'Dim' AND SUBSTRING(sourceTable,1,4) = 'Fact'
ORDER BY ProcName, tableName, column_id

--SELECT s.name schemaName, t.name tableName, c.name columnName, c.column_id 
--FROM sys.columns c 
--JOIN sys.tables t ON t.object_id = c.object_id
--JOIN sys.schemas s ON t.schema_id = s.schema_id
--WHERE c.name LIKE '%VatApplyID'-- AND t.schema_id = 6

--SELECT * FROM sys.objects WHERE object_id = 107199482


SELECT DISTINCT procname, tableName, sourceTable
FROM #TransformationTBLs
WHERE sourceTable IS NOT NULL
ORDER BY procName


---------------------------------------------------------------------------
-- Staging -> Transformation
---------------------------------------------------------------------------


SELECT name
FROM RMADW.sys.tables T (NOLOCK)
WHERE schema_id = 5 -- Staging
AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
--AND name LIKE '%Type'
ORDER BY name

-- 44 Exact matches (43 Dim, 1 Fact)
-- 43 Dim__Profile tables will never be mapped from Staging
-- 154 Dim tables to resolve
--SELECT S.name staging, LEN(S.name), T.name transformation, LEN(T.name) - 3

DROP TABLE #TransformationDim

SELECT name
INTO #TransformationDim
FROM RMADW.sys.tables T (NOLOCK)
WHERE schema_id = 6 -- Transformation
AND name LIKE 'Dim%'
AND name Like '%Profile'
AND name NOT IN (SELECT * FROM #TransformationDim)


--TRUNCATE TABLE #TransformationDim
INSERT INTO #TransformationDim
SELECT transformation FROM (
-- 123 Matches
SELECT S.name staging, T.name transformation
FROM
(
SELECT T.name
FROM RMADW.sys.tables T (NOLOCK)
WHERE schema_id = 6 -- Transformation
AND T.name NOT LIKE '%Profile'
--AND T.name NOT LIKE '%Transaction' -- has no effect
) T
JOIN
(
SELECT name
FROM RMADW.sys.tables T (NOLOCK)
WHERE schema_id = 5 -- Staging
AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
) S
--ON SUBSTRING(REPLACE(T.name,'Dim',''),1,13) = SUBSTRING(S.name,1,13)
ON REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T.name,'Dim',''),'Finance','Accounts'),'GeneralLedger','GL'),'Debtor','DR'),'Creditor','CR'),'CashBook','CB'),'Parameter','Param') = REPLACE(REPLACE(S.name,'Dbo',''),'CT','')
OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T.name,'Dim',''),'Finance','Accounts'),'GeneralLedger','GL'),'Debtor','DR'),'Creditor','CR'),'CashBook','CB') = REPLACE(S.name,'Dbo','')
OR REPLACE(T.name,'Dim','') = REPLACE(REPLACE(S.name,'Compensation',''),'Medical','')
OR REPLACE(T.name,'Dim','') = REPLACE(S.name,'MedicalMedical','Medical')
OR REPLACE(T.name,'Dim','') = REPLACE(S.name,'PensionPension','Pension')
OR REPLACE(T.name,'Dim','') = REPLACE(S.name,'Auth','Authorisation')
ORDER BY S.name
--) SRC
WHERE transformation NOT IN (SELECT * FROM #TransformationDim)

SELECT * FROM #TransformationDim ORDER BY transformation




-- 42 Exact matches
SELECT S.name staging, T.name transformation
FROM
(
SELECT T.name
FROM RMADW.sys.tables T (NOLOCK)
WHERE schema_id = 6 -- Transformation
AND T.name NOT LIKE '%Profile'
) T
JOIN
(
SELECT name
FROM RMADW.sys.tables T (NOLOCK)
WHERE schema_id = 5 -- Staging
AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
) S
--ON SUBSTRING(REPLACE(T.name,'Dim',''),1,13) = SUBSTRING(S.name,1,13)
ON REPLACE(REPLACE(T.name,'Transaction',''),'Fact','') = S.name
ORDER BY S.name


---- 117 Dimension tables matched - do not use
--SELECT name
--FROM RMADW.sys.tables T (NOLOCK)
--WHERE schema_id = 6 -- Transformation
--AND SUBSTRING(REPLACE(name,'Dim',''),1,5) IN (
--	SELECT SUBSTRING(name,1,5)
--	FROM RMADW.sys.tables T (NOLOCK)
--	WHERE schema_id = 5 -- Staging
--	AND SUBSTRING(name,1,4) NOT IN ('BPM_', 'CFG_', 'CLC_', 'CPM_', 'RUL_', 'STG_')
--	--ORDER BY name
--) 
--ORDER BY name

-- 241 Dimension tables
-- 120 Fact tables
SELECT name
FROM RMADW.sys.tables T (NOLOCK)
WHERE schema_id = 6 -- Transformation
AND name LIKE 'Dim%'
--AND name Like '%Profile'
AND name NOT IN (SELECT * FROM #TransformationDim)
ORDER BY name

