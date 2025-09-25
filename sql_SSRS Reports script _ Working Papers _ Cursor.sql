---USE ReportServer database
--DROP TABLE IF EXISTS #temp1

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition') 



  SELECT [Path],
         Name,
         report_xml.value( '(/Report/DataSources/DataSource/@Name)[1]', 'VARCHAR(50)' ) AS DataSource,
         report_xml.value( '(/Report/DataSets/DataSet/Query/CommandText/text())[1]', 'VARCHAR(MAX)' ) AS CommandText, 
         report_xml.value( '(/Report/DataSets/DataSet/Query/CommandType/text())[1]', 'VARCHAR(100)' ) AS CommandType
    Into #temp1
    FROM
         (
			SELECT [Path], 
				   Name, 
				   [Type],
				   CAST( CAST( content AS VARBINARY(MAX) ) AS XML ) report_xml 
			  FROM dbo.[Catalog]
			 WHERE Content IS NOT NULL
		  ) x


SET NOCOUNT ON;

DECLARE 
        @name nvarchar(50)
	   --,@source varchar(80)
	   ,@commandtext nvarchar(MAX) 
	   ,@CommandType nvarchar(75) ;  


PRINT 'Open loop';  
  
DECLARE CT_cursor CURSOR FOR 


  SELECT Name
        ,DataSource
		,REPLACE(REPLACE(REPLACE(CommandText,CHAR(13),' '),CHAR(10),' '),CHAR(9),' ') CommandText
        ,REPLACE(REPLACE(REPLACE(CommandType,CHAR(13),' '),CHAR(10),' '),CHAR(9),' ') CommandType
   --into [RMABIStaging].dbo.BayBridgeReports
   FROM #temp1
  WHERE Name = 'CompCareRMAB09M' ----CommandText LIKE '%USP_rptRMACS25%'

DROP TABLE IF EXISTS #testtbl

CREATE TABLE #testtbl( [name] nvarchar(50)  NULL,
                       commandtext nvarchar(MAX),
					   CommandType nvarchar(75))

OPEN CT_cursor

FETCH NEXT FROM CT_cursor   
INTO @name,@commandtext,@CommandType--,@source

--select * FROM #temp1
--PRINT @name;
--PRINT @source;
--PRINT @commandtext;
--PRINT @CommandType;

  
WHILE @@FETCH_STATUS = 0  
BEGIN


INSERT INTO #testtbl Select  @name,@commandtext,@CommandType -- where @CommandType = 'StoredProcedure'


--INSERT INTO #testtbl Select  @name,@commandtext,@CommandType


 FETCH NEXT FROM CT_cursor --INTO @testtbl
 
       END
     CLOSE CT_cursor
DEALLOCATE CT_cursor


 --SELECT * FROM #testtbl


 Declare @T Table (texts varchar(max))
 Insert @T EXEC SP_HELPTEXT 'Reports.USP_RptRMAB02M'
 SELECT * 
   FROM @T 

   			 SELECT [name] ReportName
				   ,DataSource 
				   ,CommandText
				   ,CommandType
			   FROM [RMABIStaging].dbo.BayBridgeReports 
              WHERE [name] = 'RMAB02M'