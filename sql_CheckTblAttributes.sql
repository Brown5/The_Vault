--SELECT referencing_schema_name, referencing_entity_name,
--referencing_id, referencing_class_desc, is_caller_dependent
--FROM sys.dm_sql_referencing_entities ('Compensation.InvoiceAllocation', 'OBJECT');
--GO


 SELECT Distinct x.DBName, 
	    x.TABLE_SCHEMA,
		x.Table_Name1 Table_Name,
		x.Column_Name, 
		x.DataType,
		x.ordinal_position
  FROM
  (
      SELECT tab.TABLE_CATALOG DBName, 
	         Tab.TABLE_SCHEMA,
			 TAB.Table_Name Table_Name1,
	         TableName= Tab.TABLE_SCHEMA+'.'+TAB.Table_Name, 
			 tab.ordinal_position,
			 TAB.Column_Name, 
        CASE when Data_Type = 'numeric' THEN 
             Data_type + '(' + cast(Numeric_precision as varchar) + ',' ++ cast(Numeric_scale as varchar) + ')'
        ELSE CASE When character_maximum_length is not null THEN 
             TAB.Data_type + '(' + cast(character_maximum_length as varchar) + ')' 
        ELSE TAB.Data_type end end AS DataType, tAB.Is_Nullable,
        CASE when pktab.column_name  is not null THEN 
             'PK' 
        ELSE '' 
             END AS pkConst,isnull(tab.Column_default,'') as DefaultValue,
              Replace(Isnull(Fktab.FK_SCHEMA,'.')+'.'+isnull(fktab.pk_Table,'.'),'...','') as RefTable, 
              isnull(fktab.pk_column,'') as RefColumn 
     FROM information_schema.columns TAB INNER JOIN  
          Sys.objects So on Tab.table_name = So.name 
          AND So.type ='U' LEFT OUTER JOIN
     ( SELECT i1.TABLE_NAME, i2.COLUMN_NAME 
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1 INNER JOIN 
              INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 
              ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
       WHERE  i1.CONSTRAINT_TYPE = 'PRIMARY KEY' 
     ) PKTab on tab.table_name = pktab.table_name
     AND tab.column_name = pktab.column_name LEFT OUTER JOIN
    (
    SELECT FK_SCHEMA = C.Unique_Constraint_Schema,
           FK_Table  =  FK.TABLE_NAME, 
           FK_Column = CU.COLUMN_NAME, 
           PK_Table  = PK.TABLE_NAME, 
           PK_Column = PT.COLUMN_NAME, 
           Constraint_Name = C.CONSTRAINT_NAME 
    FROM   INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C INNER JOIN 
           INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME INNER JOIN 
           INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME INNER JOIN 
           INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME INNER JOIN 
           ( 
           SELECT i1.TABLE_NAME, i2.COLUMN_NAME 
           FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1 INNER JOIN 
                  INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME 
           WHERE  i1.CONSTRAINT_TYPE = 'PRIMARY KEY' 
           ) PT ON PT.TABLE_NAME = PK.TABLE_NAME 
    ) FKTAB ON tab.table_name = fktab.fK_Table
    AND    tab.column_name = fktab.fK_Column
  ) x WHERE  TableName = 'dbo.BIStaging_ClaimsEstimateDetails'

ORDER BY 4
