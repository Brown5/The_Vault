USE RMADW;

  SELECT c.[Name]
        ,a.MedicalInvoiceID
        ,a.InvoiceDateID
        ,a.ReceivedDateID
        ,a.SubmittedDateID
        ,a.AdmittedDateID
        ,a.DischargedDateID
        ,a.EventDateID
        ,a.LastChangedDateID
        ,a.BatchSequenceNumber
        ,d.FileRefNumber ClaimFileRefNumber
        ,a.FirstName
        ,a.Surname
        ,a.SPAccountNumber
        ,a.SPInvoiceNumber
        --,a.[Status]
        ,a.SwitchBatchNo
        ,a.SwitchTransactionNo
        ,a.TotalInvoiceAmountExcl
        ,a.TotalInvoiceAmountIncl
        ,a.TotalInvoiceVAT
		,d.ClaimID
        ,d.Comments
        ,d.FileRefNumber
        ,d.HoldingKey
        ,d.InvoiceAllocationID
        ,d.InvoiceNumber
        ,d.InvoicerID
        ,d.InvoicerTypeID
        ,d.MedicalInvoiceID
        ,d.MISwitchBatchID
        ,d.PersonEventID
        ,d.SPAccountNumber
        ,d.PaymentRequestStatusDescription
        ,d.SwitchTransactionNo
        ,d.TariffBaseUnitCostTypeID
        ,d.TreatmentAuthorizationID
        ,d.TreatmentCodeID
        ,d.UnderAssessReasonID
        ,d.UnderAssessedReason
        ,d.InvoiceDate
        ,d.InvoiceDateID
        ,d.ReceivedDate
        ,d.ReceivedDateID
        ,d.SubmittedDate
        ,d.SubmittedDateID
        ,d.AdmittedDate
        ,d.AdmittedDateID
        ,d.DischargedDate
        ,d.DischargedDateID
        ,d.PaymentRequestedDate
        ,d.PaymentRequestedDateID
        ,d.PaymentRequestAuthorisedDate
        ,d.PaymentRequestAuthorisedDateID
        ,d.PaymentRequestSentDate
        ,d.PaymentRequestSentDateID
        ,d.PaymentRequestPaidDate
        ,d.PaymentRequestPaidDateID
        ,d.TotalInvoiceAmount
        ,d.TotalInvoiceVAT
        ,d.TotalInvoiceAmountIncludingVAT
        ,d.TotalAuthorisedAmount
        ,d.TotalAuthorisedVAT
        ,d.TotalAuthorisedIncludingVAT
        ,d.PaymentAmountExcludingVAT
        ,d.PaymentAmountVAT
        ,d.PaymentAmountIncludingVAT
        ,d.PayDaysOff
        ,d.SKUserID
        ,d.SKIsAuditID
        ,d.LastChangedDate
        ,d.LastChangedDateID
        ,d.SKInvoiceTypeID
        ,d.PercentageAllocation
        ,d.AssessedAmount
        ,d.AssessedVAT
        ,d.AssessedAmountIncl
        ,d.DaysOffInvoiceCapturedDate
        ,d.DaysOffInvoiceCapturedDateID
        ,d.SKDaysOffInvoiceCapturedUserID
        ,d.FirstPaymentRequestAuthorisedDate
        ,d.FirstPaymentRequestAuthorisedDateID
        ,d.LagDaysOffInvoiceCapturedToPaymentRequestAuthorisedDate
        ,d.LagDaysOffInvoiceCapturedToPaymentRequestPaidDate
        ,d.PDAwardDate
        ,d.PDAwardDateID
        ,d.LagPDAwardDateCapturedToPaymentRequestAuthorised
        ,d.LagPDAwardDateCapturedToPaymentRequestPaidDate
    FROM Derived.[FactMedicalMISwitchBatchInvoiceSnapshot] a	
	     JOIN RMADW.Derived.FactMedicalInvoiceSwitchBatchSnapshot b
      ON a.MISwitchBatchID = b.MedicalInvoiceSwitchBatchID
     AND a.SwitchBatchNo = b.SwitchBatchNumber
	 AND a.PartitionID = 202002	
	 AND b.PartitionID = 202002	
	     JOIN [Mart].[DimMedicalSwitch] c
	  ON b.[SKMedicalSwitchID] = c.[SKMedicalSwitchID]
     --AND c.SKMedicalSwitchID = 3
	     left JOIN RMADW.Derived.FactMedicalInvoiceAllocationSnapshot d
      ON a.MedicalInvoiceID = d.MedicalInvoiceID
     --AND a.ClaimFileRefNumber = d.FileRefNumber
	 AND d.PartitionID = 202002
   WHERE a.ReceivedDateID BETWEEN 20200201 AND 20200229
ORDER BY a.ReceivedDateID


  --SELECT top 1000 a.*
  --  FROM RMADW.Derived.FactMedicalInvoiceAllocationSnapshot a

--  SELECT top 1000 a.*
--    FROM RMADW.Derived.FactMedicalInvoiceSwitchBatchSnapshot a
--	     JOIN [Mart].[DimMedicalSwitch] b
--	  ON a.[SKMedicalSwitchID] = b.[SKMedicalSwitchID]
--   WHERE SwitchBatchNumber = 'CF1151'
--     AND a.PartitionID = 202003
--ORDER BY a.PartitionID

--  SELECT top 1000 a.*
--        , b.*
--    FROM RMADW.Derived.FactMedicalInvoiceSwitchBatchTransaction a
--	     JOIN [Mart].[DimMedicalSwitch] b
--	  ON a.[SKMedicalSwitchID] = b.[SKMedicalSwitchID]
--   WHERE a.SwitchBatchNumber = 'CF1151'
--     --AND a.SKMedicalSwitchID = 3


--USE RMADW;

--  SELECT distinct ssch.[name] as [Schema Name]
--        ,t.name AS tableName
--		,c.name AS columnName
--		,c.column_id
--        ,ty.Name 'DataType'
--        ,c.max_length 'MaxLength'
--        ,c.is_nullable
--        ,ISNULL(i.is_primary_key, 0) 'PrimaryKey'
--		--,o.name AS objectName
--		--,o.type_desc AS objectType
--    FROM sys.sql_dependencies d
--         INNER JOIN sys.columns c ON d.referenced_major_id = c.object_id AND d.referenced_minor_id = c.column_id
--	     INNER JOIN sys.tables t  ON c.object_id = t.object_id
--	     INNER JOIN sys.objects o ON d.object_id = o.object_id
--		 INNER JOIN sys.schemas ssch ON t.schema_id = ssch.schema_id
--         INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
--         LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
--         LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
--   WHERE t.name  = 'FactMedicalInvoiceAllocationSnapshot'
--   --WHERE ssch.[name] = 'Transformation'
--   --WHERE c.name  = 'SKMedicalSwitchID' --LIKE '%SKMedicalSwitchID%'---
--ORDER BY ssch.[name], t.name, c.column_id--, o.name, c.column_id

