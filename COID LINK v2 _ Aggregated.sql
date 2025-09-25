USE RMADW;

DROP TABLE IF EXISTS #SwitchBatchInvoice  SELECT * INTO #SwitchBatchInvoice FROM Derived.[FactMedicalMISwitchBatchInvoiceSnapshot] a   WHERE a.PartitionID = 202002					  
DROP TABLE IF EXISTS #InvoiceSwitchBatch  SELECT * INTO #InvoiceSwitchBatch FROM RMADW.Derived.FactMedicalInvoiceSwitchBatchSnapshot b WHERE b.PartitionID = 202002 					  
DROP TABLE IF EXISTS #MedicalInvoice      SELECT * INTO #MedicalInvoice     FROM RMADW.Derived.FactMedicalInvoiceSnapshot d            WHERE d.PartitionID = 202002					  
DROP TABLE IF EXISTS #InvoiceAllocation   SELECT * INTO #InvoiceAllocation  FROM RMADW.Derived.FactMedicalInvoiceAllocationSnapshot d  WHERE d.PartitionID = 202002

  SELECT c.[Name] SwitchName
        ,msp.MedicalServiceProviderName
		,CONVERT(varchar(7), a.ReceivedDate, 126)    ReceivedMonth
        ,COUNT( a.MedicalInvoiceID)          InvoicesReceived
		,SUM(DISTINCT a.TotalInvoiceAmountIncl)      TotalInvoiceAmountIncl
        ,COUNT(CASE WHEN del.[SKMISwitchDeleteReasonID] = 0 THEN NULL ELSE 'SoftDeletes' END) AS [SoftDeletes]
		,SUM(CASE WHEN iss.InvoiceStatusName LIKE '%Deleted%' THEN 1 ELSE 0 END) Deleted
		,SUM(CASE WHEN iss.InvoiceStatusName LIKE '%Pend%' THEN 1 ELSE 0 END) Pended 
		,SUM(CASE WHEN iss.InvoiceStatusName LIKE '%Reject%' THEN 1 
		          --WHEN iss.InvoiceStatusName LIKE '%Deleted%' THEN 1 
				  ELSE 0 END) Rejected 
		--,COUNT(iss.InvoiceStatusName) cnt
        ,COUNT(d.PaymentAmountIncludingVAT)          InvoicesPaid
		,SUM(DISTINCT d.TotalAuthorisedIncludingVAT) TotalAuthorisedIncludingVAT
        ,SUM(DISTINCT d.PaymentAmountIncludingVAT)   PaymentAmountIncludingVAT
    FROM #SwitchBatchInvoice a
	     LEFT JOIN [Mart].[DimMedicalServiceProvider] msp  ON a.[SKMedicalServiceProviderID] = msp.[SKMedicalServiceProviderID]
	     JOIN #InvoiceSwitchBatch b ON a.MISwitchBatchID = b.MedicalInvoiceSwitchBatchID AND a.SwitchBatchNo = b.SwitchBatchNumber   
	     JOIN [Mart].[DimMedicalSwitch] c ON b.[SKMedicalSwitchID] = c.[SKMedicalSwitchID]  AND c.SKMedicalSwitchID = 6 --IN ( 10, 20, 21, 22 )
	     LEFT JOIN #InvoiceAllocation d ON a.MedicalInvoiceID = d.MedicalInvoiceID  --AND a.ClaimFileRefNumber = d.FileRefNumber
	     LEFT JOIN #MedicalInvoice e ON a.MedicalInvoiceID = e.MedicalInvoiceID  
	     LEFT JOIN [Mart].[DimInvoiceStatus] dis ON d.[SKInvoiceStatusID] = dis.[SKInvoiceStatusID]
		 LEFT JOIN [Mart].[DimMedicalMISwitchBatchDeleteReason] del ON a.SKMISwitchDeleteReasonID = del.SKMISwitchDeleteReasonID
		 LEFT JOIN [Mart].[DimUnderAssessReason] uar ON e.[SKUnderAssessReasonID] = uar.[SKUnderAssessReasonID]
		 LEFT JOIN [Mart].[DimInvoiceStatus] iss ON e.SKInvoiceStatusID = iss.SKInvoiceStatusID
   WHERE a.ReceivedDateID BETWEEN 20190101 AND 20200229
     AND iss.InvoiceStatusDescription IS NOT NULL
GROUP BY c.[Name],msp.MedicalServiceProviderName,CONVERT(varchar(7), a.ReceivedDate, 126)
ORDER BY c.[Name],msp.MedicalServiceProviderName,CONVERT(varchar(7), a.ReceivedDate, 126)


