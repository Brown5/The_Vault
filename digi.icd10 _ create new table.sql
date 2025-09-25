USE [AZD-MCC]
GO

/****** Object:  Table [digi].[ICD10Code]    Script Date: 8/5/2020 3:35:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [digi].[ICD10Code1](
	[ICD10CodeId]            [int] IDENTITY(1,1) NOT NULL,

	[ICD10Level4Code]        [varchar](100) NOT NULL,
	[ICD10Level4Description] [varchar](200) NOT NULL,
	[ICD10Level3Code]        [varchar](100) NOT NULL,
	[ICD10Level3Description] [varchar](200) NOT NULL,
	[ICD10Level2Code]        [varchar](100) NOT NULL,
	[ICD10Level2Description] [varchar](200) NOT NULL,
	[ICD10Level1Code]        [varchar](100) NOT NULL,
	[ICD10Level1Description] [varchar](200) NOT NULL,

	[TenantId]               [int] NOT NULL,
	[IsDeleted]              [bit] NOT NULL,
	[CreatedDate]            [datetime2](7) NOT NULL,
	[CreatedBy]              [int] NOT NULL,
	[ModifiedDate]           [datetime2](7) NOT NULL,
	[ModifiedBy]             [int] NOT NULL,
	[AuditStartDate]         [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[AuditEndDate]           [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ICD10CodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([AuditStartDate], [AuditEndDate])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [digi].[ICD10CodeAudit] )
)
GO

ALTER TABLE [digi].[ICD10Code1] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO

ALTER TABLE [digi].[ICD10Code1]  WITH CHECK ADD  CONSTRAINT [FK_ICD10Code1_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [security].[User] ([Id])
GO

ALTER TABLE [digi].[ICD10Code1] CHECK CONSTRAINT [FK_ICD10Code1_CreatedBy]
GO

ALTER TABLE [digi].[ICD10Code1]  WITH CHECK ADD  CONSTRAINT [FK_ICD10Code1_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [security].[User] ([Id])
GO

ALTER TABLE [digi].[ICD10Code1] CHECK CONSTRAINT [FK_ICD10Code1_ModifiedBy]
GO

ALTER TABLE [digi].[ICD10Code1]  WITH CHECK ADD  CONSTRAINT [FK_ICD10Code1_Tenant] FOREIGN KEY([TenantId])
REFERENCES [security].[Tenant] ([Id])
GO

ALTER TABLE [digi].[ICD10Code1] CHECK CONSTRAINT [FK_ICD10Code1_Tenant]
GO


