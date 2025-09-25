USE [AZU-MCC]
GO

SELECT [WorkItemStateId]
      ,[WorkItemStateName]
      ,[TenantId]
      ,[IsDeleted]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[AuditStartDate]
      ,[AuditEndDate]
  FROM [digi].[WorkItemState]
GO


