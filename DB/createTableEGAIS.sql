create schema integration;
GO

create table integration.UTM_EntryAttributes(
	Id int identity(1,1) primary key
	,AttributeCode nvarchar(64) not null
	,NameRU nvarchar(64)
	,NameEN nvarchar(64)
	,Description nvarchar(64)
	,SqlDataType nvarchar(64) not null)
	
								
create table integration.UTM_EntryAttributeList(
	Id int identity(1,1) primary key
	,UTM_Entry_Id int
	,UTM_EntryAttribute_Id int
	,Value nvarchar(64)
	,constraint FK_UTM_EntryAttributeList_UTM_Entries foreign key(RAR_Entry_Id)
	references integration.UTM_Entries(Id)
	,constraint FK_UTM_EntryAttributeList_UTM_EntryAttributes foreign key(UTM_EntryAttribute_Id)
	references integration.UTM_EntryAttributes(Id))
	
								
create table integration.UTM_Entries(
	Id int identity(1,1) primary key
	,CreationDate datetime
	,UTM_ExchangeClass_Id int
	,UTMData_Id int
	,constraint FK_UTM_Entries_UTM_ExchangeClasses foreign key(UTM_ExchangeClass_Id)
	references integration.UTM_ExchangeClasses(Id)
	,constraint FK_UTM_Entries_UTMData foreign key(UTMData_Id)
	references integration.UTMData(Id))
	
	
create table integration.UTM_NamespaceLink(
	Id int identity(1,1) primary key
	,UTM_ExchangeType_Id int
	,UTM_NamespaceId int
	,constraint FK_UTM_NamespaceLink_UTM_ExchangeTypes foreign key(UTM_ExchangeType_Id)
	references integration.UTM_ExchangeTypes(Id)
	,constraint FK_UTM_NamespaceLink_UTM_Namespaces foreign key(UTM_NamespaceId)
	references integration.UTM_Namespaces(Id))
	
	
create table integration.UTM_NamespaceLink(
	Id int identity(1,1) primary key
	,Namespace nvarchar(256))
	
	
create table srv.UTM_ExchangeTypes(
	Id int identity(1,1) primary key
	,ExchangeTypeCode nvarchar(64)
	,NameRU nvarchar(64)
	,NameEN nvarchar(64)
	,Description nvarchar(256)
	,UTM_ExchangeClass_Id int
	,constraint FK_UTM_ExchangeTypes_UTM_ExchangeClasses foreign key(UTM_ExchangeClass_Id)
	references srv.UTM_ExchangeClasses(Id))
	
	
create table srv.UTM_ExchangeClasses(
	Id int identity(1,1) primary key
	,ClassCode nvarchar(64)
	,NameRU nvarchar(64)
	,NameEN nvarchar(64)
	,Description nvarchar(256)
	,DefaultUTM_ExchangeType_Id int
	,constraint FK_UTM_ExchangeClasses_UTM_ExchangeTypes foreign key(DefaultUTM_ExchangeType_Id)
	references srv.UTM_ExchangeTypes(Id))
	
	
create table srv.UTM_ExchangeTypeActions(
	Id int identity(1,1) primary key
	,UTM_ExchangeType_id int
	,Direction bit
	,UTM_Path nvarchar(256)
	,ProcessorProcedureName nvarchar(256)
	,NameRU nvarchar(64)
	,NameEN nvarchar(64)
	,Description nvarchar(256)
	,constraint FK_UTM_ExchangeTypeActions_UTM_ExchangeTypes foreign key(UTM_ExchangeType_id)
	references srv.UTM_ExchangeTypes(Id))
	
	
create table srv.UTM(
	Id int identity(1,1) primary key
	,FSRAR_Id nvarchar(64)
	,TaxCode nvarchar(64)
	,TaxReason nvarchar(64)
	,NameRU nvarchar(64)
	,NameEN nvarchar(64)
	,Description nvarchar(256)
	,IP nvarchar(64)
	,IsActive bit)
	
	
create table srv.UTMData(
	Id int identity(1,1) primary key
	,CreateDate datetime
	,Direction bit
	,UTM_ExchangeType_id    int
	,UTM_Id int
	,URL nvarchar(256)
	,Status nvarchar(64)
	,ReplyId nvarchar(256)
	,Document xml
	,constraint FK_UTMData_UTM_ExchangeTypes foreign key(UTM_ExchangeType_id)
	references srv.UTM_ExchangeTypes(Id)
	,constraint FK_UTMData_UTM foreign key(UTM_Id)
	references srv.UTM(Id))	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	