--USE [AZD-MCC]
--GO

--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [digi].[WorkItemTypeGroup](
--	[WorkItemTypeGroupId] [int] IDENTITY(1,1) NOT NULL,
--	[WorkItemTypeId] [int] NOT NULL,
--	[WorkItemTypeGroupName] [varchar](100) NOT NULL,
--	[WorkItemTypeGroupDescription] [varchar](200) NOT NULL,
--	[TenantId] [int] NOT NULL,
--	[IsDeleted] [bit] NOT NULL,
--	[CreatedDate] [datetime2](7) NOT NULL,
--	[CreatedBy] [int] NOT NULL,
--	[ModifiedDate] [datetime2](7) NOT NULL,
--	[ModifiedBy] [int] NOT NULL,
--	[AuditStartDate] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
--	[AuditEndDate] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
--PRIMARY KEY CLUSTERED 
--(
--	[WorkItemTypeGroupId] ASC
-- )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
--	PERIOD FOR SYSTEM_TIME ([AuditStartDate], [AuditEndDate])
--) ON [PRIMARY]
--  WITH 
--(
--  SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [digi].[WorkItemTypeGroupAudit] )
--)
--GO

--ALTER TABLE [digi].[WorkItemTypeGroup] ADD  DEFAULT ((0)) FOR [IsDeleted]
--GO

--ALTER TABLE [digi].[WorkItemTypeGroup]  WITH CHECK ADD  CONSTRAINT [FK_WorkItemTypeGroup_CreatedBy] FOREIGN KEY([CreatedBy])
--REFERENCES [security].[User] ([Id])
--GO

--ALTER TABLE [digi].[WorkItemTypeGroup] CHECK CONSTRAINT [FK_WorkItemTypeGroup_CreatedBy]
--GO

--ALTER TABLE [digi].[WorkItemTypeGroup]  WITH CHECK ADD  CONSTRAINT [FK_WorkItemTypeGroup_ModifiedBy] FOREIGN KEY([ModifiedBy])
--REFERENCES [security].[User] ([Id])
--GO

--ALTER TABLE [digi].[WorkItemTypeGroup] CHECK CONSTRAINT [FK_WorkItemTypeGroup_ModifiedBy]
--GO

--ALTER TABLE [digi].[WorkItemTypeGroup]  WITH CHECK ADD  CONSTRAINT [FK_WorkItemTypeGroup_Tenant] FOREIGN KEY([TenantId])
--REFERENCES [security].[Tenant] ([Id])
--GO

--ALTER TABLE [digi].[WorkItemTypeGroup] CHECK CONSTRAINT [FK_WorkItemTypeGroup_Tenant]
--GO


--USE [AZU-MCC]
--GO

--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [digi].[MedicalReportCategory](
--	[MedicalReportCategoryId] [int] IDENTITY(1,1) NOT NULL,
--	[MedicalReportCategoryName] [varchar](100) NOT NULL,
--	[MedicalReportCategoryDescription] [varchar](200) NOT NULL,
--	[TenantId] [int] NOT NULL,
--	[IsDeleted] [bit] NOT NULL,
--	[CreatedDate] [datetime2](7) NOT NULL,
--	[CreatedBy] [int] NOT NULL,
--	[ModifiedDate] [datetime2](7) NOT NULL,
--	[ModifiedBy] [int] NOT NULL,
--	[AuditStartDate] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
--	[AuditEndDate] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
--PRIMARY KEY CLUSTERED 
--(
--	[MedicalReportCategoryId] ASC
-- )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
--	PERIOD FOR SYSTEM_TIME ([AuditStartDate], [AuditEndDate])
--) ON [PRIMARY]
--  WITH 
--(
--  SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [digi].[MedicalReportCategoryAudit] )
--)
--GO

--ALTER TABLE [digi].[MedicalReportCategory] ADD  DEFAULT ((0)) FOR [IsDeleted]
--GO

--ALTER TABLE [digi].[MedicalReportCategory]  WITH CHECK ADD  CONSTRAINT [FK_MedicalReportCategory_CreatedBy] FOREIGN KEY([CreatedBy])
--REFERENCES [security].[User] ([Id])
--GO

--ALTER TABLE [digi].[MedicalReportCategory] CHECK CONSTRAINT [FK_MedicalReportCategory_CreatedBy]
--GO

--ALTER TABLE [digi].[MedicalReportCategory]  WITH CHECK ADD  CONSTRAINT [FK_MedicalReportCategory_ModifiedBy] FOREIGN KEY([ModifiedBy])
--REFERENCES [security].[User] ([Id])
--GO

--ALTER TABLE [digi].[MedicalReportCategory] CHECK CONSTRAINT [FK_MedicalReportCategory_ModifiedBy]
--GO

--ALTER TABLE [digi].[MedicalReportCategory]  WITH CHECK ADD  CONSTRAINT [FK_MedicalReportCategory_Tenant] FOREIGN KEY([TenantId])
--REFERENCES [security].[Tenant] ([Id])
--GO

--ALTER TABLE [digi].[MedicalReportCategory] CHECK CONSTRAINT [FK_MedicalReportCategory_Tenant]
--GO





--CREATE TABLE [digi].[MedicalReportType](
--	[MedicalReportTypeId] [int] IDENTITY(1,1) NOT NULL,
--	[MedicalReportTypeName] [varchar](100) NOT NULL,
--	[MedicalReportTypeDescription] [varchar](200) NOT NULL,
--	[TenantId] [int] NOT NULL,
--	[IsDeleted] [bit] NOT NULL,
--	[CreatedDate] [datetime2](7) NOT NULL,
--	[CreatedBy] [int] NOT NULL,
--	[ModifiedDate] [datetime2](7) NOT NULL,
--	[ModifiedBy] [int] NOT NULL,
--	[AuditStartDate] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
--	[AuditEndDate] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
--PRIMARY KEY CLUSTERED 
--(
--	[MedicalReportTypeId] ASC
-- )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
--	PERIOD FOR SYSTEM_TIME ([AuditStartDate], [AuditEndDate])
--) ON [PRIMARY]
--  WITH 
--(
--  SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [digi].[MedicalReportTypeAudit] )
--)
--GO

--ALTER TABLE [digi].[MedicalReportType] ADD  DEFAULT ((0)) FOR [IsDeleted]
--GO

--ALTER TABLE [digi].[MedicalReportType]  WITH CHECK ADD  CONSTRAINT [FK_MedicalReportType_CreatedBy] FOREIGN KEY([CreatedBy])
--REFERENCES [security].[User] ([Id])
--GO

--ALTER TABLE [digi].[MedicalReportType] CHECK CONSTRAINT [FK_MedicalReportType_CreatedBy]
--GO

--ALTER TABLE [digi].[MedicalReportType]  WITH CHECK ADD  CONSTRAINT [FK_MedicalReportType_ModifiedBy] FOREIGN KEY([ModifiedBy])
--REFERENCES [security].[User] ([Id])
--GO

--ALTER TABLE [digi].[MedicalReportType] CHECK CONSTRAINT [FK_MedicalReportType_ModifiedBy]
--GO

--ALTER TABLE [digi].[MedicalReportType]  WITH CHECK ADD  CONSTRAINT [FK_MedicalReportType_Tenant] FOREIGN KEY([TenantId])
--REFERENCES [security].[Tenant] ([Id])
--GO

--ALTER TABLE [digi].[MedicalReportType] CHECK CONSTRAINT [FK_MedicalReportType_Tenant]
--GO
