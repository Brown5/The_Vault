USE RMADW;
--USE RMAProd;

  SELECT case when ssch.[name] = 'Staging' then 1
		      when ssch.[name] = 'Transformation' then 2
		      when ssch.[name] = 'Mart' then 3
		      when ssch.[name] = 'Derived' then 4
		      when ssch.[name] = 'Report' then 5
		      else 10 end as SchemaOrder 
        ,ssch.[name] as [Schema Name]
        ,sprc.[name] as [Stored Procedure Name]
        ,ssch.[name] + '.' + sprc.[name] as [Full Name]
        ,OBJECT_DEFINITION(OBJECT_ID) AS [Object Definition]
    FROM sys.procedures sprc 
         INNER JOIN sys.schemas ssch ON sprc.schema_id = ssch.schema_id
   WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%Test%'
     --AND OBJECT_DEFINITION(OBJECT_ID) LIKE '%Transaction%'
     --AND ssch.[name] = 'Staging'
--ORDER BY sprc.create_date desc
ORDER BY 1, 4

--  select distinct [Table Name] = o.Name, 
--         [Found In] = sp.Name, 
--	     sp.type_desc
--    from sys.objects o inner join sys.sql_expression_dependencies  sd on o.object_id = sd.referenced_id
--         inner join sys.objects sp on sd.referencing_id = sp.object_id and sp.type in ('P', 'FN')
--   where o.name = 'CompensationMedicalInvoice'
--order by sp.Name