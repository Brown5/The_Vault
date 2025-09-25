---use ReportServer database
--DROP TABLE IF EXISTS #temp1

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition') --You may have to change this based on you SSRS version



  SELECT [Path],
         Name,
         report_xml.value( '(/Report/DataSources/DataSource/@Name)[1]', 'VARCHAR(50)' ) AS DataSource,
         report_xml.value( '(/Report/DataSets/DataSet/Query/CommandText/text())[1]', 'VARCHAR(MAX)' ) AS CommandText, 
         --REPLACE(REPLACE(REPLACE(ct.email,CHAR(13),' '),CHAR(10),' '),CHAR(9),' ')
         report_xml.value( '(/Report/DataSets/DataSet/Query/CommandType/text())[1]', 'VARCHAR(100)' ) AS CommandType
         --report_xml
    Into #temp1
    FROM
         (
			SELECT [Path], 
				   Name, 
				   [Type],
				   CAST( CAST( content AS VARBINARY(MAX) ) AS XML ) report_xml 
			  FROM dbo.[Catalog]
			 WHERE Content IS NOT NULL
			   --AND [Type] = 2
		  ) x
--WHERE 
--use below in where clause if searching for the CommandText.  Depending on how the report was developed I would just use the proc name and no brackets or schema.
--Example:  if you report was developed as having [dbo].[procName] just use LIKE '%procName%' below.  Because other reports could just have dbo.procName.
--report_xml.value( '(/Report/DataSets/DataSet/Query/CommandText/text())[1]', 'VARCHAR(MAX)' ) LIKE '%Your Proc Name here%'
--comment out the above and uncomment below if know your report name and want to search for that specific report.
--[x].[Name] = 'The Name Of Your Report'
--[Security].[RMAUserCompanyAccess]

  SELECT [Path]
        ,Name
        --,[Type]
        ,DataSource
        ,REPLACE(REPLACE(REPLACE(CommandText,CHAR(13),' '),CHAR(10),' '),CHAR(9),' ') CommandText
        ,REPLACE(REPLACE(REPLACE(CommandType,CHAR(13),' '),CHAR(10),' '),CHAR(9),' ') CommandType
   FROM #temp1
  WHERE Name LIKE '%Class %'



  --SELECT * FROM dbo.[Catalog]