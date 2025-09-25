USE RMADW;

DROP TABLE IF EXISTS #SwitchBatchInvoice  SELECT * INTO #SwitchBatchInvoice FROM RMADW.Derived.[FactMedicalMISwitchBatchInvoiceSnapshot] a WHERE a.PartitionID = 202002 AND a.ReceivedDateID BETWEEN 20200201 AND 20200229 						  
DROP TABLE IF EXISTS #InvoiceSwitchBatch  SELECT * INTO #InvoiceSwitchBatch FROM RMADW.Derived.FactMedicalInvoiceSwitchBatchSnapshot b WHERE b.PartitionID = 202002 AND b.ReceivedDateID BETWEEN 20200201 AND 20200229					  
DROP TABLE IF EXISTS #MedicalInvoice      SELECT * INTO #MedicalInvoice FROM RMADW.Derived.FactMedicalInvoiceSnapshot d                WHERE d.PartitionID = 202002					  
DROP TABLE IF EXISTS #InvoiceAllocation   SELECT * INTO #InvoiceAllocation FROM RMADW.Derived.FactMedicalInvoiceAllocationSnapshot d   WHERE d.PartitionID = 202002

  SELECT CONVERT(CHAR(4), b.ReceivedDate, 100) + CONVERT(CHAR(4), b.ReceivedDate, 120) ReceivedMonth
        ,c.[Name]
		,b.[SKMedicalSwitchID] 
		,SUM( b.InvoicesCounted) InvoicesCounted
		,SUM( b.InvoiceAmountStatedIncludingVAT) InvoiceAmountStatedIncludingVAT
    FROM #InvoiceSwitchBatch b
	     JOIN [Mart].[DimMedicalSwitch] c ON b.[SKMedicalSwitchID] = c.[SKMedicalSwitchID]  
   WHERE b.SKIsDeletedID = 1
GROUP BY CONVERT(CHAR(4), b.ReceivedDate, 100) + CONVERT(CHAR(4), b.ReceivedDate, 120) 
        ,c.[Name]
		,b.[SKMedicalSwitchID] 



  SELECT CONVERT(CHAR(4), a.ReceivedDate, 100) + CONVERT(CHAR(4), a.ReceivedDate, 120) ReceivedMonth
        --,COUNT(a.MedicalInvoiceID) MedicalInvoiceID
		,COUNT(dis.InvoiceStatusName) InvoiceStatusName
		,SUM(d.TotalInvoiceAmountIncludingVAT) TotalInvoiceAmountIncludingVAT
    FROM #SwitchBatchInvoice a
	     LEFT JOIN #InvoiceAllocation d ON a.MedicalInvoiceID = d.MedicalInvoiceID
		 LEFT JOIN #MedicalInvoice e ON a.MedicalInvoiceID = e.MedicalInvoiceID
	     LEFT JOIN [Mart].[DimInvoiceStatus] dis ON d.[SKInvoiceStatusID] = dis.[SKInvoiceStatusID]
		 LEFT JOIN [Mart].[DimMedicalMISwitchBatchDeleteReason] del ON a.SKMISwitchDeleteReasonID = del.SKMISwitchDeleteReasonID
		 LEFT JOIN [Mart].[DimUnderAssessReason] uar ON d.[SKUnderAssessReasonID] = uar.[SKUnderAssessReasonID]
		 LEFT JOIN [Mart].[DimInvoiceStatus] iss ON e.SKInvoiceStatusID = iss.SKInvoiceStatusID
GROUP BY CONVERT(CHAR(4), a.ReceivedDate, 100) + CONVERT(CHAR(4), a.ReceivedDate, 120) 
		,dis.InvoiceStatusName



----USE RMADW;

----DROP TABLE IF EXISTS #SwitchBatchInvoice  SELECT * INTO #SwitchBatchInvoice FROM [Mart].[FactMedicalMISwitchBatchInvoiceTransaction] a --WHERE a.PartitionID = 202002					  
----DROP TABLE IF EXISTS #InvoiceSwitchBatch  SELECT * INTO #InvoiceSwitchBatch FROM RMADW.Derived.FactMedicalInvoiceSwitchBatchSnapshot b WHERE b.PartitionID = 202002 					  
----DROP TABLE IF EXISTS #InvoiceAllocation   SELECT * INTO #InvoiceAllocation FROM RMADW.Derived.FactMedicalInvoiceAllocationSnapshot d WHERE d.PartitionID = 202002


