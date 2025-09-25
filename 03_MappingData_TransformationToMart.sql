-- Updated Mart Tables query showing the stored procedures used
-- and the tables in Mart (Target) and other schemas used (Source)
-- along with potential mappings between source and target fields

-- The tables in Mart can be populated by tables in Transformation and other tables in Mart (Dim -> Fact)

-- There is typically a 1-1 mapping between the stored procedure and the target table ('prc' + tableName = spName)

-- There is no need to compare the data with the source databases, as this is read internally.

USE RMADW;

drop table if exists #MartTBLs;

SELECT /*TGT.object_id, */TGT.ProcSchemaName, TGT.ProcName, TGT.tableSchema, TGT.tableName, TGT.columnName, TGT.column_id, TGT.datatype, TGT.max_length, TGT.is_nullable, TGT.PrimaryKey,
		SRC.tableSchema sourceSchema, SRC.tableName sourceTable, SRC.columnName sourceColumn, SRC.column_id source_id, SRC.datatype sourceType, SRC.max_length source_length, SRC.is_nullable source_is_nullable, SRC.PrimaryKey source_PrimaryKey
INTO #MartTBLs
FROM
(
SELECT o.object_id, s.name ProcSchemaName, o.name ProcName, st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey'
FROM sys.sql_dependencies d
	     JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (7) AND o.[type] = 'P' --(1,5,6,7,8)
         JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     JOIN sys.tables t  ON c.object_id = t.object_id and t.schema_id = 7
		 JOIN sys.schemas s ON s.schema_id = o.schema_id
		 JOIN sys.schemas st ON st.schema_id = t.schema_id
         JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE t.name NOT LIKE '%Audit' AND o.name NOT IN ('prcDimPracticeCodeNumberingSystemGetDetails')
AND 'prc' + t.name = o.name
--ORDER BY ProcSchemaName, tableName, column_id
) TGT
LEFT JOIN
(
SELECT o.object_id, s.name ProcSchemaName, o.name ProcName, st.name tableSchema, t.name tableName, c.name columnName, c.column_id, ty.name datatype, c.max_length, c.is_nullable, ISNULL(i.is_primary_key, 0) 'PrimaryKey'
FROM sys.sql_dependencies d
	     JOIN sys.objects o  ON d.object_id = o.object_id and o.schema_id in (7) AND o.[type] = 'P' --(1,5,6,7,8)
         JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
	     JOIN sys.tables t  ON c.object_id = t.object_id --and t.schema_id != 7
		 JOIN sys.schemas s ON s.schema_id = o.schema_id
		 JOIN sys.schemas st ON st.schema_id = t.schema_id
         JOIN sys.types ty ON c.user_type_id = ty.user_type_id
         LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
         LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE t.name NOT LIKE '%Audit'
--ORDER BY ProcSchemaName, tableName, column_id
) SRC
ON TGT.object_id = SRC.object_id AND TGT.columnName = SRC.columnName AND TGT.tableSchema != SRC.tableSchema --AND REPLACE(TGT.tableName,'Dim','') LIKE '%' + SRC.tableName + '%' --AND ((TGT.max_length >= SRC.max_length AND TGT.datatype = SRC.datatype) OR TGT.datatype LIKE '%' + SRC.datatype) --AND TGT.max_length >= SRC.max_length-- 
ORDER BY TGT.ProcName, TGT.tableName, TGT.column_id

--SELECT * FROM sys.schemas

SELECT * FROM #MartTBLs
--WHERE sourceSchema IS NULL
ORDER BY ProcName, tableName, column_id



