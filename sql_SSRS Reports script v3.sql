USE [ReportServer]
GO

  SELECT Name
         --,[ItemID] --Primary key
        ,[Path]
        ,[Description]
        --,[CreatedByID] --need link to get anything usable from here
        ,Created.UserName as CreatedByUser
        ,[CreationDate]
        --,[ModifiedByID] --need link to get anything usable from here
        ,Modified.UserName as ModifiedByUser
        ,[ModifiedDate]
    FROM [dbo].[Catalog]
         left join ( select [UserID], [UserName] from [dbo].[Users]) as Created on Catalog.CreatedByID = Created.UserID
         left join ( select [UserID], [UserName] from [dbo].[Users]) as Modified on Catalog.ModifiedByID = Modified.UserID
   WHERE [Type] = 2 ---- value per foundation Source---- http://sqlsrv4living.blogspot.com/2014/01/ssrs-get-list-of-all-reports-using.html
ORDER BY [Path]
        ,Name