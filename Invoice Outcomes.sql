USE RMADW;

DECLARE @Date int
    SET @Date = ( SELECT CONVERT(varchar(6), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0), 112) )


DROP TABLE IF EXISTS #SwitchBatchInvoice SELECT * INTO #SwitchBatchInvoice FROM Derived.[FactMedicalMISwitchBatchInvoiceSnapshot] a   WHERE a.PartitionID = @Date						  
DROP TABLE IF EXISTS #InvoiceSwitchBatch SELECT * INTO #InvoiceSwitchBatch FROM RMADW.Derived.FactMedicalInvoiceSwitchBatchSnapshot b WHERE b.PartitionID = @Date 					  
DROP TABLE IF EXISTS #MedicalInvoice     SELECT * INTO #MedicalInvoice     FROM RMADW.Derived.FactMedicalInvoiceSnapshot d            WHERE d.PartitionID = @Date					  
DROP TABLE IF EXISTS #InvoiceAllocation  SELECT * INTO #InvoiceAllocation  FROM RMADW.Derived.FactMedicalInvoiceAllocationSnapshot d  WHERE d.PartitionID = @Date


  DROP TABLE IF EXISTS #Invoices
  SELECT 
         CASE WHEN c.Name IS NULL THEN 'Unknown' ELSE c.Name END AS Name
        ,msp.[MedicalServiceProviderName] [ProviderName]
        ,msp.[PracticeNumber] [ProviderPracticeNumber]
        ,msp.[PractitionerTypeDescription] [ProviderDisciplineType] 
        ,CASE WHEN a.MedicalInvoiceID IS NULL THEN '999' ELSE a.MedicalInvoiceID END AS MedicalInvoiceID
		,e.SPInvoiceNumber
        ,a.InvoiceDateID
		,CONVERT(CHAR(4), a.InvoiceDate, 100) + CONVERT(CHAR(4), a.InvoiceDate, 120)  InvoiceMonth
        ,a.ReceivedDateID
		,CONVERT(CHAR(4), a.ReceivedDate, 100) + CONVERT(CHAR(4), a.ReceivedDate, 120) ReceivedMonth
		,CONVERT(varchar(7), a.ReceivedDate, 126) ReceivedMonth1
        ,a.SubmittedDateID
		,CONVERT(CHAR(4), a.SubmittedDate, 100) + CONVERT(CHAR(4), a.SubmittedDate, 120) SubmittedMonth
        ,a.ClaimFileRefNumber
		,iss.InvoiceStatusDescription
		,COALESCE (uar.UnderAssessReasonDescription,uar1.UnderAssessReasonDescription ) UnderAssessReasonDescription
        ,a.TotalInvoiceAmountIncl
		,d.TotalAuthorisedIncludingVAT
        ,d.PaymentAmountIncludingVAT --AVG(d.PaymentAmountIncludingVAT) PaymentAmountIncludingVAT
		,dis.[InvoiceStatusName]
		,dis.[InvoiceStatusDescription] [DIS_InvoiceStatusDescription]
        ,CASE WHEN del.[SKMISwitchDeleteReasonID] = 0 THEN NULL ELSE 'SoftDeletes' END AS [SoftDeletes]
    INTO #Invoices
    FROM #SwitchBatchInvoice a
	     LEFT JOIN [Mart].[DimMedicalServiceProvider] msp ON a.[SKMedicalServiceProviderID] = msp.[SKMedicalServiceProviderID]
	     LEFT JOIN #InvoiceSwitchBatch b              ON a.MISwitchBatchID = b.MedicalInvoiceSwitchBatchID AND a.SwitchBatchNo = b.SwitchBatchNumber   
	     LEFT JOIN [Mart].[DimMedicalSwitch] c            ON b.[SKMedicalSwitchID] = c.[SKMedicalSwitchID] 
	     LEFT JOIN #InvoiceAllocation d               ON a.MedicalInvoiceID = d.MedicalInvoiceID 
	     LEFT JOIN #MedicalInvoice e                  ON a.MedicalInvoiceID = e.MedicalInvoiceID  
	     LEFT JOIN [Mart].[DimInvoiceStatus] dis      ON d.[SKInvoiceStatusID] = dis.[SKInvoiceStatusID]
		 LEFT JOIN [Mart].[DimMedicalMISwitchBatchDeleteReason] del ON a.SKMISwitchDeleteReasonID = del.SKMISwitchDeleteReasonID
		 LEFT JOIN [Mart].[DimUnderAssessReason] uar  ON e.[SKUnderAssessReasonID] = uar.[SKUnderAssessReasonID]
		 LEFT JOIN [Mart].[DimUnderAssessReason] uar1 ON d.[SKUnderAssessReasonID] = uar1.[SKUnderAssessReasonID]
		 LEFT JOIN [Mart].[DimInvoiceStatus] iss      ON e.SKInvoiceStatusID = iss.SKInvoiceStatusID
   WHERE a.ReceivedDateID BETWEEN convert(varchar, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0),112)  --First day of previous month
                              AND convert(varchar, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1),112)  --Last Day of previous month
ORDER BY a.ReceivedDateID
        ,c.Name
        ,msp.[MedicalServiceProviderName]	



   SELECT * FROM #Invoices a