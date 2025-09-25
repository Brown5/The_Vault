

----DECLARE @user VARCHAR (50);
----    SET @user = ( SELECT Email FROM [security].[User] WHERE DisplayName = 'Neil Andrew Brown' )

----DECLARE @userid int;
----    SET @userid = ( SELECT Id FROM [security].[User] WHERE DisplayName = 'Neil Andrew Brown' )

----/*1. Insert multi tenant record into the security.Tenant table */
----SET IDENTITY_INSERT [security].[Tenant] ON
----INSERT INTO [security].[Tenant]
----            ( [Id], [Name], [Domain], [IsActive], [IsDeleted], [CreatedBy], [CreatedDate], [ModifiedBy],[ModifiedDate] )
----     VALUES 
----	 ---( -100,	'Shared','rma.msft',	1,	0,	@user,	GETDATE(),	@user,	GETdate() )
----	 (102,	'Oraleans', 'orl.local', 1,	0,	@user,	GETDATE(),	@user,	GETdate() ),
----     (103,	'Titan',	'atn.local', 1,	0,	@user,	GETDATE(),	@user,	GETdate() ),
----     (104,	'Dundl',	'lg.local',	 1,	0,	@user,	GETDATE(),	@user,	GETdate() ),
----     (105,	'News24',	'n24.local', 1,	0,	@user,	GETDATE(),	@user,	GETdate() )

----SET IDENTITY_INSERT [security].[Tenant] OFF

--/*2. Insert records into the digi.WorkItemState table */
--INSERT INTO [digi].[WorkItemState] 
--       ( [WorkItemStateName], [TenantId], [IsDeleted], [CreatedDate], [CreatedBy], [ModifiedDate], [ModifiedBy] ) 
--VALUES ( 'Complete',	-100,	0,	GETDATE(),	@userid,	GETDATE(),	@userid ),
--       ( 'Incomplete',	-100,	0,	GETDATE(),	@userid,	GETDATE(),	@userid )



----/*Insert 1st, progress and final medical reports into the digi.WorkItemType table */
----INSERT INTO [digi].[WorkItemType]
----       ( [WorkItemTypeName], [WorkItemTypeDescription], [TenantId], [IsDeleted], [CreatedDate], [CreatedBy], [ModifiedDate], [ModifiedBy] ) 
 
----VALUES 
----       ( 'First Medical Report',    'dbo.WorkItemType01',	-100,	0,	GETDATE(),	@userid,	GETDATE(),	@userid, ),
----       ( 'Progress Medical Report', 'dbo.WorkItemType01',	-100,	0,	GETDATE(),	@userid,	GETDATE(),	@userid, ),
----       ( 'Final Medical Report',	'dbo.WorkItemType01',	-100,	0,	GETDATE(),	@userid,	GETDATE(),	@userid, )


----BEGIN TRAN   
----ALTER TABLE [digi].[WorkItemType001TreatmentType] SET (SYSTEM_VERSIONING = OFF);  

----ALTER TABLE [digi].[WorkItemType001TreatmentType] ALTER COLUMN [TreatmentTypeDescription] varchar(500);   
----ALTER TABLE [digi].[WorkItemType001TreatmentTypeAudit] ALTER COLUMN [TreatmentTypeDescription] varchar(500); 

----ALTER TABLE [digi].[WorkItemType001TreatmentType] 
----SET    
----(   
----SYSTEM_VERSIONING = ON (HISTORY_TABLE = digi.WorkItemType001TreatmentTypeAudit)   
----);   
----COMMIT ;  