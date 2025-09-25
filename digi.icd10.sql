USE RMADW
Go

  SELECT  
         x.ICD10CodeID,
         x.ICD10Code                       AS Level4Code,
         x.Description                     AS Level4Description,
         x.ICD10SubCategoryCode            AS Level3Code,
         x.ICD10SubCategoryDescription     AS Level3Description,
         x.ICD10CategoryCode               AS Level2Code,
         x.ICD10CategoryDescription        AS Level2Description,
         x.ICD10DiagnosticGroupCode        AS Level1Code,
         x.ICD10DiagnosticGroupDescription AS Level1Description,
		 1                                 AS [TenantId],
         0                                 AS [IsDeleted],
         GETDATE()                         AS [CreatedDate],
         3255                              AS [CreatedBy],
         GETDATE()                         AS [ModifiedDate],
         3255                              AS [ModifiedBy]
    FROM [Mart].[DimICD10Code] x
   WHERE x.ICD10CodeID > 0
ORDER BY 1