----  SELECT c.[Name]
----        --,msp.MedicalServiceProviderName
----		,CONVERT(varchar(7), a.ReceivedDate, 126)    ReceivedMonth
----        ,COUNT(DISTINCT a.MedicalInvoiceID)          InvoicesReceived
----		,SUM(DISTINCT a.TotalInvoiceAmountIncl)      TotalInvoiceAmountIncl
----        ,COUNT(d.PaymentAmountIncludingVAT)          InvoicesPaid
----        ,COUNT(CASE WHEN del.[SKMISwitchDeleteReasonID] = 0 THEN NULL ELSE 'SoftDeletes' END) AS [SoftDeletes]
----		,SUM(DISTINCT d.TotalAuthorisedIncludingVAT) TotalAuthorisedIncludingVAT
----        ,SUM(DISTINCT d.PaymentAmountIncludingVAT)   PaymentAmountIncludingVAT
----    FROM #SwitchBatchInvoice a
----	     JOIN [Mart].[DimMedicalServiceProvider] msp  ON a.[SKMedicalServiceProviderID] = msp.[SKMedicalServiceProviderID]
----	     JOIN #InvoiceSwitchBatch b ON a.MISwitchBatchID = b.MedicalInvoiceSwitchBatchID AND a.SwitchBatchNo = b.SwitchBatchNumber   
----	     JOIN [Mart].[DimMedicalSwitch] c ON b.[SKMedicalSwitchID] = c.[SKMedicalSwitchID]  AND c.SKMedicalSwitchID IN ( 6 )--, 26 )
----	     LEFT JOIN #InvoiceAllocation d ON a.MedicalInvoiceID = d.MedicalInvoiceID  --AND a.ClaimFileRefNumber = d.FileRefNumber
----	     LEFT JOIN [Mart].[DimInvoiceStatus] dis ON d.[SKInvoiceStatusID] = dis.[SKInvoiceStatusID]
----		 LEFT JOIN [Mart].[DimMedicalMISwitchBatchDeleteReason] del ON a.SKMISwitchDeleteReasonID = del.SKMISwitchDeleteReasonID
----   WHERE a.ReceivedDateID BETWEEN 20190101 AND 20200229
----GROUP BY c.[Name], CONVERT(varchar(7), a.ReceivedDate, 126)--, msp.MedicalServiceProviderName
----ORDER BY CONVERT(varchar(7), a.ReceivedDate, 126)

----USE RMADW;

----DROP TABLE IF EXISTS #SwitchBatchInvoice  SELECT * INTO #SwitchBatchInvoice FROM [Mart].[FactMedicalMISwitchBatchInvoiceTransaction] a --WHERE a.PartitionID = 202002					  
----DROP TABLE IF EXISTS #InvoiceSwitchBatch  SELECT * INTO #InvoiceSwitchBatch FROM RMADW.Derived.FactMedicalInvoiceSwitchBatchSnapshot b WHERE b.PartitionID = 202002 					  
----DROP TABLE IF EXISTS #InvoiceAllocation   SELECT * INTO #InvoiceAllocation FROM RMADW.Derived.FactMedicalInvoiceAllocationSnapshot d WHERE d.PartitionID = 202002

----  SELECT 
----         c.Name
----        ,msp.[MedicalServiceProviderName] [ProviderName]
----        ,msp.[PracticeNumber] [ProviderPracticeNumber]
----        ,msp.[PractitionerTypeDescription] [ProviderDisciplineType]
----        ,a.MedicalInvoiceID
----        ,a.InvoiceDateID
----		,CONVERT(CHAR(4), a.InvoiceDate, 100) + CONVERT(CHAR(4), a.InvoiceDate, 120)  InvoiceMonth
----        ,a.ReceivedDateID
----		,CONVERT(CHAR(4), a.ReceivedDate, 100) + CONVERT(CHAR(4), a.ReceivedDate, 120) ReceivedMonth
----		,convert(varchar(7), a.ReceivedDate, 126) 
----        ,a.SubmittedDateID
----		,CONVERT(CHAR(4), a.SubmittedDate, 100) + CONVERT(CHAR(4), a.SubmittedDate, 120) SubmittedMonth
----        ,a.ClaimFileRefNumber
----        ,a.Status
----        ,a.TotalInvoiceAmountIncl
----		,d.TotalAuthorisedIncludingVAT
----        ,d.PaymentAmountIncludingVAT
----		,dis.[InvoiceStatusName]
----		,dis.[InvoiceStatusDescription]
----        --,Pended
----        --,Rejected
----        --,Rejection Reason
----        ,CASE WHEN del.[SKMISwitchDeleteReasonID] = 0 THEN NULL ELSE 'SoftDeletes' END AS [SoftDeletes]
----    FROM #SwitchBatchInvoice a
----	     JOIN [Mart].[DimMedicalServiceProvider] msp  ON a.[SKMedicalServiceProviderID] = msp.[SKMedicalServiceProviderID]
----	     JOIN #InvoiceSwitchBatch b ON a.MISwitchBatchID = b.MedicalInvoiceSwitchBatchID AND a.SwitchBatchNo = b.SwitchBatchNumber   
----	     JOIN [Mart].[DimMedicalSwitch] c ON b.[SKMedicalSwitchID] = c.[SKMedicalSwitchID]  AND c.SKMedicalSwitchID = 3
----	     LEFT JOIN #InvoiceAllocation d ON a.MedicalInvoiceID = d.MedicalInvoiceID  --AND a.ClaimFileRefNumber = d.FileRefNumber
----	     LEFT JOIN [Mart].[DimInvoiceStatus] dis ON d.[SKInvoiceStatusID] = dis.[SKInvoiceStatusID]
----		 LEFT JOIN [Mart].[DimMedicalMISwitchBatchDeleteReason] del ON a.SKMISwitchDeleteReasonID = del.SKMISwitchDeleteReasonID
----   WHERE a.ReceivedDateID BETWEEN 20190101 AND 20200229
