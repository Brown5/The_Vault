USE [RMAProd]
GO

select top 1  MedicalReportTypeID, MedicalReportCategoryID,* from Medical.MedicalReport --- MedicalReportTypeID, MedicalReportCategoryID
select * from Medical.MedicalReportType
select * from Medical.MedicalReportCategory  