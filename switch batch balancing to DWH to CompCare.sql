USE [RMADW]
GO

SELECT sb.[SKMedicalInvoiceSwitchBatchTransactionID]
      ,sb.[BK1MedicalInvoiceSwitchBatchTransactionID]
      ,sb.[BK2MedicalInvoiceSwitchBatchTransactionID]
      ,sb.[SKRoleID]
      ,sb.[SKAssignedUserID]
      ,sb.[SKMedicalSwitchID]
      ,ms.[Name]
      ,ms.[Description]
      ,sb.[SKMedicalInvoiceSwitchBatchProfileID]
      ,sb.[SKUserID]
      ,sb.[SKIsAuditID]
      ,sb.[MedicalInvoiceSwitchBatchID]
      ,sb.[SwitchBatchDescription]
      ,sb.[SwitchBatchNumber]
      ,sb.[SwitchFileName]
      ,sb.[SubmittedDate]
      ,sb.[SubmittedDateID]
      ,sb.[SwitchedDate]
      ,sb.[SwitchedDateID]
      ,sb.[ReceivedDate]
      ,sb.[ReceivedDateID]
      ,sb.[CompletedDate]
      ,sb.[CompletedDateID]
      ,sb.[CapturedDate]
      ,sb.[CapturedDateID]
      ,sb.[LastChangedDate]
      ,sb.[LastChangedDateID]
      ,sb.[InvoicesStated]
      ,sb.[InvoicesCounted]
      ,sb.[InvoiceLinesStated]
      ,sb.[InvoiceLinesCounted]
      ,sb.[InvoiceAmountStatedIncludingVAT]
      ,sb.[InvoiceAmountCountedIncludingVAT]
      ,sb.[MedicalInvoiceSwitchBatchTransactionCount]
      ,sb.[DWLoadDateID]
  FROM [Derived].[FactMedicalInvoiceSwitchBatchTransaction] sb
       JOIN  [Mart].[DimMedicalSwitch] ms
    ON sb.[SKMedicalSwitchID] = ms.[SKMedicalSwitchID]	 
 WHERE sb.[ReceivedDateID] BETWEEN 20191201 AND 20191231  
   AND ms.[Name] = 'MediSwitch'
ORDER BY [SwitchBatchNumber]
GO


