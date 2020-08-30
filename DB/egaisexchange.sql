USE [master]
GO
/****** Object:  Database [EgaisExchange]    Script Date: 11.06.2020 14:54:31 ******/
--CREATE DATABASE [EgaisExchange]
-- CONTAINMENT = NONE
-- ON  PRIMARY 
--( NAME = N'EgaisExchange', FILENAME = N'N:\MSSQL\egaisexchange.mdf' , SIZE = 62080000KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
-- LOG ON 
--( NAME = N'EgaisExchange_log', FILENAME = N'L:\MSSQL\egaisexchange.ldf' , SIZE = 833024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [EgaisExchange] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [EgaisExchange].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [EgaisExchange] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [EgaisExchange] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [EgaisExchange] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [EgaisExchange] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [EgaisExchange] SET ARITHABORT OFF 
GO
ALTER DATABASE [EgaisExchange] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [EgaisExchange] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [EgaisExchange] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [EgaisExchange] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [EgaisExchange] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [EgaisExchange] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [EgaisExchange] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [EgaisExchange] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [EgaisExchange] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [EgaisExchange] SET  DISABLE_BROKER 
GO
ALTER DATABASE [EgaisExchange] SET AUTO_UPDATE_STATISTICS_ASYNC ON 
GO
ALTER DATABASE [EgaisExchange] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [EgaisExchange] SET TRUSTWORTHY ON 
GO
ALTER DATABASE [EgaisExchange] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [EgaisExchange] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [EgaisExchange] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [EgaisExchange] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [EgaisExchange] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [EgaisExchange] SET  MULTI_USER 
GO
ALTER DATABASE [EgaisExchange] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [EgaisExchange] SET DB_CHAINING OFF 
GO
ALTER DATABASE [EgaisExchange] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [EgaisExchange] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'EgaisExchange', N'ON'
GO
USE [EgaisExchange]
GO
declare @idx as int
declare @randomPwd as nvarchar(64)
declare @rnd as float
select @idx = 0
select @randomPwd = N''
select @rnd = rand((@@CPU_BUSY % 100) + ((@@IDLE % 100) * 100) + 
       (DATEPART(ss, GETDATE()) * 10000) + ((cast(DATEPART(ms, GETDATE()) as int) % 100) * 1000000))
while @idx < 64
begin
   select @randomPwd = @randomPwd + char((cast((@rnd * 83) as int) + 43))
   select @idx = @idx + 1
select @rnd = rand()
end
declare @statement nvarchar(4000)
select @statement = N'CREATE APPLICATION ROLE [BOAPI] WITH DEFAULT_SCHEMA = [BOAPI], ' + N'PASSWORD = N' + QUOTENAME(@randomPwd,'''')
EXEC dbo.sp_executesql @statement

GO
/****** Object:  User [LOCAL\MSK-HQ-MONOLIT_USERS]    Script Date: 11.06.2020 14:54:31 ******/
--CREATE USER [LOCAL\MSK-HQ-MONOLIT_USERS] FOR LOGIN [LOCAL\MSK-HQ-MONOLIT_USERS]
--GO
/****** Object:  User [LOCAL\MSK-HQ-MONOLIT_ADMINS]    Script Date: 11.06.2020 14:54:31 ******/
--CREATE USER [LOCAL\MSK-HQ-MONOLIT_ADMINS] FOR LOGIN [LOCAL\MSK-HQ-MONOLIT_ADMINS]
--GO
/****** Object:  Schema [BOAPI]    Script Date: 11.06.2020 14:54:31 ******/
--CREATE SCHEMA [BOAPI]
--GO
/****** Object:  UserDefinedFunction [dbo].[bpRAR_CustNoteChangeOwnership_GetChangeOwnership]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bpRAR_CustNoteChangeOwnership_GetChangeOwnership]( @RAR_CustNoteId int=NULL, @IsWayBillAct bit=0 )                                                                              /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    returns varchar(64)
begin
	      
	
	declare @ChangeOwnership varchar(64)
		
	if isnull(@IsWayBillAct, 0) = 0
		begin
			select @ChangeOwnership = co.ChangeOwnership
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
					join mch.dbo.Document d
						on d.DocumentIntId = cn.DocumentIntId 
					join mch.dbo.TransportEx te
						on te.Document_Object = d.Document_Object
							and te.DocumentDate = d.DocumentDate
							and te.DocumentNumber = d.DocumentNumber
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteChangeOWnerShip co
						on co.DeliveryTypeId = te.DeliveryTypeId
			where cn.RAR_CustNoteId = @RAR_CustNoteId
		end
	else
		begin
			select @ChangeOwnership = isnull(co.ChangeOwnership, 'NotChange')
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
					join mch.dbo.Document d
						on d.DocumentIntId = cn.DocumentIntId
					join mch.dbo.DocumentRels dr
						on dr.SrcDocument_Object = d.Document_Object
							and dr.SrcDocumentDate = d.DocumentDate
							and dr.SrcDocumentNumber = d.DocumentNumber
					join mch.dbo.TransportEx te
						on te.Document_Object = dr.DstDocument_Object
							and te.DocumentDate = dr.DstDocumentDate
							and te.DocumentNumber = dr.DstDocumentNumber
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteChangeOwnership co
						on co.DeliveryTypeId = te.DeliveryTypeId
			where cn.RAR_CustNoteId = @RAR_CustNoteId
				and dr.DstDocument_Object = 'CustReturn'
		end
			
	return @ChangeOwnership
end
GO
/****** Object:  UserDefinedFunction [dbo].[bpUTM_ExchangeTypeDependence_GetDstTypeCode]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bpUTM_ExchangeTypeDependence_GetDstTypeCode]( @DstClassId varchar(64)=NULL, @SrcExchangeTypeCode varchar(64)=NULL )                                                                              /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    returns varchar(64)
begin
	      
	return (select DstExchangeTypeCode from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeDependence
				where SrcExchangeTypeCode = @SrcExchangeTypeCode
					and DstClassId = @DstClassId)
end
GO
/****** Object:  UserDefinedFunction [dbo].[bpUTM_ExchangeTypeDependence_GetWBTypeCode]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bpUTM_ExchangeTypeDependence_GetWBTypeCode]( @RAR_CustNoteId int=NULL )                                                                              /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    returns varchar(64)
begin
	      
	return (select coalesce(cna.Value, et.ExchangeTypeCode)
				from RAR_CustNote cn 
					left join RAR_CustNoteAttribute cna
						on cna.RAR_CustNoteId = cn.RAR_CustNoteId 
							and cna.AttributeId = 'VersionWB'
					left join UTM_ExchangeClass c
						on c.ClassId = cn.ClassId
					left join UTM_ExchangeType et
						on et.UTM_ExchangeTypeId = c.DefaultTypeId
			where cn.RAR_CustNoteId = @RAR_CustNoteId)
end
GO
/****** Object:  UserDefinedFunction [dbo].[bpUTM_Namespace_IsExists]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bpUTM_Namespace_IsExists]( @Namespace varchar(256) )                                                                              /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    
returns bit as
begin
	      
		
	declare @IsExists bit = 0
	if exists(select top 1 n.Namespace
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace n
			where n.Namespace = @Namespace)
		select @IsExists = 1

	return @IsExists
end
GO
/****** Object:  UserDefinedFunction [dbo].[bpUTM_NamespaceLink_GetNamespaceList]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bpUTM_NamespaceLink_GetNamespaceList]( @ExchangeTypeCode varchar(64) )                                                                              /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    
returns nvarchar(max) as
begin
	      
	
	declare @NamespaceList nvarchar(max) = ''
	
	select @NamespaceList += rtrim(ltrim(n.Namespace)) + char(13) + char(10)
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_NamespaceLink l
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace n
				on n.UTM_NamespaceId = l.UTM_NamespaceId	
	where l.ExchangeTypeCode = @ExchangeTypeCode

	return rtrim(ltrim(@NamespaceList))
end
GO
/****** Object:  UserDefinedFunction [dbo].[bpUTM_NamespaceLink_IsExists]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[bpUTM_NamespaceLink_IsExists]( @ExchangeTypeCode varchar(64)=NULL, @UTM_NamespaceId int=NULL )                                                                              /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    
returns bit as
begin
	      
		
	declare @IsExists bit = 0
	if exists(select top 1 l.UTM_NamespaceId
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_NamespaceLink l
			where l.UTM_NamespaceId = @UTM_NamespaceId
				and l.ExchangeTypeCode = @ExchangeTypeCode)
		select @IsExists = 1

	return @IsExists
end
GO
/****** Object:  Table [dbo].[_Old_RAR_CustNoteLineResource]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[_Old_RAR_CustNoteLineResource](
	[DocumentIntId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[IdentityRes] [int] NOT NULL,
	[AlcCode] [varchar](50) NOT NULL,
	[Quantity] [decimal](16, 4) NULL,
	[AnalytLotIntId] [int] NULL,
	[InformMotion] [varchar](50) NULL,
	[InformProduction] [varchar](50) NULL,
	[RAR_CustNoteId] [int] NOT NULL,
 CONSTRAINT [_Old_PK_RAR_CustNoteLineResource] PRIMARY KEY CLUSTERED 
(
	[DocumentIntId] ASC,
	[Position_Identity] ASC,
	[IdentityRes] ASC,
	[AlcCode] ASC,
	[RAR_CustNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[_Old_RAR_CustNoteTransport]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[_Old_RAR_CustNoteTransport](
	[CustNoteId] [int] NOT NULL,
	[Car] [varchar](255) NULL,
	[Company] [varchar](255) NULL,
	[Customer] [varchar](255) NULL,
	[Driver] [varchar](255) NULL,
	[Forwarder] [varchar](255) NULL,
	[LoadPoint] [varchar](255) NULL,
	[UnloadPoint] [varchar](255) NULL,
 CONSTRAINT [_Old_PK_RAR_CustNoteTransport] PRIMARY KEY CLUSTERED 
(
	[CustNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[_Old_RAR_Document]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_Old_RAR_Document](
	[Status] [int] NOT NULL,
	[DocumentIntId] [int] NOT NULL,
	[Content] [nvarchar](max) NULL,
 CONSTRAINT [_Old_PK_RAR_Document] PRIMARY KEY CLUSTERED 
(
	[DocumentIntId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[_Old_RAR_DocumentLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[_Old_RAR_DocumentLine](
	[DocumentIntId] [int] NOT NULL,
	[Position_Identity] [int] NULL,
	[AlcCode] [varchar](100) NULL,
	[Quantity] [decimal](16, 4) NULL,
	[RealQuantity] [decimal](16, 4) NULL,
	[Price] [decimal](16, 4) NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[_Old_RAR_DocumentLine] ADD [InformARegId] [varchar](50) NULL
ALTER TABLE [dbo].[_Old_RAR_DocumentLine] ADD [InformBRegId] [varchar](50) NULL
ALTER TABLE [dbo].[_Old_RAR_DocumentLine] ADD [AnalytLotIntId] [int] NULL

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[_Old_RAR_FormA]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[_Old_RAR_FormA](
	[InformProduction] [varchar](50) NOT NULL,
	[BottlingDate] [datetime] NOT NULL,
	[DocumentDate] [datetime] NULL,
	[DocumentNumber] [varchar](50) NULL,
	[FixNumber] [varchar](50) NULL,
	[FixDate] [datetime] NULL,
	[ShipperRAR_CompanyId] [int] NULL,
	[ConsigneeRAR_CompanyId] [int] NULL,
	[RAR_WareId] [int] NULL,
	[Quantity] [decimal](16, 4) NULL,
	[UTMId] [int] NULL,
 CONSTRAINT [_Old_PK_RAR_FormA] PRIMARY KEY CLUSTERED 
(
	[InformProduction] ASC,
	[BottlingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[_Old_RAR_WayBillActLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[_Old_RAR_WayBillActLine](
	[WayBillActId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[RealQuantity] [decimal](16, 4) NULL,
	[InformMotion] [varchar](50) NULL,
 CONSTRAINT [_Old_PK_RAR_WayBillActLine] PRIMARY KEY CLUSTERED 
(
	[WayBillActId] ASC,
	[Position_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lx_RAR_CustNote]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[lx_RAR_CustNote](
	[RAR_CustNoteId] [int] IDENTITY(1,1) NOT NULL,
	[DocumentIntId] [int] NULL,
	[DocumentNumber] [varchar](100) NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[ShipperFSRAR_Id] [varchar](50) NULL,
	[ConsigneeFSRAR_Id] [varchar](50) NULL,
	[Direction] [smallint] NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[lx_RAR_CustNote] ADD [Status] [varchar](50) NULL
ALTER TABLE [dbo].[lx_RAR_CustNote] ADD [Version] [int] NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[lx_RAR_CustNote] ADD [ReplyId] [varchar](50) NULL
ALTER TABLE [dbo].[lx_RAR_CustNote] ADD [RowId] [uniqueidentifier] NULL
ALTER TABLE [dbo].[lx_RAR_CustNote] ADD [ActionDate] [datetime] NULL
ALTER TABLE [dbo].[lx_RAR_CustNote] ADD [ClassId] [varchar](50) NULL

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[lx_ud]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[lx_ud](
	[Content] [nvarchar](max) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[Direction] [smallint] NOT NULL,
	[ExchangeTypeCode] [varchar](50) NULL,
	[ReplyId] [nvarchar](50) NULL,
	[RowId] [uniqueidentifier] NOT NULL,
	[Status] [smallint] NOT NULL,
	[URL] [varchar](255) NOT NULL,
	[UTM_Id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_ActWriteOffType]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_ActWriteOffType](
	[RAR_ActWriteOffTypeId] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [varchar](50) NOT NULL,
	[TypeDescription] [varchar](255) NULL,
 CONSTRAINT [PK_RAR_ActWriteOffType] PRIMARY KEY CLUSTERED 
(
	[RAR_ActWriteOffTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_BalanceAct]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_BalanceAct](
	[RAR_BalanceActId] [int] IDENTITY(1,1) NOT NULL,
	[DocumentIntId] [int] NULL,
	[ActNumber] [varchar](50) NOT NULL,
	[ActDate] [datetime] NOT NULL,
	[Note] [varchar](1000) NULL,
	[ReplyId] [varchar](50) NULL,
	[Status] [varchar](100) NOT NULL,
	[RAR_BalanceActTypeId] [int] NULL,
	[UTMId] [int] NULL,
	[RowId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_RAR_BalanceAct] PRIMARY KEY CLUSTERED 
(
	[RAR_BalanceActId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_BalanceActExciseStamp]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_BalanceActExciseStamp](
	[RAR_BalanceActId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[StampBarCode] [varchar](500) NOT NULL,
 CONSTRAINT [PK_RAR_BalanceActExciseStamp] PRIMARY KEY CLUSTERED 
(
	[RAR_BalanceActId] ASC,
	[Position_Identity] ASC,
	[StampBarCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_BalanceActLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_BalanceActLine](
	[RAR_BalanceActId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[AlcCode] [varchar](100) NOT NULL,
	[Quantity] [decimal](16, 4) NULL,
	[InformProduction] [varchar](50) NULL,
	[InformMotion] [varchar](50) NULL,
	[SourceDocumentNumber] [varchar](50) NULL,
	[SourceActionDate] [datetime] NULL,
	[SourceFixDate] [datetime] NULL,
	[BottlingDate] [datetime] NULL,
	[SourceFixNumber] [varchar](50) NULL,
 CONSTRAINT [PK_RAR_BalanceActLine] PRIMARY KEY CLUSTERED 
(
	[RAR_BalanceActId] ASC,
	[Position_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_BalanceActStatus]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_BalanceActStatus](
	[RAR_BalanceActStatusId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](100) NOT NULL,
	[Description] [varchar](3000) NOT NULL,
 CONSTRAINT [PK_RAR_BalanceActStatus] PRIMARY KEY CLUSTERED 
(
	[RAR_BalanceActStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_BalanceActType]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_BalanceActType](
	[RAR_BalanceActTypeId] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [varchar](50) NOT NULL,
	[TypeDescription] [varchar](255) NULL,
 CONSTRAINT [PK_RAR_BalanceActType] PRIMARY KEY CLUSTERED 
(
	[RAR_BalanceActTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_Company]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_Company](
	[RAR_CompanyId] [int] IDENTITY(1,1) NOT NULL,
	[FSRAR_Id] [varchar](50) NOT NULL,
	[IsProducer] [bit] NULL DEFAULT ((0)),
	[CountryCode] [varchar](50) NULL,
	[RegionCode] [varchar](50) NULL,
	[FullName] [varchar](4000) NULL,
	[ShortName] [varchar](4000) NULL,
	[SubstitutionName] [varchar](255) NULL,
	[Location] [varchar](4000) NULL,
	[TaxCode] [varchar](15) NULL,
	[TaxReason] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[UpdateTime] [datetime] NULL,
	[VersionWB] [varchar](50) NULL,
 CONSTRAINT [PK_RAR_Company] PRIMARY KEY CLUSTERED 
(
	[RAR_CompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CompanyAddForeignCompanyReestr]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CompanyAddForeignCompanyReestr](
	[CreateTime] [datetime] NOT NULL,
	[MonUserId] [varchar](128) NOT NULL,
	[RowId] [uniqueidentifier] NULL,
	[RAR_CompanyAddForeignCompanyReestrId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](32) NULL,
 CONSTRAINT [PK_RAR_CompanyAddForeignCompanyReestr] PRIMARY KEY CLUSTERED 
(
	[RAR_CompanyAddForeignCompanyReestrId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CompanyRests]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CompanyRests](
	[AlcCode] [varchar](50) NOT NULL,
	[FSRAR_Id] [varchar](50) NOT NULL,
	[InformProduction] [varchar](50) NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[RAR_CompanyRests] ADD [InformMotion] [varchar](50) NOT NULL
ALTER TABLE [dbo].[RAR_CompanyRests] ADD [Quantity] [decimal](16, 4) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[RAR_CompanyRests] ADD [ReplyId] [varchar](50) NULL
ALTER TABLE [dbo].[RAR_CompanyRests] ADD [RestsTime] [datetime] NOT NULL
ALTER TABLE [dbo].[RAR_CompanyRests] ADD [SourceFSRAR_Id] [varchar](50) NULL
 CONSTRAINT [PK_RAR_CompanyRests] PRIMARY KEY CLUSTERED 
(
	[AlcCode] ASC,
	[FSRAR_Id] ASC,
	[InformProduction] ASC,
	[RestsTime] ASC,
	[InformMotion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CompanyRestsExciseStamp]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CompanyRestsExciseStamp](
	[FSRAR_Id] [varchar](50) NOT NULL,
	[InformMotion] [varchar](50) NOT NULL,
	[StampBarCode] [varchar](500) NOT NULL,
	[RestsTime] [datetime] NULL,
 CONSTRAINT [PK_RAR_CompanyRestsExciseStamp] PRIMARY KEY CLUSTERED 
(
	[FSRAR_Id] ASC,
	[InformMotion] ASC,
	[StampBarCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CompanyRestsWareHouse]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RAR_CompanyRestsWareHouse](
	[AlcCode] [varchar](50) NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[RAR_CompanyRestsWareHouse] ADD [FSRAR_Id] [varchar](50) NOT NULL
ALTER TABLE [dbo].[RAR_CompanyRestsWareHouse] ADD [InformProduction] [varchar](50) NOT NULL
ALTER TABLE [dbo].[RAR_CompanyRestsWareHouse] ADD [InformMotion] [varchar](50) NOT NULL
ALTER TABLE [dbo].[RAR_CompanyRestsWareHouse] ADD [Quantity] [decimal](16, 4) NULL
ALTER TABLE [dbo].[RAR_CompanyRestsWareHouse] ADD [ReplyId] [varchar](50) NULL
ALTER TABLE [dbo].[RAR_CompanyRestsWareHouse] ADD [RestsTime] [datetime] NOT NULL
 CONSTRAINT [PK_RAR_CompanyRestsWareHouse] PRIMARY KEY CLUSTERED 
(
	[FSRAR_Id] ASC,
	[RestsTime] ASC,
	[AlcCode] ASC,
	[InformMotion] ASC,
	[InformProduction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNote]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNote](
	[RAR_CustNoteId] [int] IDENTITY(1,1) NOT NULL,
	[DocumentIntId] [int] NULL,
	[DocumentNumber] [varchar](100) NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[ShipperFSRAR_Id] [varchar](50) NULL,
	[ConsigneeFSRAR_Id] [varchar](50) NULL,
	[Direction] [smallint] NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[RAR_CustNote] ADD [Status] [varchar](50) NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[RAR_CustNote] ADD [ReplyId] [varchar](50) NULL
ALTER TABLE [dbo].[RAR_CustNote] ADD [RowId] [uniqueidentifier] NULL
ALTER TABLE [dbo].[RAR_CustNote] ADD [ActionDate] [datetime] NULL
ALTER TABLE [dbo].[RAR_CustNote] ADD [ClassId] [varchar](50) NULL
 CONSTRAINT [PK_RAR_CustNote] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteAttribute]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteAttribute](
	[Value] [varchar](255) NULL,
	[RAR_CustNoteId] [int] NOT NULL,
	[AttributeId] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RAR_CustNoteAttribute] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteId] ASC,
	[AttributeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteChangeOwnership]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RAR_CustNoteChangeOwnership](
	[DeliveryTypeId] [varchar](16) NOT NULL,
	[ChangeOwnership] [varchar](64) NOT NULL,
 CONSTRAINT [PK_RAR_CustNoteChangeOwnership] PRIMARY KEY CLUSTERED 
(
	[DeliveryTypeId] ASC,
	[ChangeOwnership] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteContent]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RAR_CustNoteContent](
	[UniqueId] [int] NOT NULL,
	[RowId] [uniqueidentifier] NULL,
	[Content] [nvarchar](max) NULL,
	[Status] [int] NULL,
	[ReplyId] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RAR_CustNoteExciseStamp]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteExciseStamp](
	[RAR_CustNoteId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[StampBarCode] [varchar](500) NOT NULL,
	[BoxBarCode] [varchar](255) NULL,
	[PalletBarCode] [varchar](2554) NULL,
 CONSTRAINT [PK_RAR_CustNoteExciseStamp] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteId] ASC,
	[Position_Identity] ASC,
	[StampBarCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteLine](
	[Position_Identity] [int] NOT NULL,
	[AlcCode] [varchar](100) NULL,
	[Quantity] [decimal](16, 4) NOT NULL,
	[RealQuantity] [decimal](16, 4) NOT NULL,
	[Price] [decimal](16, 4) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[RAR_CustNoteLine] ADD [InformMotion] [varchar](50) NULL
ALTER TABLE [dbo].[RAR_CustNoteLine] ADD [InformProduction] [varchar](50) NULL
ALTER TABLE [dbo].[RAR_CustNoteLine] ADD [AnalytLotIntId] [int] NULL
ALTER TABLE [dbo].[RAR_CustNoteLine] ADD [RAR_CustNoteId] [int] NOT NULL
 CONSTRAINT [PK_RAR_CustNoteLine] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteId] ASC,
	[Position_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteLineMarkRange]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteLineMarkRange](
	[DocumentIntId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[Range_Identity] [int] NOT NULL,
	[MarkRank] [varchar](3) NULL,
	[MarkStart] [varchar](9) NULL,
	[MarkLast] [varchar](9) NULL,
	[AnalytLotIntId] [int] NULL,
 CONSTRAINT [PK_RAR_CustNoteLineMarkRange] PRIMARY KEY CLUSTERED 
(
	[DocumentIntId] ASC,
	[Position_Identity] ASC,
	[Range_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteLineResource]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteLineResource](
	[RAR_CustNoteId] [int] NOT NULL,
	[IdentityRes] [int] NOT NULL,
	[AlcCode] [varchar](50) NOT NULL,
	[InformProduction] [varchar](50) NULL,
	[InformMotion] [varchar](50) NULL,
	[Quantity] [decimal](16, 4) NULL,
	[AnalytLotIntId] [int] NULL,
 CONSTRAINT [PK_RAR_CustNoteLineResource] PRIMARY KEY CLUSTERED 
(
	[IdentityRes] ASC,
	[AlcCode] ASC,
	[RAR_CustNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteLink]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteLink](
	[RowId] [uniqueidentifier] NOT NULL,
	[ReplyId] [varchar](50) NULL,
	[RAR_CustNoteId] [int] NOT NULL,
 CONSTRAINT [PK_RAR_CustNoteLink] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteId] ASC,
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteRoute]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteRoute](
	[RAR_CustNoteRouteId] [int] IDENTITY(1,1) NOT NULL,
	[RAR_CustNoteId] [int] NOT NULL,
	[RouteNumber] [varchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[RowId] [uniqueidentifier] NULL,
	[Status] [varchar](64) NULL,
	[Ownership] [bit] NULL,
 CONSTRAINT [PK_RAR_CustNoteRoute] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteRouteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteStatus]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RAR_CustNoteStatus](
	[RAR_CustNoteStatusId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[RAR_CustNoteStatus] ADD [Description] [varchar](3000) NOT NULL
 CONSTRAINT [PK_RAR_CustNoteStatus] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteTransport]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteTransport](
	[RAR_CustNoteTransportId] [int] IDENTITY(1,1) NOT NULL,
	[RAR_CustNoteId] [int] NOT NULL,
	[Car] [varchar](255) NULL,
	[Company] [varchar](255) NULL,
	[Customer] [varchar](255) NULL,
	[Driver] [varchar](255) NULL,
	[Forwarder] [varchar](255) NULL,
	[LoadPoint] [varchar](255) NULL,
	[UnloadPoint] [varchar](255) NULL,
 CONSTRAINT [PK_RAR_CustNoteTransport] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteTransportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_CustNoteTransportType]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_CustNoteTransportType](
	[RAR_CustNoteTransportTypeId] [int] IDENTITY(1,1) NOT NULL,
	[TypeCode] [varchar](64) NOT NULL,
	[Description] [varchar](256) NULL,
 CONSTRAINT [PK_RAR_CustNoteTransportType] PRIMARY KEY CLUSTERED 
(
	[RAR_CustNoteTransportTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_Document]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RAR_Document](
	[WBR_Identity] [int] IDENTITY(1,1) NOT NULL,
	[DocumentIntId] [int] NOT NULL,
	[Content] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_RAR_Document] PRIMARY KEY CLUSTERED 
(
	[DocumentIntId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RAR_DocumentLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_DocumentLine](
	[DocumentIntId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[AlcCode] [varchar](100) NULL,
	[Quantity] [decimal](16, 4) NULL,
	[RealQuantity] [decimal](16, 4) NULL,
	[Price] [decimal](16, 4) NULL,
	[InformARegId] [varchar](50) NULL,
	[InformBRegId] [varchar](50) NULL,
	[AnalytLotIntId] [int] NULL,
 CONSTRAINT [PK_RAR_DocumentLine] PRIMARY KEY CLUSTERED 
(
	[DocumentIntId] ASC,
	[Position_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_FormA]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_FormA](
	[InformProduction] [varchar](50) NOT NULL,
	[BottlingDate] [datetime] NOT NULL,
	[DocumentDate] [datetime] NULL,
	[DocumentNumber] [varchar](50) NULL,
	[FixNumber] [varchar](50) NULL,
	[FixDate] [datetime] NULL,
	[ShipperRAR_CompanyId] [int] NULL,
	[ConsigneeRAR_CompanyId] [int] NULL,
	[RAR_WareId] [int] NULL,
	[Quantity] [decimal](16, 4) NULL,
	[UTMId] [int] NOT NULL,
 CONSTRAINT [PK_RAR_FormA] PRIMARY KEY CLUSTERED 
(
	[InformProduction] ASC,
	[BottlingDate] ASC,
	[UTMId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_FormB]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_FormB](
	[InformMotion] [varchar](50) NOT NULL,
	[DocumentNumber] [varchar](100) NULL,
	[DocumentDate] [datetime] NULL,
	[ShippingDate] [datetime] NULL,
	[ShipperFSRAR_Id] [varchar](50) NULL,
	[ConsigneeFSRAR_Id] [varchar](50) NULL,
	[AlcCode] [varchar](1) NOT NULL,
	[ProducerFSRAR_Id] [varchar](50) NULL,
	[Quantity] [decimal](16, 4) NULL,
 CONSTRAINT [PK_RAR_FormB] PRIMARY KEY CLUSTERED 
(
	[InformMotion] ASC,
	[AlcCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_MotionInfo]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_MotionInfo](
	[RAR_MotionInfoId] [int] IDENTITY(1,1) NOT NULL,
	[DocumentNumber] [varchar](100) NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[ReplyId] [varchar](100) NULL DEFAULT (NULL),
	[FixNumber] [varchar](50) NOT NULL,
	[FixDate] [datetime] NOT NULL,
	[RegNumber] [varchar](50) NOT NULL,
	[RAR_CustNoteId] [int] NULL,
	[UTM_Id] [int] NULL,
 CONSTRAINT [PK_RAR_MotionInfo] PRIMARY KEY CLUSTERED 
(
	[RAR_MotionInfoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_MotionInfoHistoryReestr]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_MotionInfoHistoryReestr](
	[InformMotion] [varchar](50) NOT NULL,
	[DocType] [varchar](50) NULL,
	[RegId] [varchar](50) NULL,
	[OperationName] [varchar](255) NULL,
	[OperationDate] [datetime] NULL,
	[Quantity] [decimal](16, 4) NULL,
	[CreateTime] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_MotionInfoLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_MotionInfoLine](
	[Position_Identity] [int] NOT NULL,
	[InformMotion] [varchar](50) NOT NULL,
	[RAR_MotionInfoId] [int] NOT NULL,
 CONSTRAINT [PK_RAR_MotionInfoLine] PRIMARY KEY CLUSTERED 
(
	[RAR_MotionInfoId] ASC,
	[Position_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_MotionInfoMoveReestr]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_MotionInfoMoveReestr](
	[TargetInformMotion] [varchar](64) NOT NULL,
	[Level] [int] NOT NULL,
	[InformMotion] [varchar](64) NOT NULL,
	[ParentInformMotion] [varchar](64) NULL,
	[ShipperFSRAR_Id] [varchar](64) NULL,
	[ConsigneeFSRAR_Id] [varchar](64) NULL,
	[Quantity] [decimal](16, 4) NULL,
	[RegId] [varchar](64) NULL,
 CONSTRAINT [PK_RAR_MotionInfoMoveReestr] PRIMARY KEY CLUSTERED 
(
	[TargetInformMotion] ASC,
	[Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_ProductionInfo]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_ProductionInfo](
	[RAR_CustNoteId] [int] NOT NULL,
	[RAR_ProdInfoId] [int] IDENTITY(1,1) NOT NULL,
	[ProductRepId] [varchar](100) NOT NULL,
	[ReplyId] [varchar](100) NULL,
 CONSTRAINT [PK_RAR_ProductionInfo] PRIMARY KEY CLUSTERED 
(
	[RAR_ProdInfoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_ProductionInfoLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_ProductionInfoLine](
	[Position_Identity] [int] NOT NULL,
	[InformProduction] [varchar](50) NOT NULL,
	[InformMotion] [varchar](50) NOT NULL,
	[RAR_ProdInfoId] [int] NOT NULL,
 CONSTRAINT [PK_RAR_ProductionInfoLine] PRIMARY KEY CLUSTERED 
(
	[RAR_ProdInfoId] ASC,
	[Position_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_RejectRepProducedAct]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_RejectRepProducedAct](
	[RAR_RejectRepProducedActId] [int] IDENTITY(1,1) NOT NULL,
	[RAR_CustNoteId] [int] NOT NULL,
	[RegId] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[ReplyId] [varchar](50) NULL,
	[RowId] [uniqueidentifier] NULL,
	[ActDate] [datetime] NULL,
 CONSTRAINT [PK_RAR_RejectRepProducedAct] PRIMARY KEY CLUSTERED 
(
	[RAR_RejectRepProducedActId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_RejectRepProducedActStatus]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_RejectRepProducedActStatus](
	[RAR_RejectRepProducedActStatusId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
 CONSTRAINT [PK_RAR_RejectRepProducedActStatus] PRIMARY KEY CLUSTERED 
(
	[RAR_RejectRepProducedActStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_RepealWBAct]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_RepealWBAct](
	[RAR_RepealWBActId] [int] IDENTITY(1,1) NOT NULL,
	[FSRAR_Id] [varchar](50) NULL,
	[ActNumber] [varchar](50) NULL,
	[ActDate] [datetime] NULL,
	[RegId] [varchar](50) NULL,
	[Status] [varchar](50) NULL DEFAULT ((0)),
	[UTMId] [int] NULL,
	[ReplyId] [varchar](50) NULL,
	[RowId] [uniqueidentifier] NULL,
	[Direction] [smallint] NULL,
	[RAR_CustNoteId] [int] NULL,
 CONSTRAINT [PK_RAR_RepealWBAct] PRIMARY KEY CLUSTERED 
(
	[RAR_RepealWBActId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_RepealWBActStatus]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RAR_RepealWBActStatus](
	[RAR_RepealWBActStatusId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[RAR_RepealWBActStatus] ADD [Description] [varchar](255) NULL
 CONSTRAINT [PK_RAR_RepealWBActStatus] PRIMARY KEY CLUSTERED 
(
	[RAR_RepealWBActStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_RepurchaseProductRecode]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_RepurchaseProductRecode](
	[SrcInterCompanyId] [varchar](50) NOT NULL,
	[DstInterCompanyId] [varchar](50) NOT NULL,
	[PayKindId] [varchar](50) NULL,
	[ProductId] [varchar](50) NULL,
	[WareHouseId] [varchar](50) NULL,
 CONSTRAINT [PK_RAR_RepurchaseProductRecode] PRIMARY KEY CLUSTERED 
(
	[DstInterCompanyId] ASC,
	[SrcInterCompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_Ticket]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_Ticket](
	[RAR_TicketId] [int] IDENTITY(1,1) NOT NULL,
	[TicketDate] [datetime] NOT NULL,
	[Identity] [nvarchar](50) NULL,
	[ReplyId] [nvarchar](50) NULL,
	[RegId] [varchar](50) NULL,
	[DocType] [varchar](50) NOT NULL,
	[OperationName] [nvarchar](50) NULL,
	[OperationResult] [nvarchar](50) NULL,
	[OperationDate] [datetime] NULL,
	[OperationComment] [nvarchar](3000) NULL,
	[UTM_Id] [int] NULL,
	[RowId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_RAR_Ticket] PRIMARY KEY CLUSTERED 
(
	[RAR_TicketId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_Ware]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_Ware](
	[RAR_WareId] [int] IDENTITY(1,1) NOT NULL,
	[FSRAR_Id] [varchar](50) NULL,
	[AlcCode] [varchar](100) NOT NULL,
	[WareName] [varchar](1000) NULL,
	[AlcVolume] [decimal](16, 4) NOT NULL,
	[UnitType] [varchar](50) NULL,
	[Capacity] [decimal](16, 4) NULL,
	[AlcTypeCode] [varchar](10) NULL,
	[CreateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_RAR_Ware] PRIMARY KEY CLUSTERED 
(
	[RAR_WareId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WareAddRequestReestr]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_WareAddRequestReestr](
	[RAR_WareAddRequestReestrId] [int] IDENTITY(1,1) NOT NULL,
	[RequestNumber] [varchar](55) NULL,
	[AlcCode] [varchar](100) NULL,
	[RowId] [uniqueidentifier] NULL,
	[ReplyId] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[MonUserId] [varchar](128) NOT NULL,
 CONSTRAINT [PK_RAR_WareAddRequestReestr] PRIMARY KEY CLUSTERED 
(
	[RAR_WareAddRequestReestrId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WareAddRequestStatus]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_WareAddRequestStatus](
	[RAR_WareAddRequestStatusId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
 CONSTRAINT [PK_RAR_WareAddRequestStatus] PRIMARY KEY CLUSTERED 
(
	[RAR_WareAddRequestStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WarePackageType]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_WarePackageType](
	[RAR_WarePackageTypeId] [int] IDENTITY(1,1) NOT NULL,
	[TypeCode] [varchar](64) NOT NULL,
	[TypeDescription] [varchar](128) NULL,
 CONSTRAINT [PK_RAR_WarePackageType] PRIMARY KEY CLUSTERED 
(
	[RAR_WarePackageTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WareRequest]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_WareRequest](
	[Description] [varchar](500) NULL,
	[MonUserId] [varchar](128) NOT NULL,
	[RowId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_RAR_WareRequest] PRIMARY KEY CLUSTERED 
(
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WayBillAct]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_WayBillAct](
	[RAR_WayBillActId] [int] IDENTITY(1,1) NOT NULL,
	[CreateTime] [datetime] NULL,
	[Direction] [smallint] NULL,
	[FSRAR_Id] [varchar](50) NULL,
	[IsAccept] [varchar](50) NULL,
	[ActNumber] [varchar](50) NULL,
	[ActDate] [datetime] NULL,
	[RegId] [varchar](50) NULL,
	[Note] [varchar](1000) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[RAR_WayBillAct] ADD [Status] [varchar](255) NULL
ALTER TABLE [dbo].[RAR_WayBillAct] ADD [RAR_CustNoteId] [int] NULL
ALTER TABLE [dbo].[RAR_WayBillAct] ADD [ReplyId] [nvarchar](50) NULL
ALTER TABLE [dbo].[RAR_WayBillAct] ADD [RowId] [uniqueidentifier] NULL
ALTER TABLE [dbo].[RAR_WayBillAct] ADD [UTMId] [int] NULL
ALTER TABLE [dbo].[RAR_WayBillAct] ADD [SourceRowId] [uniqueidentifier] NULL
ALTER TABLE [dbo].[RAR_WayBillAct] ADD [State] [bit] NULL
 CONSTRAINT [PK_RAR_WayBillAct] PRIMARY KEY CLUSTERED 
(
	[RAR_WayBillActId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WayBillActExciseStamp]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_WayBillActExciseStamp](
	[RAR_WayBillActExciseStampId] [int] IDENTITY(1,1) NOT NULL,
	[RAR_WayBillActId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[StampBarCode] [varchar](500) NULL,
 CONSTRAINT [PK_RAR_WayBillActExciseStamp] PRIMARY KEY CLUSTERED 
(
	[RAR_WayBillActExciseStampId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WayBillActLine]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RAR_WayBillActLine](
	[RAR_WayBillActId] [int] NOT NULL,
	[Position_Identity] [int] NOT NULL,
	[RealQuantity] [decimal](16, 4) NULL,
	[InformMotion] [varchar](50) NULL,
 CONSTRAINT [PK_RAR_WayBillActLine] PRIMARY KEY CLUSTERED 
(
	[RAR_WayBillActId] ASC,
	[Position_Identity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RAR_WayBillActStatus]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RAR_WayBillActStatus](
	[RAR_WayBillActId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[RAR_WayBillActStatus] ADD [Description] [varchar](255) NULL
 CONSTRAINT [PK_RAR_WayBillActStatus] PRIMARY KEY CLUSTERED 
(
	[RAR_WayBillActId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM](
	[UTMId] [int] IDENTITY(1,1) NOT NULL,
	[FSRAR_Id] [varchar](50) NOT NULL,
	[TaxCode] [varchar](15) NOT NULL,
	[TaxReason] [varchar](50) NOT NULL,
	[Description] [varchar](255) NOT NULL,
	[URL] [varchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsTest] [bit] NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK_UTM] PRIMARY KEY CLUSTERED 
(
	[UTMId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_Data]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_Data](
	[Content] [nvarchar](max) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[Direction] [smallint] NOT NULL,
	[ExchangeTypeCode] [varchar](50) NULL,
	[ReplyId] [nvarchar](50) NULL,
	[RowId] [uniqueidentifier] NOT NULL DEFAULT (newsequentialid())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[UTM_Data] ADD [Status] [varchar](50) NOT NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[UTM_Data] ADD [URL] [varchar](255) NOT NULL
ALTER TABLE [dbo].[UTM_Data] ADD [UTM_Id] [int] NULL
ALTER TABLE [dbo].[UTM_Data] ADD [UserId] [varchar](128) NULL
 CONSTRAINT [PK_UTM_Data] PRIMARY KEY CLUSTERED 
(
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_DataContent]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UTM_DataContent](
	[UniqueId] [int] NOT NULL,
	[RowId] [uniqueidentifier] NULL,
	[Content] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UTM_ExchangeClass]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UTM_ExchangeClass](
	[ClassName] [varchar](50) NULL,
	[DefaultTypeId] [int] NULL,
	[ClassId] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UTM_ExchangeClass] PRIMARY KEY CLUSTERED 
(
	[ClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_ExchangeType]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_ExchangeType](
	[UTM_ExchangeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Direction] [smallint] NOT NULL,
	[Description] [varchar](255) NULL,
	[ExchangeTypeCode] [varchar](50) NOT NULL,
	[UTM_Path] [varchar](255) NOT NULL,
	[Method] [varchar](255) NULL,
	[UTM_ExchangeClass_ClassId] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UTM_ExchangeType] PRIMARY KEY CLUSTERED 
(
	[UTM_ExchangeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_ExchangeTypeDependence]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_ExchangeTypeDependence](
	[SrcExchangeTypeCode] [varchar](64) NOT NULL,
	[DstExchangeTypeCode] [varchar](64) NOT NULL,
	[DstClassId] [varchar](64) NOT NULL,
 CONSTRAINT [PK_UTM_ExchangeTypeDependence] PRIMARY KEY CLUSTERED 
(
	[SrcExchangeTypeCode] ASC,
	[DstClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_ExchangeTypeLink]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_ExchangeTypeLink](
	[Document_Object] [varchar](55) NOT NULL,
	[DocumentTypeId] [varchar](55) NOT NULL,
	[Method] [varchar](255) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[UTM_ExchangeTypeLink] ADD [UTM_ExchangeClass_ClassId] [varchar](50) NOT NULL
 CONSTRAINT [PK_UTM_ExchangeTypeLink] PRIMARY KEY CLUSTERED 
(
	[Document_Object] ASC,
	[DocumentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_ExchangeVersion]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_ExchangeVersion](
	[UTM_ExchangeClass_ClassId] [varchar](50) NOT NULL,
	[Version] [int] NOT NULL,
	[UTM_ExchangeType_Id] [int] NOT NULL,
	[Description] [varchar](255) NULL,
 CONSTRAINT [PK_UTM_ExchangeVersion] PRIMARY KEY CLUSTERED 
(
	[Version] ASC,
	[UTM_ExchangeClass_ClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_Namespace]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_Namespace](
	[UTM_NamespaceId] [int] IDENTITY(1,1) NOT NULL,
	[Namespace] [varchar](256) NOT NULL,
 CONSTRAINT [PK_UTM_Namespace] PRIMARY KEY CLUSTERED 
(
	[UTM_NamespaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_NamespaceLink]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_NamespaceLink](
	[ExchangeTypeCode] [varchar](64) NOT NULL,
	[UTM_NamespaceId] [int] NOT NULL,
 CONSTRAINT [PK_UTM_NamespaceLink] PRIMARY KEY CLUSTERED 
(
	[UTM_NamespaceId] ASC,
	[ExchangeTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UTM_OperationLog]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[UTM_OperationLog](
	[UTM_OperationLogId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NULL,
	[RowId] [uniqueidentifier] NULL,
	[Operation] [varchar](50) NOT NULL,
	[OperationDate] [datetime] NOT NULL,
	[OperationParams] [varchar](3000) NULL,
	[MonUserId] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UTM_OperationLog] PRIMARY KEY CLUSTERED 
(
	[UTM_OperationLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[xBOConnection]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[xBOConnection](
	[spid] [int] NOT NULL,
	[login_time] [datetime] NOT NULL,
	[bo_StartTime] [datetime] NULL,
	[bo_ConnectionName] [varchar](100) NULL,
	[bo_ConnectionMap] [varchar](100) NULL,
	[bo_LangId] [smallint] NULL,
	[bo_LangUId] [smallint] NULL,
	[bo_UserName] [varchar](100) NULL,
	[bo_SessionUserName] [varchar](100) NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[xBOConnection] ADD [role_cookie] [varbinary](8000) NULL
 CONSTRAINT [PKxBOConnection] PRIMARY KEY NONCLUSTERED 
(
	[spid] ASC,
	[login_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[xBODVersion]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[xBODVersion](
	[BOName] [varchar](100) NOT NULL,
	[BOType] [varchar](10) NOT NULL,
	[DVersion] [datetime] NULL,
	[UpdateTime] [datetime] NULL,
	[UpdateUserName] [varchar](50) NULL,
	[UpdateHostName] [varchar](50) NULL,
	[ControlUpdateGUID] [char](36) NULL,
 CONSTRAINT [PKxBODVersion] PRIMARY KEY CLUSTERED 
(
	[BOName] ASC,
	[BOType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[xBODVersionBase]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[xBODVersionBase](
	[GUID] [char](36) NULL,
	[LastUpdateTime] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[xBOMessage]    Script Date: 11.06.2020 14:54:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[xBOMessage](
	[BOName] [varchar](100) NOT NULL,
	[LangId] [smallint] NOT NULL,
	[Item] [smallint] NOT NULL,
	[Msg] [varchar](1000) NULL,
 CONSTRAINT [PKxBOMessage] PRIMARY KEY CLUSTERED 
(
	[BOName] ASC,
	[LangId] ASC,
	[Item] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [IX_RowId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RowId] ON [dbo].[RAR_BalanceAct]
(
	[RowId] ASC
)
INCLUDE ( 	[RAR_BalanceActId],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FSRAR_Id]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_FSRAR_Id] ON [dbo].[RAR_Company]
(
	[FSRAR_Id] ASC
)
INCLUDE ( 	[RAR_CompanyId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaxCode]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_TaxCode] ON [dbo].[RAR_Company]
(
	[TaxCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FSRAR_Id]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_FSRAR_Id] ON [dbo].[RAR_CompanyRestsExciseStamp]
(
	[FSRAR_Id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StampBarCode]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_StampBarCode] ON [dbo].[RAR_CompanyRestsExciseStamp]
(
	[StampBarCode] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ActionDate]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_ActionDate] ON [dbo].[RAR_CustNote]
(
	[ActionDate] ASC,
	[ClassId] ASC,
	[ShipperFSRAR_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Direction_Status]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_Direction_Status] ON [dbo].[RAR_CustNote]
(
	[Direction] ASC,
	[Status] ASC
)
INCLUDE ( 	[RAR_CustNoteId],
	[DocumentIntId],
	[ActionDate],
	[ClassId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DocumentDate]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_DocumentDate] ON [dbo].[RAR_CustNote]
(
	[DocumentDate] ASC
)
INCLUDE ( 	[RAR_CustNoteId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DocumentIntId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_DocumentIntId] ON [dbo].[RAR_CustNote]
(
	[DocumentIntId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_RowId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RowId] ON [dbo].[RAR_CustNote]
(
	[RowId] ASC
)
INCLUDE ( 	[RAR_CustNoteId],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RAR_CustNote]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RAR_CustNote] ON [dbo].[RAR_CustNoteTransport]
(
	[RAR_CustNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DocumentNumber_ReplyId_UTMId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_DocumentNumber_ReplyId_UTMId] ON [dbo].[RAR_MotionInfo]
(
	[DocumentNumber] ASC,
	[ReplyId] ASC,
	[UTM_Id] ASC
)
INCLUDE ( 	[RAR_MotionInfoId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RAR_CustNoteId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RAR_CustNoteId] ON [dbo].[RAR_MotionInfo]
(
	[RAR_CustNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RegNumber]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RegNumber] ON [dbo].[RAR_MotionInfo]
(
	[RegNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReplyId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_ReplyId] ON [dbo].[RAR_MotionInfo]
(
	[ReplyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_InformMotion]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_InformMotion] ON [dbo].[RAR_MotionInfoLine]
(
	[InformMotion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RowId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RowId] ON [dbo].[RAR_RejectRepProducedAct]
(
	[RowId] ASC
)
INCLUDE ( 	[RAR_RejectRepProducedActId],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RowId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RowId] ON [dbo].[RAR_RepealWBAct]
(
	[RowId] ASC
)
INCLUDE ( 	[RAR_RepealWBActId],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ReplyId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_ReplyId] ON [dbo].[RAR_Ticket]
(
	[ReplyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AlcCode]    Script Date: 11.06.2020 14:54:32 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AlcCode] ON [dbo].[RAR_Ware]
(
	[AlcCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RowId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RowId] ON [dbo].[RAR_WareAddRequestReestr]
(
	[RowId] ASC
)
INCLUDE ( 	[RAR_WareAddRequestReestrId],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_MonUser]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_MonUser] ON [dbo].[RAR_WareRequest]
(
	[MonUserId] ASC
)
INCLUDE ( 	[RowId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RAR_CustNoteId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RAR_CustNoteId] ON [dbo].[RAR_WayBillAct]
(
	[RAR_CustNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RegId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RegId] ON [dbo].[RAR_WayBillAct]
(
	[RegId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_RowId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RowId] ON [dbo].[RAR_WayBillAct]
(
	[RowId] ASC
)
INCLUDE ( 	[RAR_WayBillActId],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Id_Stamp_Position]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_Id_Stamp_Position] ON [dbo].[RAR_WayBillActExciseStamp]
(
	[RAR_WayBillActId] ASC,
	[Position_Identity] ASC,
	[StampBarCode] ASC
)
INCLUDE ( 	[RAR_WayBillActExciseStampId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FSRAR]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_FSRAR] ON [dbo].[UTM]
(
	[FSRAR_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Direction_Status_UTMId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_Direction_Status_UTMId] ON [dbo].[UTM_Data]
(
	[Direction] ASC,
	[Status] ASC,
	[UTM_Id] ASC
)
INCLUDE ( 	[Content],
	[CreateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ReplyId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_ReplyId] ON [dbo].[UTM_Data]
(
	[ReplyId] ASC
)
INCLUDE ( 	[RowId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ObjectId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_ObjectId] ON [dbo].[UTM_OperationLog]
(
	[ObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RowId]    Script Date: 11.06.2020 14:54:32 ******/
CREATE NONCLUSTERED INDEX [IX_RowId] ON [dbo].[UTM_OperationLog]
(
	[RowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceAct_InsertActFixBarCode]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceAct_InsertActFixBarCode]( @Document_Object varchar(50)=NULL, @DocumentDate smalldatetime=NULL, @DocumentNumber varchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare
		@DocumentIntId int
		,@RAR_BalanceActId int
		,@UTMId int
		,@AlcCode varchar(50)
		,@Quantity decimal(16,4)
		,@InformProduction varchar(50)
		,@InformMotion varchar(50)

	
	select 
		@DocumentIntId = d.DocumentIntId
		,@UTMId = u.UTMId
		,@AlcCode = caa.Value
		,@Quantity = cnl.Quantity
		,@InformProduction = alaa.Value
		,@InformMotion = alab.Value
	from mch.dbo.Document d
		join mch.dbo.AnalytLotLink alk with(nolock)
			on alk.DocumentIntId = d.DocumentIntId
		join mch.dbo.AnalytLot al with(nolock) 
			on al.AnalytLotIntId = alk.AnalytLotIntId
		join mch.dbo.CustNoteLine cnl
			on cnl.CustNote_Object = d.Document_Object
				and cnl.CustNoteDate = d.DocumentDate
				and cnl.CustNoteNumber = d.DocumentNumber
		join mch.dbo.ClassAdditionalAttrib caa
			on caa.AdditionalAttribId = 'WARE_EGAIS'
				and caa.Class_Object = 'Ware' 
				and caa.ClassId = cnl.WareId
		join mch.dbo.Company c
			on c.CompanyId = d.CompanyId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.TaxCode = c.TaxCode
				and u.TaxReason = c.TaxReason
				and u.IsTest = 0
		left join mch.dbo.AnalytLotAttribute alaa with(nolock) 
			on alaa.AnalytLotIntId = al.AnalytLotIntId 
				and alaa.AdditionalAttribId = 'InformARegId'
		left join mch.dbo.AnalytLotAttribute alab with(nolock) 
			on alab.AnalytLotIntId = al.AnalytLotIntId 
				and alab.AdditionalAttribId = 'InformBRegId'
		where d.Document_Object = @Document_Object
			and d.DocumentDate = @DocumentDate
			and d.DocumentNumber = @DocumentNumber

		
		begin try
			begin transaction

				insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct(
									ActDate
									,ActNumber
									,DocumentIntId
									,Note
									,ReplyId
									,RAR_BalanceActTypeId
									,Status
									,UTMId)
					values(
						@DocumentDate
						,@DocumentNumber
						,@DocumentIntId
						,'OldBarCode'
						,NULL
						,NULL
						,'New'
						,@UTMId)
		
				set @RAR_BalanceActId = @@identity;
		
				
				exec mch.dbo.bpRAR_BalanceActLine_Insert
						@RAR_BalanceActId = @RAR_BalanceActId
						,@AlcCode = @AlcCode
						,@Quantity = @Quantity
						,@InformProduction = @InformProduction
						,@InformMotion = @InformMotion
						,@Position_Identity = NULL
		
		
				insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActExciseStamp(
								RAR_BalanceActId
								,Position_Identity
								,StampBarCode)
					select
						@RAR_BalanceActId
						,bal.Position_Identity
						,es.StampBarCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bal
							on bal.RAR_BalanceActId = ba.RAR_BalanceActId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd
							on esd.DocumentIntId = ba.DocumentIntId				
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet est
							on est.StampSetId = esd.StampSetId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl
							on esl.ParentId = esd.StampSetId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es
							on es.StampId = esl.DescendantId	
					where ba.RAR_BalanceActId = @RAR_BalanceActId
						and len(es.StampBarCode) < 150
					union
					select 
						@RAR_BalanceActId
						,bal.Position_Identity
						,es.StampBarCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bal
							on bal.RAR_BalanceActId = ba.RAR_BalanceActId						
						join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampDocument esd
							on esd.DocumentIntId = ba.DocumentIntId
						join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStamp es 
							on es.StampId = esd.StampSetId
					where len(es.StampBarCode) <> 150
		  				and es.IsSingle = 1
		  				and esd.DocumentIntId = @DocumentIntId

			commit transaction
		end try
		begin catch
			
			select 
		        ERROR_NUMBER() AS ErrorNumber
		        ,ERROR_SEVERITY() AS ErrorSeverity
		        ,ERROR_STATE() AS ErrorState
		        ,ERROR_PROCEDURE() AS ErrorProcedure
		        ,ERROR_LINE() AS ErrorLine
		        ,ERROR_MESSAGE() AS ErrorMessage;
	
			rollback transaction
		end catch



GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceAct_IsActFixBarCode]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceAct_IsActFixBarCode]( @Document_Object varchar(50)=NULL, @DocumentDate smalldatetime=NULL, @DocumentNumber varchar(15)=NULL, @IsActFixBarCode bit OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          


	declare @DocumentIntId int

	set @IsActFixBarCode = 0
	
	select @DocumentIntId = d.DocumentIntId
		from mch.dbo.Document d
	where d.Document_Object = @Document_Object
		and d.DocumentDate = @DocumentDate
		and d.DocumentNumber = @DocumentNumber


	if exists (select top 1*
					from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet est
							on est.StampSetId = esd.StampSetId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl
							on esl.ParentId = esd.StampSetId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es
							on es.StampId = esl.DescendantId
				where esd.DocumentIntId = @DocumentIntId
					and len(es.StampBarCode) < 150
					and est.IsDisassembled = 0
					and est.WorkSiteId in ('VodkaOldStamp', 'UVK_5', 'UVK_3'))
		set @IsActFixBarCode = 1


	if exists(select top 1 1
				from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampDocument esd
					join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStamp es 
						on es.StampId = esd.StampSetId
			where len(es.StampBarCode) <> 150
		  		and es.IsSingle = 1
		  		and esd.DocumentIntId = @DocumentIntId)
		set @IsActFixBarCode = 1

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceAct_ParseInventoryRegInfo]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceAct_ParseInventoryRegInfo]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare
		@XMLContent nvarchar(max)
		,@ExchangeTypeCode nvarchar(64)

	
	select
		 @XMLContent = replace(ud.Content,'utf-8','utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1

	-- пространства имен для версии типа обмена с ЕГАИС
	declare @Namespace nvarchar(max)
	select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)
	select @Namespace = '<root ' + @Namespace + '/>'

	if(isnull(@XMLContent, '') = '')
		return 1
	
	
	begin try
		begin transaction
	
			declare 
				@Descriptor int
				,@RegId varchar(64)
	
			exec sp_xml_preparedocument @Descriptor out, @XMLContent, @Namespace
	
			select 
				@RegId = RegId			
			from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ActInventoryInformF2Reg/aint:Header', 1)
				with 
					(
						RegId varchar(50) './aint:ActRegId'						
					);
	
	
		if object_id(N'tempdb..#positionActInventory', N'U') is not null
			drop table #positionActInventory
	
		create table #positionActInventory(
										Position_Identity int
										,InformProduction varchar(64)
										,InformMotion varchar(64))
	
	
		insert into #positionActInventory(
										Position_Identity
										,InformProduction
										,InformMotion)
			select 
				Position_Identity
				,InformProduction
				,InformMotion	
			from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ActInventoryInformF2Reg/aint:Content/aint:Position', 1)
				with 
					(
						Position_Identity int './aint:Identity'	
						,InformProduction varchar(64) './aint:InformF1RegId'	
						,InformMotion varchar(64) './aint:InformF2/aint:InformF2Item/aint:F2RegId'											
					);
	
			declare @RAR_BalanceActId int
	
			select @RAR_BalanceActId = ba.RAR_BalanceActId
				from  [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t 
					join  [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
						on ba.ReplyId = t.ReplyId	
			where t.RegId = @RegId
	
	
			declare
				@Position_Identity int
				,@InformProduction varchar(64)
				,@InformMotion varchar(64)
	
			declare ActInventoryLine_Cursor cursor for   
					select 
						p.Position_Identity
						,p.InformProduction
						,p.InformMotion
					from #positionActInventory p
	
			open ActInventoryLine_Cursor
			
			fetch next from ActInventoryLine_Cursor   
				into
					@Position_Identity
					,@InformProduction 
					,@InformMotion
	
			while @@fetch_status = 0  
				begin
	
					update bal	
						set 
							bal.InformProduction = @InformProduction
							,bal.InformMotion = @InformMotion
					from  [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
						join  [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bal
							on bal.RAR_BalanceActId = ba.RAR_BalanceActId
					where ba.RAR_BalanceActId = @RAR_BalanceActId
						and bal.Position_Identity = @Position_Identity
	
	
					fetch next from ActInventoryLine_Cursor   
						into
							@Position_Identity
							,@InformProduction 
							,@InformMotion
	
				end
	
			close ActInventoryLine_Cursor
			deallocate ActInventoryLine_Cursor
	
	
			exec  [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'
	
		commit transaction
	end try			
		begin catch
			select 
		        ERROR_NUMBER() AS ErrorNumber
		        ,ERROR_SEVERITY() AS ErrorSeverity
		        ,ERROR_STATE() AS ErrorState
		        ,ERROR_PROCEDURE() AS ErrorProcedure
		        ,ERROR_LINE() AS ErrorLine
		        ,ERROR_MESSAGE() AS ErrorMessage
	
			rollback transaction
		end catch

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceAct_SendActChargeOn]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceAct_SendActChargeOn]( @RAR_BalanceActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


declare 
	@Content nvarchar(max)
	,@ClassId varchar(50) = 'ActChargeOn'	
	,@ExchangeTypeCode varchar(50)
	,@UTMId int
	,@CurrentStatus varchar(50)
	,@Note varchar(3000)
	,@Namespace nvarchar(max)
	
	select 
		@CurrentStatus = ba.Status
		,@Note = ba.Note	
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
		where ba.RAR_BalanceActId  = @RAR_BalanceActId


	if (@CurrentStatus = 'New' or @CurrentStatus = 'Rejected')
		begin

			if(@Note <> 'OldBarCode')
				begin
					exec bpUTM_ExchangeClass_GetDefaultType
							@ClassId
							,@ExchangeTypeCode out
					
					-- пространства имен для версии типа обмена с ЕГАИС
					select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)

					select 
						@UTMId = ba.UTMId
						,@Content = '<?xml version="1.0" ?> 
										<ns:Documents Version="1.0"' + char(13) + char(10) +
											@Namespace + ' >' +	
											'<ns:Owner>
												<ns:FSRAR_ID>' + isnull(u.FSRAR_Id, '') + '</ns:FSRAR_ID>
											</ns:Owner>
											<ns:Document>
												<ns:' + @ExchangeTypeCode + '>
													<ainp:Header>
														<ainp:Number>' + isnull(ba.ActNumber, '') + '</ainp:Number>
														<ainp:ActDate>' + isnull(convert(varchar(15), ba.ActDate, 23), '') + '</ainp:ActDate>
														<ainp:Note>' + isnull(ba.Note, '') + '</ainp:Note>
														<ainp:TypeChargeOn>' + isnull(bt.TypeName, '') + '</ainp:TypeChargeOn>' +
														case when bt.RAR_BalanceActTypeId = 1 then 
														'<ainp:ActWriteOff>' + isnull(cna.Value, '') + '</ainp:ActWriteOff>'
														else '' end +
													'</ainp:Header>
													<ainp:Content>'
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
								on u.UTMId = ba.UTMId
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActType bt
								on bt.RAR_BalanceActTypeId = ba.RAR_BalanceActTypeId
							left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute cna
								on cna.RAR_CustNoteId = ba.RAR_BalanceActId
									and cna.AttributeId = 'ActWriteOffRegId'
						where ba.RAR_BalanceActId = @RAR_BalanceActId
					
					
					declare @Position_Identity int
					
					declare Position_Cursor cursor for
						select 
							bl.Position_Identity
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bl
								on bl.RAR_BalanceActId = ba.RAR_BalanceActId
						where ba.RAR_BalanceActId =  @RAR_BalanceActId   
					
					open Position_Cursor
					
					fetch next from Position_Cursor  
						into @Position_Identity
					
					while @@fetch_status = 0  
						begin
					
							select @Content += '<ainp:Position>
													<ainp:Identity>' + isnull(convert(varchar(50), bl.Position_Identity), '') + '</ainp:Identity> 
													<ainp:Product>
														<pref:FullName>' + isnull(w.WareName, '') + '</pref:FullName> 
														<pref:AlcCode>' + isnull(bl.AlcCode, '') + '</pref:AlcCode> 
														<pref:Capacity>' + isnull(convert(varchar(15), w.Capacity), '') + '</pref:Capacity> 
														<pref:UnitType>' + isnull(w.UnitType, '') + '</pref:UnitType> 
														<pref:AlcVolume>' + isnull(convert(varchar(15), w.AlcVolume), '') + '</pref:AlcVolume> 
														<pref:ProductVCode>' + isnull(w.AlcTypeCode, '') + '</pref:ProductVCode> 
														<pref:Producer><oref:UL>
															<oref:ClientRegId>' + isnull(w.FSRAR_Id, '') + '</oref:ClientRegId> 
															<oref:INN>' + isnull(c.TaxCode, '') + '</oref:INN> 
															<oref:KPP>' + isnull(c.TaxReason, '') + '</oref:KPP> 
															<oref:FullName>' + isnull(c.FullName, '') + '</oref:FullName> 
															<oref:ShortName>' + isnull(c.ShortName, '') + '</oref:ShortName> 
															<oref:address>
																<oref:Country>' + isnull(c.CountryCode, '') + '</oref:Country> 
																<oref:RegionCode>' + isnull(c.RegionCode, '') + '</oref:RegionCode> 
																<oref:description>' + isnull(c.Location, '') + '</oref:description> 
															</oref:address>
														</oref:UL></pref:Producer>
													</ainp:Product>
													<ainp:Quantity>' + isnull(convert(varchar(50), bl.Quantity), '') + '</ainp:Quantity> 
													<ainp:InformF1F2>
														<ainp:InformF1F2Reg>
															<ainp:InformF1>
																<iab:Quantity>' + isnull(convert(varchar(50), bl.Quantity), '') + '</iab:Quantity> 
																<iab:BottlingDate>' + isnull(convert(varchar(50), bl.BottlingDate, 23), '') + '</iab:BottlingDate> 
																<iab:TTNNumber>' + isnull(convert(varchar(50), bl.SourceDocumentNumber), '') + '</iab:TTNNumber> 
																<iab:TTNDate>' + isnull(convert(varchar(50), bl.SourceActionDate, 23), '') + '</iab:TTNDate> 
																<iab:EGAISFixNumber>' + isnull(bl.SourceFixNumber, '') + '</iab:EGAISFixNumber> 
																<iab:EGAISFixDate>' + isnull(convert(varchar(50), bl.SourceFixDate, 23), '') + '</iab:EGAISFixDate> 
															</ainp:InformF1>
														</ainp:InformF1F2Reg>
													</ainp:InformF1F2>'
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
									join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bl
										on bl.RAR_BalanceActId = ba.RAR_BalanceActId
									left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware w
										on w.AlcCode = bl.AlcCode
									left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company c
										on c.FSRAR_Id = w.FSRAR_Id
											and c.Status = 'Active'
								where ba.RAR_BalanceActId =  @RAR_BalanceActId
									and bl.Position_Identity = @Position_Identity
					
					
							if exists(select top 1* 
										from RAR_BalanceActExciseStamp es
									where es.RAR_BalanceActId = @RAR_BalanceActId
										and es.Position_Identity = @Position_Identity)
								begin
					
									declare @StampInfo nvarchar(max) = '<ainp:MarkCodeInfo>'
					
									select @StampInfo += '<MarkCode>' + es.StampBarCode + '</MarkCode>'
										from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActExciseStamp es
									where es.RAR_BalanceActId = @RAR_BalanceActId
										and es.Position_Identity = @Position_Identity
					
									select @StampInfo += '</ainp:MarkCodeInfo></ainp:Position>'
									select @Content += @StampInfo
					
								end
							else
								begin
					
									select @Content += '</ainp:Position>'
					
								end
														
						fetch next from Position_Cursor  
							into @Position_Identity
					
					end
					
					close Position_Cursor
						deallocate Position_Cursor
					
					
					select @Content += '</ainp:Content>
									</ns:' + @ExchangeTypeCode + '>
								</ns:Document>
							</ns:Documents>'
				
				end
			else if(@Note = 'OldBarCode')
				begin				
					select @ClassId = 'ActFixBarCode'

					exec bpUTM_ExchangeClass_GetDefaultType
							@ClassId
							,@ExchangeTypeCode out
					
					-- пространства имен для версии типа обмена с ЕГАИС
					select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)


					select
						 @UTMId = ba.UTMId
						,@Content = '<?xml version="1.0"?>
										   <ns:Documents Version="1.0"' + char(13) + char(10) +
											   @Namespace + ' >' +
										   '<ns:Owner>
											  <ns:FSRAR_ID>' + isnull(u.FSRAR_Id, '') + '</ns:FSRAR_ID>
										   </ns:Owner>
										   <ns:Document>
											  <ns:' + @ExchangeTypeCode + '>
												 <awr:Identity>' + isnull(convert(varchar(50), ba.RAR_BalanceActId), '') + '</awr:Identity>
												 <awr:Header>
												    <awr:Number>' + isnull(ba.ActNumber, '') + '</awr:Number>
												    <awr:ActDate>' + isnull(convert(varchar(50), getdate(), 23), '') + '</awr:ActDate>
												    <awr:Note>' + isnull(ba.Note, '') + '</awr:Note>
												 </awr:Header>
												 <awr:Content>'
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
								on u.UTMId = ba.UTMId					
						where ba.RAR_BalanceActId = @RAR_BalanceActId


						declare @BarCodeInfo nvarchar(max) = ''
						
						select @BarCodeInfo += '<ce:amc>' + es.StampBarCode + '</ce:amc>'
							from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
								join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd
									on esd.DocumentIntId = ba.DocumentIntId
								join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet est
									on est.StampSetId = esd.StampSetId
								join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl
									on esl.ParentId = esd.StampSetId
								join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es
									on es.StampId = esl.DescendantId
						where ba.RAR_BalanceActId = @RAR_BalanceActId
							and len(es.StampBarCode) < 150

						select @BarCodeInfo += '<ce:amc>' + es.StampBarCode + '</ce:amc>'
							from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba													
								join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd
									on esd.DocumentIntId = ba.DocumentIntId
								join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es 
									on es.StampId = esd.StampSetId
							where len(es.StampBarCode) <> 150
					  			and es.IsSingle = 1
					  			and ba.RAR_BalanceActId = @RAR_BalanceActId

						
						select @Content += '<awr:Position>
												<awr:Identity>' + isnull(convert(varchar(50), bal.Position_Identity), '') + '</awr:Identity>
												<awr:Inform2RegId>' + isnull(bal.InformMotion, '') + '</awr:Inform2RegId>
												<awr:MarkInfo>'
													+ @BarCodeInfo +	
												'</awr:MarkInfo>
											</awr:Position>
										</awr:Content>
									</ns:' + @ExchangeTypeCode + 'e>
								</ns:Document>
							</ns:Documents>'
							from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
								join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bal
									on bal.RAR_BalanceActId = ba.RAR_BalanceActId
							where ba.RAR_BalanceActId = @RAR_BalanceActId

				end

			if isnull(@Content, '') = ''
						begin
							return 1
						end
					else
						begin
							begin try
								begin transaction
		
									declare @RowId uniqueidentifier 
									exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_InsertRequest
												@Content = @Content
												,@ExchangeTypeCode = @ExchangeTypeCode
												,@UTMId = @UTMId
												,@RowId = @RowId out
																			
						
									update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct
										set 
											RowId = @RowId
											,Status = 'Awaiting'
									where RAR_BalanceActId = @RAR_BalanceActId
				
								commit transaction
		
							end try
							begin catch
								
								select 
							        ERROR_NUMBER() AS ErrorNumber
							        ,ERROR_SEVERITY() AS ErrorSeverity
							        ,ERROR_STATE() AS ErrorState
							        ,ERROR_PROCEDURE() AS ErrorProcedure
							        ,ERROR_LINE() AS ErrorLine
							        ,ERROR_MESSAGE() AS ErrorMessage;
						
								rollback transaction
						
							end catch
						end

		end
	else
		begin

			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_BalanceAct.SendActChargeOn'                and Item=0), 'Статус акта запрещает повторно отправить документ!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1

		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceAct_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceAct_SetStatus]( @Status varchar(50), @RAR_BalanceActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct
		set Status = @Status
	where RAR_BalanceActId = @RAR_BalanceActId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceAct_UpdateReplyId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceAct_UpdateReplyId]( @RowId uniqueidentifier=NULL, @Status varchar(50), @ReplyId varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct
		set 
			Status = @Status
			,ReplyId = @ReplyId
	where RowId = @RowId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceAct_UpdateStampStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceAct_UpdateStampStatus]( @RAR_BalanceActId int=NULL, @StampStatus bit=0 )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	
declare @AnalytLotIntId int 


	select @AnalytLotIntId = al.AnalytLotIntId
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
			join mch.dbo.Document d
				on d.DocumentIntId = ba.DocumentIntId
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bal
				on bal.RAR_BalanceActId = ba.RAR_BalanceActId
			join mch.dbo.AnalytLotLink alk
				on alk.DocumentIntId = d.DocumentIntId
					and alk.Quantity = bal.Quantity
			join mch.dbo.AnalytLot al
				on al.AnalytLotIntId = alk.AnalytLotIntId
					and al.IsClosed = 0
	where ba.RAR_BalanceActId = @RAR_BalanceActId
	
	
	update es
		set 
			[Status] = @StampStatus
			,AnalytLotIntId = @AnalytLotIntId
		from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es
			join (select es.StampId
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd
							on esd.DocumentIntId = ba.DocumentIntId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet est
							on est.StampSetId = esd.StampSetId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl
							on esl.ParentId = esd.StampSetId
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es
							on es.StampId = esl.DescendantId
					where ba.RAR_BalanceActId = @RAR_BalanceActId
						and len(es.StampBarCode) < 150
						and es.Status = 0
					union
							select es.StampId
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba													
							join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd
								on esd.DocumentIntId = ba.DocumentIntId
							join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es 
								on es.StampId = esd.StampSetId
						where len(es.StampBarCode) <> 150
							and es.IsSingle = 1
							and es.Status = 0
							and ba.RAR_BalanceActId = @RAR_BalanceActId) as fixStamp
				on es.StampId = fixStamp.StampId


	update est
		set est.Status = @StampStatus
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd
					on esd.DocumentIntId = ba.DocumentIntId
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet est
					on est.StampSetId = esd.StampSetId
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl
					on esl.ParentId = esd.StampSetId
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es
					on es.StampId = esl.DescendantId
			where ba.RAR_BalanceActId = @RAR_BalanceActId
				and len(es.StampBarCode) < 150
				and est.Status = 0
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceActLine_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_BalanceActLine_Delete]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceActLine_Describe]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceActLine_Describe]( @Position_Identity int=NULL, @RAR_BalanceActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


select 
	bl.RAR_BalanceActId
    ,bl.Position_Identity
	,w.WareName
	,w.AlcCode
	,bl.Quantity
	,w.AlcVolume
	,w.Capacity
	,bl.InformProduction
	,bl.InformMotion
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bl
	join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware w 
		on w.AlcCode = bl.AlcCode
where bl.RAR_BalanceActId = @RAR_BalanceActId
	and bl.Position_Identity = @Position_Identity 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceActLine_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceActLine_Edit]( @RAR_BalanceActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


select 
	bl.RAR_BalanceActId
    ,bl.Position_Identity
	,w.WareName
	,w.AlcCode
	,bl.Quantity
	,w.AlcVolume
	,w.Capacity
	,bl.InformProduction
	,bl.InformMotion
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine bl
	join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware w 
		on w.AlcCode = bl.AlcCode
where bl.RAR_BalanceActId = @RAR_BalanceActId
	order by bl.Position_Identity
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceActLine_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceActLine_Insert]( @AlcCode varchar(100)=NULL, @InformMotion varchar(50)=NULL, @InformProduction varchar(50)=NULL, @Position_Identity int=NULL, @Quantity decimal(16,4)=NULL, @RAR_BalanceActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare
		@Status varchar(15)

	
	select @Status = ba.Status
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
	where ba.RAR_BalanceActId = @RAR_BalanceActId


	if(@Status = 'New')
		begin

			
			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine(
								RAR_BalanceActId
								,Position_Identity
								,AlcCode
								,Quantity
								,InformProduction
								,InformMotion)
				values(
					@RAR_BalanceActId
					,@Position_Identity
					,@AlcCode
					,@Quantity
					,@InformProduction
					,@InformMotion)
	
		end
	else
		begin

			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_BalanceActLine.Insert'                and Item=0), 'Статус акта не позволяет добавлять позиции в документ!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1

		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_BalanceActLine_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_BalanceActLine_Update]( @AlcCode varchar(100)=NULL, @InformMotion varchar(50)=NULL, @InformProduction varchar(50)=NULL, @Position_Identity int=NULL, @Quantity decimal(16,4)=NULL, @RAR_BalanceActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare
		@Status varchar(15)

	
	select @Status = ba.Status
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
	where ba.RAR_BalanceActId = @RAR_BalanceActId


	if(@Status = 'New')
		begin

			
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceActLine
				set
					AlcCode = @AlcCode
					,Quantity = @Quantity
				where RAR_BalanceActId = @RAR_BalanceActId
					and Position_Identity = @Position_Identity
					

		end
	else
		begin

			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_BalanceActLine.Update'                and Item=0), 'Статус акта не позволяет редактировать позиции в документ!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1

		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_AddToClassifier]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_AddToClassifier]( @RAR_CompanyId int=NULL, @CountryCode varchar(15), @RegionCode varchar(15) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


declare
	@TreeObject_ClassId varchar(50) = 'RAR_CompanyTree'
	,@RF varchar(15) = '643' -- Russian Fed
	,@FR varchar(15) = 'foreign'
	,@TreeIntId int
	,@OwnerId varchar(15)
	,@TreeId  varchar(15)
	,@TreeName varchar(127)


select @TreeIntId = (select t.TreeIntId 
						from mch.dbo.Tree t 
					where t.Tree_Object = @TreeObject_ClassId
						and t.TreeClassId = @TreeObject_ClassId
						and t.TreeId = coalesce(@RegionCode, @CountryCode))


if(@TreeIntId is null)
	begin

		if(@CountryCode = @RF)
			begin
				
				select 
					@OwnerId = @RF
					,@TreeId = @RegionCode
					,@TreeName = r.RegionName#Rus
				from mch.dbo.Region r
					where left(r.RegionName#Rus, 2) = @RegionCode

			end
		else
			begin
			
				select 
					@OwnerId = @FR
					,@TreeId = @CountryCode
					,@TreeName = @CountryCode + ' - ' + c.CountryName#Rus 
				from mch.dbo.Country c 
					where c.CountryId = @CountryCode
			
			end

		exec mch.dbo.bpTree_Insert
				@Tree_Object = @TreeObject_ClassId
				,@TreeClassId = @TreeObject_ClassId
				,@TreeId = @TreeId
				,@OwnerId = @OwnerId
				,@TreeName#Rus = @TreeName
				,@TreeIntId = @TreeIntId out

	end


if(@RAR_CompanyId is not null and @TreeIntId is not null)
	begin

		insert into mch.dbo.TreeElement(
					ElementId
					,TreeIntId)
		values(
			@RAR_CompanyId
			,@TreeIntId)

	end


GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
	
	select *,
		ShortName = isnull(SubstitutionName,ShortName),
		ShortNameCellStyle = iif(SubstitutionName is not null, 8, 0)
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company order by UpdateTime desc
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_GetRAR_CompanyId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_GetRAR_CompanyId]( @FSRAR_Id varchar(50), @RAR_CompanyId int=NULL OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	select @RAR_CompanyId = rc.RAR_CompanyId	
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc
	where rc.FSRAR_Id = @FSRAR_Id 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_Insert]( @CountryCode varchar(50)=NULL, @FSRAR_Id varchar(50)=NULL, @FullName varchar(4000)=NULL, @IsProducer bit=0, @Location varchar(4000)=NULL, @RAR_CompanyId int=NULL OUTPUT, @RegionCode varchar(50)=NULL, @ShortName varchar(4000)=NULL, @Status varchar(50)=NULL, @SubstitutionName varchar(255)=NULL, @TaxCode varchar(15)=NULL, @TaxReason varchar(50)=NULL, @UpdateTime datetime=NULL, @VersionWB varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company(
						FSRAR_Id
						,IsProducer
						,TaxCode
						,TaxReason
						,FullName
						,ShortName
						,SubstitutionName
						,CountryCode
						,RegionCode
						,Location
						,Status
                        ,VersionWB
						,UpdateTime)
		values(
			@FSRAR_Id
			,@IsProducer
			,@TaxCode
			,@TaxReason
			,@FullName
			,@ShortName
			,@SubstitutionName
			,@CountryCode
			,@RegionCode
			,@Location
			,@Status
            ,@VersionWB
			,@UpdateTime)

	set @RAR_CompanyId = @@Identity;
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_IsExistsFSRAR_Id]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_IsExistsFSRAR_Id]( @FSRAR_Id varchar(50), @IsExists bit=0 OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	if exists(select rc.FSRAR_Id 
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc
				where rc.FSRAR_Id = @FSRAR_Id)
		set @IsExists = 1;
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_Parse_ReplyClient_v2]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_Parse_ReplyClient_v2]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

declare @XMLDescriptor int
	,@XMLContent nvarchar(max)
	,@CreateTime datetime
	,@FSRAR_Id varchar(50)
	,@TaxCode varchar(15)
	,@TaxReason varchar(50)
	,@FullName varchar(4000)
	,@ShortName varchar(4000)
	,@CountryCode varchar(50)
	,@RegionCode varchar(50)
	,@Location varchar(4000)
	,@Status varchar(50)
	
declare @CompanyInfo table (
	FSRAR_Id varchar(50)
	,TaxCode varchar(15)
	,TaxReason varchar(50)
	,FullName varchar(4000)
	,ShortName varchar(4000)
	,CountryCode varchar(50)
	,RegionCode varchar(50)
	,Location varchar(4000)
	,Status varchar(50))

select @XMLContent = replace(ud.Content,'utf-8','utf-16')
	,@CreateTime = ud.CreateTime  
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
where ud.RowId = @RowId 

exec sp_xml_preparedocument @XMLDescriptor out, @XMLContent, '<root xmlns:rc="http://fsrar.ru/WEGAIS/ReplyClient_v2" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"/>'
		
begin try
	insert into @CompanyInfo
	select FSRAR_Id
		,TaxCode
		,TaxReason
		,FullName
		,ShortName
		,CountryCode
		,RegionCode
		,Location
		,Status
	from openxml(@XMLDescriptor, N'/ns:Documents/ns:Document/ns:ReplyClient_v2/rc:Clients/rc:Client', 1)
		with (
				FSRAR_Id varchar(50) './oref:OrgInfoV2/oref:UL/oref:ClientRegId'
				,TaxCode varchar(15) './oref:OrgInfoV2/oref:UL/oref:INN'
				,TaxReason varchar(50) './oref:OrgInfoV2/oref:UL/oref:KPP'
				,FullName varchar(4000) './oref:OrgInfoV2/oref:UL/oref:FullName'
				,ShortName varchar(4000) './oref:OrgInfoV2/oref:UL/oref:ShortName'	
				,CountryCode varchar(50) './oref:OrgInfoV2/oref:UL/oref:address/oref:Country'
				,RegionCode varchar(50) './oref:OrgInfoV2/oref:UL/oref:address/oref:RegionCode'
				,Location varchar(4000) './oref:OrgInfoV2/oref:UL/oref:address/oref:description'
				,Status varchar(50) './oref:State'
			);
end try
begin catch
	select 1
	--	rollback transaction
end catch

declare Company_Cursor cursor for   
select FSRAR_Id
	,TaxCode
	,TaxReason
	,FullName
	,ShortName
	,CountryCode
	,RegionCode
	,Location
	,Status
from CompanyInfo
	  
open Company_Cursor  
	 	
fetch next from Company_Cursor   
into @FSRAR_Id,@TaxCode,@TaxReason,@FullName,@ShortName,@CountryCode,@RegionCode,@Location,@Status

while @@fetch_status = 0  
begin
	if exists(select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc where rc.FSRAR_Id = @FSRAR_Id)
	begin
		update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company
		set	FSRAR_Id = @FSRAR_Id
			,TaxCode = @TaxCode
			,TaxReason = @TaxReason
			,FullName = @FullName
			,ShortName = @ShortName
			,CountryCode = @CountryCode
			,RegionCode = @RegionCode
			,Location = @Location
			,Status = @Status
		where FSRAR_Id = @FSRAR_Id
	end
	else
	begin
		insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company(FSRAR_Id
				,TaxCode
				,TaxReason
				,FullName
				,ShortName
				,CountryCode
				,RegionCode
				,Location
				,Status
				,UpdateTime)
		values(@FSRAR_Id
				,@TaxCode
				,@TaxReason
				,@FullName
				,@ShortName
				,@CountryCode
				,@RegionCode
				,@Location
				,@Status
				,@CreateTime)
	end

	fetch next from Company_Cursor   
	into @FSRAR_Id,@TaxCode,@TaxReason,@FullName,@ShortName,@CountryCode,@RegionCode,@Location,@Status
end

close Company_Cursor
deallocate Company_Cursor

-- устанавливаем статус только после окончания обработки --
update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data
set Status = 'Accepted'
where RowId = @RowId



GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_ParseReplyClient]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_ParseReplyClient]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@CreateTime datetime
		,@ClientRegId varchar(50)
		,@INN varchar(15)
		,@KPP varchar(50)
		,@FullName varchar(4000)
		,@ShortName varchar(4000)
		,@Country varchar(50)
		,@RegionCode varchar(50)
		,@Description varchar(4000)
		,@State varchar(50)
		,@RAR_CompanyId int
        ,@VersionWB varchar(50)
	
	create table #Company(
					ClientRegId varchar(50)
					,INN varchar(15)
					,KPP varchar(50)
					,FullName varchar(4000)
					,ShortName varchar(4000)
					,Country varchar(50)
					,RegionCode varchar(50)
					,Description varchar(4000)
					,State varchar(50)
					,CreateTime datetime
                    ,VersionWB varchar(50))

  
	select 
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@CreateTime = ud.CreateTime  
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			--and ud.Status = 'New' 
			and ud.Direction = 1 
	
		
	exec sp_xml_preparedocument @Descriptor out, @Content, '<root 
																xmlns:rc="http://fsrar.ru/WEGAIS/ReplyClient_v2" 
																xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2" 
																xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" />' 
	
	begin try
		begin transaction

			insert into #Company
				select 
					ClientRegId = coalesce(ClientRegIdUL, ClientRegIdFL, ClientRegIdFO)
					,INN = coalesce(INNUL, INNFL)
					,KPP = coalesce(KPPUL, KPPFL)
					,FullName = coalesce(FullNameUL, FullNameFL, FullNameFO)
					,ShortName = coalesce(ShortNameUL, ShortNameFL, ShortNameFO)
					,Country = coalesce(CountryUL, CountryFL, CountryFO)
					,RegionCode = coalesce(RegionCodeUL, RegionCodeFL)
					,[Description] = coalesce(DescriptionUL, DescriptionFL, DescriptionFO)
					,[State]
					,@CreateTime
                    ,VersionWB
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyClient_v2/rc:Clients/rc:Client', 1)
					with 
						(
							ClientRegIdUL varchar(50) './oref:OrgInfoV2/oref:UL/oref:ClientRegId'
							,ClientRegIdFL varchar(50) './oref:OrgInfoV2/oref:FL/oref:ClientRegId'
							,ClientRegIdFO varchar(50) './oref:OrgInfoV2/oref:FO/oref:ClientRegId'
							,INNUL varchar(15) './oref:OrgInfoV2/oref:UL/oref:INN'
							,INNFL varchar(15) './oref:OrgInfoV2/oref:FL/oref:INN'
							,KPPUL varchar(50) './oref:OrgInfoV2/oref:UL/oref:KPP'
							,KPPFL varchar(50) './oref:OrgInfoV2/oref:FL/oref:KPP'
							,FullNameUL varchar(4000) './oref:OrgInfoV2/oref:UL/oref:FullName'
							,FullNameFL varchar(4000) './oref:OrgInfoV2/oref:FL/oref:FullName'
							,FullNameFO varchar(4000) './oref:OrgInfoV2/oref:FO/oref:FullName'
							,ShortNameUL varchar(4000) './oref:OrgInfoV2/oref:UL/oref:ShortName'	
							,ShortNameFL varchar(4000) './oref:OrgInfoV2/oref:FL/oref:ShortName'
							,ShortNameFO varchar(4000) './oref:OrgInfoV2/oref:FO/oref:ShortName'
							,CountryUL varchar(50) './oref:OrgInfoV2/oref:UL/oref:address/oref:Country'
							,CountryFL varchar(50) './oref:OrgInfoV2/oref:FL/oref:address/oref:Country'
							,CountryFO varchar(50) './oref:OrgInfoV2/oref:FO/oref:address/oref:Country'
							,RegionCodeUL varchar(50) './oref:OrgInfoV2/oref:UL/oref:address/oref:RegionCode'
							,RegionCodeFL varchar(50) './oref:OrgInfoV2/oref:FL/oref:address/oref:RegionCode'
							,DescriptionUL varchar(4000) './oref:OrgInfoV2/oref:UL/oref:address/oref:description'
							,DescriptionFL varchar(4000) './oref:OrgInfoV2/oref:FL/oref:address/oref:description'
							,DescriptionFO varchar(4000) './oref:OrgInfoV2/oref:FO/oref:address/oref:description'
							,State varchar(50) './oref:State'
                            ,VersionWB varchar(50) './oref:VersionWB'
						);
	
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 'Accepted' where RowId = @RowId
	
		commit transaction			
	end try
	begin catch
		
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;

		rollback transaction
	end catch


	declare Company_Cursor cursor for   
		select * from #Company 
	  
	open Company_Cursor  
	 	
	fetch next from Company_Cursor   
		into 
			@ClientRegId
			,@INN
			,@KPP
			,@FullName
			,@ShortName
			,@Country
			,@RegionCode 
			,@Description
			,@State
			,@CreateTime
            ,@VersionWB

	while @@fetch_status = 0  
		begin
			 if exists(select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc where rc.FSRAR_Id = @ClientRegId)
				begin
					update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company
						set
							FSRAR_Id = @ClientRegId
							,TaxCode = @INN
							,TaxReason = @KPP
							,FullName = @FullName
							,ShortName = @ShortName
							,CountryCode = @Country
							,RegionCode = @RegionCode
							,Location = @Description
							,Status = @State
							,UpdateTime = @CreateTime
                            ,VersionWB = @VersionWB
					where FSRAR_Id = @ClientRegId
				end
			else
				begin

					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Company_Insert
								@FSRAR_Id = @ClientRegId
								,@TaxCode = @INN
								,@TaxReason = @KPP
								,@FullName = @FullName
								,@ShortName = @ShortName
								,@CountryCode = @Country
								,@RegionCode = @RegionCode
								,@Location = @Description
								,@Status = @State
								,@UpdateTime = @CreateTime
                                ,@VersionWB = @VersionWB
								,@RAR_CompanyId = @RAR_CompanyId out	 

					
					-- Добавляние организации в классификатор ЕГАИС.Организации			
					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Company_AddToClassifier
								@RAR_CompanyId = @RAR_CompanyId
								,@CountryCode = @Country
								,@RegionCode = @RegionCode
										
					
				end

			fetch next from Company_Cursor   
				into 
					@ClientRegId
					,@INN
					,@KPP
					,@FullName
					,@ShortName
					,@Country
					,@RegionCode 
					,@Description
					,@State
					,@CreateTime
                    ,@VersionWB
		end

	close Company_Cursor
		deallocate Company_Cursor







GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_SendQueryClients]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_SendQueryClients]( @Client_FSRAR_Id varchar(50)=NULL, @TaxCode varchar(15)=NULL, @FSRAR_Id varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	if isnull(@FSRAR_Id, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Company.SendQueryClients'                and Item=0), 'Не указан ФСРАР ИД инициатора запроса!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@Client_FSRAR_Id, '') = '' and isnull(@TaxCode, '') = ''
		begin
			return 1
		end

	declare 
		@Content nvarchar(max)
		,@ClassId varchar(50) = 'QueryClients'	
		,@ExchangeTypeCode varchar(50)
		,@UTM_Path varchar(255)
		,@Direction smallint = -1
		,@Status smallint = 0


	exec bpUTM_ExchangeClass_GetDefaultType
			@ClassId
			,@ExchangeTypeCode out


	select @Content = '<?xml version="1.0" ?>' + char(13)+
							'<ns:Documents Version="1.0" ' + char(13)+
								'xmlns:xsi="http://wwww.w3.org/2001/XMLSchema-instance"' + char(13)+
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13)+
								'xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef"' + char(13)+
								'xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters" >' + char(13)+
								'<ns:Owner>' + char(13)+
									'<ns:FSRAR_ID>' + coalesce(@FSRAR_ID,'') + '</ns:FSRAR_ID>' + char(13)+
								'</ns:Owner>' + char(13)+
								'<ns:Document>' + char(13)+
									'<ns:QueryClients_v2>' + char(13) +
										'<qp:Parameters>' + char(13)+
											'<qp:Parameter>' + char(13)
				
										if isnull(@Client_FSRAR_Id, '') <> ''
											begin		
												select @Content = @Content +
												'<qp:Name>СИО</qp:Name>' + char(13)+
												'<qp:Value>' + ltrim(rtrim(@Client_FSRAR_Id)) + '</qp:Value>' + char(13)
											end
										else if isnull(@TaxCode, '') <> ''
											begin
												select @Content = @Content +
												'<qp:Name>ИНН</qp:Name>' + char(13)+
												'<qp:Value>' + ltrim(rtrim(@TaxCode)) + '</qp:Value>' + char(13)
											end	
							
	select @Content = @Content + 
											'</qp:Parameter>' + char(13)+
										'</qp:Parameters>' + char(13)+
									'</ns:QueryClients_v2>' + char(13) +
								'</ns:Document>' + char(13)+
							'</ns:Documents>' + char(13)	


	if isnull(@Content,'') = ''
		begin
			return 1
		end
	else
		begin
			select @UTM_Path = udt.UTM_Path 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType udt 
			where udt.ExchangeTypeCode = @ExchangeTypeCode
				and udt.Direction = @Direction
			
			if isnull(@UTM_Path, '') = ''
				begin
					return 1
				end
			else
				begin
					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,u.URL + @UTM_Path
						,getdate()
						,@Direction
						,u.UTMId
						,@Status
						,@ExchangeTypeCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						where u.FSRAR_Id = @FSRAR_Id
							and u.IsActive = 1
				end					
		end  
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Company_SendReplyClientVersion]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Company_SendReplyClientVersion]( @Client_FSRAR_Id varchar(50)=NULL, @TaxCode varchar(15)=NULL, @FSRAR_Id varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
    

	if isnull(@FSRAR_Id, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Company.SendReplyClientVersion'                and Item=0), 'Не указан ФСРАР ИД инициатора запроса!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@Client_FSRAR_Id, '') = '' and isnull(@TaxCode, '') = ''
		begin
			return 1
		end

	declare 
		@Content nvarchar(max)	
		,@TypeCode varchar(50) = 'QueryClients_v2'
		,@UTM_Path varchar(255)
		,@Direction smallint = -1
		,@Status smallint = 0


	select @Content = '<?xml version="1.0" ?>' + char(13)+
							'<ns:Documents Version="1.0" ' + char(13)+
								'xmlns:xsi="http://wwww.w3.org/2001/XMLSchema-instance"' + char(13)+
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13)+
								'xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef"' + char(13)+
								'xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters" >' + char(13)+
								'<ns:Owner>' + char(13)+
									'<ns:FSRAR_ID>' + coalesce(@FSRAR_ID,'') + '</ns:FSRAR_ID>' + char(13)+
								'</ns:Owner>' + char(13)+
								'<ns:Document>' + char(13)+
									'<ns:QueryClients_v2>' + char(13) +
										'<qp:Parameters>' + char(13)+
											'<qp:Parameter>' + char(13)
				
										if isnull(@Client_FSRAR_Id, '') <> ''
											begin		
												select @Content = @Content +
												'<qp:Name>СИО</qp:Name>' + char(13)+
												'<qp:Value>' + ltrim(rtrim(@Client_FSRAR_Id)) + '</qp:Value>' + char(13)
											end
										else if isnull(@TaxCode, '') <> ''
											begin
												select @Content = @Content +
												'<qp:Name>ИНН</qp:Name>' + char(13)+
												'<qp:Value>' + ltrim(rtrim(@TaxCode)) + '</qp:Value>' + char(13)
											end	
							
	select @Content = @Content + 
											'</qp:Parameter>' + char(13)+
										'</qp:Parameters>' + char(13)+
									'</ns:QueryClients_v2>' + char(13) +
								'</ns:Document>' + char(13)+
							'</ns:Documents>' + char(13)	


	if isnull(@Content,'') = ''
		begin
			return 1
		end
	else
		begin
			select @UTM_Path = udt.UTM_Path 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType udt 
			where udt.TypeCode = @TypeCode
				and udt.Direction = @Direction
			
			if isnull(@UTM_Path, '') = ''
				begin
					return 1
				end
			else
				begin
					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,DocumentTypeId)
					select 
						@Content
						,u.URL + @UTM_Path
						,getdate()
						,@Direction
						,u.Id
						,@Status
						,@TypeCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						where u.FSRAR_Id = @FSRAR_Id
				end					
		end 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyAddForeignCompanyReestr_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyAddForeignCompanyReestr_Insert]( @CreateTime datetime=NULL, @MonUserId varchar(128)=NULL, @RAR_CompanyAddForeignCompanyReestrId int=NULL OUTPUT, @RowId uniqueidentifier=NULL, @Status varchar(32)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     

	
	if isnull(@MonUserId, '') = ''
		select @MonUserId = ( select coalesce(    case when __xc.bo_UserName is null then __xc.bo_UserName else SUBSTRING(__xc.bo_UserName,CHARINDEX('\',__xc.bo_UserName)+1,LEN(__xc.bo_UserName)) end,    SUBSTRING(__s.login_name,CHARINDEX('\',__s.login_name)+1,LEN(__s.login_name)) )  from sys.dm_exec_sessions __s left join xBOConnection __xc on __s.session_id=__xc.spid and __s.login_time=__xc.login_time where __s.session_id=@@spid )

	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyAddForeignCompanyReestr(
													CreateTime 
													,MonUserId
													,Status)
		select
			getdate()
			,@MonUserId
			,'New'

	set @RAR_CompanyAddForeignCompanyReestrId = @@identity;
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyAddForeignCompanyReestr_SetRowId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyAddForeignCompanyReestr_SetRowId]( @RowId uniqueidentifier=NULL, @RAR_CompanyAddForeignCompanyReestrId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyAddForeignCompanyReestr
		set RowId = @RowId
	where RAR_CompanyAddForeignCompanyReestrId = @RAR_CompanyAddForeignCompanyReestrId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyAddForeignCompanyReestr_View]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CompanyAddForeignCompanyReestr_View]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select 
	r.CreateTime
	,r.Status
	,UserName =  mu.MonUserName#Rus
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyAddForeignCompanyReestr r
	join mch.dbo.MonUser mu
		on mu.MonUserId = r.MonUserId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRests_GetCompareRestsRetail]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRests_GetCompareRestsRetail]( @DepartmentId varchar(30)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRests_GetCompareRestsWholesale]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRests_GetCompareRestsWholesale]( @HeaderCompanyId varchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          


if object_id(N'tempdb..#ListWareHouse', N'U') is not null
	drop table #ListWareHouse

--Получение списка складов в привязкой к FSRAR_ID
select 
	ic.CompanyId 
	,ic.InterCompanyName#Rus as CompanyName 
	,wh.WareHouseId 
	,wh.WareHouseName#Rus 
	,c.TaxCode as INN 
	,caa.Value as KPP 
	,rc.FSRAR_Id 
	,u.Description as DepartmentName
into #ListWareHouse
	from mch.dbo.LegalCompany lc with(nolock)
		join mch.dbo.InterCompany ic with(nolock)
			on ic.LegalCompanyId = lc.LegalCompanyId
		join mch.dbo.WareHouse wh with(nolock)
			on wh.InterCompanyId = ic.InterCompanyId
		join mch.dbo.Company c with(nolock)
			on c.CompanyId = ic.CompanyId
		join mch.dbo.ClassAdditionalAttrib caa with(nolock)
			on caa.Class_Object = 'Address'
				and caa.ClassId = wh.AddressId
				and caa.AdditionalAttribId = 'AddrTaxReason'
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc with(nolock)
			on rc.TaxCode = c.TaxCode
				and rc.TaxReason = caa.Value
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u with(nolock)
			on u.FSRAR_Id = rc.FSRAR_Id
				and u.IsTest = 0
where lc.LegalCompanyId = @HeaderCompanyId
  	and wh.IsAnalytLotEnable = 1 


if object_id(N'tempdb..#RestsM', N'U') is not null
	drop table #RestsM

--Получение остатков в Монолите
select 
	lwh.FSRAR_Id
	,lwh.WareHouseId 
	,al.WareId 
	,a.Value as AlcCode 
	,al.PartNumber
	,case isnull(rw.Capacity, 0) when 0 then als.Quantity * cuf.FactorValue / cuf2.FactorValue else als.Quantity end as Quantity 
	,alaA.Value as InformProduction 
	,alaB.Value as InformMotion
	,datediff(day, getdate(), try_convert(datetime, dateEnd.Value)) as DayEndUsed
into #RestsM
	from #ListWareHouse lwh
		join (select 
				AnalytLotIntId
				,AnalytLotQuantId 
				,PlaceId 
				,MAX(SaldoDate) as SaldoDate 
				,WareHouseId 
			from mch.dbo.AnalytLotSaldo with(nolock)
				group by AnalytLotIntId, AnalytLotQuantId, PlaceId, WareHouseId) as alsMax
					on alsMax.WareHouseId = lwh.WareHouseId
		join mch.dbo.AnalytLotSaldo als with(nolock)
			on als.AnalytLotIntId = alsMax.AnalytLotIntId
				and als.AnalytLotQuantId = alsMax.AnalytLotQuantId
				and als.WareHouseId = alsMax.WareHouseId
				and als.SaldoDate = alsMax.SaldoDate
				and als.PlaceId = alsMax.PlaceId
		join mch.dbo.AnalytLot al with(nolock)
			on al.AnalytLotIntId = als.AnalytLotIntId
		join mch.dbo.AnalytLotQuant alq with(nolock)
			on alq.AnalytLotQuantId = als.AnalytLotQuantId
		left join mch.dbo.AnalytLotAttribute alaA with(nolock)
			on alaA.AnalytLotIntId = als.AnalytLotIntId
				and alaA.AdditionalAttribId = 'InformARegId'
		join mch.dbo.AnalytLotAttribute alaB with(nolock)
			 on alaB.AnalytLotIntId = als.AnalytLotIntId
				and alaB.AdditionalAttribId = 'InformBRegId'
		join mch.dbo.AnalytLotAttribute a 
			on a.AnalytLotIntId = als.AnalytLotIntId
				and a.AdditionalAttribId in ('AlcCode', 'WL906')
		join mch.dbo.CrossUnitFactor cuf with(nolock)
			on cuf.WareId = alq.WareId
				and cuf.UnitId = alq.UnitId
		join mch.dbo.CrossUnitFactor cuf2 with(nolock)
			on cuf2.WareId = al.WareId
				and cuf2.UnitId = 'dal'
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw with(nolock)
			on rw.AlcCode = a.Value
		left join mch.dbo.AnalytLotAttribute dateEnd
			on dateEnd.AnalytLotIntId = als.AnalytLotIntId
				and dateEnd.AdditionalAttribId = 'DateEndUsed'
	where als.Quantity != 0
		 and rw.AlcTypeCode in ('321', '350')


insert into #RestsM
	select 
		lwh.FSRAR_Id 
		,lwh.WareHouseId 
		,al.WareId 
		,caaW.Value as AlcCode 
		,al.PartNumber 
		,case isnull(rw.Capacity, 0) when 0 then als.Quantity * cuf.FactorValue / cuf2.FactorValue else als.Quantity end as Quantity 
		,alaA.Value as InformProduction
		,alaB.Value as InformMotion
		,datediff(day, getdate(), try_convert(datetime, dateEnd.Value)) as DayEndUsed
	from #ListWareHouse lwh
		join (select 
				AnalytLotIntId 
				,AnalytLotQuantId 
				,PlaceId 
				,MAX(SaldoDate) as SaldoDate 
				,WareHouseId 
			from mch.dbo.AnalytLotSaldo with(nolock)
			group by AnalytLotIntId, AnalytLotQuantId, PlaceId, WareHouseId) as alsMax
				on alsMax.WareHouseId = lwh.WareHouseId
		join mch.dbo.AnalytLotSaldo als with(nolock)
			on als.AnalytLotIntId = alsMax.AnalytLotIntId
				 and als.AnalytLotQuantId = alsMax.AnalytLotQuantId
				 and als.WareHouseId = alsMax.WareHouseId
				 and als.SaldoDate = alsMax.SaldoDate
				 and als.PlaceId = alsMax.PlaceId
		join mch.dbo.AnalytLot al with(nolock)
			 on al.AnalytLotIntId = als.AnalytLotIntId
		join mch.dbo.AnalytLotQuant alq with(nolock)
			on alq.AnalytLotQuantId = als.AnalytLotQuantId
		left join mch.dbo.AnalytLotAttribute alaA with(nolock)
			on alaA.AnalytLotIntId = als.AnalytLotIntId
				and alaA.AdditionalAttribId = 'InformARegId'
		join mch.dbo.AnalytLotAttribute alaB with(nolock)
			on alaB.AnalytLotIntId = als.AnalytLotIntId
				and alaB.AdditionalAttribId = 'InformBRegId'
		join mch.dbo.ClassAdditionalAttrib caaW  with(nolock)
			on caaW.AdditionalAttribId = 'WARE_EGAIS' 
				and caaW.ClassId = al.WareId
		join mch.dbo.CrossUnitFactor cuf with(nolock)
			on cuf.WareId = alq.WareId
				and cuf.UnitId = alq.UnitId
		join mch.dbo.CrossUnitFactor cuf2 with(nolock)
			on cuf2.WareId = al.WareId
				and cuf2.UnitId = 'dal'
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw with(nolock)
			on rw.AlcCode = caaW.Value		
		left join mch.dbo.AnalytLotAttribute dateEnd
			on dateEnd.AnalytLotIntId = als.AnalytLotIntId
				and dateEnd.AdditionalAttribId = 'DateEndUsed'
	where als.Quantity != 0
		and rw.AlcTypeCode not in ('321', '350')


if object_id(N'tempdb..#RestsE', N'U') is not null
	drop table #RestsE

--Получение остатков в ЕГАИС
select distinct 
	cr.FSRAR_Id 
	,cr.RestsTime
	,cr.AlcCode 
	,cr.InformProduction
	,cr.InformMotion
	,cr.Quantity
into #RestsE
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRests cr with(nolock)
		join #ListWareHouse lwh 
			on lwh.FSRAR_Id = cr.FSRAR_Id


/*if object_id(N'tempdb..#Result', N'U') is not null
	drop table #Result*/

--Итог
create table #Result(
				[Level] int 
				,WareId varchar(15) 
				,CompanyId varchar(15) 
				,CompanyName varchar(255) 
				,FSRAR_Id varchar(50) 
				,DepartmentName varchar(255) 
				,WareHouseId varchar(15)
				,RestsDate datetime 
				,AlcCode varchar(50) 
				,AlcVolume varchar(50) 
				,BottlingDate smalldatetime
				,WareName varchar(255) 
				,InformProduction varchar(50) 
				,InformMotion varchar(50) 
				,PartNumber varchar(150)
				,QuantityM decimal(16,4) default 0 
				,QuantityE decimal(16,4) default 0 
				,IsDiff bit default 0
				,DayEndUsed int)

insert #Result(
		[Level] 
		,FSRAR_Id 
		,AlcCode 
		,InformMotion 
		,AlcVolume)
	select distinct 
		3 
		,m.FSRAR_Id 
		,m.AlcCode 
		,m.InformMotion
		,rw.AlcVolume
	from #RestsM m
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw with(nolock)
			on rw.AlcCode = m.AlcCode
union
	select distinct 
		3 
		,e.FSRAR_Id 
		,e.AlcCode 
		,e.InformMotion
		,rw.AlcVolume
	from #RestsE e
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw with(nolock)
			on rw.AlcCode = e.AlcCode


update r 
	set r.InformProduction = e.InformProduction
from #Result r
	join #RestsE e 
		on e.FSRAR_Id = r.FSRAR_Id
			and e.AlcCode = r.AlcCode
		    and e.InformMotion = r.InformMotion
where r.Level = 3

update r 
	set r.InformProduction = m.InformProduction
from #Result r
	join #RestsM m 
		on m.FSRAR_Id = r.FSRAR_Id
			and m.AlcCode = r.AlcCode
		    and m.InformMotion = r.InformMotion
where r.InformProduction is null
  and r.Level = 3


-- Обновление количества дней до конца срока годности (Monolit)
update r 
	set 
		r.PartNumber = m.PartNumber
		,r.DayEndUsed = m.DayEndUsed
from #Result r
	join #RestsM m 
		on m.AlcCode = r.AlcCode
			and m.InformMotion = r.InformMotion
		    and m.FSRAR_Id = r.FSRAR_Id
where r.Level = 3

-- Обновление количества дней до конца срока годности (EGAIS)
update r
	set r.DayEndUsed = datediff(day, getdate(), try_convert(datetime, dateEnd.Value))
from #Result r
	join #RestsE e
		on e.AlcCode = r.AlcCode
			and e.InformMotion = r.InformMotion
			and e.FSRAR_Id = r.FSRAR_Id
	join mch.dbo.AnalytLotAttribute ala
		on ala.AdditionalAttribId = 'InformARegId'
		and ala.Value = r.InformProduction
		and ala.AnalytLotIntId = (select max(maxAnalyt.AnalytLotIntId) 
									from mch.dbo.AnalytLotAttribute maxAnalyt 
								where maxAnalyt.AdditionalAttribId = 'InformARegId' 
									and maxAnalyt.Value = r.InformProduction)
	join mch.dbo.AnalytLotAttribute dateEnd
		on dateEnd.AnalytLotIntId = ala.AnalytLotIntId
			and dateEnd.AdditionalAttribId = 'DateEndUsed'	
where r.Level = 3
	and r.DayEndUsed is null


update r 
	set r.WareId = m.WareId
from #Result r
	join #RestsM m 
		on m.AlcCode = r.AlcCode

update r 
	set r.BottlingDate = fa.BottlingDate
from #Result r
	left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_FormA fa with(nolock)
		on fa.InformProduction = r.InformProduction

update r 
	set r.CompanyId = lwh.CompanyId
from #Result r
	join #ListWareHouse lwh
		on lwh.FSRAR_Id = r.FSRAR_Id
where r.[Level] = 3
  
update r 
	set r.QuantityM = m.Quantity
from #Result r
	join #ListWareHouse lwh
		on lwh.FSRAR_Id = r.FSRAR_Id
	join (select 
			FSRAR_Id 
			,AlcCode 
			,InformMotion 
			,sum(Quantity) as Quantity 
		from #RestsM
			group by FSRAR_Id, AlcCode, InformMotion) as m
		on m.FSRAR_Id = r.FSRAR_Id
			and m.AlcCode = r.AlcCode
			and m.InformMotion = r.InformMotion 
where r.[Level] = 3

update r 
	set r.QuantityE = e.Quantity
from #Result r
	join #RestsE e
		on e.FSRAR_Id = r.FSRAR_Id
			and e.AlcCode = r.AlcCode
			and e.InformProduction = r.InformProduction
			and e.InformMotion = r.InformMotion
where r.[Level] = 3
 
update r 
	set r.WareName = rw.WareName + ' Емкость: ' + case 
													when isnull(rw.Capacity ,0) = 0 then '' 
													else convert(varchar(50), rw.Capacity) 
												end
from #Result r
	join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw with(nolock)
		on rw.AlcCode = r.AlcCode
where r.[Level] = 3

 
insert #Result(
			[Level] 
			,CompanyId 
			,FSRAR_Id 
			,AlcCode 
			,WareName 
			,QuantityM 
			,QuantityE
			,WareHouseId)
select 
	2 
	,CompanyId 
	,FSRAR_Id 
	,AlcCode 
	,WareName 
	,sum(QuantityM) 
	,sum(QuantityE)
	,WareHouseId 
from #Result
	where [Level] = 3
		group by CompanyId, FSRAR_Id, AlcCode, WareName, WareHouseId

insert #Result(
			[Level] 
			,CompanyId 
			,FSRAR_Id 
			,DepartmentName 
			,RestsDate)
select distinct 
	1 
	,r.CompanyId 
	,r.FSRAR_Id 
	,lwh.DepartmentName 
	,e.RestsTime 
from #Result r
	join #ListWareHouse lwh
		on lwh.FSRAR_Id = r.FSRAR_Id
	join #RestsE e
		on e.FSRAR_Id = r.FSRAR_Id

update #Result 
	set IsDiff = 1
where QuantityM != QuantityE
	and [Level] in (2 , 3, 4, 5)

 delete from #Result where QuantityM = 0 and QuantityE = 0 and [level] <> 1


select 
	[Level] 
	,WareId 
	,CompanyId
	,CompanyName 
	,FSRAR_Id 
	,DepartmentName 
	,WareHouseId
	,RestsDate 
	,AlcCode 
	,AlcVolume 
	,BottlingDate 
	,WareName 
	,InformProduction
	,InformMotion
	,PartNumber
	,QuantityM 
	,QuantityE 
	,IsDiff
	,DayEndUsed
from #Result
	order by CompanyId, FSRAR_Id, AlcCode, [Level] 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRests_GetReportCompanyRests]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRests_GetReportCompanyRests]( @FSRAR_ID varchar(50)=NULL, @AlcTypeCode varchar(10)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    set nocount on
set dateformat dmy

declare @Spirit decimal(18, 4)

create table #Rests(level int, AlcCode varchar(50), AlcTypeCode varchar(10), WareName nvarchar(1000), InformProduction varchar(50), InformMotion varchar(50), AlcVolume decimal(16, 4),Spirit decimal(16, 4), QuantityDal decimal(16, 4), QuantitySht decimal(16, 4))
insert into #Rests(level, AlcCode, AlcTypeCode, WareName, InformProduction, InformMotion, AlcVolume, Spirit, QuantityDal, QuantitySht)
select 0
      ,cr.AlcCode
	  ,w.AlcTypeCode
	  ,w.WareName
	  ,cr.InformProduction
	  ,cr.InformMotion
	  ,w.AlcVolume
 	  ,null
	  ,case when w.Capacity is null then cr.Quantity else round(convert(decimal(16, 4), w.Capacity) * cr.Quantity * 0.1, 4) end as QuantityDal
      ,case when w.Capacity is null then 0 else cr.Quantity end as QuantitySht
from RAR_CompanyRests cr
join RAR_Ware w on w.AlcCode = cr.AlcCode
where cr.FSRAR_Id = @FSRAR_ID
  and (   w.AlcTypeCode = @AlcTypeCode
       or @AlcTypeCode is null)

insert into #Rests (level, AlcCode, AlcVolume, AlcTypeCode, QuantityDal, QuantitySht)
select 1
      ,r.AlcCode
      ,r.AlcVolume
      ,r.AlcTypeCode
	  ,sum(r.QuantityDal)
	  ,sum(r.QuantitySht)
from #Rests r
where Level = 0
group by r.AlcCode,r.AlcVolume,r.AlcTypeCode

insert into #Rests (Level, AlcCode, WareName, InformProduction, InformMotion, AlcVolume, QuantityDal, QuantitySht)
select 2
      ,r.AlcCode
      ,r.WareName
      ,r.InformProduction
      ,r.InformMotion
      ,r.AlcVolume
      ,r.QuantityDal
      ,r.QuantitySht
from #Rests r
where r.Level = 0

insert into #Rests (Level, AlcVolume, InformMotion, Spirit, QuantityDal, QuantitySht)
select 3
      ,r.AlcVolume
      ,'Итого по крепости:'
      ,null
      ,sum(r.QuantityDal)
      ,sum(r.QuantitySht)
from #Rests r
where Level = 0
group by r.AlcVolume

update #Rests set Spirit = QuantityDal*AlcVolume/100 where level = 3

insert into #Rests (level, AlcVolume, InformMotion, Spirit, QuantityDal, QuantitySht)
select 4
      ,'99.999'
      ,'Итого:'
      ,NULL
 	  ,sum(r.QuantityDal)
	  ,sum(r.QuantitySht)
from #Rests r
where Level = 0

select @Spirit = sum(r.Spirit) from #Rests r

update #Rests set Spirit = @Spirit where level = 4

Print 'EndHeader'

select r.level
      ,case when r.level = 1 then r.AlcCode end as AlcCode
	  ,case when r.level = 1 then r.AlcTypeCode end as AlcTypeCode
	  ,r.WareName
	  ,r.InformProduction
	  ,r.InformMotion
	  ,case when r.level in (1,3) then r.AlcVolume end as AlcVolume
      ,r.Spirit
	  ,r.QuantityDal
	  ,r.QuantitySht
from #Rests r
where r.level <> 0
order by r.AlcVolume
        ,r.AlcCode
	    ,r.level
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRests_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRests_Insert]( @AlcCode varchar(50)=NULL, @FSRAR_Id varchar(50)=NULL, @InformMotion varchar(50)=NULL, @InformProduction varchar(50)=NULL, @Quantity decimal(16,4)=NULL, @ReplyId varchar(50)=NULL, @RestsTime datetime=NULL, @SourceFSRAR_Id varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRests(
						AlcCode
						,FSRAR_Id
						,InformProduction
						,InformMotion
						,SourceFSRAR_Id
						,Quantity
						,ReplyId
						,RestsTime)
		values(
			@AlcCode
			,@FSRAR_Id
			,@InformProduction
			,@InformMotion
			,@SourceFSRAR_Id
			,@Quantity
			,@ReplyId
			,@RestsTime)
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRests_J_UpdateBalances]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRests_J_UpdateBalances]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare 
		@FSRAR_Id varchar(50)
		,@RowId uniqueidentifier

	declare UTM_Cursor cursor for
		select distinct FSRAR_Id
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
		where u.IsActive = 1

	open UTM_Cursor

	fetch next from UTM_Cursor
		into @FSRAR_Id
		
	while @@fetch_status = 0  
		begin
	
			exec mch.dbo.bpRAR_CompanyRests_SendQueryRests 
					@FSRAR_Id = @FSRAR_Id
					,@RowId = @RowId out

			select @RowId

			fetch next from UTM_Cursor
				into @FSRAR_Id

		end

	close UTM_Cursor
		deallocate UTM_Cursor 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRests_ParseReplyRests]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRests_ParseReplyRests]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@ReplyId varchar(50)
		,@AlcCode varchar(100)
		,@FSRAR_Id varchar(50)
		,@InformProduction varchar(50)
		,@InformMotion varchar(50)
		,@Quantity decimal(16, 4)
		,@SourceFSRAR_Id varchar(50)
		,@RestsTime datetime

	
	create table #CompanyRests(
					AlcCode varchar(100)
					,FSRAR_Id varchar(50)
					,InformProduction varchar(50)
					,InformMotion varchar(50)
					,SourceFSRAR_Id varchar(50)
					,Quantity decimal(16, 4)
					,ReplyId varchar(50)
					,RestsTime datetime)

	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ReplyId = ud.ReplyId
		,@FSRAR_Id = u.FSRAR_Id  
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.UTMId = ud.UTM_Id  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1  


	exec sp_xml_preparedocument @Descriptor out, @Content, '<root  
															 	xmlns:rst="http://fsrar.ru/WEGAIS/ReplyRests_v2"
															 	xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" 
																xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"
																xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2" />'

	begin try
		begin transaction

			delete from RAR_CompanyRests where FSRAR_Id = @FSRAR_Id

			select @RestsTime = RestDate
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyRests_v2', 1)
					with(RestDate datetime './rst:RestsDate')

			insert into #CompanyRests(Quantity, InformProduction, InformMotion, AlcCode, SourceFSRAR_Id, ReplyId, FSRAR_Id, RestsTime)
				select 
					Quantity
					,InformF1RegId
					,InformF2RegId 
					,AlcCode
					,ClientRegId
					,@ReplyId
					,@FSRAR_Id
					,@RestsTime
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyRests_v2/rst:Products/rst:StockPosition', 1)
					with 
						(
							Quantity decimal(16, 4) './rst:Quantity'
							,InformF1RegId varchar(50) './rst:InformF1RegId'
							,InformF2RegId varchar(50) './rst:InformF2RegId'
							,AlcCode varchar(50) './rst:Product/pref:AlcCode'
							,ClientRegId varchar(50) './rst:Product/pref:Producer/oref:UL/oref:ClientRegId'	
						);
			
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus	
						@RowId = @RowId
						,@Status = 'Accepted'		
	
		commit transaction
	end try			
	begin catch
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage

		rollback transaction
	end catch

	
	declare CompanyRests_Cursor	cursor for
		select 
			AlcCode 
			,InformProduction
			,InformMotion
			,Quantity
			,SourceFSRAR_Id
		from #CompanyRests

	open CompanyRests_Cursor
	
	fetch next from CompanyRests_Cursor
		into
			@AlcCode
			,@InformProduction
			,@InformMotion
			,@Quantity
			,@SourceFSRAR_Id

	while @@fetch_status = 0  
		begin		
			if exists(select top 1 * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRests crwh 
						where crwh.FSRAR_Id = @FSRAR_Id
							and crwh.AlcCode = @AlcCode
							and crwh.InformProduction = @InformProduction
							and crwh.InformMotion = @InformMotion)
				begin
					update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRests
						set 
							Quantity = @Quantity
							,RestsTime = @RestsTime
							,ReplyId = @ReplyId
					where FSRAR_Id = @FSRAR_Id
						and AlcCode = @AlcCode
						and InformProduction = @InformProduction
						and InformMotion = @InformMotion 
				end
			else
				begin

					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CompanyRests_Insert
								@AlcCode = @AlcCode
								,@FSRAR_Id = @FSRAR_Id
								,@InformProduction = @InformProduction
								,@InformMotion = @InformMotion
								,@SourceFSRAR_Id = @SourceFSRAR_Id
								,@Quantity = @Quantity 
								,@ReplyId = @ReplyId 
								,@RestsTime = @RestsTime

				end

			fetch next from CompanyRests_Cursor
				into
					@AlcCode
					,@InformProduction
					,@InformMotion
					,@Quantity
					,@SourceFSRAR_Id

		end

	close CompanyRests_Cursor
		deallocate CompanyRests_Cursor
 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRestsExciseStamp_ParseReplyES]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CompanyRestsExciseStamp_ParseReplyES]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

SET ANSI_NULLS ON
SET ANSI_WARNINGS ON
set concat_null_yields_null on
set ANSI_padding on 

declare @XMLContent xml  
       ,@Cursor cursor
	   ,@CreateTime datetime
	   ,@FSRAR_Id varchar(50)
    
    select @CreateTime = ud.CreateTime
          ,@FSRAR_Id = u.FSRAR_Id
		  ,@XMLContent = ud.Content
    from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
    join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u on u.UTMId = ud.UTM_Id
    where ud.RowId = @RowId

     create table #RestsES(CreateTime datetime, FSRAR_Id varchar(100), InformMotion varchar(50), BarCode varchar(500))

	  ;WITH XMLNAMESPACES ('http://fsrar.ru/WEGAIS/ReplyRestBCode' AS rst, 'http://fsrar.ru/WEGAIS/CommonV3' as ce)
	  insert into #RestsES(CreateTime, FSRAR_Id, InformMotion, BarCode)
	  select @CreateTime as CreateTime
	        ,@FSRAR_Id as FSRAR_ID
	        ,el.value('.','varchar(50)') as el
		    ,e.value('.','varchar(500)') as e 
	  from @XMLContent.nodes('//rst:Inform2RegId') r(el)  
	  outer apply @XMLContent.nodes('//ce:amc') as t(e)


	exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
			@RowId = @RowId
			,@Status = 'Accepted'

    delete c from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRestsExciseStamp c
    join #RestsES r on r.FSRAR_ID = c.FSRAR_Id
                   and r.InformMotion = c.InformMotion

    insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRestsExciseStamp(FSRAR_Id, InformMotion, StampBarCode, RestsTime)
    select r.FSRAR_Id
          ,r.InformMotion
		  ,r.BarCode
		  ,r.CreateTime      
	 from #RestsES r
	 where r.BarCode is not null
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRestsWareHouse_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRestsWareHouse_Edit]( @FSRAR_Id varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRestsWareHouse wh where wh.FSRAR_Id = @FSRAR_Id
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRestsWareHouse_ParseReplyRests]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRestsWareHouse_ParseReplyRests]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@ReplyId varchar(50)
		,@AlcCode varchar(100)
		,@FSRAR_Id varchar(50)
		,@InformProduction varchar(50)
		,@InformMotion varchar(50)
		,@Quantity decimal(16, 4)
		,@RestsTime datetime

	
	create table #CompanyRests(
					AlcCode varchar(100)
					,FSRAR_Id varchar(50)
					,InformProduction varchar(50)
					,InformMotion varchar(50)
					,Quantity decimal(16, 4)
					,ReplyId varchar(50)
					,RestsTime datetime)

	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ReplyId = ud.ReplyId
		,@FSRAR_Id = u.FSRAR_Id  
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.Id = ud.UTM_Id  
		where ud.RowId = @RowId 
			and ud.Status = 0
			and ud.Direction = 1  


	exec sp_xml_preparedocument @Descriptor out, @Content, '<root  
															 	xmlns:rst="http://fsrar.ru/WEGAIS/ReplyRests_v2"
															 	xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" 
																xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2" />'

	begin try
		begin transaction

			select @RestsTime = RestDate
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyRests_v2', 1)
					with(RestDate datetime './rst:RestsDate')

			insert into #CompanyRests(Quantity, InformProduction, InformMotion, AlcCode, ReplyId, FSRAR_Id, RestsTime)
				select 
					Quantity
					,InformF1RegId
					,InformF2RegId 
					,AlcCode
					,@ReplyId
					,@FSRAR_Id
					,@RestsTime
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyRests_v2/rst:Products/rst:StockPosition', 1)
					with 
						(
							Quantity decimal(16, 4) './rst:Quantity'
							,InformF1RegId varchar(50) './rst:InformF1RegId'
							,InformF2RegId varchar(50) './rst:InformF2RegId'
							,AlcCode varchar(50) './rst:Product/pref:AlcCode'	
						);

			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 1 where RowId = @RowId and Status = 0  		
	
		commit transaction
	end try			
	begin catch
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage

		rollback transaction
	end catch

	
	declare CompanyRests_Cursor	cursor for
		select 
			AlcCode 
			,InformProduction
			,InformMotion
			,Quantity
		from #CompanyRests

	open CompanyRests_Cursor
	
	fetch next from CompanyRests_Cursor
		into
			@AlcCode
			,@InformProduction
			,@InformMotion
			,@Quantity

	while @@fetch_status = 0  
		begin		
			if exists(select top 1 * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRestsWareHouse crwh 
						where crwh.FSRAR_Id = @FSRAR_Id
							and crwh.AlcCode = @AlcCode
							and crwh.InformProduction = @InformProduction
							and crwh.InformMotion = @InformMotion)
				begin
					update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRestsWareHouse
						set 
							Quantity = @Quantity
							,RestsTime = @RestsTime
							,ReplyId = @ReplyId
					where FSRAR_Id = @FSRAR_Id
						and AlcCode = @AlcCode
						and InformProduction = @InformProduction
						and InformMotion = @InformMotion 
				end
			else
				begin
					insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRestsWareHouse(
									AlcCode
									,FSRAR_Id
									,InformProduction
									,InformMotion
									,Quantity
									,ReplyId
									,RestsTime)
						values(
							@AlcCode
							,@FSRAR_Id
							,@InformProduction
							,@InformMotion
							,@Quantity
							,@ReplyId
							,@RestsTime)
				end

			fetch next from CompanyRests_Cursor
				into
					@AlcCode
					,@InformProduction
					,@InformMotion
					,@Quantity
		end

	close CompanyRests_Cursor
		deallocate CompanyRests_Cursor

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CompanyRestsWareHouse_SendQueryRests]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CompanyRestsWareHouse_SendQueryRests]( @FSRAR_Id varchar(50), @RowId uniqueidentifier OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@Content nvarchar(max)
		,@ClassId varchar(50) = 'QueryRests'
		,@ExchangeTypeCode varchar(50)
		,@UTM_Path varchar(255)
		,@Direction int = -1
		,@Status smallint = 0

	declare @TableRowId table(RowId uniqueidentifier)
		
	if isnull(@FSRAR_Id,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CompanyRestsWareHouse.SendQueryRests'                and Item=0), 'Не указан ФСРАР ИД инициатора запроса!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	
	exec bpUTM_ExchangeClass_GetDefaultType
			@ClassId
			,@ExchangeTypeCode out
 

	select @Content = '<?xml version="1.0" encoding="UTF-8"?>' + char(13) +
							'<ns:Documents Version="1.0"' + char(13) +
								'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + char(13) +
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13) +
								'xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters">' + char(13) +
									'<ns:Owner>' + char(13) +
										'<ns:FSRAR_ID>' + @FSRAR_Id + '</ns:FSRAR_ID>' + char(13) +
									'</ns:Owner>' + char(13) +
									'<ns:Document>' + char(13) +
										'<ns:QueryRests_v2></ns:QueryRests_v2>' + char(13) +
									'</ns:Document>' + char(13) +
							'</ns:Documents>' 

	if isnull(@Content,'') = ''
		begin
			return 1
		end
	else
		begin
			select @UTM_Path = udt.UTM_Path 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType udt 
			where udt.ExchangeTypeCode = @ExchangeTypeCode
				and udt.Direction = @Direction

			if isnull(@UTM_Path, '') = ''
				begin
					return 1
				end
			else
				begin
					insert into UTM_Data(
								Content
								,URL
								,CreateTime
								,Direction
								,UTM_ID
								,Status
								,ExchangeTypeCode)
							output inserted.RowId into @TableRowId 
							select
								@Content
								,u.URL + @UTM_Path
								,getdate()
								,@Direction
								,u.Id
								,@Status
								,@ExchangeTypeCode
							from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
								where u.FSRAR_Id = @FSRAR_Id
									and u.IsActive = 1
				end
		end

	select @RowId = RowId from @TableRowId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_AddEntry]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_AddEntry]( @ActionDate datetime=NULL, @ClassId varchar(50)=NULL, @ConsigneeFSRAR_Id varchar(50)=NULL, @Direction smallint=NULL, @DocumentDate datetime=NULL, @DocumentIntId int=NULL, @DocumentNumber varchar(100)=NULL, @RAR_CustNoteId int=NULL, @ReplyId varchar(50)=NULL, @RowId uniqueidentifier=NULL, @ShipperFSRAR_Id varchar(50)=NULL, @Status varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote(
						DocumentIntId
						,DocumentNumber
						,DocumentDate
						,ActionDate
						,ClassId
						,ShipperFSRAR_Id
						,ConsigneeFSRAR_Id
						,Direction
						,Status
						,ReplyId
						,RowId)
		values(
			@DocumentIntId
			,@DocumentNumber
			,@DocumentDate
			,@ActionDate
			,@ClassId
			,@ShipperFSRAR_Id
			,@ConsigneeFSRAR_Id
			,@Direction
			,@Status
			,@ReplyId
			,@RowId) 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ConfirmWayBill]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CustNote_ConfirmWayBill]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_Create_Content_ProdReceipt]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CustNote_Create_Content_ProdReceipt]( @DocumentIntId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                             declare @__r__msg varchar(1000)                                                                                                   
      


declare @DocumentTypeId nvarchar(50)
       ,@Version varchar(5)
       ,@DocumentStatus varchar(15)
       ,@Skip int = 1
       --,@DocumentIntId int
       ,@SSPQuantity decimal(16,4)
       ,@iXml xml
       ,@s nvarchar(max)
       ,@QuantTTN int
       ,@QuantMark int
       ,@TypeContent varchar(5)
	   ,@IsSingle bit = 0
	   ,@IsOldBarCode int = 0

/*select @DocumentTypeId = DocumentTypeId
      ,@DocumentStatus = Status
      ,@DocumentIntId = DocumentIntId
from Document D where D.Document_Object = @Document_Object and 
			D.DocumentDate = @DocumentDate and 
			D.DocumentNumber = @DocumentNumber

if exists(
			select top 1 1 
			from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampDocument esd
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampSet ess on ess.StampSetId = esd.StampSetId
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampSetLine esl on esl.ParentId = ess.StampSetId
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStamp es on es.StampId = esl.DescendantId
			where esd.DocumentIntId = @DocumentIntId
			  and ess.IsDisassembled = 0
			  and len(es.StampBarCode) <> 150
			  and ess.WorkSiteId in ('VodkaOldStamp', 'UVK_5'))
select @IsOldBarCode = 1

if exists(
			select top 1 1
			from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampDocument esd
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStamp es on es.StampId = esd.StampSetId
			where len(es.StampBarCode) <> 150
			  and es.IsSingle = 1
			  and esd.DocumentIntId = @DocumentIntId)
select @IsOldBarCode = 1

select top 1 @IsSingle = es.IsSingle
from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd
join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es on esd.StampSetId = es.StampId
where esd.DocumentIntId = @DocumentIntId

select @QuantTTN = alk.Quantity from AnalytLotLink alk where alk.DocumentIntId = @DocumentIntId

if(@IsSingle = 0)
	begin
		select @QuantMark = count(es.StampId) 
		from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSetLine] as esl on esl.DescendantId = es.StampId
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSet] as ess on ess.StampSetId = esl.ParentId
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] as esd on esd.StampSetId = ess.StampSetId
		join AnalytLotLink alk on alk.DocumentIntId = esd.DocumentIntId
		where alk.DocumentIntId = @DocumentIntId
		  and ess.IsDisassembled = 0
	end
else
if(@IsSingle = 1)
	begin		
		select @QuantMark = count(es.StampId) 
		from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd on esd.StampSetId = es.StampId
		where esd.DocumentIntId = @DocumentIntId 
		  and es.IsSingle & 1 = 1
	end	

if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd where esd.DocumentIntId = @DocumentIntId) and @DocumentIntId <> 19035035
begin
	  if @QuantTTN <> @QuantMark
      begin
           select @Skip = 0
           set @ErrMessageFix = 'Несоответствие количества продукции в документе '+convert(varchar(15),@QuantTTN)+' шт. с количеством отсканированных марок '+convert(varchar(15),@QuantMark)+' шт!'
           print @ErrMessageFix
           RETURN 1
      end
end

if @DocumentStatus <> 'NRICMO'
select @Skip = 0

if @IsOldBarCode = 1
select @Skip = 1

if @Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange' set @Skip = 1

if   (((@Document_Object = ('ProdReceipt') and @DocumentTypeId in ('ProductFGD', 'ProductFGN')) or @IsForceCreate=1)
  or ((@Document_Object = 'ProdReceipt' and @DocumentTypeId = 'Product') or @IsForceCreate=1)
  or (@Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange')) and @Skip = 1
begin

	declare @DocumentShippingDate varchar(50), @Shipper_ClientRegId varchar(50),
			@Consignee_ClientRegId varchar(50), 
			@SrcDocumentNumber varchar(50), @Status varchar(50),
			@CompanyId varchar(50), @CompanyName varchar(500), 
			@AddressId varchar(50), @Location varchar(500), @INN varchar(50)


if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd where esd.DocumentIntId = @DocumentIntId)
begin
	if(@IsSingle = 0)
		begin
		    update es set es.AnalytLotIntId = alk.AnalytLotIntId 
		    from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSetLine] as esl on esl.DescendantId = es.StampId
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSet] as ess on ess.StampSetId = esl.ParentId
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] as esd on esd.StampSetId = ess.StampSetId
		    join AnalytLotLink alk on alk.DocumentIntId = esd.DocumentIntId
		    where alk.DocumentIntId = @DocumentIntId
		      and ess.IsDisassembled = 0
              and es.Status = 0
		end
	else
	if(@IsSingle = 1)
		begin
			update es set es.AnalytLotIntId = alk.AnalytLotIntId
			from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd on esd.StampSetId = es.StampId
			join AnalytLotLink alk on alk.DocumentIntId = esd.DocumentIntId
			where esd.DocumentIntId = @DocumentIntId 
			  and es.IsSingle & 1 = 1
              and es.Status = 0
		end
end


    if @IsOldBarCode = 1
    begin
	   delete from EGAIS_ActChargeHeader where DocumentIntId = @DocumentIntId
	   delete from EGAIS_ActChargeLine where DocumentIntId = @DocumentIntId

	   insert into EGAIS_ActChargeHeader(FSRAR_ID, Number, ActDate, Note, DocumentIntId)
	   select @Shipper_ClientRegId, @SrcDocumentNumber, format(getdate(), 'yyyy-MM-dd'), 'OldBarCode', @DocumentIntId

	   insert into EGAIS_ActChargeLine(Position_Identity, AlcCode, Quantity, InformARegId, InformBRegId, DocumentIntId)
	   select d.Position_Identity, d.AlcCode, d.Quantity, ataa.Value, atab.Value, @DocumentIntId
	   from #DocumentLine d
	   join AnalytLotAttribute ataa on ataa.AnalytLotIntId = d.AnalytLotIntId
							 and ataa.AdditionalAttribId = 'InformARegId'
	   join AnalytLotAttribute atab on atab.AnalytLotIntId = d.AnalytLotIntId
							 and atab.AdditionalAttribId = 'InformBRegId'

	   exec bpEGAIS_Document_UpdStatusExciseStamp @Document_Object = @Document_Object, @DocumentDate = @DocumentDate, @DocumentNumber = @DocumentNumber

	   exec bpExciseStampTurnover_SetAnalytLotAttribute @Document_Object = @Document_Object, @DocumentDate = @DocumentDate, @DocumentNumber = @DocumentNumber
    end

	if @IsWriteToTable = 0
	begin
		select @DocumentIntId as DocumentIntId, '' as DocumentUnitType, 
			@DocumentShippingDate as DocumentShippingDate, @Shipper_ClientRegId as Shipper_ClientRegId,
			@Consignee_ClientRegId as Consignee_ClientRegId, '' as Tran_CAR,
			'' as Tran_Customer, '' as Tran_Driver, 
			'' as Tran_LoadPoint, '' as Tran_UnloadPoint,
			'' as Tran_Forwarder, ''  as Tran_Company
	end

	if (@IsWriteToTable = 1 and @IsOldBarCode <> 1)
	begin

		begin transaction EGAIS_DOCUMENT_Write
		
		begin try

        delete from EGAIS_Document where IntId = @DocumentIntId
        delete from EGAIS_DocumentHeader where IntId = @DocumentIntId
        delete from EGAIS_DocumentTransport where IntId = @DocumentIntId
        delete from EGAIS_DocumentLine where IntId = @DocumentIntId

		insert EGAIS_Document (IntId, DocumentIntId, WayBill_Identity, DocumentType, Direction, PrimaryDocumentIntId, [Status], SourceXML, ResponseXML, CompanyId, CompanyName,INN,AddressId,Location)
		select @DocumentIntId as IntId, @DocumentIntId, null as WayBill_Identity, 'RepProducedProduct' as DocumentType, 1 as Direction, null as PrimaryDocumentIntId, 'New' as [Status], null as SourceXML, null as ResponseXML,
			@CompanyId, @CompanyName, @INN, @AddressId, @Location
		
		insert EGAIS_DocumentHeader (IntId, DocumentNumber, DocumentDate, DocumentUnitType, DocumentShippingDate, Shipper_ClientRegId, Consignee_ClientRegId)
		select @DocumentIntId as IntId, coalesce(@SrcDocumentNumber, @DocumentNumber), convert(varchar(10), @DocumentDate, 120), ''
        ,convert(varchar(10), convert(smalldatetime, @DocumentShippingDate), 120), @Shipper_ClientRegId, @Consignee_ClientRegId
		
		insert EGAIS_DocumentTransport (Tran_CAR, Tran_COMPANY, Tran_CUSTOMER, Tran_DRIVER, Tran_FORWARDER, Tran_LOADPOINT, Tran_UNLOADPOINT, IntId)
		select '', '', '', '', '', '', '', @DocumentIntId as IntId
		
		insert EGAIS_DocumentLine (AlcCode, InformARegId, InformBRegId, OriginalQuantity, Price, Producer_ClientRegId, Quantity, RealQuantity, IntId, Position_Identity, LineNumber, BottlingDate, FSMType)
		select 
			dl.AlcCode, dl.InformARegId, dl.InformBRegId
			, dl.Quantity as OriginalQuantity, dl.Price
			, ew.ClientRegId as Producer_ClientRegId 
			, dl.Quantity, dl.Quantity as RealQuantity, @DocumentIntId as IntId
--			, row_number() OVER(ORDER BY dl.Position_Identity ASC)
			, dl.Position_Identity
			, dl.LineNumber, convert(nvarchar(50), dl.DateB), dl.FSMType
		from #DocumentLine dl
		join EGAIS_Ware ew
		  on ew.AlcCode = dl.AlcCode
		where dl.AlcCode is not null


--		select* from EGAIS_DocumentLine where IntId=@DocumentIntId

		declare @ProducedDate smalldatetime
		
		select @ProducedDate = convert(smalldatetime, at1.Value) from document d
			join analytLotLink alli on d.documentintid=alli.documentintid
			join analytLotAttribute at1 on at1.AnalytLotIntId=alli.AnalytLotIntId and at1.AdditionalAttribId='DateB'
		where d.DocumentIntId=@DocumentIntId

if @Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange'
begin
		select @ProducedDate=convert(smalldatetime, at1.Value) from document d
			join analytLotLink alli on d.documentintid=alli.documentintid
			join analytLotAttribute at1 on at1.AnalytLotIntId=alli.AnalytLotIntId and at1.AdditionalAttribId='ProdDate'
		where d.DocumentIntId=@DocumentIntId
		and alli.Direction = 1
end

		declare @SourceXML nvarchar(max), @ContentResource nvarchar(max)

if not exists(select 1 from EGAIS_DocumentLineMarkRange dm where dm.IntId = @DocumentIntId)
begin
		select @SourceXML = 
			'<?xml version="1.0"?>
			<ns:Documents Version="1.0"
				xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2"
 				xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"
				xmlns:rpp="http://fsrar.ru/WEGAIS/RepProducedProduct_v3"
				xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
 				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3"
				>
			<ns:Owner>
				<ns:FSRAR_ID>' + edh.Shipper_ClientRegId + '</ns:FSRAR_ID>
			</ns:Owner>
			<ns:Document>
				<ns:RepProducedProduct_v3>
					<rpp:Identity>' + convert(varchar(50), @DocumentIntId) + '</rpp:Identity>
						<rpp:Header>
							<rpp:Type>OperProduction</rpp:Type>
							<rpp:NUMBER>'+convert(varchar(50), edh.DocumentNumber)+'</rpp:NUMBER>
							<rpp:Date>' + convert(varchar(50), edh.DocumentShippingDate, 112) + '</rpp:Date>
							<rpp:ProducedDate>' + coalesce(convert(varchar(10), @ProducedDate, 120), convert(varchar(50), edh.DocumentShippingDate, 112)) + '</rpp:ProducedDate>
							<rpp:Producer>
 								<oref:UL>
									<oref:ClientRegId>'+edh.Shipper_ClientRegId+'</oref:ClientRegId>
									<oref:FullName>'+Shipper.FullName+'</oref:FullName>
									<oref:ShortName>'+Shipper.ShortName+'</oref:ShortName>
									<oref:INN>'+Shipper.INN+'</oref:INN>
									<oref:KPP>'+Shipper.KPP+'</oref:KPP>
									<oref:address>
										<oref:Country>'+Shipper.Country+'</oref:Country>
										<oref:RegionCode>'+Shipper.RegionCode+'</oref:RegionCode>
										<oref:description>'+Shipper.description+'</oref:description> 
									</oref:address> 
								</oref:UL> 
							</rpp:Producer> 
							<rpp:Note>Производственный отчет</rpp:Note>
						</rpp:Header>
						<rpp:Content>'
		from EGAIS_Document ed
		join EGAIS_DocumentHeader edh
  		on edh.IntId = ed.IntId
		join EGAIS_Company_2 Shipper with (NOLOCK)
  		on Shipper.ClientRegId = edh.Shipper_ClientRegId
		join EGAIS_Company_2 Consignee with (NOLOCK)
  		on Consignee.ClientRegId = edh.Consignee_ClientRegId
		join EGAIS_DocumentTransport edt
  		on edt.IntId = ed.IntId
		where ed.IntId = @DocumentIntId



		declare @AlcCode varchar(50), @Producer_ClientRegId varchar(50), @Quantity varchar(50), @Position_Identity varchar(50), @FSMType varchar(3)
		declare Walker  cursor LOCAL STATIC for
		select 
				AlcCode, (Producer_ClientRegId), 
				convert(varchar(50),(Quantity)), convert(varchar(50),(Position_Identity)), isnull(convert(varchar(3), FSMType),'')
			 from EGAIS_DocumentLine 
			where IntId = @DocumentIntId
	--	group by AlcCode

		open Walker
		fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		while @@fetch_status = 0
		begin 

		if @IsSingle = 0
		begin
		    SELECT @iXml = (
		    SELECT '<ce:amc>'+ es.StampBarCode + '</ce:amc>' + char(13)+char(10)
		    FROM [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSetLine] as esl on esl.DescendantId = es.StampId
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSet] as ess on ess.StampSetId = esl.ParentId		
		    join #DocumentLine dl on dl.AnalytLotIntId = es.AnalytLotIntId
		    where ess.IsDisassembled = 0
		    FOR XML PATH);
		end
		else
		if @IsSingle = 1
		begin
		    SELECT @iXml = (
		    SELECT '<ce:amc>'+ es.StampBarCode + '</ce:amc>' + char(13)+char(10)
		    FROM [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es	
		    join #DocumentLine dl on dl.AnalytLotIntId = es.AnalytLotIntId
		    FOR XML PATH);
		end
		
		select @s = @iXml.value('string(/)','nvarchar(max)');

			select @SourceXML = @SourceXML +
				'	<rpp:Position>
						<rpp:ProductCode>'+convert(varchar(50), @AlcCode)+'</rpp:ProductCode>
						<rpp:Quantity>'+convert(varchar(50), @Quantity)+'</rpp:Quantity>
						<rpp:Party>'+isnull(dl.PartNumber,'')+'</rpp:Party>
						<rpp:Identity>'+@Position_Identity+'</rpp:Identity>
						<rpp:Comment1>Комментарий строки</rpp:Comment1>'
			from #DocumentLine dl 
			where  dl.Position_identity = @Position_Identity

			if exists(select 1 from #DocumentLIne dl
			          join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es on es.AnalytLotIntId = dl.AnalytLotIntId)
               begin
				select @SourceXML = @SourceXML + '<rpp:MarkInfo>' + @s + '</rpp:MarkInfo>'
			   end

			select @SourceXML = @SourceXML + '</rpp:Position>'

			fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		end
		close walker
		deallocate walker

		select @SourceXML = @SourceXML + 
						'</rpp:Content>'
			
		select @ContentResource = ''
		if exists (select 1 from EGAIS_DocumentLineContentResource where IntId = @DocumentIntId)
		begin

			select @ContentResource = '<rpp:ContentResource>'
				
			select @ContentResource = @ContentResource +'
				<rpp:Resource>
					<rpp:IdentityRes>'+convert(varchar(50), CR.IdentityRes)+'</rpp:IdentityRes>
					<rpp:Product>
						<pref:UnitType>'+convert(varchar(50), W.WareType)+'</pref:UnitType>
						<pref:Type>'+case when convert(varchar(50), W.ProductVCode) = '321' then 'ССП' when convert(varchar(50), W.ProductVCode) = '020' then 'Спирт' else 'АП' end +'</pref:Type>
						<pref:FullName>'+isnull(W.FullName,'')+'</pref:FullName>
						<pref:AlcCode>'+W.AlcCode+'</pref:AlcCode> 
						'+ case when W.WareType = 'Unpacked' then '' else '<pref:Capacity>'+isnull(convert(varchar(50), W.Capacity), '0')+'</pref:Capacity>' end +'
						<pref:AlcVolume>'+convert(varchar(50), W.AlcVolume)+'</pref:AlcVolume> 
						<pref:ProductVCode>'+convert(varchar(50), W.ProductVCode)+'</pref:ProductVCode>
						<pref:Producer>
							<oref:UL>
								<oref:ClientRegId>'+convert(varchar(50), ECR.Producer_ClientRegId)+'</oref:ClientRegId>
								<oref:FullName>'+isnull(convert(varchar(255), C.FullName), '')+'</oref:FullName>
								<oref:INN>'+isnull(convert(varchar(50), C.INN), '')+'</oref:INN>
								<oref:KPP>'+isnull(convert(varchar(50), C.KPP), '')+'</oref:KPP>
								<oref:address>
									<oref:Country>'+isnull(convert(varchar(50), C.Country), '643')+'</oref:Country>
									<oref:RegionCode>'+isnull(convert(varchar(50), C.RegionCode), '')+'</oref:RegionCode>
									<oref:description>'+isnull(convert(varchar(255), C.description), '')+'</oref:description>
								</oref:address>
							</oref:UL>
						</pref:Producer>
 					</rpp:Product>' 
					+ case when CR.InformF2RegId is not null then '<rpp:RegForm2>'+isnull(convert(varchar(50), CR.InformF2RegId), '')+'</rpp:RegForm2>' else '' end +
					'<rpp:Quantity>'+Replace(isnull(convert(varchar(50), CR.Quantity),'0'), ',', '.')+'</rpp:Quantity>
 				</rpp:Resource>'
			from EGAIS_DocumentLineContentResource CR
				left join EGAIS_Ware W on W.AlcCode = CR.AlcCode
				left join EGAIS_CompanyRests ECR on ECR.AlcCode = CR.AlcCode and ECR.InformARegId = CR.InformF1RegId and ECR.InformBRegId = CR.InformF2RegId and 
						ECR.FSRAR_ID = @Consignee_ClientRegId
				left join EGAIS_Company_2 C on C.ClientRegId = ECR.Producer_ClientRegId
			where CR.IntId = @DocumentIntId

			select  @ContentResource = @ContentResource + '</rpp:ContentResource>'

		end

		select @SourceXML = @SourceXML + isnull(@ContentResource,'')


		select @SourceXML = @SourceXML + 
						'</ns:RepProducedProduct_v3>
					</ns:Document>
				</ns:Documents>
			'
        select @Version = 'v3'
end

if exists(select 1 from EGAIS_DocumentLineMarkRange dm where dm.IntId = @DocumentIntId)
begin
		select @SourceXML = 
			'<?xml version="1.0"?>
			<ns:Documents Version="1.0"
				xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2"
 				xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"
				xmlns:rpp="http://fsrar.ru/WEGAIS/RepProducedProduct"
				xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
 				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				>
			<ns:Owner>
				<ns:FSRAR_ID>' + edh.Shipper_ClientRegId + '</ns:FSRAR_ID>
			</ns:Owner>
			<ns:Document>
				<ns:RepProducedProduct>
					<rpp:Identity>' + convert(varchar(50), @DocumentIntId) + '</rpp:Identity>
						<rpp:Header>
							<rpp:Type>OperProduction</rpp:Type>
							<rpp:NUMBER>'+convert(varchar(50), edh.DocumentNumber)+'</rpp:NUMBER>
							<rpp:Date>' + convert(varchar(50), edh.DocumentShippingDate, 112) + '</rpp:Date>
							<rpp:ProducedDate>' + coalesce(convert(varchar(10), @ProducedDate, 120), convert(varchar(50), edh.DocumentShippingDate, 112)) + '</rpp:ProducedDate>
							<rpp:Producer>
 								<oref:UL>
									<oref:ClientRegId>'+edh.Shipper_ClientRegId+'</oref:ClientRegId>
									<oref:INN>'+Shipper.INN+'</oref:INN>
									<oref:KPP>'+Shipper.KPP+'</oref:KPP>
									<oref:FullName>'+Shipper.FullName+'</oref:FullName>
									<oref:ShortName>'+Shipper.ShortName+'</oref:ShortName>
									<oref:address>
										<oref:Country>'+Shipper.Country+'</oref:Country>
										<oref:RegionCode>'+Shipper.RegionCode+'</oref:RegionCode>
										<oref:description>'+Shipper.description+'</oref:description> 
									</oref:address> 
								</oref:UL> 
							</rpp:Producer>
							<rpp:Note>Производственный отчет</rpp:Note>
						</rpp:Header>
						<rpp:Content>'
		from EGAIS_Document ed
		join EGAIS_DocumentHeader edh
  		on edh.IntId = ed.IntId
		join EGAIS_Company_2 Shipper with (NOLOCK)
  		on Shipper.ClientRegId = edh.Shipper_ClientRegId
		join EGAIS_Company_2 Consignee with (NOLOCK)
  		on Consignee.ClientRegId = edh.Consignee_ClientRegId
		join EGAIS_DocumentTransport edt
  		on edt.IntId = ed.IntId
		where ed.IntId = @DocumentIntId

		

	--	declare @AlcCode varchar(50), @Producer_ClientRegId varchar(50), @Quantity varchar(50), @Position_Identity varchar(50), @FSMType varchar(3)
		declare Walker  cursor LOCAL STATIC for
		select 
				AlcCode, (Producer_ClientRegId), 
				convert(varchar(50),(Quantity)), convert(varchar(50),(Position_Identity)), isnull(convert(varchar(3), FSMType),'')
			 from EGAIS_DocumentLine 
			where IntId = @DocumentIntId
	--	group by AlcCode

		open Walker
		fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		while @@fetch_status = 0
		begin 
			
			declare @Ranges nvarchar(max), @IsRangesExists int
			select @IsRangesExists = case when exists(select 1 from EGAIS_DocumentLineMarkRange M 
														where M.IntId = @DocumentIntId and 
					  									M.Position_Identity = @Position_Identity
												) then 1
										else 0
									end

			select @Ranges = '<rpp:MarkInfo>'+
							'	<pref:Type>'+convert(varchar(3),@FSMType)+'</pref:Type>'+
							'	<pref:Ranges>'

			select @Ranges = @Ranges + '		<pref:Range>
									   				<pref:Identity>'+convert(varchar(50), M.Range_Identity)+'</pref:Identity> 
									   				<pref:Rank>'+convert(varchar(50), M.MarkRank)+'</pref:Rank> 
									   				<pref:Start>'+convert(varchar(50), M.MarkStart)+'</pref:Start> 
									   				<pref:Last>'+convert(varchar(50), M.MarkLast)+'</pref:Last> 
									   			</pref:Range>'
				from EGAIS_DocumentLineMarkRange M 
				where M.IntId = @DocumentIntId and 
					  M.Position_Identity = @Position_Identity
			
			select @Ranges = @Ranges + '	</pref:Ranges>
										 </rpp:MarkInfo>'

			
	
			select @SourceXML = @SourceXML + ''+
				'	<rpp:Position>
						<rpp:ProductCode>'+convert(varchar(50), @AlcCode)+'</rpp:ProductCode>
						<rpp:Quantity>'+convert(varchar(50), @Quantity)+'</rpp:Quantity>
						<rpp:Party>'+isnull(dl.PartNumber,'')+'</rpp:Party>
						<rpp:Identity>'+@Position_Identity+'</rpp:Identity>
						<rpp:Comment1>Комментарий строки</rpp:Comment1> 
					'+ case when @IsRangesExists = 1 then @Ranges else '' end + '
				 	</rpp:Position>'
			from #DocumentLIne dl where  dl.Position_identity = @Position_Identity
	
			fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		end
		close walker
		deallocate walker

		select @SourceXML = @SourceXML + 
						'</rpp:Content>'

			
		select @ContentResource = ''
		if exists (select 1 from EGAIS_DocumentLineContentResource where IntId = @DocumentIntId)
		begin
		
			select @ContentResource = '<rpp:ContentResource>'
				
			select @ContentResource = @ContentResource +'
				<rpp:Resource>
					<rpp:IdentityRes>'+convert(varchar(50), CR.IdentityRes)+'</rpp:IdentityRes>
					<rpp:Product>
						<pref:FullName>'+isnull(W.FullName,'')+'</pref:FullName>
						<pref:AlcCode>'+W.AlcCode+'</pref:AlcCode> 
						'+ case when W.WareType = 'Unpacked' then '' else '<pref:Capacity>'+isnull(convert(varchar(50), W.Capacity), '0')+'</pref:Capacity>' end +'
						<pref:UnitType>'+convert(varchar(50), W.WareType)+'</pref:UnitType>
						<pref:AlcVolume>'+convert(varchar(50), W.AlcVolume)+'</pref:AlcVolume> 
						<pref:ProductVCode>'+convert(varchar(50), W.ProductVCode)+'</pref:ProductVCode>
						<pref:Producer>
							<oref:UL>
								<oref:ClientRegId>'+convert(varchar(50), ECR.Producer_ClientRegId)+'</oref:ClientRegId>
								<oref:INN>'+isnull(convert(varchar(50), C.INN), '')+'</oref:INN>
								<oref:KPP>'+isnull(convert(varchar(50), C.KPP), '')+'</oref:KPP>
								<oref:FullName>'+isnull(convert(varchar(255), C.FullName), '')+'</oref:FullName>
								<oref:ShortName>'+isnull(convert(varchar(255), C.ShortName), '')+'</oref:ShortName>
								<oref:address>
									<oref:Country>'+isnull(convert(varchar(50), C.Country), '643')+'</oref:Country>
									<oref:RegionCode>'+isnull(convert(varchar(50), C.RegionCode), '')+'</oref:RegionCode>
									<oref:description>'+isnull(convert(varchar(255), C.description), '')+'</oref:description>
								</oref:address>
							</oref:UL>
						</pref:Producer>
 					</rpp:Product>
					' + case when CR.InformF2RegId is not null then '<rpp:RegForm2>'+isnull(convert(varchar(50), CR.InformF2RegId), '')+'</rpp:RegForm2>' else '' end +'
					<rpp:Quantity>'+Replace(isnull(convert(varchar(50), CR.Quantity),'0'), ',', '.')+'</rpp:Quantity>
 				</rpp:Resource>'
			from EGAIS_DocumentLineContentResource CR
				left join EGAIS_Ware W on W.AlcCode = CR.AlcCode
				left join EGAIS_CompanyRests ECR on ECR.AlcCode = CR.AlcCode and ECR.InformARegId = CR.InformF1RegId and ECR.InformBRegId = CR.InformF2RegId and 
						ECR.FSRAR_ID = @Consignee_ClientRegId
				left join EGAIS_Company_2 C on C.ClientRegId = ECR.Producer_ClientRegId
			where CR.IntId = @DocumentIntId

			select  @ContentResource = @ContentResource + '</rpp:ContentResource>'

		end

		select @SourceXML = @SourceXML + isnull(@ContentResource,'')


		select @SourceXML = @SourceXML + 
						'</ns:RepProducedProduct>
					</ns:Document>
				</ns:Documents>
			'
        select @Version = 'v2' 
end

		update EGAIS_Document set
			SourceXML = @SourceXML
           ,Version = @Version
		where IntId = @DocumentIntId

		end try	

		begin catch


 			SELECT 
        		ERROR_NUMBER() AS ErrorNumber
        		,ERROR_SEVERITY() AS ErrorSeverity
        		,ERROR_STATE() AS ErrorState
        		,ERROR_PROCEDURE() AS ErrorProcedure
        		,ERROR_LINE() AS ErrorLine
        		,ERROR_MESSAGE() AS ErrorMessage;

			if @@trancount>0
				rollback tran EGAIS_DOCUMENT_Write

		end catch

		if @@trancount>0
			commit tran EGAIS_DOCUMENT_Write

	end
		
	
end*/


GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_CreateContent_ActWriteOff]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CustNote_CreateContent_ActWriteOff]( @RAR_CustNoteId int=NULL, @ExchangeTypeCode varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_CreateContent_Despatch]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_CreateContent_Despatch]( @RAR_CustNoteId int=NULL, @ExchangeTypeCode varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

set CONCAT_NULL_YIELDS_NULL on
set ANSI_WARNINGS on
set ANSI_PADDING on


	declare 
		@NDS decimal(16,2) = '1.20'
	   ,@IsX5 int = 0   
	   ,@Skip int = 0
	   ,@Type varchar(15)
	   ,@SourceXML nvarchar(max)
	   ,@SourceXMLMarkInfoPallet varchar(max) = ''
	   ,@SourceXMLBoxInfoPallet varchar(max) = ''
	   ,@CursorMarkInfoPallet cursor
	   ,@CursorBoxInfoPallet cursor
	   ,@StampSetBarCode varchar(500)
	   ,@StampBarCode varchar(500)
	   ,@PartNumber varchar(15)
	   ,@Pack_ID varchar(100)
	   ,@iXml xml
	   ,@DocumentIntId int
	   ,@Document_Object varchar(50)
	   ,@DocumentTypeId	varchar(15)
	   ,@AlcCode varchar(50)
	   ,@InformARegId varchar(50)
	   ,@InformBRegId varchar(50)
	   ,@Price varchar(50)
	   ,@Producer_ClientRegId varchar(50)
	   ,@Quantity varchar(50)
	   ,@Position_Identity int
	   ,@AnalytLotIntId int
	   ,@EAN_13 varchar(50)
	   ,@RowId uniqueidentifier	 

	declare @SrcAnalytLotSet table (AnalytLotIntId int)


	select 
		@DocumentIntId = rc.DocumentIntId
		,@Document_Object = d.Document_Object
		,@DocumentTypeId = d.DocumentTypeId
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote rc
		join mch.dbo.Document d
			on d.DocumentIntId = rc.DocumentIntId
	where rc.RAR_CustNoteId = @RAR_CustNoteId

	declare @WBType varchar(64) = 'WBInvoiceFromMe'

	if @Document_Object = 'VendReturn' and @DocumentTypeId = 'InterCompany'
		select @WBType = 'WBReturnFromMe'


	-- смена собственника продукции при отгрузке
	declare @ChangeOwnership varchar(64)
	select @ChangeOwnership = EgaisExchange.dbo.bpRAR_CustNoteChangeOwnership_GetChangeOwnership(@RAR_CustNoteId, 0)

	if exists(select 1
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
					join mch.dbo.Document d
						on d.DocumentIntId = cn.DocumentIntId
					join mch.dbo.Company c
						on c.CompanyId = d.CompanyId
					join mch.dbo.CompanyGroup cg 
						on cg.Companyid = c.Companyid
				where cn.RAR_CustNoteId = @RAR_CustNoteId 
					and (cg.CompanyGroupName like '%х5%' or cg.CompanyGroupName like '%x5%'))
		begin
			select @IsX5 = 1
		end
		
	
	if exists(select 1 
				from mch.dbo.Document d 
					join mch.dbo.TreeRef tr 
						on tr.ElementId = d.CompanyId 
							and tr.Tree_Object = 'CompanyTree' 
							and tr.TreeClassId = 'CompanyType' 
							and tr.TreeId = 'CustLowCoster'
				where d.DocumentIntId = @DocumentIntId) 
		or exists(select 1 
					from mch.dbo.Document d 
						join mch.dbo.TreeRef tr 
							on tr.ElementId = d.CompanyId 
								and tr.Tree_Object = 'CompanyTree' 
								and tr.TreeClassId = 'Maclay'
					where d.DocumentIntId = @DocumentIntId)
			begin
				set @NDS = '1'
			end

		;with Stamp(Pallet, Box, StampBarCode, AnalytLotIntId)
		as
		(
			select ess2.StampSetBarCode, ess.StampSetBarCode, es.StampBarCode, es.AnalytLotIntId
				from mch.dbo.ExciseStampTurnover est
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet ess2 on ess2.StampSetBarCode = est.BarCode
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl2 on esl2.ParentId = ess2.StampSetId
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet ess on ess.StampSetId = esl2.DescendantId
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl on esl.ParentId = ess.StampSetId
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es on es.StampId = esl.DescendantId
				where est.DocumentIntId = @DocumentIntId
			union all
			select null, ess.StampSetBarCode, es.StampBarCode, es.AnalytLotIntId
				from mch.dbo.ExciseStampTurnover est
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet ess on ess.StampSetBarCode = est.BarCode
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl on esl.ParentId = ess.StampSetId
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es on es.StampId = esl.DescendantId
				where est.DocumentIntId = @DocumentIntId
					and ess.IsPallet = 0
			union all 
			select null, null, es.StampBarCode, es.AnalytLotIntId
				from mch.dbo.ExciseStampTurnover est
					join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es on es.StampBarCode = est.BarCode
				where est.DocumentIntId = @DocumentIntId
		)
		select * 
			into #Stamp
		from Stamp

		insert @SrcAnalytLotSet
			select distinct alk.AnalytLotIntId
		from mch.dbo.AnalytLotLink alk
			where alk.DocumentIntId = @DocumentIntId


		update dc
			set dc.AnalytLotIntId = sas.AnalytLotIntId
		from #Stamp dc
			join mch.dbo.AnalytLotTrace alt 
				on alt.DstAnalytLotIntId = dc.AnalytLotIntId
					and alt.TraceLevel = 1
			join @SrcAnalytLotSet sas 
				on sas.AnalytLotIntId = alt.SrcAnalytLotIntId
		where dc.AnalytLotIntId is not null

		-- пространства имен для версии типа обмена с ЕГАИС
		declare @Namespace nvarchar(max)
		select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)

		if(isnull(@ExchangeTypeCode, '') <> '')
			begin
				
				select @SourceXML = 
								'<ns:Documents Version="1.0"' + char(13) + char(10) +
									@Namespace + ' >' + 
							   '<ns:Owner>' + char(13) + char(10) +
									'<ns:FSRAR_ID>' + isnull(shipper.FSRAR_Id, '') + '</ns:FSRAR_ID>' + char(13) + char(10) +
							   '</ns:Owner>' + char(13) + char(10) +
							   '<ns:Document>' + char(13) + char(10) +
									'<ns:' + @ExchangeTypeCode + '>' + char(13) + char(10) +
										'<wb:Identity>' + convert(varchar(15), rc.RAR_CustNoteId) + '</wb:Identity>' + char(13) + char(10) +
										'<wb:Header>' + char(13) + char(10) +
											'<wb:NUMBER>' + isnull(rc.DocumentNumber, '') + '</wb:NUMBER>' + char(13) + char(10) +
											'<wb:Date>' + convert(varchar(50), isnull(rc.ActionDate, ''), 23) + '</wb:Date>' + char(13) + char(10) +
											'<wb:ShippingDate>' + convert(varchar(50), isnull(rc.ActionDate, ''), 23) + '</wb:ShippingDate>' + char(13) + char(10) +
											'<wb:Type>' + isnull(@WBType, '') + '</wb:Type>' + char(13) + char(10) +
											'<wb:Shipper>' + char(13) + char(10) +
												'<oref:UL>' + char(13) + char(10) +
													'<oref:INN>' + isnull(shipper.TaxCode, '') + '</oref:INN>' + char(13) + char(10) +
													'<oref:KPP>' + isnull(shipper.TaxReason, '') + '</oref:KPP>' + char(13) + char(10) +
													'<oref:ClientRegId>' + isnull(shipper.FSRAR_Id, '') + '</oref:ClientRegId>' + char(13) + char(10) +
													'<oref:FullName>' + isnull(shipper.FullName, '') + '</oref:FullName>' + char(13) + char(10) +
													'<oref:ShortName>' + convert(varchar(64), isnull(shipper.ShortName, '')) + '</oref:ShortName>' + char(13) + char(10) +
													'<oref:address>' + char(13) + char(10) +
														'<oref:Country>' + isnull(shipper.CountryCode, '') + '</oref:Country>' + char(13) + char(10) +
														'<oref:RegionCode>' + isnull(shipper.RegionCode, '') + '</oref:RegionCode>' + char(13) + char(10) +
														'<oref:description>' + isnull(shipper.[Location], '') + '</oref:description>' + char(13) + char(10) +
													 '</oref:address>' + char(13) + char(10) +
												'</oref:UL>' + char(13) + char(10) +
											'</wb:Shipper>' + char(13) + char(10) +
											'<wb:Consignee>' + char(13) + char(10) +	 				
		       									+ case when isnull(consignee.TaxReason, '') <> '' then 
		       									'<oref:UL>'	+ char(13) + char(10) 
		       										+ case when isnull(consignee.TaxCode, '') != '' then
		       										'<oref:INN>' + isnull(consignee.TaxCode, '') + '</oref:INN>' else '' end 
		       										+ case when len(ltrim(rtrim(isnull(consignee.TaxCode, '')))) = 12 then '' 
		       										when isnull(consignee.TaxReason, '') != '' then  '<oref:KPP>' + isnull(consignee.TaxReason, '') + '</oref:KPP>' else '' end + 
		       										'<oref:ClientRegId>' + isnull(consignee.FSRAR_Id, '') + '</oref:ClientRegId>'	+ char(13) + char(10) +	
		       										'<oref:FullName>' + isnull(replace(Consignee.FullName, '&', '&amp;'), '') + '</oref:FullName>'	+ char(13) + char(10) +	
		       										'<oref:ShortName>' + convert(varchar(64), isnull(replace(Consignee.ShortName, '&', '&amp;'), '')) + '</oref:ShortName>'	+ char(13) + char(10) +	
		       										'<oref:address>' + char(13) + char(10) +	
		       											'<oref:Country>' + isnull(consignee.CountryCode, '') + '</oref:Country>' + case when isnull(consignee.RegionCode, '') != '' then 
		       											'<oref:RegionCode>' + isnull(consignee.RegionCode, '') + '</oref:RegionCode>' else '' end +
		       											'<oref:description>' + isnull(consignee.[Location], '') + '</oref:description>' + char(13) + char(10) +	
		       										'</oref:address>' + char(13) + char(10) +	
		       									'</oref:UL>' + char(13) + char(10)	       
												when (isnull(consignee.CountryCode, '643') <> '643') then 
												'<oref:TS>' + char(13) + char(10) +
													'<oref:TSNUM>' + isnull(consignee.FSRAR_Id, '') + '</oref:TSNUM>' + char(13) + char(10) +
													'<oref:FullName>' + isnull(replace(Consignee.FullName, '&', '&amp;'), '') + '</oref:FullName>' + char(13) + char(10) +
													'<oref:ShortName>' + convert(varchar(64), isnull(replace(Consignee.ShortName, '&', '&amp;'), '')) + '</oref:ShortName>' + char(13) + char(10) +
													'<oref:ClientRegId>' + consignee.FSRAR_Id + '</oref:ClientRegId>' + char(13) + char(10) +
													'<oref:address>' + char(13) + char(10) +
			     										'<oref:Country>' + isnull(consignee.CountryCode, '') + '</oref:Country>' + char(13) + char(10) + 
			     										'<oref:description>' + isnull(consignee.[Location], '') + '</oref:description>' + char(13) + char(10) +
													'</oref:address>' + char(13) + char(10) +
												'</oref:TS>' + char(13) + char(10) 
												else
												'<oref:FL>' + char(13) + char(10)
												+ case when isnull(consignee.TaxReason, '') = '' then
													'<oref:INN>' + isnull(consignee.TaxCode, '') + '</oref:INN>' else '' end 
												+ case when len(ltrim(rtrim(isnull(consignee.TaxCode, '')))) = 12 then '' 
			     							   when isnull(consignee.TaxReason, '') != '' then  '<oref:KPP>' + isnull(consignee.TaxReason, '') + '</oref:KPP>' else '' end + 
													'<oref:ClientRegId>' + isnull(consignee.FSRAR_Id, '') + '</oref:ClientRegId>' + char(13) + char(10) +
													'<oref:FullName>' + isnull(replace(Consignee.FullName, '&', '&amp;'), '') + '</oref:FullName>' + char(13) + char(10) +
													'<oref:ShortName>' + convert(varchar(64), isnull(replace(Consignee.ShortName, '&', '&amp;'), '')) + '</oref:ShortName>' + char(13) + char(10) +
													'<oref:address>' + char(13) + char(10) +
			     										'<oref:Country>' + isnull(consignee.CountryCode, '') + '</oref:Country>' + case when isnull(Consignee.RegionCode, '') != '' then 
			     										'<oref:RegionCode>' + isnull(Consignee.RegionCode, '') + '</oref:RegionCode>' else '' end +
			     										'<oref:description>' + isnull(consignee.[Location], '') + '</oref:description>' + char(13) + char(10) +
													'</oref:address>' + char(13) + char(10) +
												'</oref:FL>' + char(13) + char(10)
												end + '</wb:Consignee>' + char(13) + char(10) +
												'<wb:Transport>' + char(13) + char(10) +
													'<wb:TRAN_TYPE>413</wb:TRAN_TYPE>' + char(13) + char(10) +
													case
														when @ExchangeTypeCode = 'WayBill_v4' then
													'<wb:ChangeOwnership>' + isnull(@ChangeOwnership, '') + '</wb:ChangeOwnership>'
													else '' end + char(13) + char(10) +
													'<wb:TRAN_COMPANY>' + isnull(cnt.Company, '') + '</wb:TRAN_COMPANY>' + char(13) + char(10) +
													'<wb:TRAN_CAR>' + isnull(cnt.Car, '') + '</wb:TRAN_CAR>' + char(13) + char(10) +
													'<wb:TRAN_TRAILER></wb:TRAN_TRAILER>' + char(13) + char(10) +
													'<wb:TRAN_CUSTOMER>' + isnull(replace(cnt.Customer, '&', '&amp;'), '') + '</wb:TRAN_CUSTOMER>' + char(13) + char(10) +
													'<wb:TRAN_DRIVER>' + isnull(cnt.Driver, '') + '</wb:TRAN_DRIVER>' + char(13) + char(10) +
													'<wb:TRAN_LOADPOINT>' + isnull(cnt.LoadPoint, '') + '</wb:TRAN_LOADPOINT>' + char(13) + char(10) +
													'<wb:TRAN_UNLOADPOINT>' + isnull(cnt.UnloadPoint, '') + '</wb:TRAN_UNLOADPOINT>' + char(13) + char(10) +
													'<wb:TRAN_REDIRECT></wb:TRAN_REDIRECT>' + char(13) + char(10) +
													'<wb:TRAN_FORWARDER>' + isnull(cnt.Forwarder, '') + '</wb:TRAN_FORWARDER>' + char(13) + char(10) +
											  '</wb:Transport>' + char(13) + char(10) +
											  '<wb:Base></wb:Base>' + char(13) + char(10) +
											  '<wb:Note></wb:Note>' + char(13) + char(10) +
										'</wb:Header>' + char(13) + char(10) +
								   '<wb:Content>' + char(13) + char(10) 
							from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote rc
								join mch.dbo.Document d
									on d.DocumentIntId = rc.DocumentIntId
								join mch.dbo.CustNote cn 
									on cn.CustNote_Object = d.Document_Object
										and cn.CustNoteDate = d.DocumentDate
										and cn.CustNoteNumber = d.DocumentNumber
								join mch.dbo.DocumentEx de
									on de.DocumentIntId = d.DocumentIntId								
								left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company shipper
									on shipper.FSRAR_Id = rc.ShipperFSRAR_Id
										and shipper.FSRAR_Id is not null
								left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company consignee 
									on consignee.FSRAR_Id = rc.ConsigneeFSRAR_Id 
										and consignee.FSRAR_Id is not null
								left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteTransport cnt
									on cnt.RAR_CustNoteId = rc.RAR_CustNoteId 									
							where rc.RAR_CustNoteId = @RAR_CustNoteId

				declare Walker_v2  cursor LOCAL STATIC for
					select distinct 
								cnl.AlcCode
								,cnl.InformProduction
								,cnl.InformMotion
								,ltrim(rtrim(str(max(round(cnl.Price * @NDS, 2)), 16, 2)))
								,max(w.FSRAR_Id) 
								,convert(varchar(50), sum(cnl.Quantity))
								,min(cnl.Position_Identity)
								,case when @Document_Object = 'Despatch' and @DocumentTypeId = 'ProductCurrency' then null else cnl.AnalytLotIntId end
						 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware w
								on w.AlcCode = cnl.AlcCode 
					where cnl.RAR_CustNoteId = @RAR_CustNoteId
						group by cnl.AlcCode, cnl.InformProduction, cnl.InformMotion, case when @Document_Object = 'Despatch' and @DocumentTypeId = 'ProductCurrency' then null else cnl.AnalytLotIntId end
					order by 7
			
				select @Position_Identity = 0

				open Walker_v2
					fetch next from Walker_v2 into @AlcCode, @InformARegId, @InformBRegId, @Price, @Producer_ClientRegId, @Quantity, @Position_Identity, @AnalytLotIntId
				while @@fetch_status = 0
					begin

						select @Pack_id = 'Марка'
							from #Stamp s
						where s.Box is null
							and s.AnalytLotIntId = @AnalytLotIntId

	   					select @Pack_id = 'Упаковка'
							from #Stamp s
						where s.Pallet is null
							and s.AnalytLotIntId = @AnalytLotIntId
		
						select @Pack_id = 'Паллета'
							from #Stamp s
						where s.AnalytLotIntId = @AnalytLotIntId
							 and s.Pallet is not null

						if exists(select 1 from #Stamp s where s.AnalytLotIntId = @AnalytLotIntId)
							begin

								select @SourceXMLMarkInfoPallet = @SourceXMLMarkInfoPallet + '<ce:MarkInfo>' + char(13) + char(10) 

								--марки
								if exists(select 1 from #Stamp s where s.AnalytLotIntId = @AnalytLotIntid and s.Box is null)
									begin

										set @CursorMarkInfoPallet = cursor scroll for
											select distinct s.StampBarCode
												from #Stamp s
											where s.AnalytLotIntId = @AnalytLotIntid
												and s.Box is null
												
										select @SourceXMLMarkInfoPallet = @SourceXMLMarkInfoPallet + '<ce:boxpos><ce:amclist>' + char(13) + char(10) 

										open @CursorMarkInfoPallet
											fetch next from @CursorMarkInfoPallet into @StampSetBarCode

										while @@fetch_status = 0
											begin 
												 select @iXml = (
													select distinct '<ce:amc>'+ s.StampBarCode + '</ce:amc>' + char(13) + char(10) 
														from #Stamp s
													 where s.StampBarCode = @StampSetBarCode
														and s.Box is null
													FOR XML PATH);

												   select @SourceXMLMarkInfoPallet = @SourceXMLMarkInfoPallet + @iXml.value('string(/)','nvarchar(max)')
														fetch next from @CursorMarkInfoPallet into @StampSetBarCode
											end

										close @CursorMarkInfoPallet
											deallocate @CursorMarkInfoPallet

										select @SourceXMLMarkInfoPallet = @SourceXMLMarkInfoPallet+'</ce:amclist></ce:boxpos>' + char(13) + char(10) 

									end

									--короб-марки
									if exists(select 1 from #Stamp s where s.AnalytLotIntId = @AnalytLotIntid and s.box is not null)
										begin 
												
											set @CursorMarkInfoPallet = cursor scroll for
												select distinct s.Box
													from #Stamp s
											where s.AnalytLotIntId = @AnalytLotIntid
												and s.Box is not null

											open @CursorMarkInfoPallet
												fetch next from @CursorMarkInfoPallet into @StampSetBarCode

											while @@fetch_status = 0
												begin

													  select @SourceXMLMarkInfoPallet = @SourceXMLMarkInfoPallet + '<ce:boxpos>' + char(13) + char(10) +
															'<ce:boxnumber>'+@StampSetBarCode + '</ce:boxnumber>' + char(13) + char(10) +
															'<ce:amclist>'
													  select @iXml = (
														  select distinct '<ce:amc>' + s.StampBarCode + '</ce:amc>' + char(13) + char(10) 
															  from #Stamp s
																	where s.Box = @StampSetBarCode
																		and s.AnalytLotIntId = @AnalytLotIntId
														FOR XML PATH);

														select @SourceXMLMarkInfoPallet = @SourceXMLMarkInfoPallet + @iXml.value('string(/)','nvarchar(max)') + '</ce:amclist>' + char(13) + char(10) +
															'</ce:boxpos>' + char(13) + char(10)  

													fetch next from @CursorMarkInfoPallet into @StampSetBarCode

												end

											close @CursorMarkInfoPallet
												deallocate @CursorMarkInfoPallet

										end

										select @SourceXMLMarkInfoPallet = @SourceXMLMarkInfoPallet + '</ce:MarkInfo>' + char(13) + char(10) 


										if exists(select 1 from #Stamp s where s.AnalytLotIntId = @AnalytLotIntid and s.Box is not null)
											begin
												select @SourceXMLBoxInfoPallet = @SourceXMLBoxInfoPallet + '<wb:boxInfo>' + char(13) + char(10) 

												--поддон-короб
												if exists(select 1 from #Stamp s where s.AnalytLotIntId = @AnalytLotIntid and s.Pallet is not null)
													begin

														set @CursorBoxInfoPallet  = cursor scroll for
															select distinct s.Pallet
																from #Stamp s
															where s.AnalytLotIntId = @AnalytLotIntId
																and s.Pallet is not null

														open @CursorBoxInfoPallet
															fetch next from @CursorBoxInfoPallet into @StampSetBarCode
		
														while @@fetch_status = 0
															begin
																select @SourceXMLBoxInfoPallet = @SourceXMLBoxInfoPallet + 
																		'<wb:boxtree>' + char(13) + char(10) +
																		'<ce:boxnum>' + @StampSetBarCode + '</ce:boxnum>' + char(13) + char(10) +
																		'<ce:bl>' + char(13) + char(10) 
																SELECT @iXml = (
																	select distinct '<ce:boxnum>' + s.Box+'</ce:boxnum>' + char(13) + char(10) 
																		 from #Stamp s
																	where s.Pallet = @StampSetBarCode
																		 and s.AnalytLotIntId = @AnalytLotIntId
																FOR XML PATH);

																select @SourceXMLBoxInfoPallet = @SourceXMLBoxInfoPallet + @iXml.value('string(/)','nvarchar(max)') + '</ce:bl>' + char(13) + char(10) +
																		'</wb:boxtree>' + char(13) + char(10)

																fetch next from @CursorBoxInfoPallet into @StampSetBarCode

															end

														close @CursorBoxInfoPallet

													end

												--короб
												if exists(select 1 from #Stamp s where s.AnalytLotIntId = @AnalytLotIntid and s.Pallet is null)
													begin
												
														set @CursorBoxInfoPallet  = cursor scroll for 
															select distinct s.Box
																from #Stamp s
															where s.AnalytLotIntId = @AnalytLotIntId
																and s.Pallet is null
																and s.Box is not null
	
														open @CursorBoxInfoPallet
															fetch next from @CursorBoxInfoPallet into @StampSetBarCode
			
														while @@fetch_status = 0
															begin
																select distinct @SourceXMLBoxInfoPallet = @SourceXMLBoxInfoPallet + 
																	'<wb:boxtree>' + char(13) + char(10) +
																	'<ce:boxnum>'+@StampSetBarCode+'</ce:boxnum>' + char(13) + char(10) 
																from #Stamp s
																	 where s.Box = @StampSetBarCode
																		and s.AnalytLotIntId = @AnalytLotIntId
	
																select @SourceXMLBoxInfoPallet = @SourceXMLBoxInfoPallet + '</wb:boxtree>' + char(13) + char(10)
													 
																fetch next from @CursorBoxInfoPallet into @StampSetBarCode
	
															end
	
														close @CursorBoxInfoPallet											
	
													end 
	
													select @SourceXMLBoxInfoPallet = @SourceXMLBoxInfoPallet + '</wb:boxInfo>' + char(13) + char(10)
											 	
											end

							end

							if(@IsX5 = 1)
								begin

									select @EAN_13 = wd.BarCode 
										from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
											join mch.dbo.Document d
												on d.DocumentIntId = cn.DocumentIntId
											join mch.dbo.AnalytLotLink alk
												on alk.DocumentIntId = d.DocumentIntId
											join mch.dbo.CustNoteLine cnl
												on cnl.CustNote_Object = d.Document_Object
													and cnl.CustNoteNumber = d.DocumentNumber
													and cnl.CustNoteDate = d.DocumentDate
													and cnl.LineNumber = alk.LineNumber
											join mch.dbo.Ware w with(NOLOCK) 
												on w.WareId = cnl.WareId 
													and w.IsLotControl = 1
											left join mch.dbo.ClassAdditionalAttrib caa with(NOLOCK) 
												on caa.AdditionalAttribId = 'WARE_EGAIS' 
													and caa.Class_Object='Ware' 
													and caa.ClassId = w.WareId
											left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw with(NOLOCK) 
												on rw.AlcCode = ltrim(rtrim(caa.Value))
											left join mch.dbo.Unit u with(NOLOCK) 
												on u.UnitId = cnl.UnitId
											left join mch.dbo.WareDespatchUnit wd 
												on wd.WareId = w.WareId
												   and wd.UnitId = u.UnitId
									where cn.RAR_CustNoteId = @RAR_CustNoteId
										and alk.Direction = -1
										and rw.AlcCode = @AlcCode
										and cnl.LineNumber = @Position_Identity

								end

								select @SourceXML = @SourceXML +
														'<wb:Position>' + char(13) + char(10) +
															  '<wb:Identity>' + isnull(convert(nvarchar(50), @Position_Identity), '') + '</wb:Identity>' + char(13) + char(10) +
															  '<wb:Product>' + char(13) + char(10) +
																'<pref:Type>' + case when convert(varchar(50), w.AlcTypeCode) = '321' then 'ССП' else 'АП' end +'</pref:Type>' + char(13) + char(10) +
																'<pref:FullName>' + isnull(w.WareName, '') + '</pref:FullName>' + char(13) + char(10) +
																'<pref:ShortName>' + convert(varchar(64), isnull(w.WareName, '')) + '</pref:ShortName>' + char(13) + char(10) +
																'<pref:AlcCode>' + isnull(@AlcCode, '') + '</pref:AlcCode>' + char(13) + char(10) +
																case when w.UnitType = 'Packed' then '<pref:Capacity>' + isnull(convert(nvarchar(50), w.Capacity), '') + '</pref:Capacity>' else '' end +
																'<pref:AlcVolume>' + isnull(convert(nvarchar(50), w.AlcVolume), '') + '</pref:AlcVolume>' + char(13) + char(10) +
																'<pref:ProductVCode>' + isnull(w.AlcTypeCode, '') + '</pref:ProductVCode>' + char(13) + char(10) +
																'<pref:UnitType>' + isnull(w.UnitType, '') + '</pref:UnitType>' + char(13) + char(10) +
																'<pref:Producer>' + char(13) + char(10) +
																case when isnull(Producer.CountryCode, '') <> '643' then
																'<oref:TS>' + char(13) + char(10) 
																else	
																'<oref:UL>' + char(13) + char(10) 
																end +
																  '<oref:ClientRegId>' + isnull(@Producer_ClientRegId, '') + '</oref:ClientRegId>' + char(13) + char(10) +
																  '<oref:FullName>' + isnull(Producer.FullName, '') + '</oref:FullName>' + char(13) + char(10) +
																  '<oref:ShortName>' + isnull(Producer.ShortName, '') + '</oref:ShortName>' + char(13) + char(10) +
																	case when isnull(Producer.TaxCode, '') <> '' then								
																  '<oref:INN>' + isnull(Producer.TaxCode, '') + '</oref:INN>' + char(13) + char(10) 
																	else '' end +
																	case when isnull(Producer.TaxReason, '') <> '' then
																  '<oref:KPP>' + isnull(Producer.TaxReason, '') + '</oref:KPP>' + char(13) + char(10) 
																	else '' end +
																  '<oref:address>' + char(13) + char(10) +
																	'<oref:Country>' + isnull(Producer.CountryCode, '') + '</oref:Country>' + char(13) + char(10) +
																	case when isnull(Producer.RegionCode, '') <> '' then
																	'<oref:RegionCode>' + isnull(Producer.RegionCode, '') + '</oref:RegionCode>' + char(13) + char(10) 
																	else '' end +
																	'<oref:description>' + isnull(Producer.[Location], '') + '</oref:description>' + char(13) + char(10) +
																  '</oref:address>' + char(13) + char(10) +	
																case when isnull(Producer.CountryCode, '') <> '643' then
																'</oref:TS>' + char(13) + char(10) 
																else	
																'</oref:UL>' + char(13) + char(10) 
																end +
																'</pref:Producer>' + char(13) + char(10) +
															  '</wb:Product>' + case when @EAN_13 is not null and @IsX5 = 1 then
															  '<wb:EAN13>' + isnull(substring(@EAN_13, 1, 12), '') + '</wb:EAN13>' else '' end +
															  '<wb:Quantity>' + isnull(convert(nvarchar(50), @Quantity), '') + '</wb:Quantity>' + char(13) + char(10) +
															  '<wb:Price>' + isnull(convert(nvarchar(50), @Price), '') + '</wb:Price>' + char(13) + char(10) +
															  '<wb:Pack_ID>' + isnull(@Pack_ID, 'pack') + '</wb:Pack_ID>' + char(13) + char(10) +
															  '<wb:Party>' + isnull(convert(varchar(15),@AnalytLotIntId), 'party') + '</wb:Party>' + char(13) + char(10) +
															  '<wb:FARegId>' + isnull(@InformARegId, '') + '</wb:FARegId>' + char(13) + char(10) +
															  '<wb:InformF2>' + char(13) + char(10) +
																'<ce:F2RegId>' + isnull(@InformBRegId, '') + '</ce:F2RegId>' + char(13) + char(10) +
														  		isnull(@SourceXMLMarkInfoPallet, '') + 																	
															'</wb:InformF2>' + char(13) + char(10) +
														  		isnull(@SourceXMLBoxInfoPallet, '') +
															'</wb:Position>' + char(13) + char(10)
										from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company Producer
												join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware w
	  												on w.AlcCode = @AlcCode
											where Producer.FSRAR_Id = @Producer_ClientRegId 
												and Producer.[Status] = 'Active'
 
									select 
										@Position_Identity = 0
										,@SourceXMLMarkInfoPallet = ''
										,@SourceXMLBoxInfoPallet = ''


						fetch next from Walker_v2 into @AlcCode, @InformARegId, @InformBRegId, @Price, @Producer_ClientRegId, @Quantity, @Position_Identity, @AnalytLotIntId

					end
					
					close Walker_v2 
					deallocate Walker_v2

					select @SourceXML = @SourceXML + 
											  '</wb:Content>' + char(13) + char(10) +
											 '</ns:' + @ExchangeTypeCode + '>' + char(13) + char(10) +
										   '</ns:Document>' + char(13) + char(10) +
										 '</ns:Documents>'	

			end

			begin try
				begin transaction
					
					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_Insert
								@RAR_CustNoteId
								,@SourceXML
								,@ExchangeTypeCode
								,@RowId out

					declare @Status varchar(50)					

					if(@RowId is not null)
						set @Status = 'Ready'
					else
						set @Status = 'New'

					update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
						set
							Status = @Status
							,RowId = @RowId
					where RAR_CustNoteId = @RAR_CustNoteId
								
				commit transaction
			end try
			begin catch
				rollback transaction

				-- Логирование -------------------------------------------
				declare
					@ErrorNumber int = ERROR_NUMBER()
					,@ErrorSeverity int = ERROR_SEVERITY()
					,@ErrorState int = ERROR_STATE()
					,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE()
					,@ErrorLine int = ERROR_LINE()
					,@ErrorMessage nvarchar(256) = ERROR_MESSAGE()
					,@Method nvarchar(128) = object_name(@@ProcId)
	
				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_ExceptionLog
							@ObjectId = @RAR_CustNoteId
							,@RowId = NULL
							,@Operation = 'createXMLContent'
							,@Method = @Method
							,@ErrorNumber = @ErrorNumber
							,@ErrorSeverity = @ErrorSeverity
							,@ErrorState = @ErrorState
							,@ErrorProcedure = @ErrorProcedure
							,@ErrorLine = @ErrorLine
							,@ErrorMessage = @ErrorMessage				 
			end catch	
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_CreateContent_ProdReceipt]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_CreateContent_ProdReceipt]( @RAR_CustNoteId int, @ExchangeTypeCode varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

set CONCAT_NULL_YIELDS_NULL on
set ANSI_WARNINGS on
set ANSI_PADDING on

declare
	@Document_Object nvarchar(50)
	,@DocumentTypeId nvarchar(50)
	,@DocumentDate smalldatetime
	,@DocumentNumber nvarchar(50)
	,@DocumentIntId int
	,@DocumentStatus varchar(15)
	,@Skip int = 1
	,@SSPQuantity decimal(16,4)
	,@iXml xml
	,@s nvarchar(max)
	,@QuantTTN int
	,@QuantMark int
	,@TypeContent varchar(5)
	,@IsSingle bit = 0
	,@IsOldBarCode int = 0
	,@ErrMessageFix nvarchar(max)
	,@IsForceCreate int = 0
	,@ProducedDate smalldatetime
	,@SourceXML nvarchar(max)
	,@ContentResource nvarchar(max)
	,@AlcCode varchar(50)
	,@Producer_ClientRegId varchar(50)
	,@Quantity varchar(50)
	,@Position_Identity varchar(50)
	,@AnalytLotIntId int
	,@RowId uniqueidentifier


select 
	@Document_Object = d.Document_Object
	,@DocumentTypeId = d.DocumentTypeId
	,@DocumentDate = d.DocumentDate
	,@DocumentNumber = d.DocumentNumber
	,@DocumentIntId = d.DocumentIntId
	,@DocumentStatus = d.Status
	,@DocumentIntId = d.DocumentIntId
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
	join mch.dbo.Document d
		on d.DocumentIntId = cn.DocumentIntId 
where cn.RAR_CustNoteId = @RAR_CustNoteId

if exists(
		select top 1 1 
			from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd with(nolock)
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet ess with(nolock)
					on ess.StampSetId = esd.StampSetId
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine esl with(nolock)
					on esl.ParentId = ess.StampSetId
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
					on es.StampId = esl.DescendantId
		where esd.DocumentIntId = @DocumentIntId
			and ess.IsDisassembled = 0
			and len(es.StampBarCode) <> 150
			and ess.WorkSiteId in ('VodkaOldStamp', 'UVK_5'))
	select @IsOldBarCode = 1


if exists(
		select top 1 1
			from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd with(nolock)
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
					on es.StampId = esd.StampSetId
		where len(es.StampBarCode) <> 150
		  	and es.IsSingle = 1
		  	and esd.DocumentIntId = @DocumentIntId)
	select @IsOldBarCode = 1


select top 1 @IsSingle = es.IsSingle
	from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd with(nolock)
		join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
			on esd.StampSetId = es.StampId
where esd.DocumentIntId = @DocumentIntId


select @QuantTTN = alk.Quantity from mch.dbo.AnalytLotLink alk where alk.DocumentIntId = @DocumentIntId


if(@IsSingle = 0)
	begin
		select @QuantMark = count(es.StampId) 
			from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine as esl with(nolock)
					on esl.DescendantId = es.StampId
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet as ess with(nolock)
					on ess.StampSetId = esl.ParentId
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument as esd with(nolock)
					on esd.StampSetId = ess.StampSetId
				join  mch.dbo.AnalytLotLink alk with(nolock)
					on alk.DocumentIntId = esd.DocumentIntId
		where alk.DocumentIntId = @DocumentIntId
		  	and ess.IsDisassembled = 0
	end
else
if(@IsSingle = 1)
	begin		
		select @QuantMark = count(es.StampId)
			from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd with(nolock)
				join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
					on es.StampId = esd.StampSetId
		where esd.DocumentIntId = @DocumentIntId
			and es.IsSingle & 1 = 1
	end	

if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd with(nolock) where esd.DocumentIntId = @DocumentIntId)
begin
	  if @QuantTTN <> @QuantMark
      begin
           select @Skip = 0
           set @ErrMessageFix = 'Несоответствие количества продукции в документе ' + convert(varchar(15), @QuantTTN) + ' шт. с количеством отсканированных марок ' + convert(varchar(15), @QuantMark) + ' шт!'
           print @ErrMessageFix
      end
end

if @DocumentStatus <> 'NRICMO'
	select @Skip = 0

if @IsOldBarCode = 1
	select @Skip = 1

if @Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange' set @Skip = 1

select @Skip = 1 

if (((@Document_Object = ('ProdReceipt') and @DocumentTypeId in ('ProductFGD', 'ProductFGN')) or @IsForceCreate=1)
	or ((@Document_Object = 'ProdReceipt' and @DocumentTypeId = 'Product') or @IsForceCreate=1)
	or (@Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange')) and @Skip = 1
	begin

		declare 
			@DocumentShippingDate varchar(50)
			,@Shipper_ClientRegId varchar(50)
			,@Consignee_ClientRegId varchar(50)
			,@SrcDocumentNumber varchar(50) 
			,@CompanyId varchar(50)
			,@CompanyName varchar(500)
			,@AddressId varchar(50)
			,@Location varchar(500)
			,@INN varchar(50)
		
	
		begin try
			begin transaction EGAIS_DOCUMENT_Write

				select @ProducedDate = convert(smalldatetime, coalesce(at1p.Value, at1pb.Value)) 
					from mch.dbo.Document d
						join  mch.dbo.AnalytLotLink alli 
							on d.Documentintid = alli.Documentintid
						left join  mch.dbo.AnalytLotAttribute at1p 
							on at1p.AnalytLotIntId = alli.AnalytLotIntId 
								and at1p.AdditionalAttribId = 'ProdDate'
						left join  mch.dbo.AnalytLotAttribute at1pb 
							on at1pb.AnalytLotIntId = alli.AnalytLotIntId 
								and at1pb.AdditionalAttribId = 'DateB'		
				where d.DocumentIntId = @DocumentIntId
					and alli.Direction = 1

				if not exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange mr with(nolock) where mr.DocumentIntId = @DocumentIntId)
					begin
						-- пространства имен для версии типа обмена с ЕГАИС
						declare @Namespace nvarchar(max)
						select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)
	
						select @SourceXML = 
									'<?xml version="1.0"?> 
										<ns:Documents Version="1.0"' + char(13) + char(10) +
											@Namespace + ' >' +
										'<ns:Owner>
											<ns:FSRAR_ID>' + isnull(rc.FSRAR_Id, '') + '</ns:FSRAR_ID>
										</ns:Owner>
										<ns:Document>
											<ns:' + @ExchangeTypeCode + '>
												<rpp:Identity>' + convert(varchar(50), cn.RAR_CustNoteId) + '</rpp:Identity>
													<rpp:Header>
														<rpp:Type>OperProduction</rpp:Type>
														<rpp:NUMBER>' + convert(varchar(50), cn.DocumentNumber) + '</rpp:NUMBER>
														<rpp:Date>' + convert(varchar(50), cn.ActionDate, 23) + '</rpp:Date>
														<rpp:ProducedDate>' + convert(varchar(10), @ProducedDate, 23) + '</rpp:ProducedDate>
														<rpp:Producer>
 															<oref:UL>
																<oref:ClientRegId>' + isnull(rc.FSRAR_Id, '') + '</oref:ClientRegId>
																<oref:FullName>' + isnull(rc.FullName, '') + '</oref:FullName>
																<oref:ShortName>' + isnull(rc.ShortName, '') + '</oref:ShortName>
																<oref:INN>' + isnull(rc.TaxCode, '') + '</oref:INN>
																<oref:KPP>' + isnull(rc.TaxReason, '') + '</oref:KPP>
																<oref:address>
																	<oref:Country>' + isnull(rc.CountryCode, '') + '</oref:Country>
																	<oref:RegionCode>' + isnull(rc.RegionCode, '') + '</oref:RegionCode>
																	<oref:description>' + isnull(rc.Location, '') + '</oref:description> 
																</oref:address> 
															</oref:UL> 
														</rpp:Producer> 
														<rpp:Note>Производственный отчет</rpp:Note>
													</rpp:Header>
													<rpp:Content>'
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc
								on rc.FSRAR_Id = cn.ShipperFSRAR_Id								
						where cn.DocumentIntId = @DocumentIntId
							and cn.RAR_CustNoteId = (select max(cn2.RAR_CustNoteId) from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn2 where cn2.DocumentIntId = @DocumentIntId)


						declare Walker cursor local static for
							select 
								AlcCode
								,rc.FSRAR_Id
								,convert(varchar(50), (Quantity)) as Quantity
								,convert(varchar(50), (Position_Identity)) as Position_Identity
							from mch.dbo.Document d 
								join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
									on cn.DocumentIntId = d.DocumentIntId
								join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl
									on cnl.RAR_CustNoteId = cn.RAR_CustNoteId
								join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc
									on rc.FSRAR_Id = cn.ShipperFSRAR_Id
							where d.DocumentIntId = @DocumentIntId
								and cn.RAR_CustNoteId = (select max(cn2.RAR_CustNoteId) from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn2 where cn2.DocumentIntId = @DocumentIntId)


						open Walker
							fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity
						while @@fetch_status = 0
							begin 
								if @IsSingle = 0
									begin
										select @iXml = (
											select distinct '<ce:amc>' + es.StampBarCode + '</ce:amc>' + char(13)+char(10)
		    									from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
		    										join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSetLine as esl with(nolock)
														on esl.DescendantId = es.StampId
		    										join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampSet as ess with(nolock)
														on ess.StampSetId = esl.ParentId
													join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd with(nolock)
														on esd.StampSetId = ess.StampSetId 
		    										join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cl with(nolock)
														on cl.AnalytLotIntId = es.AnalytLotIntId
											where esd.DocumentIntId = @DocumentIntId and ess.IsDisassembled = 0
										for xml path);
									end
								else if @IsSingle = 1
									begin
										select @iXml = (
											select distinct '<ce:amc>' + es.StampBarCode + '</ce:amc>' + char(13) + char(10)
												from RAR_CustNote cn
													join RAR_CustNoteLine cnl
														on cnl.RAR_CustNoteId = cn.RAR_CustNoteId
													join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStampDocument esd with(nolock)
														on esd.DocumentIntId = @DocumentIntId
													join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
														on es.StampId = esd.StampSetId
											where cn.RAR_CustNoteId = @RAR_CustNoteId
											/*select distinct '<ce:amc>' + es.StampBarCode + '</ce:amc>' + char(13) + char(10)
		    									from _ES.ExciseStamp es	with(nolock)
		    										join _EG.RAR_CustNoteLine cl with(nolock)
														on cl.AnalytLotIntId = es.AnalytLotIntId
													join _EG.RAR_CustNote cn with(nolock)
														on cn.RAR_CustNoteId = cl.RAR_CustNoteId
												 where cn.DocumentIntId = @DocumentIntId*/
										for xml path);
									end

									select @s = @iXml.value('string(/)','nvarchar(max)');

									select @SourceXML = @SourceXML +
														'	<rpp:Position>
																<rpp:ProductCode>' + convert(varchar(50), @AlcCode) + '</rpp:ProductCode>
																<rpp:Quantity>' + convert(varchar(50), @Quantity) + '</rpp:Quantity>
																<rpp:Party>' + isnull(al.PartNumber, '') + '</rpp:Party>
																<rpp:Identity>' + @Position_identity + '</rpp:Identity>
																<rpp:Comment1>Комментарий строки</rpp:Comment1>'
									from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
										join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl
											on cnl.RAR_CustNoteId = cn.RAR_CustNoteId
										join  mch.dbo.AnalytLot al
											on al.AnalytLotIntId = cnl.AnalytLotIntId
									where cn.DocumentIntId = @DocumentIntId 
										and cnl.Position_identity = @Position_identity
										and cn.RAR_CustNoteId = (select max(cn2.RAR_CustNoteId) from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn2 where cn2.DocumentIntId = @DocumentIntId)


									select @AnalytLotIntId = cnl.AnalytLotIntId 
										from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
											join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl
												on cnl.RAR_CustNoteId = cn.RAR_CustNoteId
										where cn.DocumentIntId = @DocumentIntId


									if exists(select top 1*	
												from [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es with(nolock)
											where es.AnalytLotIntId = @AnalytLotIntId)
										begin
											select @SourceXML = @SourceXML + '<rpp:MarkInfo>' + @s + '</rpp:MarkInfo>'
										end


										select @SourceXML = @SourceXML + '</rpp:Position>'

										fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity
							end

							close walker
								deallocate walker

							select @SourceXML = @SourceXML + '</rpp:Content>'
			
							select @ContentResource = ''

							if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource with(nolock) where RAR_CustNoteId = @RAR_CustNoteId)
								begin
									select @ContentResource = '<rpp:ContentResource>'
									
									select @ContentResource = @ContentResource + ' 
																	<rpp:Resource>
																		<rpp:IdentityRes>' + convert(varchar(50), lr.IdentityRes) + '</rpp:IdentityRes>
																		<rpp:Product>
																			<pref:UnitType>' + convert(varchar(50), w.UnitType) + '</pref:UnitType>
																			<pref:Type>' + case when convert(varchar(50), w.AlcTypeCode) = '321' then 'ССП' when convert(varchar(50), w.AlcTypeCode) = '020' then 'Спирт' else 'АП' end +'</pref:Type>
																			<pref:FullName>' + isnull(w.WareName,'') + '</pref:FullName>
																			<pref:AlcCode>' + w.AlcCode + '</pref:AlcCode> 
																			' + case when w.UnitType = 'Unpacked' then '' else '<pref:Capacity>' + isnull(convert(varchar(50), w.Capacity), '0') + '</pref:Capacity>' end + '
																			<pref:AlcVolume>' + convert(varchar(50), w.AlcVolume) + '</pref:AlcVolume> 
																			<pref:ProductVCode>' + convert(varchar(50), w.AlcTypeCode) + '</pref:ProductVCode>
																			<pref:Producer>
																				<oref:UL>
																				<oref:ClientRegId>' + isnull(convert(varchar(50), c.FSRAR_Id), '') + '</oref:ClientRegId>
																					<oref:FullName>' + isnull(convert(varchar(255), c.FullName), '') + '</oref:FullName>
																					<oref:INN>' + isnull(convert(varchar(50), c.TaxCode), '') + '</oref:INN>
																					<oref:KPP>' + isnull(convert(varchar(50), c.TaxReason), '') + '</oref:KPP>
																					<oref:address>
																						<oref:Country>' + isnull(convert(varchar(50), c.CountryCode), '643') + '</oref:Country>
																						<oref:RegionCode>' + isnull(convert(varchar(50), c.RegionCode), '') + '</oref:RegionCode>
																						<oref:description>' + isnull(c.Location, '') + '</oref:description>
																					</oref:address>
																				</oref:UL>
																			</pref:Producer>
 																		</rpp:Product>' 
																		+ case when lr.InformMotion is not null then '<rpp:RegForm2>' + isnull(convert(varchar(50), lr.InformMotion), '') + '</rpp:RegForm2>' else '' end +
																		'<rpp:Quantity>' + Replace(isnull(convert(varchar(50), lr.Quantity),'0'), ',', '.') + '</rpp:Quantity>
 																	</rpp:Resource>'
									from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource lr
										join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRests wh 
											on wh.AlcCode = lr.AlcCode
												and wh.InformProduction = lr.InformProduction
												and wh.InformMotion = lr.InformMotion
										left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware w 
											on w.AlcCode = lr.AlcCode
										left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u 
											on u.FSRAR_Id = wh.FSRAR_Id
												and u.IsTest = 0
										left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_FormA fa
											on fa.InformProduction = wh.InformProduction
												and fa.UTMId = u.UTMId
										left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company c 
											on c.RAR_CompanyId = fa.ShipperRAR_CompanyId
									where lr.RAR_CustNoteId = @RAR_CustNoteId

									select  @ContentResource = @ContentResource + '</rpp:ContentResource>'

								end

								select @SourceXML = @SourceXML + isnull(@ContentResource,'')

								select @SourceXML = @SourceXML + 
														'</ns:' + @ExchangeTypeCode + '>
													</ns:Document>
												</ns:Documents>'
					end

				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_Insert
						@RAR_CustNoteId
						,@SourceXML
						,@ExchangeTypeCode
						,@RowId out

		
				declare @Status varchar(50)					

				if(@RowId is not null)
					set @Status = 'Ready'
				else
					set @Status = 'New'

				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
					set
						Status = @Status
						,RowId = @RowId
				where RAR_CustNoteId = @RAR_CustNoteId

		
			commit tran EGAIS_DOCUMENT_Write
			
		end try 
		begin catch		
			rollback tran EGAIS_DOCUMENT_Write
			
			-- Логирование -------------------------------------------
				declare
					@ErrorNumber int = ERROR_NUMBER()
					,@ErrorSeverity int = ERROR_SEVERITY()
					,@ErrorState int = ERROR_STATE()
					,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE()
					,@ErrorLine int = ERROR_LINE()
					,@ErrorMessage nvarchar(256) = ERROR_MESSAGE()
					,@Method nvarchar(128) = object_name(@@ProcId)
	
				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_ExceptionLog
							@ObjectId = @RAR_CustNoteId
							,@RowId = NULL
							,@Operation = 'createXMLContent'
							,@Method = @Method
							,@ErrorNumber = @ErrorNumber
							,@ErrorSeverity = @ErrorSeverity
							,@ErrorState = @ErrorState
							,@ErrorProcedure = @ErrorProcedure
							,@ErrorLine = @ErrorLine
							,@ErrorMessage = @ErrorMessage
			
		end catch		
			
	end

 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_CreateContent_ProdReturn]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_CreateContent_ProdReturn]( @RAR_CustNoteId int=NULL, @ExchangeTypeCode varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      
	
	declare 
		@SourceXML nvarchar(max)
		,@Ranges nvarchar(max)
		,@IsRangesExists int
		,@Position_Identity int
		,@InformProduction nvarchar(50)
		,@InformMotion nvarchar(50)
		,@Quantity decimal(16,4)
		,@DocumentIntId int
	    ,@Document_Object varchar(50)
	    ,@DocumentTypeId varchar(15)
		,@AnalytLotIntId int
		,@Type varchar(20) 
		,@InterCompanyId varchar(15)
		,@RowId uniqueidentifier
		,@ExciseStamp nvarchar(max) = ''

	select 
		@DocumentIntId = rc.DocumentIntId
		,@Document_Object = d.Document_Object
		,@DocumentTypeId = d.DocumentTypeId
		,@InterCompanyId = de.InterCompanyId
		,@Type = da.value
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote rc
		join mch.dbo.Document d
			on d.DocumentIntId = rc.DocumentIntId
		join mch.dbo.DocumentEx de
			on de.DocumentIntId = d.DocumentIntId
		left join mch.dbo.DocumentAttrib da 
			on da.DocumentIntId = d.DocumentIntId	
				and da.AdditionalAttribId = 'EGAIS_ActWriteO'
	where rc.RAR_CustNoteId = @RAR_CustNoteId

	-- пространства имен для версии типа обмена с ЕГАИС
	declare @Namespace nvarchar(max)
	select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)

	if(isnull(@DocumentIntId, 0) <> 0)
		begin -- Списание на основе документа списания в монолит

			select 
				@SourceXML = '<ns:Documents Version="1.0"' + char(13) + char(10) +
							 @Namespace + ' >' + 			
						'	<ns:Owner>' + char(13) +
						'		<ns:FSRAR_ID>' + isnull(cn.ShipperFSRAR_Id, '') + '</ns:FSRAR_ID>' + char(13) +
						'	</ns:Owner>' + char(13) +
						'	<ns:Document>' + char(13) +
						'		<ns:' + @ExchangeTypeCode + '>' + char(13) +
						'			<awr:Identity>' + convert(varchar(50), cn.RAR_CustNoteId) + '</awr:Identity>' + char(13) +
						'			<awr:Header>' + char(13) +
						'				<awr:ActNumber>' + isnull(cn.DocumentNumber, '') + '</awr:ActNumber>' + char(13) +
						'				<awr:ActDate>' + convert(varchar(15), cn.ActionDate, 23) + '</awr:ActDate>' + char(13) +
						'				<awr:TypeWriteOff>' + isnull(awt.TypeName, '') + '</awr:TypeWriteOff>' + char(13) +
						'				<awr:Note>' + case 
														when isnull(@Type, '') = '' 
															and @Document_Object = 'Despatch' 
															and @DocumentTypeId = 'Internal' then 'Списание в рекламных целях' 
														else isnull(awt.TypeDescription, '')
													  end +
									+ '</awr:Note>' + char(13) +
						'			</awr:Header>' + char(13) +
						'			<awr:Content>' + char(13)
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn with(nolock)
					left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_ActWriteOffType awt
	  					on awt.RAR_ActWriteOffTypeId = case 
														when isnull(@Type, '') = '' 
															and @Document_Object = 'Despatch' 
															and @DocumentTypeId = 'Internal' then 2 -- списание в рекламных целях 
														else convert(int, @Type)
													   end
				where cn.DocumentIntId = @DocumentIntId


			declare cWalker cursor local  for
				select distinct 
					cnl.Position_Identity
					,cnl.InformProduction
					,cnl.InformMotion
					,cnl.Quantity
					,cnl.AnalytLotIntId
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl
				where cnl.RAR_CustNoteId = @RAR_CustNoteId
	
			open cWalker

			fetch next from cWalker 
				into 
					@Position_Identity
					,@InformProduction
					,@InformMotion
					,@Quantity
					,@AnalytLotIntId  
	
			while @@fetch_status = 0
				begin
		
					select 
						@SourceXML += '<awr:Position>
										<awr:Identity>' + convert(varchar(15), @Position_Identity) + '</awr:Identity> 
										<awr:Quantity>' + convert(varchar(15), @Quantity) + '</awr:Quantity> 
										<awr:InformF1F2>
											<awr:InformF2>
												<pref:F2RegId>' + isnull(@InformMotion, '') + '</pref:F2RegId>
											</awr:InformF2>
										</awr:InformF1F2>'


					if exists(select top 1* 
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteExciseStamp ces
							where ces.RAR_CustNoteId = @RAR_CustNoteId
								and ces.Position_Identity = @Position_Identity)
						begin

							select @ExciseStamp += '<ce:amc>' + ces.StampBarCode + '</ce:amc>'
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteExciseStamp ces
							where ces.RAR_CustNoteId = @RAR_CustNoteId
								and ces.Position_Identity = @Position_Identity

						end
					else
						begin

							select @ExciseStamp += '<ce:amc>' + dis.BarCode + '</ce:amc>' 
								from (select distinct gd.BarCode 
									from mch.dbo.Document d
										join mch.dbo.CustNote cn
											on cn.CustNote_Object = d.Document_Object
												and cn.CustNoteDate = d.DocumentDate
												and cn.CustNoteNumber = d.DocumentNumber
										join mch.dbo.CustNoteLine cnl
											on cnl.CustNote_Object = cn.CustNote_Object
												and cnl.CustNoteDate = cn.CustNoteDate
												and cnl.CustNoteNumber = cn.CustNoteNumber
										join mch.dbo.AnalytLotLink alk
											on alk.DocumentIntId = d.DocumentIntId
										join mch.dbo.AnalytLot al
											on al.AnalytLotIntId = alk.AnalytLotIntId
										join mch.dbo.bpExciseStampTurnover_GetDocumentContent(@DocumentIntId) gd
											on gd.AnalytLotIntId = al.AnalytLotIntId
												and gd.BarCodeType = 'Stamp'
										join mch.dbo.AnalytLotAttribute production
											on production.AnalytLotIntId = gd.AnalytLotIntId
												and production.AdditionalAttribId = 'InformARegId'
												and production.Value = @InformProduction
										join mch.dbo.AnalytLotAttribute motion
											on motion.AnalytLotIntId = gd.AnalytLotIntId
												and motion.AdditionalAttribId = 'InformBRegId'
												and motion.Value = @InformMotion					
								where d.DocumentIntId = @DocumentIntId
									and alk.AnalytLotIntId = @AnalytLotIntId) as dis

						end				
				

					if(isnull(@ExciseStamp, '') <> '')
						begin

							select @SourceXML += '<awr:MarkCodeInfo>'
							select @SourceXML += @ExciseStamp
							select @SourceXML += '</awr:MarkCodeInfo>'

						end

					select @SourceXML += '</awr:Position>'
					select @ExciseStamp = ''

					fetch next from cWalker 
						into 
							@Position_Identity
							,@InformProduction
							,@InformMotion
							,@Quantity 
							,@AnalytLotIntId

				end

			close cWalker
			deallocate cWalker
	
			select @SourceXML +=
				'			</awr:Content>' + char(13) +
				'		</ns:' + @ExchangeTypeCode + '>' + char(13) +
				'	</ns:Document>' + char(13) +
				'</ns:Documents>' + char(13)

		end
	else
		begin -- Списание в ручном режиме

			select @SourceXML = 
						'<ns:Documents Version="1.0"' + char(13) + char(10) +
									 @Namespace + ' >' + 			
								'	<ns:Owner>' + char(13) +
								'		<ns:FSRAR_ID>' + isnull(cn.ShipperFSRAR_Id, '') + '</ns:FSRAR_ID>' + char(13) +
								'	</ns:Owner>' + char(13) +
								'	<ns:Document>' + char(13) +
								'		<ns:' + @ExchangeTypeCode + '>' + char(13) +
								'			<awr:Identity>' + convert(varchar(50), cn.RAR_CustNoteId) + '</awr:Identity>' + char(13) +
								'			<awr:Header>' + char(13) +
								'				<awr:ActNumber>' + isnull(cn.DocumentNumber, '') + '</awr:ActNumber>' + char(13) +
								'				<awr:ActDate>' + convert(varchar(15), cn.ActionDate, 23) + '</awr:ActDate>' + char(13) +
								'				<awr:TypeWriteOff>' + isnull(aot.TypeName, '') + '</awr:TypeWriteOff>' + char(13) +
								'				<awr:Note>' + isnull(aot.TypeDescription, '') + '</awr:Note>' + char(13) +	
								'			</awr:Header>' + char(13) +
								'			<awr:Content>' + char(13)
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn 
						left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute cna
							on cna.RAR_CustNoteId = cn.RAR_CustNoteId
								and cna.AttributeId = 'TypeWriteOff'
						left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_ActWriteOffType aot
							on aot.RAR_ActWriteOffTypeId = cna.Value				
					where cn.RAR_CustNoteId = @RAR_CustNoteId


			declare cWalker cursor local  for
				select distinct 
					cnl.Position_Identity
					,cnl.InformProduction
					,cnl.InformMotion
					,cnl.Quantity
                    ,cnl.AnalytLotIntId 
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl
				where cnl.RAR_CustNoteId = @RAR_CustNoteId
	
			open cWalker

			fetch next from cWalker 
				into 
					@Position_Identity
					,@InformProduction
					,@InformMotion
					,@Quantity 
					,@AnalytLotIntId 
	
			while @@fetch_status = 0
				begin
		
					select 
						@SourceXML += '<awr:Position>
										<awr:Identity>' + convert(varchar(15), @Position_Identity) + '</awr:Identity> 
										<awr:Quantity>' + convert(varchar(15), @Quantity) + '</awr:Quantity> 
										<awr:InformF1F2>
											<awr:InformF2>
												<pref:F2RegId>' + isnull(@InformMotion, '') + '</pref:F2RegId>
											</awr:InformF2>
										</awr:InformF1F2>'


					select @ExciseStamp += '<ce:amc>' + ces.StampBarCode + '</ce:amc>'
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteExciseStamp ces
					where ces.RAR_CustNoteId = @RAR_CustNoteId
						and ces.Position_Identity = @Position_Identity
			

					if(isnull(@ExciseStamp, '') <> '')
						begin

							select @SourceXML += '<awr:MarkCodeInfo>'
							select @SourceXML += @ExciseStamp
							select @SourceXML += '</awr:MarkCodeInfo>'

						end

					select @SourceXML += '</awr:Position>'
					select @ExciseStamp = ''

					fetch next from cWalker 
						into 
							@Position_Identity
							,@InformProduction
							,@InformMotion
							,@Quantity 
							,@AnalytLotIntId

				end

			close cWalker
			deallocate cWalker
	
			select @SourceXML +=
				'			</awr:Content>' + char(13) +
				'		</ns:' + @ExchangeTypeCode + '>' + char(13) +
				'	</ns:Document>' + char(13) +
				'</ns:Documents>' + char(13)

		end

	begin try
		begin transaction
		
			if isnull(@SourceXML, '') <> ''
				begin

					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_Insert
							@RAR_CustNoteId
							,@SourceXML
							,@ExchangeTypeCode
							,@RowId out
		
				
					declare @Status varchar(50)					
		
					if(@RowId is not null)
						set @Status = 'Ready'
					else
						set @Status = 'New'
		
					update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
						set
							Status = @Status
							,RowId = @RowId
					where RAR_CustNoteId = @RAR_CustNoteId

				end
					
		commit transaction
	end try
		begin catch
			rollback transaction 
			
			-- Логирование -------------------------------------------
			declare
				@ErrorNumber int = ERROR_NUMBER()
				,@ErrorSeverity int = ERROR_SEVERITY()
				,@ErrorState int = ERROR_STATE()
				,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE()
				,@ErrorLine int = ERROR_LINE()
				,@ErrorMessage nvarchar(256) = ERROR_MESSAGE()
				,@Method nvarchar(128) = object_name(@@ProcId)
	
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_ExceptionLog
						@ObjectId = @RAR_CustNoteId
						,@RowId = NULL
						,@Operation = 'createXMLContent'
						,@Method = @Method
						,@ErrorNumber = @ErrorNumber
						,@ErrorSeverity = @ErrorSeverity
						,@ErrorState = @ErrorState
						,@ErrorProcedure = @ErrorProcedure
						,@ErrorLine = @ErrorLine
						,@ErrorMessage = @ErrorMessage
		end catch



GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_CreateRepurchase]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_CreateRepurchase]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare 
		@CustNote_Object varchar(50) = 'CustReturn'
		,@DocumentIntId int
		,@CustNoteDate smalldatetime 
		,@CustNoteNumber varchar(50) 
		,@ActionDate smalldatetime 
		,@ShipperFSRAR_Id varchar(50) 
		,@ConsigneeFSRAR_Id varchar(50) 
		,@DocumentTypeId varchar(50)
		,@WareHouseId varchar(50)
		,@PayKindId varchar(50)
		,@ProductId varchar(50)
		,@CompanyId varchar(50)
		,@DstInterCompanyId varchar(50) 
		,@SrcInterCompanyId varchar(50) 

	
	select
		@CustNoteNumber	= cn.DocumentNumber
		,@CustNoteDate = cn.DocumentDate	
		,@ActionDate = cn.ActionDate
		,@ShipperFSRAR_Id = cn.ShipperFSRAR_Id
		,@ConsigneeFSRAR_Id = cn.ConsigneeFSRAR_Id
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
		where cn.RAR_CustNoteId = @RAR_CustNoteId


	-- Получение @CompanyId отправителя
	select top 1 
		@CompanyId = d.CompanyId 
		,@DstInterCompanyId = de.InterCompanyId
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cnin
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnlin
			on cnlin.RAR_CustNoteId = cnin.RAR_CustNoteId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnlout
			on cnlout.InformProduction = cnlin.InformProduction
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cnout
			on cnout.RAR_CustNoteId = cnlout.RAR_CustNoteId
		join mch.dbo.Document d
			on d.DocumentIntId = cnout.DocumentIntId
		join mch.dbo.DocumentEx de
			on de.DocumentIntId = d.DocumentIntId				
	where cnin.RAR_CustNoteId = @RAR_CustNoteId
		and cnout.ConsigneeFSRAR_Id = @ShipperFSRAR_Id
		
	
	select @SrcInterCompanyId = ic.InterCompanyId
		from mch.dbo.InterCompany ic
			join mch.dbo.Company c
				on c.CompanyId = ic.CompanyId
			join mch.dbo.Company src
				on src.CompanyId = @CompanyId
	where c.TaxCode = src.TaxCode
		and c.TaxReason = src.TaxReason
		and c.CompanyTypeId <> 'Factory'
			

	if isnull(@SrcInterCompanyId, '') = ''
		begin

			select 
				@PayKindId = c.PayKindId
				,@ProductId = c.ProductId
				,@DocumentTypeId = 'Common'
			from mch.dbo.bpCompany_GetContractTerm(@CompanyId, getdate(), default, default, @DstInterCompanyId) c

		end
	else 
		begin
			
			select
				@PayKindId = pr.PayKindId
				,@ProductId = pr.ProductId
				,@WareHouseId = pr.WareHouseId
				,@DocumentTypeId = 'InterCompany'
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepurchaseProductRecode pr
				where pr.SrcInterCompanyId = @SrcInterCompanyId
					and pr.DstInterCompanyId = @DstInterCompanyId
				
		end

	if(isnull(@PayKindId, '') <> '' and isnull(@ProductId, '') <> '')
		begin

			declare @Err int

			exec @Err = mch.dbo.bpCustNote_Create
							@CustNote_Object = @CustNote_Object out
							,@CustNoteDate = @CustNoteDate out
							,@CustNoteNumber = @CustNoteNumber out
							,@DocumentTypeId = @DocumentTypeId
							,@PayKindId = @PayKindId
							,@ProductId = @ProductId
							,@WareHouseId = @WareHouseId
							,@CompanyId = @CompanyId
							,@WorkDate = @ActionDate
							,@ActionDate = @ActionDate
							,@SrcDocumentNumber = @CustNoteNumber 
							,@ChangedNumber = 1

			if @Err = 1
				return 1

			select @DocumentIntId = d.DocumentIntId
				from mch.dbo.Document d
			where d.Document_Object = @CustNote_Object
				and d.DocumentNumber = @CustNoteNumber
				and d.DocumentDate = @CustNoteDate

		end

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_DespatchViewHistory]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_DespatchViewHistory]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    set CONCAT_NULL_YIELDS_NULL on
set ANSI_WARNINGS on
set ANSI_PADDING on

      
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


	select 
		cn.RAR_CustNoteId
		,t.TicketDate
		,FixNumber = m.FixNumber
		,FixDate = m.FixDate       
	    ,RegNumber = coalesce(m.RegNumber, t.RegId)
		,Comment = t.OperationComment
         ,ReplyId = t.ReplyId
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.FSRAR_Id = cn.ShipperFSRAR_Id
		left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t 
			on t.ReplyId = cn.ReplyId
				and t.UTM_Id = u.UTMId
	    left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo m 
			on m.RAR_CustNoteId = cn.RAR_CustNoteId
				and m.UTM_Id = u.UTMId
	where cn.RAR_CustNoteId = @RAR_CustNoteId
		and cn.Direction = -1
	order by t.TicketDate desc
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	select *
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_GenerateDocument]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_GenerateDocument]( @RAR_CustNoteId int=NULL, @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare @CurrentStatus varchar(64)
	select @CurrentStatus = cn.Status
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
	where cn.RAR_CustNoteId = @RAR_CustNoteId
	

	if @CurrentStatus = 'ResourceInput'
		begin
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
						@RAR_CustNoteId
						,@Status
		end
	else
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.GenerateDocument'                and Item=0), 'На данном статусе формирование документа запрещено!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_GetReestrShipment]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_GetReestrShipment]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    declare @StartDate smalldatetime = '20200401'
,@EndDate smalldatetime = '20200413'
,@ShipperFSRAR_Id varchar(50) = '020000241122'

--select @StartDate as d1, @EndDate as d2

create table #Shipment(Level int, DocumentNumber varchar(100), ActionDate datetime, Status varchar(50), RegNumber varchar(50), ShipperFSRAR_Id varchar(50), ConsigneeFSRAR_Id varchar(50), FullName varchar(4000), QuantDal decimal(16,4), QuantSht decimal(16,4))
insert into #Shipment(Level, DocumentNumber, ActionDate, Status, RegNumber, ShipperFSRAR_Id, ConsigneeFSRAR_Id, FullName, QuantDal, QuantSht)
select 1 as [level]
      ,cn.DocumentNumber
      ,cn.ActionDate
	  ,cn.Status
	  ,m.RegNumber
      ,cn.ShipperFSRAR_Id
      ,cn.ConsigneeFSRAR_Id
	  ,cc.FullName
	  ,sum(case when w.Capacity is null then cnl.RealQuantity else round(convert(decimal(16, 4), w.Capacity) * cnl.RealQuantity * 0.1, 4) end)
      ,sum(case when w.Capacity is null then 0 else cnl.RealQuantity end)
from EgaisExchange.dbo.RAR_CustNote cn
join EgaisExchange.dbo.RAR_CustNoteLine cnl on cnl.RAR_CustNoteId = cn.RAR_CustNoteId
join EgaisExchange.dbo.RAR_MotionInfo m on m.RAR_CustNoteId = cn.RAR_CustNoteId
join EgaisExchange.dbo.RAR_Company cc on cc.FSRAR_Id = cn.ConsigneeFSRAR_Id
join EgaisExchange.dbo.RAR_Ware w on w.AlcCode = cnl.AlcCode
where cn.ActionDate between @StartDate and @EndDate
  and cn.Direction = -1
  and cn.ClassId in ('WayBill', 'WBReturnFromMe')
  and cn.Status in ('Accepted' , 'Confirmed', 'Recorded')
  and m.RAR_MotionInfoId = (select max(mm.RAR_MotionInfoId) from EgaisExchange.dbo.RAR_MotionInfo mm where mm.RAR_CustNoteId = m.RAR_CustNoteId and mm.ReplyId is not null)
  and cn.ShipperFSRAR_Id = @ShipperFSRAR_Id
group by cn.DocumentNumber
        ,cn.ActionDate
		,cn.Status
	    ,m.RegNumber
        ,cn.ShipperFSRAR_Id
        ,cn.ConsigneeFSRAR_Id
	    ,cc.FullName

insert into #Shipment(Level, QuantDal, QuantSht)
select 2
      ,sum(s.QuantDal)
	  ,sum(s.QuantSht)
from #Shipment s
where s.Level = 1

print 'EndHeader'

select s.Level
      ,s.DocumentNumber
      ,convert(varchar, s.ActionDate, 104) as ActionDate
      ,case when s.Status = 'Confirmed' then 'Подтверждён' when s.Status = 'Recorded' then 'Зафиксирован' when s.Status = 'Accepted' then 'Принят' end as Status
      ,s.RegNumber
      ,s.ShipperFSRAR_Id
      ,s.ConsigneeFSRAR_Id
      ,s.FullName as CompanyName
      ,s.QuantDal
      ,convert(int, s.QuantSht) as QuantSht
from #Shipment s
order by s.Level
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_GetReportShipment]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_GetReportShipment]( @DBegin datetime=NULL, @DEnd datetime=NULL, @ShipperFSRAR_Id varchar(50)=NULL, @AlcTypeCode varchar(10)=NULL, @FSRAR_Id varchar(50)=NULL, @AlcCode varchar(100)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

set nocount on
set dateformat dmy

  if @DBegin is null
       set @DBegin = getdate()
  
  if @DEnd is null
       set @DEnd = getdate()

--drop table #Shipment
create table #Shipment (Level int, ActionDate datetime, AlcTypeCode varchar(50), WareName varchar(1000), AlcCode varchar(100), Capacity decimal(16, 4), QuantityDal decimal(16,4), QuantitySht decimal(16,4))
insert into #Shipment(Level, ActionDate, AlcTypeCode, WareName, AlcCode, Capacity, QuantityDal, QuantitySht)
select 0
     ,convert(datetime, cn.ActionDate, 111)
     ,w.AlcTypeCode
     ,w.WareName    
     ,w.AlcCode  
	,w.Capacity
     ,sum(case when w.Capacity is null then cnl.RealQuantity else round(convert(decimal(16, 4), w.Capacity) * cnl.RealQuantity * 0.1, 4) end)
     ,sum(case when w.Capacity is null then 0 else cnl.RealQuantity end)
from RAR_CustNote cn
join RAR_CustNoteLine cnl on cnl.RAR_CustNoteId = cn.RAR_CustNoteId
join RAR_Ware w on w.AlcCode = cnl.AlcCode
join RAR_MotionInfo m on m.RAR_CustNoteId = cn.RAR_CustNoteId
left join RAR_WayBillAct wba on wba.RegId = m.RegNumber
where cn.Direction = -1
  and cn.ActionDate between @DBegin and @DEnd
  and cn.RAR_CustNoteId = (select max(cnn.RAR_CustNoteId) from RAR_CustNote cnn where cnn.DocumentIntId = cn.DocumentIntId)
  and m.RAR_MotionInfoId = (select max(mm.RAR_MotionInfoId) from RAR_MotionInfo mm where mm.RAR_CustNoteId = cn.RAR_CustNoteId)
  and (   (    wba.RAR_WayBillActId = (select max(wba.RAR_WayBillActId) from RAR_WayBillAct wba where wba.RegId = m.RegNumber)
           and wba.IsAccept <> 'Rejected')
       or wba.RAR_WayBillActId is null)
  and (   @ShipperFSRAR_Id = cn.ShipperFSRAR_Id 
	  or @ShipperFSRAR_Id is null)
  and (   w.AlcTypeCode = @AlcTypeCode
	  or @AlcTypeCode is null)
  and (   w.AlcCode like '%'+@AlcCode+'%'
       or @AlcCode is null)
  and (   w.FSRAR_Id = @FSRAR_Id
       or @FSRAR_Id is null)
group by cn.ActionDate
        ,w.AlcTypeCode
        ,w.WareName    
        ,w.AlcCode  
	   ,w.Capacity

insert #Shipment (Level, AlcTypeCode, WareName, AlcCode, Capacity)
select distinct
      1 
	,s.AlcTypeCode
	,s.WareName
	,s.AlcCode
	,s.Capacity
  from #Shipment s
  where Level = 0

insert #Shipment (Level, ActionDate, AlcCode, QuantityDal, QuantitySht) 
select 2 
	,s.ActionDate
	,s.AlcCode
	,sum(s.QuantityDal)
	,sum(s.QuantitySht)
from #Shipment s
where Level = 0  
group by s.ActionDate
	   ,s.AlcCode

insert #Shipment (Level, ActionDate, AlcCode, AlcTypeCode/*Capacity*/, QuantityDal, QuantitySht) 
select 3 
	 ,@DEnd
	 ,s.AlcCode
	 ,'Итого по коду'
	 ,sum(QuantityDal)
	 ,sum(QuantitySht)
from #Shipment s
where Level = 0  
group by s.AlcCode

insert #Shipment (Level, AlcCode, AlcTypeCode, QuantityDal, QuantitySht) 
select 4 
	,'9999999999999999999'
	,'Итого:'
	,sum(QuantityDal)
	,sum(QuantitySht)
from #Shipment
where Level = 0

  select [Level] 
  ,s.WareName  
  ,iif(level = 1, s.AlcCode, null)  as AlcCode
  ,s.AlcTypeCode  
  ,s.Capacity
  ,iif(level = 3, null, convert(varchar(10), s.ActionDate, 104)) as DocumentShippingDate
  ,convert(decimal(16, 4), s.QuantityDal) as [RealQuantityDal]
  ,convert(int, s.QuantitySht) as [RealQuantitySht]
  from #Shipment s
  where s.level <> 0
  order by s.AlcCode
	     ,s.ActionDate
          ,s.Level
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_Insert]( @Document_Object varchar(50)=NULL, @DocumentDate smalldatetime=NULL, @DocumentNumber varchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


	declare
		@Method nvarchar(255)
		,@Expression nvarchar(max)

	select @Method = etl.Method 
		from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl
				on etl.Document_Object = d.Document_Object
					and etl.DocumentTypeId = d.DocumentTypeId
	where d.Document_Object = @Document_Object
		and d.DocumentDate = @DocumentDate
		and d.DocumentNumber = @DocumentNumber

	if isnull(@Method,'') <> ''
		begin
			set @Expression = N'exec ' + @Method + ' @Document_Object, @DocumentDate, @DocumentNumber';

			exec sp_executesql @Expression, N'@Document_Object nvarchar(55), @DocumentDate smalldatetime, @DocumentNumber nvarchar(55)'
					,@Document_Object = @Document_Object
					,@DocumentDate = @DocumentDate
					,@DocumentNumber = @DocumentNumber;
		end

	
						
		
	
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_Insert_Despatch]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_Insert_Despatch]( @Document_Object varchar(50)=NULL, @DocumentDate smalldatetime=NULL, @DocumentNumber varchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@DocumentIntId int
		,@DocumentTypeId varchar(55)
		,@ShipperFSRAR_Id varchar(50)
		,@ConsigneeFSRAR_Id varchar(50)
		,@RAR_CustNoteId int
		,@DocumentUnitType varchar(50)
		,@DocumentShippingDate varchar(50)
		,@Shipper_ClientRegId varchar(50)
		,@Consignee_ClientRegId varchar(50)
		,@Tran_CAR varchar(255)
		,@Tran_Customer varchar(255)
		,@Tran_Driver varchar(255)
		,@Tran_LoadPoint varchar(255)
		,@Tran_UnloadPoint varchar(255)
		,@Tran_Forwarder varchar(255)
		,@Tran_Company varchar(255)
		,@SrcDocumentNumber varchar(50)
		,@Status varchar(50)
		,@Date smalldatetime
		,@SourceLineType varchar(50)
		,@ErrMessageFix varchar(255)
	

	create table #RAR_CustNoteLine
	(
		Position_Identity int identity(1,1)
		,AlcCode varchar(50)
		,Quantity decimal(16,4)
		,Price decimal(16, 4)
		,InformARegId varchar(50)
		,InformBRegId varchar(50)
		,AnalytLotIntId int
	)


	/*select 
		@DocumentIntId = d.DocumentIntId
		,@DocumentTypeId = d.DocumentTypeId
	from _EM.Document d
		where d.Document_Object = @Document_Object
			and d.DocumentDate = @DocumentDate
			and d.DocumentNumber = @DocumentNumber */

	select 
			@DocumentIntId = d.DocumentIntId
			,@DocumentTypeId = d.DocumentTypeId
			,@ShipperFSRAR_Id = shipper.FSRAR_Id
			,@ConsigneeFSRAR_Id = consignee.FSRAR_Id			
		from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNote cn 
				on cn.CustNote_Object = d.Document_Object
					and cn.CustNoteDate = d.DocumentDate
					and cn.CustNoteNumber = d.DocumentNumber
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.DocumentEx de
				on de.DocumentIntId = d.DocumentIntId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.InterCompany ic
				on ic.InterCompanyId = de.InterCompanyId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Company c
				on c.CompanyId = ic.CompanyId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.WareHouse Wh 
				on Wh.WareHouseId = cn.WareHouseId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.[Address] a 
				on a.AddressId = Wh.AddressId
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib caa 
				on caa.AdditionalAttribId = 'AddrTaxReason' 
					and caa.Class_Object = 'Address' 
					and caa.ClassId = a.AddressId
			left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company shipper
				on shipper.TaxCode = c.TaxCode
					and isnull(shipper.TaxReason, '') = coalesce(caa.Value, isnull(c.TaxReason, ''))
					and shipper.FSRAR_Id is not null
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Company c2
				on c2.CompanyId	= d.CompanyId			
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.TransportEx te 
				on te.Document_Object = d.Document_Object  
					and te.DocumentDate = d.DocumentDate 
					and te.DocumentNumber = d.DocumentNumber
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.[Address] a2 
				on a2.AddressId = te.DeliveryAddressId
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib caa2 
				on caa2.AdditionalAttribId = 'AddrTaxReason'  
					and caa2.Class_Object = 'Address' 
					and caa2.ClassId = a2.AddressId  
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib caaf 
				on caaf.AdditionalAttribId = 'FSRAR_ID'
					and caaf.Class_Object = 'Address' 
					and caaf.ClassId = de.DeliveryAddressId 
					and ltrim(rtrim(caaf.Value))<>''
			left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company consignee 
				on consignee.TaxCode = c2.TaxCode
					and isnull(consignee.TaxReason, '') = coalesce(caa2.Value, isnull(c2.TaxReason, '')) 
					and consignee.FSRAR_Id is not null	
		where d.Document_Object = @Document_Object
				and d.DocumentDate = @DocumentDate
				and d.DocumentNumber = @DocumentNumber


	if @Document_Object in ('Despatch', 'VendReturn', 'MovingNote') --or @IsForceCreate=1
		begin
			
			select 
				@DocumentIntId = D.DocumentIntId
				,@DocumentShippingDate = convert(varchar(50), CN.ActionDate,112)
				,@Shipper_ClientRegId = rc_2.FSRAR_Id
				,@Consignee_ClientRegId = coalesce(rc.FSRAR_Id, ltrim(rtrim(CAAF.[Value])))
				,@Tran_CAR = Te.AutoNumber
				,@Tran_Company = Te.AutoCompany
				,@Tran_Customer = C2.CompanyName#Rus
				,@Tran_Driver = Te.AutoDriver
				,@Tran_LoadPoint = Te.SendPoint
				,@Tran_UnloadPoint = Te.ReceivePoint
				,@SrcDocumentNumber = D.SrcDocumentNumber
				,@Status = D.[Status]
			from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document D
				join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNote CN 
					on CN.CustNote_Object = D.Document_Object 
						and CN.CustNoteDate = D.DocumentDate 
						and CN.CustNoteNumber = D.DocumentNumber
				join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.TransportEx Te 
					on Te.Document_Object = D.Document_Object  
						and Te.DocumentDate = D.DocumentDate 
						and Te.DocumentNumber = D.DocumentNumber
				join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.DocumentEx De 
					on De.DocumentIntId = D.DocumentIntId
				join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.InterCompany IC 
					on IC.InterCompanyId = De.InterCompanyId
				join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Company C1 
					on C1.CompanyId = D.CompanyId
				left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.[Address] A1 
					on A1.AddressId = Te.DeliveryAddressId
				left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA1 
					on CAA1.AdditionalAttribId = 'AddrTaxReason' 
						and CAA1.Class_Object = 'Address' 
						and CAA1.ClassId = A1.AddressId  
				left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAAF 
					on CAAF.AdditionalAttribId = 'FSRAR_ID'  
						and CAAF.Class_Object = 'Address' 
						and CAAF.ClassId = De.DeliveryAddressId 
						and ltrim(rtrim(CAAF.[Value])) <> ''
				left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc 
					on rc.TaxCode = C1.TaxCode  
						and isnull(rc.TaxReason, '') = coalesce(CAA1.[Value], isnull(C1.TaxReason, '')) 
						and rc.FSRAR_Id is not null
				join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Company C2 
					on C2.CompanyId = IC.CompanyId
				join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.WareHouse Wh 
					on Wh.WareHouseId = CN.WareHouseId
				left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.[Address] A2 
					on A2.AddressId = Wh.AddressId
				left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA2 
					on CAA2.AdditionalAttribId = 'AddrTaxReason' 
						and CAA2.Class_Object = 'Address' 
						and CAA2.ClassId = A2.AddressId
				left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company rc_2 
					on rc_2.TaxCode = C2.TaxCode  
						and isnull(rc_2.TaxReason, '') = coalesce(CAA2.[Value], isnull(C2.TaxReason, '')) 
						and rc_2.FSRAR_Id is not null
			where D.Document_Object = @Document_Object 
					and D.DocumentDate = @DocumentDate  
					and D.DocumentNumber = @DocumentNumber


			select @Date = cn.ActionDate
				from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
					join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNote cn 
						on cn.CustNote_Object = d.Document_Object 
							and cn.CustNoteDate = d.DocumentDate 
							and cn.CustNoteNumber = d.DocumentNumber
				where d.DocumentIntId = @DocumentIntId


			if(@Date < dateadd(dd, 0, datediff(dd, 0, getdate()))) or (@Date >= dateadd(dd, 0, datediff(dd, 0, getdate())))	 
				begin

					--if (@Status not like '%O%' and @Document_Object not in ('MovingNote')) 
					--		or(@Status not like '%M%' and @Document_Object = 'MovingNote')
					--			return 1


					if exists (select 1 
									from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNoteLine 
								where CustNote_Object = @Document_Object 
									and CustNoteDate = @DocumentDate 
									and CustNoteNumber = @DocumentNumber 
									and WareId in ('0220', '0221'))
						select @DocumentUnitType = 'Unpacked'
					else
						select @DocumentUnitType = 'Packed'

					
					if (@SourceLineType is null or @SourceLineType = 'AnalytLot')
						begin

							insert into #RAR_CustNoteLine(
											--Position_Identity
											Quantity
											,Price
											,AlcCode
											,InformARegId
											,InformBRegId
											,AnalytLotIntId)
								select 
									--cnl.LineNumber
									case when rw.UnitType = 'Unpacked' then alli.Quantity * cuf.FactorValue / cufdal.FactorValue else alli.Quantity end
									,case when rw.UnitType = 'Unpacked' then cnl.DiscountPrice / (cuf.FactorValue / cufdal.FactorValue) else cnl.DiscountPrice end
									,coalesce(ALA_W.[Value], caf.[Value], CAA1.[Value]) as AlcCode
									,AlA1.[Value] as InformARegId
									,AlA2.[Value] as InformBRegId
								   ,alli.AnalytLotIntId
							from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotLink alli with(NOLOCK)
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNoteLine cnl with(NOLOCK) 
									on CNL.CustNOte_Object = @Document_Object 
										and CNL.CustNoteDate = @DocumentDate 
										and CNL.CustNoteNumber = @DocumentNumber 
										and alli.LineNumber = cnl.LineNumber
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Ware W with(NOLOCK) 
									on W.WareId = CNL.WareId 
										and W.IsLotControl = 1
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA1 with(NOLOCK) 
									on CAA1.AdditionalAttribId = 'WARE_EGAIS' 
										and CAA1.Class_Object = 'Ware' 
										and CAA1.ClassId = W.WareId
								left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw
									on rw.AlcCode = ltrim(rtrim(CAA1.[Value]))
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Unit U with(NOLOCK) 
									on U.UnitId = CNL.UnitId
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA1 with(NOLOCK) 
									on AlA1.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA1.AdditionalAttribId = 'InformARegId'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA2 with(NOLOCK) 
									on AlA2.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA2.AdditionalAttribId = 'InformBRegId'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA3 with(NOLOCK) 
									on AlA3.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA3.AdditionalAttribId = 'DateB'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA_W with(NOLOCK) 
									on AlA_W.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA_W.AdditionalAttribId = 'AlcCode'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUF with(NOLOCK) 
									on CUF.WareId = W.WareId 
										and CUF.UnitId = U.UnitId
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUFDAL with(NOLOCK) 
									on CUFDAL.WareId = W.WareId 
										and CUFDAL.UnitId = 'dal'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAttribHist caf with(NOLOCK) 
									on caf.ClassId = w.WareId 
										and caf.AttribId = 'WARE_EGAIS' 
										and caf.Class_Object = 'Ware' 
										and ala3.[Value] between caf.BeginDate and caf.EndDate
										and caf.[Value] is not null
							where alli.DocumentIntId = @DocumentIntId 
								and alli.Direction = -1

						end

					if (@SourceLineType = 'CustNote')
						begin

							insert into #RAR_CustNoteLine(
											--Position_Identity
											Quantity
											,Price
											,AlcCode
											,InformARegId
											,InformBRegId)
								select 
									--cnl.LineNumber
									case when rw.UnitType = 'Unpacked' then cnl.Quantity * cuf.FactorValue / cufdal.FactorValue else cnl.Quantity end
									,case when rw.UnitType = 'Unpacked' then (cnl.DiscountCost / cnl.Quantity) / (cuf.FactorValue / cufdal.FactorValue) else cnl.DiscountCost / cnl.Quantity end
									,ltrim(rtrim(coalesce(CAA1.[Value], CAA2.[Value]))) as AlcCode 
									,'' as InformARegId
									,'' as InformBRegId
								from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document D 
									join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNoteLine cnl with(NOLOCK) 
										on CNL.CustNote_Object=D.Document_Object 
											and CNL.CustNoteDate=D.DocumentDate
											and CNL.CustNoteNumber=D.DocumentNumber 
									join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Ware W with(NOLOCK) 
										on W.WareId = CNL.WareId-- and W.IsLotControl = 1
									left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Ware W2 with(NOLOCK) 
										on W2.WareId = replace(W.WareId, '-M', '')
									left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA1 with(NOLOCK) 
										on CAA1.AdditionalAttribId = 'WARE_EGAIS' 
											and CAA1.Class_Object='Ware' 
											and CAA1.ClassId = W.WareId
									left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA2 with(NOLOCK) 
										on CAA2.AdditionalAttribId = 'WARE_EGAIS' 
											and CAA2.Class_Object = 'Ware' 
											and CAA2.ClassId = W2.WareId
									left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw 
										on rw.AlcCode = coalesce(ltrim(rtrim(CAA1.[Value])), ltrim(rtrim(CAA2.[Value])))
									join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Unit U with(NOLOCK) 
										on U.UnitId = CNL.UnitId
									left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUF with(NOLOCK) 
										on CUF.WareId = W.WareId 
											and CUF.UnitId = U.UnitId
									left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUFDAL with(NOLOCK) 
										on CUFDAL.WareId = W.WareId 
											and CUFDAL.UnitId = 'dal'
								where D.DocumentIntId = @DocumentIntId
									and (CAA1.[Value] is not Null or CAA2.[Value] is not null)
						end

					begin try
						begin transaction							

								insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote(
										DocumentIntId
										,DocumentNumber
										,DocumentDate
										,Status
										,Direction
										,ShipperFSRAR_Id
										,ConsigneeFSRAR_Id)
									values(
										@DocumentIntId
										,@DocumentNumber
										,@DocumentDate
										,0
										,-1
										,@ShipperFSRAR_Id
										,@ConsigneeFSRAR_Id)
	
								set @RAR_CustNoteId = @@Identity;


								insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteTransport(
												RAR_CustNoteId
												,Car
												,Company
												,Customer
												,Driver
												,Forwarder
												,LoadPoint
												,UnloadPoint)
								select 
									@RAR_CustNoteId
									,@Tran_CAR
									,@Tran_COMPANY
									,@Tran_CUSTOMER
									,@Tran_DRIVER
									,@Tran_FORWARDER
									,@Tran_LOADPOINT
									,@Tran_UNLOADPOINT
		

								insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine(
												RAR_CustNoteId
												,Position_Identity
												,AlcCode
												,Quantity
												,RealQuantity
												,Price
												,InformProduction
												,InformMotion
												,AnalytLotIntId)
								select 
									@RAR_CustNoteId
									,cl.Position_Identity
									,cl.AlcCode
									,cl.Quantity
									,cl.Quantity
									,cl.Price
									,cl.InformARegId
									,cl.InformBRegId
									,cl.AnalytLotIntId									
								from #RAR_CustNoteLine cl
									join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw
										on rw.AlcCode = cl.AlcCode
								where cl.AlcCode is not null

						commit transaction
					end try
					begin catch
						select 
        					ERROR_NUMBER() AS ErrorNumber
        					,ERROR_SEVERITY() AS ErrorSeverity
        					,ERROR_STATE() AS ErrorState
        					,ERROR_PROCEDURE() AS ErrorProcedure
        					,ERROR_LINE() AS ErrorLine
        					,ERROR_MESSAGE() AS ErrorMessage;

						rollback tran 
					end catch

				end
			else 
				if(@Date < dateadd(dd, 0, datediff(dd, 0, getdate())))
					begin
	
						set @ErrMessageFix = 'Дата отгрузки документа меньше текущей даты!'
					  	print @ErrMessageFix
					  	return 1
	
					end

	
		end








		
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_Insert_ProdReceipt]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_Insert_ProdReceipt]( @Document_Object varchar(50)=NULL, @DocumentDate smalldatetime=NULL, @DocumentNumber varchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      
	
	declare 
		@DocumentIntId int
		,@DocumentTypeId varchar(50)
		,@ShipperFSRAR_Id varchar(50)
		,@ConsigneeFSRAR_Id varchar(50)
		,@SSPQuantity decimal(16,4)
		,@RAR_CustNoteId int


	create table #RAR_CustNoteLine
	(
		Position_Identity int
		,LineNumber int
		,Type varchar(50)
		,AlcCode varchar(50)
		,Producer_ClientRegId varchar(50)
		,Quantity decimal(16,4)
		,Price decimal(16, 4)
		,InformARegId varchar(50)
		,InformBRegId varchar(50)
		,PackId varchar(50)
		,Party varchar(50)
		,WareId varchar(50)
		,WareName varchar(255)
		,UnitId varchar(50)
		,UnitName varchar(255)
		,WareTaxCode varchar(50)
		,PRInterCompanyId varchar(50)
		,DateB nvarchar(50)
		,PartNumber nvarchar(50)
		,FSMType nvarchar(3)
		,AnalytLotIntId int
	)
	
		/*select 
			@DocumentIntId = d.DocumentIntId
			,@DocumentTypeId = d.DocumentTypeId
		from _EM.Document d
			where d.Document_Object = @Document_Object
				and d.DocumentDate = @DocumentDate
				and d.DocumentNumber = @DocumentNumber */

		select 
			@DocumentIntId = d.DocumentIntId
			,@DocumentTypeId = d.DocumentTypeId
			,@ShipperFSRAR_Id = shipper.FSRAR_Id
			,@ConsigneeFSRAR_Id = consignee.FSRAR_Id			
		from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNote cn 
				on cn.CustNote_Object = d.Document_Object
					and cn.CustNoteDate = d.DocumentDate
					and cn.CustNoteNumber = d.DocumentNumber
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.DocumentEx de
				on de.DocumentIntId = d.DocumentIntId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.InterCompany ic
				on ic.InterCompanyId = de.InterCompanyId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Company c
				on c.CompanyId = ic.CompanyId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.WareHouse Wh 
				on Wh.WareHouseId = cn.WareHouseId
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.[Address] a 
				on a.AddressId = Wh.AddressId
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib caa 
				on caa.AdditionalAttribId = 'AddrTaxReason' 
					and caa.Class_Object = 'Address' 
					and caa.ClassId = a.AddressId
			left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company shipper
				on shipper.TaxCode = c.TaxCode
					and isnull(shipper.TaxReason, '') = coalesce(caa.Value, isnull(c.TaxReason, ''))
					and shipper.FSRAR_Id is not null
			join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Company c2
				on c2.CompanyId	= d.CompanyId			
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.TransportEx te 
				on te.Document_Object = d.Document_Object  
					and te.DocumentDate = d.DocumentDate 
					and te.DocumentNumber = d.DocumentNumber
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.[Address] a2 
				on a2.AddressId = te.DeliveryAddressId
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib caa2 
				on caa2.AdditionalAttribId = 'AddrTaxReason'  
					and caa2.Class_Object = 'Address' 
					and caa2.ClassId = a2.AddressId  
			left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib caaf 
				on caaf.AdditionalAttribId = 'FSRAR_ID'
					and caaf.Class_Object = 'Address' 
					and caaf.ClassId = de.DeliveryAddressId 
					and ltrim(rtrim(caaf.Value))<>''
			left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company consignee 
				on consignee.TaxCode = c2.TaxCode
					and isnull(consignee.TaxReason, '') = coalesce(caa2.Value, isnull(c2.TaxReason, '')) 
					and consignee.FSRAR_Id is not null	
		where d.Document_Object = @Document_Object
				and d.DocumentDate = @DocumentDate
				and d.DocumentNumber = @DocumentNumber  

	
		if @Document_Object = 'ProdReceipt' and @DocumentTypeId in ('ProductFGD', 'ProductFGN')
			begin
				/*if exists(select * from _EG.RAR_CustNote rd where rd.DocumentIntId = @DocumentIntId and rd.Status = 0)
					begin
						delete from _EG.RAR_CustNote where DocumentIntId = @DocumentIntId
					--	delete from _EG.RAR_CustNoteLine where DocumentIntId = @DocumentIntId
					end*/
				begin try
					begin transaction

						insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote(
										DocumentIntId
										,DocumentNumber
										,DocumentDate
										,Status
										,Direction
										,ShipperFSRAR_Id
										,ConsigneeFSRAR_Id)
							values(
								@DocumentIntId
								,@DocumentNumber
								,@DocumentDate
								,0
								,-1
								,@ShipperFSRAR_Id
								,@ConsigneeFSRAR_Id)
		
						set @RAR_CustNoteId = @@Identity;
		
						select @SSPQuantity = alk2.Quantity
							from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d 
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotLink alk 
									on alk.DocumentIntId = d.DocumentIntId
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLot al 
									on al.AnalytLotIntId = alk.AnalytLotIntId
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLot al2 
									on al2.WareId = al.WareId
								    	and al2.PartNumber = al.PartNumber
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotLink alk2 
									on alk2.AnalytLotIntId = al2.AnalytLotIntId
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d2 
									on d2.DocumentIntId = alk2.DocumentIntId
							where d.DocumentIntid = @DocumentIntid
								and alk.Direction = 1
								and (d2.Document_Object = 'ProdReceipt' and d2.DocumentTypeId = 'Product')
		
		
						insert into #RAR_CustNoteLine(
										Position_Identity
										--,LineNumber
										--,WareId
										--,WareName
										--,UnitId
										--,UnitName
										,Quantity
										,Price
										,AlcCode
										,InformARegId
										,InformBRegId
										--,DateB
										--,PartNumber
										--,FSMType
										,AnalytLotIntId)
							 select 
							  	ROW_NUMBER() over(order by alli.AnalytLotIntId asc) as LineNumber
								--,ROW_NUMBER() over(order by alli.AnalytLotIntId asc) as LineNumber
							  	--,W.WareId
							  	--,W.WareName#Rus
							  	--,U.UnitId
							  	--,U.UnitName#Rus 
							  	,sum(case when EW.WareType = 'Unpacked' then alli.Quantity * cuf.FactorValue / cufdal.FactorValue else alli.Quantity end) + isnull(@SSPQuantity, 0)
							  	,case when EW.WareType = 'Unpacked' then cnl.DiscountPrice / (cuf.FactorValue / cufdal.FactorValue) else cnl.DiscountPrice end
						        ,coalesce(ALA_W.Value, caf.Value, CAA1.Value) as AlcCode
							  	,NULL as InformARegId
							  	,NULL as InformBRegId
							  	--,convert(nvarchar(50), ltrim(rtrim(Ala3.Value)))
							  	--,A.PartNumber
							  	--,coalesce(convert(varchar(3), ltrim(rtrim(CAA_FSM.Value))), '') 
							  	,alli.AnalytLotIntId
							from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotLink alli with(nolock)
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLot A with(nolock) 
									on A.AnalytLotIntId = Alli.AnalytLotIntId
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNoteLine cnl with(nolock) 	
									on CNL.CustNOte_Object = @Document_Object 
										and CNL.CustNoteDate = @DocumentDate 
										and CNL.CustNoteNumber = @DocumentNumber 
										and alli.LineNumber = cnl.LineNumber
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Ware W with(nolock) 
									on W.WareId = a.WareId 
										and W.IsLotControl = 1
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA1 with(nolock) 
									on CAA1.AdditionalAttribId = 'WARE_EGAIS' 
										and CAA1.Class_Object = 'Ware' 
										and CAA1.ClassId = W.WareId
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.EGAIS_Ware EW with(NOLOCK) 
									on EW.AlcCode = ltrim(rtrim(CAA1.Value))
								join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Unit U with(nolock) 
									on U.UnitId = CNL.UnitId
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA1 with(nolock) 
									on AlA1.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA1.AdditionalAttribId = 'InformARegId'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA2 with(nolock) 
									on AlA2.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA2.AdditionalAttribId = 'InformBRegId'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA3 with(nolock) 
									on AlA3.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA3.AdditionalAttribId = 'DateB'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA_W with(nolock) 
									on AlA_W.AnalytLotIntId = alli.AnalytLotIntId 
										and AlA_W.AdditionalAttribId in ('AlcCode','WL906')
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA_FSM with(nolock) 
									on CAA_FSM.AdditionalAttribId = 'EGAIS_FSMType' 
										and CAA_FSM.Class_Object = 'Ware' 
										and CAA_FSM.ClassId = W.WareId
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUF with(nolock) 
									on CUF.WareId = W.WareId 
										and CUF.UnitId = U.UnitId
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUFDAL with(nolock) 
									on CUFDAL.WareId = W.WareId 
										and CUFDAL.UnitId = 'dal'
								left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAttribHist caf with(nolock) 
									on caf.ClassId = w.WareId 
								        and caf.AttribId = 'WARE_EGAIS' 
										and caf.Class_Object = 'Ware' 
										and ala3.Value between caf.BeginDate and caf.EndDate
										and caf.Value is not null
								where alli.DocumentIntId = @DocumentIntId 
								  and alli.Direction = 1
							    group by W.WareId
							         ,W.WareName#Rus
							         ,U.UnitId
							         ,U.UnitName#Rus
							         ,ALA_W.Value
							         ,caf.Value
							         ,CAA1.Value
							         ,Ala3.Value
							         ,A.PartNumber
							         ,CAA_FSM.Value 
							         ,alli.AnalytLotIntId
							         ,EW.WareType
								     ,cnl.DiscountPrice
								     ,cuf.FactorValue
								     ,cufdal.FactorValue
						
		
						insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine(
										RAR_CustNoteId
										,Position_Identity
										,AlcCode
										,Quantity
										,RealQuantity
										,Price
										,InformProduction
										,InformMotion
										,AnalytLotIntId)
							select 
								@RAR_CustNoteId
								,Position_Identity
								,AlcCode
								,Quantity
								,Quantity
								,Price
								,InformARegId
								,InformBRegId
								,AnalytLotIntId
							from #RAR_CustNoteLine
	
					commit transaction
				end try
				begin catch
		
					select 
				        ERROR_NUMBER() AS ErrorNumber
				        ,ERROR_SEVERITY() AS ErrorSeverity
				        ,ERROR_STATE() AS ErrorState
				        ,ERROR_PROCEDURE() AS ErrorProcedure
				        ,ERROR_LINE() AS ErrorLine
				        ,ERROR_MESSAGE() AS ErrorMessage;

					rollback transaction
				end catch

			end
	

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_InsertEntry]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_InsertEntry]( @ActionDate datetime=NULL, @ClassId varchar(50)=NULL, @ConsigneeFSRAR_Id varchar(50)=NULL, @Direction smallint=NULL, @DocumentDate datetime=NULL, @DocumentIntId int=NULL, @DocumentNumber varchar(100)=NULL, @RAR_CustNoteId int=NULL OUTPUT, @ReplyId varchar(50)=NULL, @RowId uniqueidentifier=NULL, @ShipperFSRAR_Id varchar(50)=NULL, @Status varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote(
						DocumentIntId
						,DocumentNumber
						,DocumentDate
						,ActionDate
						,ClassId
						,ShipperFSRAR_Id
						,ConsigneeFSRAR_Id
						,Direction
						,Status
						,ReplyId
						,RowId)
		values(
			@DocumentIntId
			,@DocumentNumber
			,@DocumentDate
			,@ActionDate
			,@ClassId
			,@ShipperFSRAR_Id
			,@ConsigneeFSRAR_Id
			,@Direction
			,@Status
			,@ReplyId
			,@RowId)


	set @RAR_CustNoteId	= @@identity;
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_InsertToUTM_Data]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_InsertToUTM_Data]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      
	
	
	declare 
		@UniqueId int
		,@DocumentIntId int
		,@Version int
		,@ExchangeTypeCode varchar(50)
		,@Method nvarchar(255)
		,@Expression nvarchar(max)
	

	declare CustNote_Cursor cursor for
		select distinct cn.UniqueId, cn.DocumentIntId, cn.Version
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
		where cn.Status = 0

	open CustNote_Cursor

	fetch next from CustNote_Cursor
		into @UniqueId, @DocumentIntId, @Version

	while @@fetch_status = 0
		begin
			
			if isnull(@Version, 0) = 0
				begin
					select
						@ExchangeTypeCode = et.ExchangeTypeCode 
						,@Method = et.Method
					from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl
							on etl.Document_Object = d.Document_Object
								and etl.DocumentTypeId = d.DocumentTypeId
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
							on ec.ClassId = etl.UTM_ExchangeClass_ClassId
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
							on et.Id = ec.DefaultTypeId
					where d.DocumentIntId = @DocumentIntId
				end
			else
				begin
					select
						 @ExchangeTypeCode = et.ExchangeTypeCode 
						,@Method = et.Method
					from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl
							on etl.Document_Object = d.Document_Object
								and etl.DocumentTypeId = d.DocumentTypeId
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeVersion ev
							on ev.UTM_ExchangeClass_ClassId = etl.UTM_ExchangeClass_ClassId
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
							on et.Id = ev.UTM_ExchangeType_Id			
					where d.DocumentIntId = @DocumentIntId 
						and ev.Version = @Version
				end
	

			if isnull(@Method, '') <> ''
				begin
					set @Expression = N'exec ' + @Method + ' @UniqueId, @ExchangeTypeCode';
		
					exec sp_executesql @Expression, N'@UniqueId int, @ExchangeTypeCode varchar(50)'
							,@UniqueId = @UniqueId
							,@ExchangeTypeCode = @ExchangeTypeCode;
				end


			fetch next from CustNote_Cursor
				into @UniqueId, @DocumentIntId, @Version

		end

	close CustNote_Cursor
		deallocate CustNote_Cursor
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_J_SendDespatch]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_J_SendDespatch]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare @RAR_CustNoteId int

	declare RAR_CustNote_Cursor   cursor for   
		select cn.RAR_CustNoteId
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
				join mch.dbo.Document d
					on d.DocumentIntId = cn.DocumentIntId
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink utl
					on utl.Document_Object = d.Document_Object
						and utl.DocumentTypeId = d.DocumentTypeId
		where cn.Status = 'NotReady'
			and cn.Direction = -1
			and utl.UTM_ExchangeClass_ClassId = 'WayBill'
			and cn.ConsigneeFSRAR_Id is not null
			and cn.ShipperFSRAR_Id is not null
			and cn.ActionDate >= convert(date, getdate())
	  
	open RAR_CustNote_Cursor  
	 	
	fetch next from RAR_CustNote_Cursor   
		into @RAR_CustNoteId 
			
	while @@fetch_status = 0  
		begin
				
			declare @Status varchar(15) = 'New'

			if not exists(select top 1* 
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cl
							left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CompanyRests cr
								on cr.AlcCode = cl.AlcCode
									and cr.InformProduction = cl.InformProduction
									and cr.InformMotion = cl.InformMotion
					where cl.RAR_CustNoteId = @RAR_CustNoteId 
						and cl.Quantity > isnull(cr.Quantity, 0))
				and(select count(*) from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl where cnl.RAR_CustNoteId = @RAR_CustNoteId) <> 0
				begin

					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
								@RAR_CustNoteId = @RAR_CustNoteId
								,@Status = @Status

				end
			
			fetch next from RAR_CustNote_Cursor   
				into @RAR_CustNoteId 
						
		end

	close RAR_CustNote_Cursor
		deallocate RAR_CustNote_Cursor 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ListViewProduction]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ListViewProduction]( @PeriodBegin smalldatetime=NULL, @PeriodEnd smalldatetime=NULL, @UTMId int=NULL, @DocumentNumber varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    
      

	select rn.*
          ,ShipperName = sc.ShortName
          ,StatusDesc = s.Description
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote rn
    join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteStatus s on s.Status = rn.Status
    join mch.dbo.Document d on d.DocumentIntId = rn.DocumentIntId
    join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl on etl.Document_Object = d.Document_Object
                                     and etl.DocumentTypeId = d.DocumentTypeId
    left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company sc on sc.FSRAR_Id = rn.ShipperFSRAR_Id
	left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company cc on cc.FSRAR_Id = rn.ConsigneeFSRAR_Id
	left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u on u.FSRAR_Id = rn.ShipperFSRAR_Id
				       and u.UTMId = @UTMId
	where rn.DocumentDate between @PeriodBegin and @PeriodEnd
	  and (@UTMId is null or u.UTMId is not null)
	  and (@DocumentNumber is null or rn.DocumentNumber like '%' + @DocumentNumber + '%')
      and etl.UTM_ExchangeClass_ClassId = 'RepProducedProduct'
order by rn.DocumentDate desc
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ListViewWriteOff]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ListViewWriteOff]( @PeriodBegin smalldatetime=NULL, @PeriodEnd smalldatetime=NULL, @UTMId int=NULL, @DocumentNumber varchar(50)=NULL, @Status int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select rn.*
          ,ShipperName = sc.ShortName
          ,StatusDesc = s.Description
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote rn
    join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteStatus s on s.Status = rn.Status
    join mch.dbo.Document d on d.DocumentIntId = rn.DocumentIntId
    join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl on etl.Document_Object = d.Document_Object
                                     and etl.DocumentTypeId = d.DocumentTypeId
    left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company sc on sc.FSRAR_Id = rn.ShipperFSRAR_Id
	left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company cc on cc.FSRAR_Id = rn.ConsigneeFSRAR_Id
	left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u on u.FSRAR_Id = rn.ShipperFSRAR_Id
				       and u.UTMId = @UTMId
	where rn.DocumentDate between @PeriodBegin and @PeriodEnd
	  and (@UTMId is null or u.UTMId is not null)
	  and (@DocumentNumber is null or rn.DocumentNumber like '%' + @DocumentNumber + '%')
	  and (@Status is null or rn.Status = @Status)
      and etl.UTM_ExchangeClass_ClassId = 'ActWriteOff'
order by rn.DocumentDate desc
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ManualTransferPMInfo]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ManualTransferPMInfo]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare
		@InformMotion varchar(50)
		,@InformProduction varchar(50)
		,@AnalytLotIntId int
		,@ProductionAttrib varchar(50) = 'InformARegId'
		,@MotionAttrib varchar(50) = 'InformBRegId'
		,@CurrentStatus nvarchar(50)
	
	
	select @CurrentStatus = cn.Status
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
	where cn.RAR_CustNoteId = @RAR_CustNoteId


	if(@CurrentStatus = 'Recorded')
		begin
	
			declare CustNoteLine_Cursor	cursor for
				select 
					cnl.InformMotion
					,cnl.InformProduction
					,cnl.AnalytLotIntId
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine cnl
					where cnl.RAR_CustNoteId = @RAR_CustNoteId
			
			open CustNoteLine_Cursor
				
			fetch next from CustNoteLine_Cursor
				into
					@InformMotion
					,@InformProduction
					,@AnalytLotIntId
			
			while @@fetch_status = 0  
				begin
			
					if not exists(select top 1* 
									from mch.dbo.AnalytLotAttribute ala 
								where ala.AnalytLotIntId = @AnalytLotIntId 
									and ala.AdditionalAttribId = @ProductionAttrib)
						begin
			
							insert into mch.dbo.AnalytLotAttribute(AnalytLotIntId, AdditionalAttribId, Value)
								values(@AnalytLotIntId, @ProductionAttrib, @InformProduction)
			
						end
					else
						begin
			
							update mch.dbo.AnalytLotAttribute
								set [Value] = @InformProduction
							where AnalytLotIntId = @AnalytLotIntId
								and AdditionalAttribId = @ProductionAttrib
			
						end
			
					if not exists(select top 1* 
									from mch.dbo.AnalytLotAttribute ala 
								where ala.AnalytLotIntId = @AnalytLotIntId 
									and ala.AdditionalAttribId = @MotionAttrib)
						begin
			
							insert into mch.dbo.AnalytLotAttribute(AnalytLotIntId, AdditionalAttribId, Value)
								values(@AnalytLotIntId, @MotionAttrib, @InformMotion)
			
						end
					else
						begin
							
							update mch.dbo.AnalytLotAttribute
								set [Value] = @InformMotion
							where AnalytLotIntId = @AnalytLotIntId
								and AdditionalAttribId = @MotionAttrib
			
						end
			
					fetch next from CustNoteLine_Cursor
						into
							@InformMotion
							,@InformProduction
							,@AnalytLotIntId
			
				end 
			
			close CustNoteLine_Cursor
				deallocate CustNoteLine_Cursor

		end
	else
		begin

			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.ManualTransferPMInfo'                and Item=0), 'Производственный отчет не зафиксирован в ЕГАИС!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1

		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ManualUpdateDespatchStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ManualUpdateDespatchStatus]( @ShipperFSRAR_Id varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	declare @RAR_TicketId int

	declare Despatch_Accepted cursor for   
		select t.RAR_TicketId
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t 
					on t.ReplyId = cn.ReplyId
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket tl
					on tl.ReplyId = t.ReplyId	
						and tl.RegId = t.RegId
						and (tl.TicketDate < t.TicketDate or tl.OperationDate < t.OperationDate)
		where cn.Direction = -1
			and cn.Status = 'Accepted'
			and cn.DocumentType = 'WBInvoiceFromMe'	
			and t.OperationName = 'Confirm'
			and t.OperationResult = 'Accepted'	
	
	open Despatch_Accepted  
		 	
		fetch next from Despatch_Accepted 
			into @RAR_TicketId
	
		while @@fetch_status = 0  
			begin 
				
				exec bpRAR_Ticket_UpdateStatus
						@RAR_TicketId = @RAR_TicketId
						
				fetch next from Despatch_Accepted   
					into @RAR_TicketId
	
			end
	
	close Despatch_Accepted
		deallocate Despatch_Accepted 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ParseAccept]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ParseAccept]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@UniqueId int
		,@Descriptor int
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@IsAccept varchar(50)
		,@WBRegId varchar(50)	
		,@Note varchar(50)


	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 0
			and ud.Direction = 1

	
	exec sp_xml_preparedocument @Descriptor out, @Content, '<root
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
																xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
																xmlns:wa= "http://fsrar.ru/WEGAIS/ActTTNSingle_v3" 
																xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" />'


	begin try
		begin transaction

			select 
				@IsAccept = IsAccept
				,@WBRegId = WBRegId
				,@Note = Note
			from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:WayBillAct_v3/wa:Header', 1)
				with(
						IsAccept varchar(50) './wa:IsAccept'
						,WBRegId varchar(50) './wa:WBRegId'
						,Note varchar(50) './wa:Note'						
					)


			if(@IsAccept = 'Accepted' and @Note = 'Ok!' and @WBRegId is not null)
				begin
					
					select @UniqueId = cnl.UniqueId
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLink cnl
								on cnl.ReplyId = t.ReplyId
						where t.DocType = 'WayBill_v3'
							and t.OperationResult = 'Accepted'
							and t.OperationName = 'Confirm'
							and t.RegId = @WBRegId
							and t.TicketDate = (select max(t2.TicketDate) 
													from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t2 
												where t2.DocType = 'WayBill_v3' 
													and t2.OperationResult = 'Accepted' 
													and t.OperationName = 'Confirm' 
													and t.RegId = @WBRegId)

					
					exec bpRAR_CustNote_SetStatus
							@UniqueId = @UniqueId
							,@Status = 2	

				end

			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 1 where RowId = @RowId

		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ParseWayBill]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ParseWayBill]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare 
		@RAR_CustNoteId int
		,@Descriptor int
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@NUMBER varchar(50)
		,@Date datetime
		,@ShippingDate datetime
		,@Type varchar(50)
		,@ShipperFSRAR_Id varchar(50)
		,@ConsigneeFSRAR_Id varchar(50)
		,@Identity int
		,@WayBill_Identity varchar(255)
		,@DocumentIntId int
		,@UTMId int
		

	if object_id(N'tempdb..#Line', N'U') is not null
		drop table #Line

	create table #Line(
					Position_Identity int
					,AlcCode varchar(50)
					,Quantity decimal(16,4)
					,Price decimal(16,4)
					,Pack_Id varchar(50)
					,AnalytLotIntId int
					,FARegId varchar(50)
					,F2RegId varchar(50))


	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
		,@UTMId = ud.UTM_Id
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1


	declare @Namespace nvarchar(max)
	select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)
	select @Namespace = '<root ' + @Namespace + '/>'

	exec sp_xml_preparedocument @Descriptor out, @Content, @Namespace

	begin try
		begin transaction

			declare @rootPath nvarchar(256)
			select @rootPath = '/ns:Documents/ns:Document/ns:' + @ExchangeTypeCode
		
			select 
				@NUMBER = NUMBER
				,@Date = Date
				,@ShippingDate = ShippingDate 
				,@Type = Type
				,@ShipperFSRAR_Id = ShipperFSRAR_Id
				,@ConsigneeFSRAR_Id = ConsigneeFSRAR_Id
				,@WayBill_Identity = WayBill_Identity
			from openxml(@Descriptor, @rootPath, 1)
				with(
						NUMBER varchar(50) './wb:Header/wb:NUMBER'
						,Date datetime './wb:Header/wb:Date'
						,ShippingDate datetime './wb:Header/wb:ShippingDate'
						,Type varchar(50) './wb:Header/wb:Type'
						,ShipperFSRAR_Id varchar(50) './wb:Header/wb:Shipper/oref:UL/oref:ClientRegId'
						,ConsigneeFSRAR_Id varchar(50) './wb:Header/wb:Consignee/oref:UL/oref:ClientRegId'
						,WayBill_Identity varchar(255) './wb:Identity'
					)

			declare @positionPath nvarchar(256)
			select @positionPath = '/ns:Documents/ns:Document/ns:' + @ExchangeTypeCode + '/wb:Content/wb:Position'

			insert into #Line(
							Position_Identity
							,AlcCode 
							,Quantity 
							,Price 
							,Pack_Id 
							,AnalytLotIntId 
							,FARegId 
							,F2RegId)
				select
					Position_Identity
					,AlcCode 
					,Quantity 
					,Price 
					,Pack_Id 
					,case when isnumeric(Party) = 1 then coalesce(cast(Party as int), null) else null end  
					,FARegId 
					,F2RegId 
				from openxml(@Descriptor, @positionPath, 1)
					with 
						(	
							Position_Identity int './wb:Identity' 							
							,AlcCode varchar(50) './wb:Product/pref:AlcCode'
							,Quantity decimal(16,4) './wb:Quantity' 
							,Price decimal(16,4) './wb:Price' 
							,Pack_Id varchar(50) './wb:Pack_ID' 
							,Party varchar(50) './wb:Party' 
							,FARegId varchar(50) './wb:FARegId' 
							,F2RegId varchar(50) './wb:InformF2/ce:F2RegId' 					
						);


			declare @ClassId varchar(50)
			select @ClassId = case 
								when @Type = 'WBReturnFromMe' then @Type 
								else 'WayBill'
							  end

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_InsertEntry
						@DocumentNumber = @NUMBER
						,@DocumentDate = @Date
						,@ActionDate = @ShippingDate
						,@ClassId = @ClassId
						,@DocumentIntId = @DocumentIntId
						,@ShipperFSRAR_Id = @ShipperFSRAR_Id
						,@ConsigneeFSRAR_Id = @ConsigneeFSRAR_Id
						,@Direction = 1
						,@Status = 'New'
						,@RAR_CustNoteId = @RAR_CustNoteId out
		

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine(
							RAR_CustNoteId
							,Position_Identity
							,AlcCode
							,Quantity
							,RealQuantity
							,Price
							,InformProduction
							,InformMotion
							,AnalytLotIntId)
				select
					@RAR_CustNoteId
					,Position_Identity
					,AlcCode 
					,Quantity 
					,Quantity
					,Price 
					,FARegId 
					,F2RegId
					,AnalytLotIntId
				from #Line

				
			-- Обратный выкуп / приход от поставщика / возврат от магазинов и т.д.
			if(@ShipperFSRAR_Id not in(select u.FSRAR_Id from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u)) 
				begin
					
					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNoteExciseStamp_ParseWayBill
								@RAR_CustNoteId = @RAR_CustNoteId
			
				end
			

			declare @InformProduction varchar(50)

			--Запрос по справке "А"
			declare CustNoteLine_Cursor cursor for
				select cnl.FARegId from #Line cnl

			open CustNoteLine_Cursor

			fetch next from CustNoteLine_Cursor
				into @InformProduction

			while @@fetch_status = 0  
				begin
							
					exec mch.dbo.bpRAR_FormA_SendQueryFormA
									@UTMId = @UTMId
									,@InformProduction = @InformProduction
				
					fetch next from CustNoteLine_Cursor
						into @InformProduction
				end
		
			close CustNoteLine_Cursor
				deallocate CustNoteLine_Cursor	
			

			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
				set
					Status = 'New'
					,RowId = @RowId
			where RAR_CustNoteId = @RAR_CustNoteId


			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'

		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ParseWayBill_v3]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ParseWayBill_v3]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare 
		@RAR_CustNoteId int
		,@Descriptor int
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@NUMBER varchar(50)
		,@Date datetime
		,@ShippingDate datetime
		,@Type varchar(50)
		,@ShipperFSRAR_Id varchar(50)
		,@ConsigneeFSRAR_Id varchar(50)
		,@Identity int
		,@WayBill_Identity varchar(255)
		,@DocumentIntId int
		,@UTMId int
		

	if object_id(N'tempdb..#Line', N'U') is not null
		drop table #Line

	create table #Line(
					Position_Identity int
					,AlcCode varchar(50)
					,Quantity decimal(16,4)
					,Price decimal(16,4)
					,Pack_Id varchar(50)
					,AnalytLotIntId int
					,FARegId varchar(50)
					,F2RegId varchar(50))


	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
		,@UTMId = ud.UTM_Id
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1


	-- пространства имен для версии типа обмена с ЕГАИС
	declare @Namespace nvarchar(max)
	select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)
	select @Namespace = '<root ' + @Namespace + '/>'

	exec sp_xml_preparedocument @Descriptor out, @Content, @Namespace

	begin try
		begin transaction

			declare @rootPath nvarchar(256)
			select @rootPath = '/ns:Documents/ns:Document/ns:' + @ExchangeTypeCode
		
			select 
				@NUMBER = NUMBER
				,@Date = Date
				,@ShippingDate = ShippingDate 
				,@Type = Type
				,@ShipperFSRAR_Id = ShipperFSRAR_Id
				,@ConsigneeFSRAR_Id = ConsigneeFSRAR_Id
				,@WayBill_Identity = WayBill_Identity
			from openxml(@Descriptor, @rootPath, 1)
				with(
						NUMBER varchar(50) './wb:Header/wb:NUMBER'
						,Date datetime './wb:Header/wb:Date'
						,ShippingDate datetime './wb:Header/wb:ShippingDate'
						,Type varchar(50) './wb:Header/wb:Type'
						,ShipperFSRAR_Id varchar(50) './wb:Header/wb:Shipper/oref:UL/oref:ClientRegId'
						,ConsigneeFSRAR_Id varchar(50) './wb:Header/wb:Consignee/oref:UL/oref:ClientRegId'
						,WayBill_Identity varchar(255) './wb:Identity'
					)

			declare @positionPath nvarchar(256)
			select @positionPath = '/ns:Documents/ns:Document/ns:' + @ExchangeTypeCode + '/wb:Content/wb:Position'

			insert into #Line(
							Position_Identity
							,AlcCode 
							,Quantity 
							,Price 
							,Pack_Id 
							,AnalytLotIntId 
							,FARegId 
							,F2RegId)
				select
					Position_Identity
					,AlcCode 
					,Quantity 
					,Price 
					,Pack_Id 
					,case when isnumeric(Party) = 1 then coalesce(cast(Party as int), null) else null end  
					,FARegId 
					,F2RegId 
				from openxml(@Descriptor, @positionPath, 1)
					with 
						(	
							Position_Identity int './wb:Identity' 							
							,AlcCode varchar(50) './wb:Product/pref:AlcCode'
							,Quantity decimal(16,4) './wb:Quantity' 
							,Price decimal(16,4) './wb:Price' 
							,Pack_Id varchar(50) './wb:Pack_ID' 
							,Party varchar(50) './wb:Party' 
							,FARegId varchar(50) './wb:FARegId' 
							,F2RegId varchar(50) './wb:InformF2/ce:F2RegId' 					
						);


			declare @ClassId varchar(50)
			select @ClassId = case 
								when @Type = 'WBReturnFromMe' then @Type 
								else 'WayBill'
							  end

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_InsertEntry
						@DocumentNumber = @NUMBER
						,@DocumentDate = @Date
						,@ActionDate = @ShippingDate
						,@ClassId = @ClassId
						,@DocumentIntId = @DocumentIntId
						,@ShipperFSRAR_Id = @ShipperFSRAR_Id
						,@ConsigneeFSRAR_Id = @ConsigneeFSRAR_Id
						,@Direction = 1
						,@Status = 'New'
						,@RAR_CustNoteId = @RAR_CustNoteId out
		

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine(
							RAR_CustNoteId
							,Position_Identity
							,AlcCode
							,Quantity
							,RealQuantity
							,Price
							,InformProduction
							,InformMotion
							,AnalytLotIntId)
				select
					@RAR_CustNoteId
					,Position_Identity
					,AlcCode 
					,Quantity 
					,Quantity
					,Price 
					,FARegId 
					,F2RegId
					,AnalytLotIntId
				from #Line

				
			-- Обратный выкуп / приход от поставщика / возврат от магазинов и т.д.
			if(@ShipperFSRAR_Id not in(select u.FSRAR_Id from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u)) 
				begin
					
					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNoteExciseStamp_ParseWayBill
								@RAR_CustNoteId = @RAR_CustNoteId
			
				end
			

			declare @InformProduction varchar(50)

			--Запрос по справке "А"
			declare CustNoteLine_Cursor cursor for
				select cnl.FARegId from #Line cnl

			open CustNoteLine_Cursor

			fetch next from CustNoteLine_Cursor
				into @InformProduction

			while @@fetch_status = 0  
				begin
							
					exec mch.dbo.bpRAR_FormA_SendQueryFormA
									@UTMId = @UTMId
									,@InformProduction = @InformProduction
				
					fetch next from CustNoteLine_Cursor
						into @InformProduction
				end
		
			close CustNoteLine_Cursor
				deallocate CustNoteLine_Cursor	
			

			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
				set
					Status = 'New'
					,RowId = @RowId
			where RAR_CustNoteId = @RAR_CustNoteId


			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'

		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ParseWayBillAct]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ParseWayBillAct]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@UniqueId int
		,@Descriptor int
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@IsAccept varchar(50)
		,@WBRegId varchar(50)	
		,@Note varchar(50)


	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 0
			and ud.Direction = 1

	
	exec sp_xml_preparedocument @Descriptor out, @Content, '<root
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
																xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
																xmlns:wa= "http://fsrar.ru/WEGAIS/ActTTNSingle_v3" 
																xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" />'


	begin try
		begin transaction

			select 
				@IsAccept = IsAccept
				,@WBRegId = WBRegId
				,@Note = Note
			from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:WayBillAct_v3/wa:Header', 1)
				with(
						IsAccept varchar(50) './wa:IsAccept'
						,WBRegId varchar(50) './wa:WBRegId'
						,Note varchar(50) './wa:Note'						
					)

			
		select @UniqueId = cnl.UniqueId
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLink cnl
								on cnl.ReplyId = t.ReplyId
						where t.DocType = 'WayBill_v3'
							and t.OperationResult = 'Accepted'
							and t.OperationName = 'Confirm'
							and t.RegId = @WBRegId
							and t.TicketDate = (select max(t2.TicketDate) 
													from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t2 
												where t2.DocType = 'WayBill_v3' 
													and t2.OperationResult = 'Accepted' 
													and t.OperationName = 'Confirm' 
													and t.RegId = @WBRegId)


			if(@IsAccept = 'Accepted' and @Note = 'Ok!' and @WBRegId is not null)
				begin
					
					exec bpRAR_CustNote_SetStatus
							@UniqueId = @UniqueId
							,@Status = 2	

				end
			else if(@IsAccept = 'Rejected' and @Note = 'No!' and @WBRegId is not null)
				begin
			
					exec bpRAR_CustNote_SetStatus
							@UniqueId = @UniqueId
							,@Status = 4

				end

			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 1 where RowId = @RowId

		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SendAccept]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SendAccept]( @UniqueId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@Content nvarchar(max)
		,@ActDate datetime
		,@RegNumber varchar(50)
		,@FSRAR_Id varchar(50)
		,@ExchangeTypeCode varchar(50)
		,@ClassId varchar(50) =	'WayBillAct'
		,@URL varchar(255)
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@Direction smallint = -1
		,@Status smallint = 0
			

	select 
		@ExchangeTypeCode = et.ExchangeTypeCode
		,@UTM_Path = et.UTM_Path
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.Id = ec.DefaultTypeId
	where ec.ClassId = @ClassId


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@UTM_Id = u.Id
		,@URL = u.URL 
	from RAR_CustNote cn
		join RAR_CustNoteLink cnl
			on cnl.UniqueId = cn.UniqueId
		join UTM_Data ud
			on ud.RowId = cnl.RowId
		join UTM u 
			on u.Id = ud.UTM_Id
	where cn.UniqueId = @UniqueId


	/*if exists(select * from _EG.UTM u where u.FSRAR_Id = @ConsigneeFSRAR_Id)
		begin
			select @RegNumber = (select top 1 mi.RegNumber from _EG.RAR_MotionInfo mi where mi.UniqueId = @UniqueId)	
		end
	else
		begin
			select @RegNumber = (select top 1 mi.RegNumber 
									from _EG.RAR_CustNote cn
										join _EG.RAR_MotionInfo mi
											on mi.DocumentNumber = cn.DocumentNumber
												and mi.DocumentDate = cn.DocumentDate
												and mi.ReplyId is null
								where cn.UniqueId = @UniqueId)
		end*/

	
	select @RegNumber = (select top 1 mi.RegNumber 
									from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
										join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
											on mi.DocumentNumber = cn.DocumentNumber
												and mi.DocumentDate = cn.DocumentDate
												and mi.ReplyId is null
								where cn.UniqueId = @UniqueId)


	set @ActDate = getdate();

 	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents Version="1.0"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
								xmlns:wa= "http://fsrar.ru/WEGAIS/ActTTNSingle_v3"
								xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" >
								<ns:Owner>
									<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:WayBillAct_v3>
										<wa:Header>
											<wa:IsAccept>Accepted</wa:IsAccept>
											<wa:ACTNUMBER>' + convert(varchar(50), @UniqueId) + '</wa:ACTNUMBER>
											<wa:ActDate>' + convert(varchar(50), @ActDate, 23) + '</wa:ActDate>
											<wa:WBRegId>' + coalesce(@RegNumber, '') +'</wa:WBRegId>
											<wa:Note>Ok!</wa:Note>
										</wa:Header>
										<wa:Content>
										</wa:Content>
									</ns:WayBillAct_v3>
								</ns:Document>
							</ns:Documents>'


	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendAccept'                and Item=0), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@URL, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendAccept'                and Item=1), 'Ошибка отправки запроса! Отсутствует URL для отправки')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendAccept'                and Item=2), 'Ошибка отправки запроса! Отсутствует путь для типа обмена в УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@RegNumber, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendAccept'                and Item=3), 'Ошибка отправки запроса! Отсутствует регистрационный номер ТТН')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			begin try
				begin transaction

					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,@URL + @UTM_Path
						,getdate()
						,@Direction
						,@UTM_Id
						,@Status
						,@ExchangeTypeCode


					exec bpRAR_CustNote_SetStatus
							@UniqueId = @UniqueId
							,@Status = 2

				commit transaction

			end try
			begin catch
				
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;

				rollback transaction

			end catch
		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SendQueryRejectRepProduced]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SendQueryRejectRepProduced]( @RAR_CustNoteId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


	declare 
		@FSRAR_Id varchar(50)
		,@RegId varchar(50)
		,@Content nvarchar(max)
		,@ClassId varchar(50) = 'QueryRejectRepProduced'
		,@ExchangeTypeCode varchar(50)	
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@Direction smallint = -1
		,@Status smallint = 0


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@RegId = t.RegId
		,@ExchangeTypeCode = et.ExchangeTypeCode 
		,@UTM_Path = u.URL + et.UTM_Path
		,@UTM_Id = u.UTMId
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLink cnlk
			on cnlk.RAR_CustNoteId = cn.RAR_CustNoteId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
			on t.ReplyId = cnlk.ReplyId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
			on ud.RowId = cnlk.RowId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.UTMId = ud.UTM_Id
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
			on ec.ClassId = @ClassId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.UTM_ExchangeTypeId = ec.DefaultTypeId
	where cn.RAR_CustNoteId = @RAR_CustNoteId 
		and t.OperationName = 'Confirm'
		and t.OperationResult = 'Accepted'


	if isnull(@FSRAR_Id, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryRejectRepProduced'                and Item=0), 'Ошибка отправки запроса! Отсутствует ФСРАР_ИД отправителя документа')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
	
	if isnull(@RegId, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryRejectRepProduced'                and Item=1), 'Ошибка отправки запроса! Отсутствует регистрационный номер документа')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryRejectRepProduced'                and Item=2), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryRejectRepProduced'                and Item=3), 'Ошибка отправки запроса! Отсутствует URL для отправки')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end  


	select @Content = '<?xml version="1.0" encoding="utf-8"?>' + char(13) +
							'<ns:Documents Version="1.0"' + char(13) +
								'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + char(13) +
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13) +
								'xmlns:qrrp="http://fsrar.ru/WEGAIS/QueryRejectRepProduced">' + char(13) +
								'<ns:Owner>' + char(13) +
									'<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>' + char(13) +
								'</ns:Owner>' + char(13) +
								'<ns:Document>' + char(13) +
									'<ns:QueryRejectRepProduced>' + char(13) +
										'<qrrp:RegId>' + coalesce(@RegId, '') + '</qrrp:RegId>' + char(13) +
									'</ns:QueryRejectRepProduced>' + char(13) +
								'</ns:Document>' + char(13) +
							'</ns:Documents>'


	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			insert into UTM_Data(
				Content
				,URL
				,CreateTime
				,Direction
				,UTM_ID
				,Status
				,ExchangeTypeCode)
			select 
				@Content
				,@UTM_Path
				,getdate()
				,@Direction
				,@UTM_Id
				,@Status
				,@ExchangeTypeCode
		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SendQueryResendDoc]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SendQueryResendDoc]( @FSRAR_Id varchar(50), @RegId varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Content nvarchar(max)
		,@ClassId varchar(50) = 'QueryResendDoc'
		,@ExchangeTypeCode varchar(50)	
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@Direction smallint = -1
		,@Status smallint = 0 


	select 
		@ExchangeTypeCode = et.ExchangeTypeCode
		,@UTM_Path = u.URL + et.UTM_Path
		,@UTM_Id = u.UTMId
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.UTM_ExchangeTypeId = ec.DefaultTypeId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.FSRAR_Id = @FSRAR_Id
	where ec.ClassId = @ClassId	


	if isnull(@FSRAR_Id, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryResendDoc'                and Item=0), 'Ошибка отправки запроса! Отсутствует ФСРАР_ИД инициатора запроса')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
	
	if isnull(@RegId, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryResendDoc'                and Item=1), 'Ошибка отправки запроса! Отсутствует регистрационный номер документа')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryResendDoc'                and Item=2), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendQueryResendDoc'                and Item=3), 'Ошибка отправки запроса! Отсутствует URL для отправки')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 


	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents Version="1.0"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
								xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters" >
								<ns:Owner>
									<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:QueryResendDoc>
										<qp:Parameters>
											<qp:Parameter>
												<qp:Name>WBREGID</qp:Name>
												<qp:Value>' + coalesce(@RegId, '') + '</qp:Value>
											</qp:Parameter>
										</qp:Parameters>
									</ns:QueryResendDoc>
								</ns:Document>
							</ns:Documents>'


	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			insert into UTM_Data(
				Content
				,URL
				,CreateTime
				,Direction
				,UTM_ID
				,Status
				,ExchangeTypeCode)
			select 
				@Content
				,@UTM_Path
				,getdate()
				,@Direction
				,@UTM_Id
				,@Status
				,@ExchangeTypeCode
		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SendReject]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SendReject]( @UniqueId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@Content nvarchar(max)
		,@ActDate datetime
		,@RegNumber varchar(50)
		,@FSRAR_Id varchar(50)
		,@ExchangeTypeCode varchar(50)
		,@ClassId varchar(50) =	'WayBillAct'
		,@URL varchar(255)
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@Direction smallint = -1
		,@Status smallint = 0


	select 
		@ExchangeTypeCode = et.ExchangeTypeCode
		,@UTM_Path = et.UTM_Path
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.Id = ec.DefaultTypeId
	where ec.ClassId = @ClassId


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@UTM_Id = u.Id
		,@URL = u.URL 
	from RAR_CustNote cn
		join RAR_CustNoteLink cnl
			on cnl.UniqueId = cn.UniqueId
		join UTM_Data ud
			on ud.RowId = cnl.RowId
		join UTM u 
			on u.Id = ud.UTM_Id
	where cn.UniqueId = @UniqueId


	select @RegNumber = (select top 1 mi.RegNumber 
									from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
										join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
											on mi.DocumentNumber = cn.DocumentNumber
												and mi.DocumentDate = cn.DocumentDate
												and mi.ReplyId is null
								where cn.UniqueId = @UniqueId)

	
	set @ActDate = getdate();
	
	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents Version="1.0"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
								xmlns:wa= "http://fsrar.ru/WEGAIS/ActTTNSingle_v3"
								xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" >
								<ns:Owner>
									<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:WayBillAct_v3>
										<wa:Header>
											<wa:IsAccept>Rejected</wa:IsAccept>
											<wa:ACTNUMBER>' + convert(varchar(50), @UniqueId) + '</wa:ACTNUMBER>
											<wa:ActDate>' + convert(varchar(50), @ActDate, 23) + '</wa:ActDate>
											<wa:WBRegId>' + coalesce(@RegNumber, '') +'</wa:WBRegId>
											<wa:Note>No!</wa:Note>
										</wa:Header>
										<wa:Content>
										</wa:Content>
									</ns:WayBillAct_v3>
								</ns:Document>
							</ns:Documents>'


	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendReject'                and Item=0), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@URL, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendReject'                and Item=1), 'Ошибка отправки запроса! Отсутствует URL для отправки')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendReject'                and Item=2), 'Ошибка отправки запроса! Отсутствует путь для типа обмена в УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@RegNumber, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendReject'                and Item=3), 'Ошибка отправки запроса! Отсутствует регистрационный номер ТТН')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			begin try
				begin transaction

					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,@URL + @UTM_Path
						,getdate()
						,@Direction
						,@UTM_Id
						,@Status
						,@ExchangeTypeCode


					exec bpRAR_CustNote_SetStatus
							@UniqueId = @UniqueId
							,@Status = 2

				commit transaction

			end try
			begin catch
				
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;

				rollback transaction

			end catch
		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SendRequestRepealWB]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SendRequestRepealWB]( @UniqueId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	 declare 
		@FSRAR_Id varchar(50)
		,@RegId varchar(50)
		,@Content nvarchar(max)
		,@ClassId varchar(50) = 'RequestRepealWB'
		,@ExchangeTypeCode varchar(50)	
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@ActDate datetime
		,@Direction smallint = -1
		,@Status smallint = 0


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@RegId = mi.RegNumber
		,@UTM_Id = u.Id
		,@UTM_Path = u.URL + et.UTM_Path
		,@ExchangeTypeCode = et.ExchangeTypeCode
	from RAR_CustNote cn
		join RAR_CustNoteLink cnl
			on cnl.UniqueId = cn.UniqueId
		join UTM_Data ud
			on ud.RowId = cnl.RowId
		join UTM u
			on u.Id = ud.UTM_Id
		join RAR_MotionInfo mi
			on mi.DocumentNumber = cn.DocumentNumber
				and mi.DocumentDate = cn.DocumentDate	
				and mi.ReplyId is null
				and cn.DocumentIntId is null	
		left join UTM_ExchangeClass ec
			on ec.ClassId = @ClassId
		left join UTM_ExchangeType et
			on et.Id = ec.DefaultTypeId
				and et.Direction = @Direction
	where cn.UniqueId = @UniqueId


	set @ActDate = getdate();

	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents Version="1.0"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
								xmlns:qp="http://fsrar.ru/WEGAIS/RequestRepealWB">
								<ns:Owner>
									<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:RequestRepealWB>
										<qp:ClientId>' + coalesce(@FSRAR_Id, '') + '</qp:ClientId>
										<qp:RequestNumber>' + convert(varchar(50), @UniqueId) + '</qp:RequestNumber>
										<qp:RequestDate>' + convert(varchar(50), @ActDate, 126) + '</qp:RequestDate>
										<qp:WBRegId>' + coalesce(@RegId, '') + '</qp:WBRegId>
									</ns:RequestRepealWB>
								</ns:Document>
							</ns:Documents>'

	
	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendRequestRepealWB'                and Item=0), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendRequestRepealWB'                and Item=1), 'Ошибка отправки запроса! Отсутствует путь для типа обмена в УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@RegId, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendRequestRepealWB'                and Item=2), 'Ошибка отправки запроса! Отсутствует регистрационный номер ТТН')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			begin try
				begin transaction

					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,@UTM_Path
						,getdate()
						,@Direction
						,@UTM_Id
						,@Status
						,@ExchangeTypeCode

				commit transaction

			end try
			begin catch
				
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;

				rollback transaction

			end catch
		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SendWayBillAct]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SendWayBillAct]( @UniqueId int, @IsAccept smallint=1 )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@Content nvarchar(max)
		,@ActDate datetime
		,@RegNumber varchar(50)
		,@FSRAR_Id varchar(50)
		,@ExchangeTypeCode varchar(50)
		,@ClassId varchar(50) =	'WayBillAct'
		,@URL varchar(255)
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@Direction smallint = -1
		,@Status smallint = 0
			

	select 
		@ExchangeTypeCode = et.ExchangeTypeCode
		,@UTM_Path = et.UTM_Path
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.Id = ec.DefaultTypeId
	where ec.ClassId = @ClassId


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@UTM_Id = u.Id
		,@URL = u.URL 
	from RAR_CustNote cn
		join RAR_CustNoteLink cnl
			on cnl.UniqueId = cn.UniqueId
		join UTM_Data ud
			on ud.RowId = cnl.RowId
		join UTM u 
			on u.Id = ud.UTM_Id
	where cn.UniqueId = @UniqueId


	/*if exists(select * from _EG.UTM u where u.FSRAR_Id = @ConsigneeFSRAR_Id)
		begin
			select @RegNumber = (select top 1 mi.RegNumber from _EG.RAR_MotionInfo mi where mi.UniqueId = @UniqueId)	
		end
	else
		begin
			select @RegNumber = (select top 1 mi.RegNumber 
									from _EG.RAR_CustNote cn
										join _EG.RAR_MotionInfo mi
											on mi.DocumentNumber = cn.DocumentNumber
												and mi.DocumentDate = cn.DocumentDate
												and mi.ReplyId is null
								where cn.UniqueId = @UniqueId)
		end*/

	
	select @RegNumber = (select top 1 mi.RegNumber 
									from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
										join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
											on mi.DocumentNumber = cn.DocumentNumber
												and mi.DocumentDate = cn.DocumentDate
												and mi.ReplyId is null
								where cn.UniqueId = @UniqueId)


	if(@IsAccept <> 2)	
		begin

			set @ActDate = getdate();
		
		 	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
									<ns:Documents Version="1.0"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
										xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
										xmlns:wa= "http://fsrar.ru/WEGAIS/ActTTNSingle_v3"
										xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" >
										<ns:Owner>
											<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
										</ns:Owner>
										<ns:Document>
											<ns:WayBillAct_v3>
												<wa:Header>
													<wa:IsAccept>' + case @IsAccept when 1 then 'Accepted' when 0 then 'Rejected' end + '</wa:IsAccept>
													<wa:ACTNUMBER>' + convert(varchar(50), @UniqueId) + '</wa:ACTNUMBER>
													<wa:ActDate>' + convert(varchar(50), @ActDate, 23) + '</wa:ActDate>
													<wa:WBRegId>' + coalesce(@RegNumber, '') +'</wa:WBRegId>
													<wa:Note>' + case @IsAccept when 1 then 'Ok!' when 0 then 'No!' end + '</wa:Note>
												</wa:Header>
												<wa:Content>
												</wa:Content>
											</ns:WayBillAct_v3>
										</ns:Document>
									</ns:Documents>'

		end



	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendWayBillAct'                and Item=0), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@URL, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendWayBillAct'                and Item=1), 'Ошибка отправки запроса! Отсутствует URL для отправки')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendWayBillAct'                and Item=2), 'Ошибка отправки запроса! Отсутствует путь для типа обмена в УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@RegNumber, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNote.SendWayBillAct'                and Item=3), 'Ошибка отправки запроса! Отсутствует регистрационный номер ТТН')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			begin try
				begin transaction

					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,@URL + @UTM_Path
						,getdate()
						,@Direction
						,@UTM_Id
						,@Status
						,@ExchangeTypeCode


					exec bpRAR_CustNote_SetStatus
							@UniqueId = @UniqueId
							,@Status = 2

				commit transaction

			end try
			begin catch
				
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;

				rollback transaction

			end catch
		end 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SetDocumentType]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SetDocumentType]( @RAR_CustNoteId int=NULL, @DocumentType varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
		set DocumentType = @DocumentType
	where RAR_CustNoteId = @RAR_CustNoteId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SetRowId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SetRowId]( @RAR_CustNoteId int=NULL, @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
		set RowId = @RowId
	where RAR_CustNoteId = @RAR_CustNoteId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_SetStatus]( @RAR_CustNoteId int, @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
		set Status = @Status
	where RAR_CustNoteId = @RAR_CustNoteId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ViewBarCode]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ViewBarCode]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select *
from RAR_CustNote cn
join mch.dbo.Document d on d.documentintid = cn.documentintid
join excisestamp.dbo.ExciseStampDocument esd on esd.documentintid = d.documentintid
join excisestamp.dbo.ExciseStampSet ess on ess.StampSetId = esd.StampSetId
join excisestamp.dbo.ExciseStampSetLine esl on esl.ParentId = ess.StampSetId
join excisestamp.dbo.ExciseStamp es on es.StampId = esl.DescendantId
where d.document_object = 'ProdReceipt'
  and cn.RAR_CustNoteId = @RAR_CustNoteId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ViewBCWriteOff]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ViewBCWriteOff]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select distinct ROW_NUMBER() OVER(ORDER BY est.BarCode ASC) AS RowBC, est.BarCode
from RAR_CustNote rn
join RAR_CustNoteStatus s on s.Status = rn.Status
join mch.dbo.Document d on d.DocumentIntId = rn.DocumentIntId
join UTM_ExchangeTypeLink etl on etl.Document_Object = d.Document_Object
                             and etl.DocumentTypeId = d.DocumentTypeId
join mch.dbo.ExciseStampTurnover est on est.DocumentIntId = d.DocumentIntId
where etl.UTM_ExchangeClass_ClassId = 'ActWriteOff'
  and rn.RAR_CustNoteId = @RAR_CustNoteId
order by RowBC
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ViewHistoryWayBill]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ViewHistoryWayBill]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    set CONCAT_NULL_YIELDS_NULL on
set ANSI_WARNINGS on
set ANSI_PADDING on

      
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     

select
	cn.RAR_CustNoteId	
	,t.TicketDate
	,FixNumber = NULL
	,FixDate = t.OperationDate       
	,RegNumber = coalesce(wba.RegId, t.RegId)
	,Comment = t.OperationComment
       ,ReplyId = t.ReplyId
from RAR_CustNote cn
	join RAR_WayBillAct wba
		on wba.RAR_CustNoteId = cn.RAR_CustNoteId
	join RAR_Ticket t
		on t.ReplyId = wba.ReplyId
where cn.RAR_CustNoteId = @RAR_CustNoteId
	order by t.TicketDate desc
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNote_ViewProducer]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNote_ViewProducer]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

declare @FSRAR_Id varchar(50)

select @FSRAR_Id = cn.ShipperFSRAR_Id
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
where cn.RAR_CustNoteId = @RAR_CustNoteId

select MemberType = 'Производитель',
	FSRAR_Id,
	ShortName = isnull(SubstitutionName,ShortName),
	TaxCode,
	TaxReason,
	Location
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Company sc
where sc.FSRAR_Id = @FSRAR_Id
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteAttribute_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteAttribute_Delete]( @AttributeId varchar(50)=NULL, @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     

	
	delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute
		where RAR_CustNoteId = @RAR_CustNoteId
			and AttributeId = @AttributeId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteAttribute_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteAttribute_Insert]( @AttributeId varchar(50)=NULL, @RAR_CustNoteId int=NULL, @Value varchar(255)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


	if not exists(select top 1*
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute cna
				where cna.RAR_CustNoteId = @RAR_CustNoteId
					and cna.AttributeId = @AttributeId)
		begin

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute(
								RAR_CustNoteId
								,AttributeId
								,Value)
				values(
					@RAR_CustNoteId
					,@AttributeId
					,@Value)

		end
	else
		begin

			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNoteAttribute.Insert'                and Item=0), 'Данный атрибут для документа уже существует!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1

		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteAttribute_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteAttribute_Update]( @AttributeId varchar(50)=NULL, @RAR_CustNoteId int=NULL, @Value varchar(255)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


	if not exists(select top 1*
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute cna
				where cna.RAR_CustNoteId = @RAR_CustNoteId
					and cna.AttributeId = @AttributeId)
		begin
	
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNoteAttribute_Insert
						@RAR_CustNoteId = @RAR_CustNoteId
						,@AttributeId = @AttributeId
						,@Value = @Value

		end
	else
		begin
			
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute
				set Value = @Value
			where RAR_CustNoteId = @RAR_CustNoteId
				and AttributeId = @AttributeId

		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteContent_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteContent_Insert]( @UniqueId int, @Content nvarchar(max) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteContent(UniqueId, Content, Status) 
		values(@UniqueId, @Content, 0)
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteContent_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteContent_Update]( @UniqueId int, @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	if(@RowId is not null)
		begin
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteContent
				set RowiD = @RowId
			where UniqueId = @UniqueId
		end
	
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteExciseStamp_CheckCountOfStamps]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteExciseStamp_CheckCountOfStamps]( @RAR_CustNoteId int=NULL, @Result bit=1 OUTPUT, @Message varchar(255) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


	declare 
		@Position_Identity int
		,@Quantity decimal(16,4)
		,@StampCount int
		,@InformProduction varchar(50)
		,@InformMotion varchar(50)
	
	
	declare Line cursor local  for
			select distinct
				cnl.Position_Identity
				,cnl.Quantity
				,cnl.InformProduction
				,cnl.InformMotion
		from RAR_CustNoteLine cnl
			where cnl.RAR_CustNoteId = @RAR_CustNoteId
		
	open Line
	
	fetch next from Line 
		into 
			@Position_Identity
			,@Quantity  
			,@InformProduction
			,@InformMotion
		
	while @@fetch_status = 0
		begin
	
			if (select top 1
				len(es.StampBarCode)
					from mch.dbo.AnalytLotAttribute ala
						join [MSK-HQ-MNT01\ERP_MAIN].ExciseStamp.dbo.ExciseStamp es
							on es.AnalytLotIntId = ala.AnalytLotIntId
					where ala.AdditionalAttribId = 'InformARegId'
						and ala.Value = @InformProduction) = 150 -- если эта партия марочная, проверяем количество в позиции с количеством марок
				begin
	
					select @StampCount = count(stamp.StampBarCode)
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteExciseStamp stamp					
					where stamp.RAR_CustNoteId = @RAR_CustNoteId
						and stamp.Position_Identity = @Position_Identity
	
					if @Quantity <> @StampCount
						select 
							@Result = 1
							,@Message = 'В позиции ' + convert(varchar(50),@Position_Identity) + ' неверное количество марок!'
	
				end			 
	
			fetch next from Line 
				into 
					@Position_Identity
					,@Quantity  
					,@InformProduction
					,@InformMotion
	
		end
	
	close Line
		deallocate Line 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteExciseStamp_ParseWayBill]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteExciseStamp_ParseWayBill]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare  
		@XMLContent xml
		,@Descriptor int
		,@ExchangeTypeCode nvarchar(64)


	select  
		@XMLContent = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
	 	join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
			on ud.RowId = cn.RowId 
		where cn.RAR_CustNoteId = @RAR_CustNoteId
			and cn.Direction = 1

	if @XMLContent is null
		return 1


	set ansi_warnings on;
	set ANSI_NULLS on;
	set CONCAT_NULL_YIELDS_NULL on; 
	set ANSI_PADDING on;

	begin try
		begin transaction 

			if object_id(N'tempdb..#Stamps', N'U') is not null
				drop table #Stamps	
								
			create table #Stamps(
							Position_Identity int
							,Boxnumber varchar(50)
							,Stamp varchar(500))
			
			if object_id(N'tempdb..#Pallets', N'U') is not null
				drop table #Pallets	
								
			create table #Pallets(
							Position_Identity int
							,Pallet varchar(50)
							,Boxnumber varchar(50))

			if @ExchangeTypeCode = 'WayBill_v3'
				begin
		
					;with XMLNAMESPACES (  
							   'http://www.w3.org/2001/XMLSchema-instance' as xsi
							   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
							   ,'http://fsrar.ru/WEGAIS/ClientRef_v2' as oref
							   ,'http://fsrar.ru/WEGAIS/ProductRef_v2' as pref
							   ,'http://fsrar.ru/WEGAIS/TTNSingle_v3' as wb
							   ,'http://fsrar.ru/WEGAIS/CommonV3' as ce)
					
					insert into #Stamps 
						select 
							Position_Identity = Position.value('wb:Identity[1]', 'int')
							,Boxnumber = Boxpos.value('ce:boxnumber[1]', 'varchar(50)')
							,Stamp = Amc.value('.', 'varchar(500)')
						from @XMLContent.nodes('/ns:Documents/ns:Document/ns:WayBill_v3/wb:Content/wb:Position') as Position (Position)
							outer apply Position.nodes('wb:InformF2') as InformF2 (InformF2)
							outer apply InformF2.nodes('ce:MarkInfo') as MarkInfo (MarkInfo)
							outer apply MarkInfo.nodes('ce:boxpos') as Boxpos (Boxpos)
							outer apply Boxpos.nodes('ce:amclist') as Amclist (Amclist)
							outer apply Amclist.nodes('ce:amc') as Amc (Amc)
						order by Position_Identity, Boxnumber
				
			
					;with XMLNAMESPACES (  
							   'http://www.w3.org/2001/XMLSchema-instance' as xsi
							   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
							   ,'http://fsrar.ru/WEGAIS/ClientRef_v2' as oref
							   ,'http://fsrar.ru/WEGAIS/ProductRef_v2' as pref
							   ,'http://fsrar.ru/WEGAIS/TTNSingle_v3' as wb
							   ,'http://fsrar.ru/WEGAIS/CommonV3' as ce)
					
					insert into #Pallets
						select 
							Position_Identity = Position.value('wb:Identity[1]', 'int')
							,Pallet = Boxtree.value('ce:boxnum[1]', 'varchar(50)')
							,Boxnumber = Boxnum.value('.', 'varchar(50)')
						from @XMLContent.nodes('/ns:Documents/ns:Document/ns:WayBill_v3/wb:Content/wb:Position') as Position (Position)
							outer apply Position.nodes('wb:boxInfo') as BoxInfo (BoxInfo)
							outer apply BoxInfo.nodes('wb:boxtree') as Boxtree (Boxtree)
							outer apply Boxtree.nodes('ce:bl') as Bl (Bl)
							outer apply Bl.nodes('ce:boxnum') as Boxnum (Boxnum)
						order by Position_Identity, Pallet

				end
			else if @ExchangeTypeCode = 'WayBill_v4'
				begin
	
					;with XMLNAMESPACES (  
							   'http://www.w3.org/2001/XMLSchema-instance' as xsi
							   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
							   ,'http://fsrar.ru/WEGAIS/ClientRef_v2' as oref
							   ,'http://fsrar.ru/WEGAIS/ProductRef_v2' as pref
							   ,'http://fsrar.ru/WEGAIS/TTNSingle_v4' as wb
							   ,'http://fsrar.ru/WEGAIS/CommonV3' as ce)
					
					insert into #Stamps 
						select 
							Position_Identity = Position.value('wb:Identity[1]', 'int')
							,Boxnumber = Boxpos.value('ce:boxnumber[1]', 'varchar(50)')
							,Stamp = Amc.value('.', 'varchar(500)')
						from @XMLContent.nodes('/ns:Documents/ns:Document/ns:WayBill_v4/wb:Content/wb:Position') as Position (Position)
							outer apply Position.nodes('wb:InformF2') as InformF2 (InformF2)
							outer apply InformF2.nodes('ce:MarkInfo') as MarkInfo (MarkInfo)
							outer apply MarkInfo.nodes('ce:boxpos') as Boxpos (Boxpos)
							outer apply Boxpos.nodes('ce:amclist') as Amclist (Amclist)
							outer apply Amclist.nodes('ce:amc') as Amc (Amc)
						order by Position_Identity, Boxnumber
				
			
					;with XMLNAMESPACES (  
							   'http://www.w3.org/2001/XMLSchema-instance' as xsi
							   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
							   ,'http://fsrar.ru/WEGAIS/ClientRef_v2' as oref
							   ,'http://fsrar.ru/WEGAIS/ProductRef_v2' as pref
							   ,'http://fsrar.ru/WEGAIS/TTNSingle_v4' as wb
							   ,'http://fsrar.ru/WEGAIS/CommonV3' as ce)
					
					insert into #Pallets
						select 
							Position_Identity = Position.value('wb:Identity[1]', 'int')
							,Pallet = Boxtree.value('ce:boxnum[1]', 'varchar(50)')
							,Boxnumber = Boxnum.value('.', 'varchar(50)')
						from @XMLContent.nodes('/ns:Documents/ns:Document/ns:WayBill_v4/wb:Content/wb:Position') as Position (Position)
							outer apply Position.nodes('wb:boxInfo') as BoxInfo (BoxInfo)
							outer apply BoxInfo.nodes('wb:boxtree') as Boxtree (Boxtree)
							outer apply Boxtree.nodes('ce:bl') as Bl (Bl)
							outer apply Bl.nodes('ce:boxnum') as Boxnum (Boxnum)
						order by Position_Identity, Pallet			

				end
			
	
			-- марки - упаковки - паллет
			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteExciseStamp(
								RAR_CustNoteId
								,Position_Identity
								,StampBarCode
								,BoxBarCode
								,PalletBarCode)
				select distinct
					 @RAR_CustNoteId
					,s.Position_Identity		
					,s.Stamp 
					,s.Boxnumber
					,p.Pallet
				from #Stamps s
					left join #Pallets p
						on p.Boxnumber = s.Boxnumber
							and p.Position_Identity = s.Position_Identity

			commit transaction
		end try
		begin catch
	
			select 
		        ERROR_NUMBER() AS ErrorNumber
		        ,ERROR_SEVERITY() AS ErrorSeverity
		        ,ERROR_STATE() AS ErrorState
		        ,ERROR_PROCEDURE() AS ErrorProcedure
		        ,ERROR_LINE() AS ErrorLine
		        ,ERROR_MESSAGE() AS ErrorMessage;
	
			rollback transaction
		end catch 



GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLine_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLine_Insert]( @AlcCode varchar(100)=NULL, @AnalytLotIntId int=NULL, @InformMotion varchar(50)=NULL, @InformProduction varchar(50)=NULL, @Position_Identity int=NULL, @Price decimal(16,4)=NULL, @Quantity decimal(16,4)=NULL, @RAR_CustNoteId int=NULL, @RealQuantity decimal(16,4)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine
		values(
			@RAR_CustNoteId
			,@Position_Identity
			,@AlcCode
			,@Quantity
			,@RealQuantity
			,@Price
			,@InformProduction
			,@InformMotion
			,@AnalytLotIntId)	
					
		 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLine_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLine_Update]( @Position_Identity int=NULL, @RAR_CustNoteId int=NULL, @InformProduction varchar(50), @InformMotion varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare @CurrentStatus varchar(50)


	select @CurrentStatus = cn.Status
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
	where cn.RAR_CustNoteId = @RAR_CustNoteId


	if(@CurrentStatus in('New', 'NotReady'))
		begin

			begin try
				begin transaction

					update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine
						set
							InformProduction = @InformProduction
							,InformMotion = @InformMotion
						where RAR_CustNoteId = @RAR_CustNoteId
							and Position_Identity = @Position_Identity

					-- Логирование -------------------------------------------
					create table #OperationLog(
									Param varchar(50)
									,Value varchar(255))
					
					insert into #OperationLog(
									Param
									,Value)
						values
							('Method', object_name(@@ProcId))
							,('InformProduction', @InformProduction)
							,('InformMotion ', @InformMotion)
							,('Position_Identity', convert(varchar(50), @Position_Identity))
		
			
					declare 
						@ObjectId varchar(50)
						,@Operation varchar(50) = 'update'
						,@MonUserId varchar(50)
					
					select 
						@ObjectId = @RAR_CustNoteId
						,@MonUserId = ( select coalesce(    case when __xc.bo_UserName is null then __xc.bo_UserName else SUBSTRING(__xc.bo_UserName,CHARINDEX('\',__xc.bo_UserName)+1,LEN(__xc.bo_UserName)) end,    SUBSTRING(__s.login_name,CHARINDEX('\',__s.login_name)+1,LEN(__s.login_name)) )  from sys.dm_exec_sessions __s left join xBOConnection __xc on __s.session_id=__xc.spid and __s.login_time=__xc.login_time where __s.session_id=@@spid );
					
					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_Insert
								@ObjectId = @ObjectId
								,@Operation = @Operation
								,@MonUserId = @MonUserId
					
					if object_id(N'tempdb..#OperationLog', N'U') is not null
						drop table #OperationLog
					----------------------------------------------------------
		
				commit transaction
			end try
			begin catch
			
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;
			
				rollback transaction
			end catch

		end
			else
				begin
		
					begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_CustNoteLine.Update'                and Item=0), 'На данном статусе редактирование позиций запрещено!')  raiserror(@__r__msg,15,2) with seterror  end
					return 1
				
				end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLine_UpdateInform]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLine_UpdateInform]( @RAR_CustNoteId int, @Position_Identity int, @InformProduction varchar(50), @InformMotion varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      
	
	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLine
		set
			InformProduction = @InformProduction
			,InformMotion = @InformMotion
		where RAR_CustNoteId = @RAR_CustNoteId
			and Position_Identity = @Position_Identity
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineMarkRange_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLineMarkRange_Delete]( @DocumentIntId int=NULL, @Position_Identity int=NULL, @Range_Identity int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

if exists (
			select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange
				where DocumentIntId = @DocumentIntId 
					and Position_Identity = @Position_Identity 
					and Range_Identity = @Range_Identity
		)
begin
	delete T
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange mr
			where mr.DocumentIntId = @DocumentIntId 
				and mr.Position_Identity = @Position_Identity 
				and mr.Range_Identity = @Range_Identity
end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineMarkRange_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLineMarkRange_Edit]( @AnalytLotIntId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

select *
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange mr
where mr.AnalytLotIntId = @AnalytLotIntId	

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineMarkRange_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLineMarkRange_Insert]( @AnalytLotIntId int=NULL, @DocumentIntId int=NULL, @MarkLast varchar(9)=NULL, @MarkRank varchar(3)=NULL, @MarkStart varchar(9)=NULL, @Position_Identity int=NULL, @Range_Identity int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange mr where mr.DocumentIntId = @DocumentIntId and mr.AnalytLotIntId <> @AnalytLotIntId)
	begin
	  delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange where DocumentIntId = @DocumentIntId and AnalytLotIntId <> @AnalytLotIntId
	end

if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange mr where mr.DocumentIntId = @DocumentIntId and mr.AnalytLotIntId is null)
	begin
	  delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange where DocumentIntId = @DocumentIntId and AnalytLotIntId is null
	end

select @Range_Identity = max(Range_Identity) + 1 
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange
where DocumentIntId = @DocumentIntId
  and AnalytLotIntId = @AnalytLotIntId

select @Range_Identity = isnull(@Range_Identity, 1)

insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange(	
				DocumentIntId
				,Position_Identity
				,Range_Identity
				,MarkRank
				,MarkStart
				,MarkLast
				,AnalytLotIntId)
select 
	@DocumentIntId
	,@Position_Identity
	,@Range_Identity
	,@MarkRank
	,@MarkStart
	,@MarkLast
	,@AnalytLotIntId

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineMarkRange_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLineMarkRange_Update]( @AnalytLotIntId int=NULL, @DocumentIntId int=NULL, @MarkLast varchar(9)=NULL, @MarkRank varchar(3)=NULL, @MarkStart varchar(9)=NULL, @Position_Identity int=NULL, @Range_Identity int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

if exists (
			select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange
				where DocumentIntId = @DocumentIntId 
					and Position_Identity = @Position_Identity
					and Range_Identity = @Range_Identity
		)
begin
	update mr
		set 
			mr.MarkRank = @MarkRank,
			mr.MarkStart = @MarkStart,
			mr.MarkLast = @MarkLast
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineMarkRange mr
		where mr.DocumentIntId = @DocumentIntId 
			and mr.Position_Identity = @Position_Identity 
			and mr.Range_Identity = @Range_Identity	
end 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineResource_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLineResource_Delete]( @AlcCode varchar(50)=NULL, @DocumentIntId int=NULL, @IdentityRes int=NULL, @InformF2RegId varchar(50)=NULL, @Position_Identity int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

if exists (
			select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource 
				where DocumentIntId = @DocumentIntId 
					and Position_Identity = @Position_Identity 
					and IdentityRes = @IdentityRes
		)
begin
	delete r
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource r
			where r.DocumentIntId = @DocumentIntId 
				and r.Position_Identity = @Position_Identity
				and r.IdentityRes = @IdentityRes
end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineResource_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLineResource_Edit]( @AnalytLotIntId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

select *
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource r
where r.AnalytLotIntId = @AnalytLotIntId	
 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineResource_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLineResource_Insert]( @AlcCode varchar(50)=NULL, @AnalytLotIntId int=NULL, @DocumentIntId int=NULL, @IdentityRes int=NULL, @InformF1RegId varchar(50)=NULL, @InformF2RegId varchar(50)=NULL, @Position_Identity int=NULL, @Quantity decimal(16,4)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

select @IdentityRes = max(r.IdentityRes) + 1 
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource r
where r.DocumentIntId = @DocumentIntId

select @IdentityRes = isnull(@IdentityRes, 1)

insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource(	
				DocumentIntId
				,Position_Identity
				,IdentityRes
				,AlcCode
				,InformF1RegId
				,InformF2RegId
				,Quantity
				,AnalytLotIntId)
select 
	@DocumentIntId
	,@Position_Identity
	,@IdentityRes
	,@AlcCode
	,@InformF1RegId
	,@InformF2RegId
	,@Quantity
	,@AnalytLotIntId


GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLineResource_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CustNoteLineResource_Update]( @AlcCode varchar(50)=NULL, @AnalytLotIntId int=NULL, @DocumentIntId int=NULL, @IdentityRes int=NULL, @InformF1RegId varchar(50)=NULL, @InformF2RegId varchar(50)=NULL, @OldAlcCode varchar(50)=NULL, @OldAnalytLotIntId int=NULL, @OldDocumentIntId int=NULL, @OldIdentityRes int=NULL, @OldInformF1RegId varchar(50)=NULL, @OldInformF2RegId varchar(50)=NULL, @OldPosition_Identity int=NULL, @OldQuantity decimal(16,4)=NULL, @Position_Identity int=NULL, @Quantity decimal(16,4)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

if exists (
			select 1 from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource
				where DocumentIntId = @DocumentIntId  
					and Position_Identity = @Position_Identity
					and IdentityRes = @OldIdentityRes and AlcCode = @OldAlcCode 
					and InformF2RegId = @OldInformF2RegId			
		)
begin
	update r
		set 
			r.AlcCode = @AlcCode,
			r.InformF1RegId = @InformF1RegId,
			r.InformF2RegId = @InformF2RegId,
			r.IdentityRes = @IdentityRes,
			r.Quantity = @Quantity
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLineResource r
		where r.DocumentIntId = @DocumentIntId 
			and r.Position_Identity = @Position_Identity
			and r.IdentityRes = @OldIdentityRes and AlcCode = @OldAlcCode 
			and r.InformF2RegId = @OldInformF2RegId	
end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLink_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLink_Insert]( @RAR_CustNoteId int, @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      
	

	begin try
		begin transaction
	
			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLink(RAR_CustNoteId, RowId) 
				values(@RAR_CustNoteId, @RowId)
		
			/*exec bpRAR_CustNote_SetStatus
					@RAR_CustNoteId
					,@Status*/
	
		commit transaction
	end try
	begin catch

		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;

		rollback transaction
	end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteLink_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteLink_Update]( @RowId uniqueidentifier, @ReplyId varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	if(@ReplyId is not null)
		begin
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLink
				set ReplyId = @ReplyId
			where RowId = @RowId
		end
	
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteRoute_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteRoute_Insert]( @CreateTime datetime=NULL, @Ownership bit=NULL, @RAR_CustNoteId int=NULL, @RAR_CustNoteRouteId int=NULL OUTPUT, @RouteNumber varchar(64)=NULL, @RowId uniqueidentifier=NULL, @Status varchar(64)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteRoute(
								RAR_CustNoteId
								,RouteNumber
								,Ownership
								,CreateTime
								,RowId
								,Status)
		select 
			@RAR_CustNoteId
			,@RouteNumber
			,@Ownership
			,@CreateTime
			,@RowId
			,@Status

	set @RAR_CustNoteRouteId = @@identity
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteRoute_SendCancelRoute]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteRoute_SendCancelRoute]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

declare
	@XMLContent nvarchar(max)
	,@ClassId varchar(64) = 'CancelRoute'	
	,@ExchangeTypeCode varchar(64) 


declare @SrcExchangeTypeCode varchar(64)
select @SrcExchangeTypeCode = EgaisExchange.dbo.bpUTM_ExchangeTypeDependence_GetWBTypeCode(@RAR_CustNoteId) -- получение версии типа обмена акта для отгрузки
select @ExchangeTypeCode = EgaisExchange.dbo.bpUTM_ExchangeTypeDependence_GetDstTypeCode(@ClassId, @SrcExchangeTypeCode) -- получение версии типа для акта

-- пространства имен для версии типа обмена с ЕГАИС
declare @Namespace nvarchar(max)
select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)


if isnull(@ExchangeTypeCode, '') <> ''
	begin
		select @XMLContent =
						'<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents' + char(13) + char(10) +
								@Namespace + ' >' +
								'<ns:Owner>
									<ns:FSRAR_ID>' + isnull(cn.ShipperFSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:' + isnull(@ExchangeTypeCode, '') + '>
										<crt:Date>' + isnull(convert(varchar(64), cn.ActionDate, 23), '') + '</crt:Date>
										<crt:RouteId>RT-0002221096</crt:RouteId>
									</ns:' + isnull(@ExchangeTypeCode, '') + '>
								</ns:Document>
							</ns:Documents>'
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
				where cn.RAR_CustNoteId = @RAR_CustNoteId
	end


if isnull(@XMLContent, '') <> ''
	begin
		begin try
			declare @UTMId int
			select @UTMId = u.UTMId
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						on u.FSRAR_Id = cn.ShipperFSRAR_Id
							and u.IsTest = 0
			where cn.RAR_CustNoteId = @RAR_CustNoteId

			declare @RowId uniqueidentifier
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_InsertRequest
						@Content = @XMLContent
						,@ExchangeTypeCode = @ExchangeTypeCode
						,@UTMId = @UTMId
						,@RowId = @RowId out
	
			commit transaction
		end try
		begin catch
			rollback transaction

			-- Логирование -------------------------------------------
			declare
				@ErrorNumber int = ERROR_NUMBER()
				,@ErrorSeverity int = ERROR_SEVERITY()
				,@ErrorState int = ERROR_STATE()
				,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE()
				,@ErrorLine int = ERROR_LINE()
				,@ErrorMessage nvarchar(256) = ERROR_MESSAGE()
				,@Method nvarchar(128) = object_name(@@ProcId)

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_ExceptionLog
						@ObjectId = @RAR_CustNoteId
						,@RowId = NULL
						,@Operation = 'cancelRoute'
						,@Method = @Method
						,@ErrorNumber = @ErrorNumber
						,@ErrorSeverity = @ErrorSeverity
						,@ErrorState = @ErrorState
						,@ErrorProcedure = @ErrorProcedure
						,@ErrorLine = @ErrorLine
						,@ErrorMessage = @ErrorMessage				
		end catch
	end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteRoute_SendRoute]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteRoute_SendRoute]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

declare
	@XMLContent nvarchar(max)
	,@ClassId varchar(64) = 'Route'	
	,@ExchangeTypeCode varchar(64)


declare @SrcExchangeTypeCode varchar(64)
select @SrcExchangeTypeCode = EgaisExchange.dbo.bpUTM_ExchangeTypeDependence_GetWBTypeCode(@RAR_CustNoteId) -- получение версии типа обмена акта для отгрузки
select @ExchangeTypeCode = EgaisExchange.dbo.bpUTM_ExchangeTypeDependence_GetDstTypeCode(@ClassId, @SrcExchangeTypeCode) -- получение версии типа для акта

-- пространства имен для версии типа обмена с ЕГАИС
declare @Namespace nvarchar(max)
select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)

-- смена собственника продукции при отгрузке
declare @Ownership bit
select @Ownership = case EgaisExchange.dbo.bpRAR_CustNoteChangeOwnership_GetChangeOwnership(@RAR_CustNoteId, 0)
						when 'IsChange' then 1 
						when 'NotChange' then 0 
					end


declare @RouteNumber varchar(64), @CreateTime datetime
select 
	@RouteNumber = 'ТН-' + convert(varchar(64), @RAR_CustNoteId)
	,@CreateTime = getdate()


if isnull(@ExchangeTypeCode, '') <> ''
	begin
		select @XMLContent =
						'<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents' + char(13) + char(10) +
								@Namespace + ' >' +
								'<ns:Owner>
									<ns:FSRAR_ID>' + isnull(cn.ShipperFSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:' + isnull(@ExchangeTypeCode, '') + '>
										<mskr:NUMBER>' + isnull(@RouteNumber, '') + '</mskr:NUMBER>
										<mskr:Date>' + isnull(convert(varchar(64), cn.ActionDate, 23), '') + '</mskr:Date>
										<mskr:Ownership>' + isnull(convert(varchar(1), @Ownership), '') + '</mskr:Ownership>
										<mskr:WBRegId>' + isnull(mi.RegNumber, '') + '</mskr:WBRegId>' +
										--<mskr:ParentRoutes>
										--	<mskr:RouteId>mskr-0002221096</mskr:RouteId>
										--	<mskr:RouteId>mskr-0001111096</mskr:RouteId>
										--</mskr:ParentRoutes>
										'<mskr:TRAN_TYPE>413</mskr:TRAN_TYPE>
										<mskr:TRAN_COMPANY>' + isnull(cnt.Company, '') + '</mskr:TRAN_COMPANY>
										<mskr:TRAN_CAR>' + isnull(cnt.Car, '') + '</mskr:TRAN_CAR>
										<mskr:TRAN_TRAILER/>
										<mskr:TRAN_CUSTOMER>' + isnull(cnt.Customer, '') + '</mskr:TRAN_CUSTOMER>
										<mskr:TRAN_DRIVER>' + isnull(cnt.Driver, '') + '</mskr:TRAN_DRIVER>
										<mskr:TRAN_LOADPOINT>' + isnull(cnt.LoadPoint, '') + '</mskr:TRAN_UNLOADPOINT>
										<mskr:TRAN_REDIRECT/>
										<mskr:TRAN_FORWARDER/>
										<mskr:Quantity>0</mskr:Quantity>
									</ns:' +  isnull(@ExchangeTypeCode, '') + '>
								</ns:Document>
							</ns:Documents>'
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteTransport cnt
					on cnt.RAR_CustNoteId = cn.RAR_CustNoteId
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
					on u.FSRAR_Id = cn.ShipperFSRAR_Id
						and u.IsTest = 0
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
					on mi.DocumentNumber = cn.DocumentNumber
						and mi.DocumentDate = cn.ActionDate
						and mi.FixDate = cn.ActionDate
						and mi.UTM_Id = u.UTMId
			where cn.RAR_CustNoteId = @RAR_CustNoteId
		end

	
if isnull(@XMLContent, '') <> ''
	begin
		begin try
			declare @RAR_CustNoteRouteId int
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNoteRoute_Insert
						@RAR_CustNoteId = @RAR_CustNoteId
						,@RouteNumber = @RouteNumber
						,@Ownership = @Ownership
						,@CreateTime = @CreateTime
						,@Status = 'New'
						,@RAR_CustNoteRouteId = @RAR_CustNoteRouteId out	

			declare @UTMId int
			select @UTMId = u.UTMId
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						on u.FSRAR_Id = cn.ShipperFSRAR_Id
							and u.IsTest = 0
			where cn.RAR_CustNoteId = @RAR_CustNoteId

			declare @RowId uniqueidentifier
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_InsertRequest
						@Content = @XMLContent
						,@ExchangeTypeCode = @ExchangeTypeCode
						,@UTMId = @UTMId
						,@RowId = @RowId out

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNoteRoute_SetRowId	
						@RAR_CustNoteRouteId = @RAR_CustNoteRouteId
						,@RowId = @RowId
			
			commit transaction
		end try
		begin catch
			rollback transaction

			-- Логирование -------------------------------------------
			declare
				@ErrorNumber int = ERROR_NUMBER()
				,@ErrorSeverity int = ERROR_SEVERITY()
				,@ErrorState int = ERROR_STATE()
				,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE()
				,@ErrorLine int = ERROR_LINE()
				,@ErrorMessage nvarchar(256) = ERROR_MESSAGE()
				,@Method nvarchar(128) = object_name(@@ProcId)

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_ExceptionLog
						@ObjectId = @RAR_CustNoteRouteId
						,@RowId = NULL
						,@Operation = 'send'
						,@Method = @Method
						,@ErrorNumber = @ErrorNumber
						,@ErrorSeverity = @ErrorSeverity
						,@ErrorState = @ErrorState
						,@ErrorProcedure = @ErrorProcedure
						,@ErrorLine = @ErrorLine
						,@ErrorMessage = @ErrorMessage				
		end catch
	end


 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteRoute_SetRowId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CustNoteRoute_SetRowId]( @RAR_CustNoteRouteId int=NULL, @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteRoute
		set RowId = @RowId
	where RAR_CustNoteRouteId = @RAR_CustNoteRouteId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteTransport_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteTransport_Insert]( @Car varchar(255)=NULL, @Company varchar(255)=NULL, @Customer varchar(255)=NULL, @Driver varchar(255)=NULL, @Forwarder varchar(255)=NULL, @LoadPoint varchar(255)=NULL, @RAR_CustNoteId int=NULL, @RAR_CustNoteTransportId int=NULL, @UnloadPoint varchar(255)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteTransport(
						RAR_CustNoteId
						,Car
						,Company
						,Customer
						,Driver
						,Forwarder
						,LoadPoint
						,UnloadPoint)
		values(
			@RAR_CustNoteId
			,@Car
			,@Company
			,@Customer
			,@Driver
			,@Forwarder
			,@LoadPoint
			,@UnloadPoint) 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteTransport_SendCancelRoute]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CustNoteTransport_SendCancelRoute]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteTransport_SendRoute]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_CustNoteTransport_SendRoute]( @RAR_CustNoteId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_CustNoteTransportType_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_CustNoteTransportType_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select 
		t.RAR_CustNoteTransportTypeId
		,t.TypeCode
		,t.Description
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteTransportType t 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Document_Create_Content_ProdReceipt]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Document_Create_Content_ProdReceipt]( @DocumentIntId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


declare @DocumentTypeId nvarchar(50)
       ,@Version varchar(5)
       ,@DocumentStatus varchar(15)
       ,@Skip int = 1
       --,@DocumentIntId int
       ,@SSPQuantity decimal(16,4)
       ,@iXml xml
       ,@s nvarchar(max)
       ,@QuantTTN int
       ,@QuantMark int
       ,@TypeContent varchar(5)
	   ,@IsSingle bit = 0
	   ,@IsOldBarCode int = 0

/*select @DocumentTypeId = DocumentTypeId
      ,@DocumentStatus = Status
      ,@DocumentIntId = DocumentIntId
from Document D where D.Document_Object = @Document_Object and 
			D.DocumentDate = @DocumentDate and 
			D.DocumentNumber = @DocumentNumber

if exists(
			select top 1 1 
			from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampDocument esd
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampSet ess on ess.StampSetId = esd.StampSetId
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampSetLine esl on esl.ParentId = ess.StampSetId
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStamp es on es.StampId = esl.DescendantId
			where esd.DocumentIntId = @DocumentIntId
			  and ess.IsDisassembled = 0
			  and len(es.StampBarCode) <> 150
			  and ess.WorkSiteId in ('VodkaOldStamp', 'UVK_5'))
select @IsOldBarCode = 1

if exists(
			select top 1 1
			from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStampDocument esd
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].ExciseStamp es on es.StampId = esd.StampSetId
			where len(es.StampBarCode) <> 150
			  and es.IsSingle = 1
			  and esd.DocumentIntId = @DocumentIntId)
select @IsOldBarCode = 1

select top 1 @IsSingle = es.IsSingle
from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd
join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es on esd.StampSetId = es.StampId
where esd.DocumentIntId = @DocumentIntId

select @QuantTTN = alk.Quantity from AnalytLotLink alk where alk.DocumentIntId = @DocumentIntId

if(@IsSingle = 0)
	begin
		select @QuantMark = count(es.StampId) 
		from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSetLine] as esl on esl.DescendantId = es.StampId
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSet] as ess on ess.StampSetId = esl.ParentId
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] as esd on esd.StampSetId = ess.StampSetId
		join AnalytLotLink alk on alk.DocumentIntId = esd.DocumentIntId
		where alk.DocumentIntId = @DocumentIntId
		  and ess.IsDisassembled = 0
	end
else
if(@IsSingle = 1)
	begin		
		select @QuantMark = count(es.StampId) 
		from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd on esd.StampSetId = es.StampId
		where esd.DocumentIntId = @DocumentIntId 
		  and es.IsSingle & 1 = 1
	end	

if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd where esd.DocumentIntId = @DocumentIntId) and @DocumentIntId <> 19035035
begin
	  if @QuantTTN <> @QuantMark
      begin
           select @Skip = 0
           set @ErrMessageFix = 'Несоответствие количества продукции в документе '+convert(varchar(15),@QuantTTN)+' шт. с количеством отсканированных марок '+convert(varchar(15),@QuantMark)+' шт!'
           print @ErrMessageFix
           RETURN 1
      end
end

if @DocumentStatus <> 'NRICMO'
select @Skip = 0

if @IsOldBarCode = 1
select @Skip = 1

if @Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange' set @Skip = 1

if   (((@Document_Object = ('ProdReceipt') and @DocumentTypeId in ('ProductFGD', 'ProductFGN')) or @IsForceCreate=1)
  or ((@Document_Object = 'ProdReceipt' and @DocumentTypeId = 'Product') or @IsForceCreate=1)
  or (@Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange')) and @Skip = 1
begin

	declare @DocumentShippingDate varchar(50), @Shipper_ClientRegId varchar(50),
			@Consignee_ClientRegId varchar(50), 
			@SrcDocumentNumber varchar(50), @Status varchar(50),
			@CompanyId varchar(50), @CompanyName varchar(500), 
			@AddressId varchar(50), @Location varchar(500), @INN varchar(50)


if exists(select 1 from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd where esd.DocumentIntId = @DocumentIntId)
begin
	if(@IsSingle = 0)
		begin
		    update es set es.AnalytLotIntId = alk.AnalytLotIntId 
		    from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSetLine] as esl on esl.DescendantId = es.StampId
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSet] as ess on ess.StampSetId = esl.ParentId
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] as esd on esd.StampSetId = ess.StampSetId
		    join AnalytLotLink alk on alk.DocumentIntId = esd.DocumentIntId
		    where alk.DocumentIntId = @DocumentIntId
		      and ess.IsDisassembled = 0
              and es.Status = 0
		end
	else
	if(@IsSingle = 1)
		begin
			update es set es.AnalytLotIntId = alk.AnalytLotIntId
			from [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
			join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampDocument] esd on esd.StampSetId = es.StampId
			join AnalytLotLink alk on alk.DocumentIntId = esd.DocumentIntId
			where esd.DocumentIntId = @DocumentIntId 
			  and es.IsSingle & 1 = 1
              and es.Status = 0
		end
end


    if @IsOldBarCode = 1
    begin
	   delete from EGAIS_ActChargeHeader where DocumentIntId = @DocumentIntId
	   delete from EGAIS_ActChargeLine where DocumentIntId = @DocumentIntId

	   insert into EGAIS_ActChargeHeader(FSRAR_ID, Number, ActDate, Note, DocumentIntId)
	   select @Shipper_ClientRegId, @SrcDocumentNumber, format(getdate(), 'yyyy-MM-dd'), 'OldBarCode', @DocumentIntId

	   insert into EGAIS_ActChargeLine(Position_Identity, AlcCode, Quantity, InformARegId, InformBRegId, DocumentIntId)
	   select d.Position_Identity, d.AlcCode, d.Quantity, ataa.Value, atab.Value, @DocumentIntId
	   from #DocumentLine d
	   join AnalytLotAttribute ataa on ataa.AnalytLotIntId = d.AnalytLotIntId
							 and ataa.AdditionalAttribId = 'InformARegId'
	   join AnalytLotAttribute atab on atab.AnalytLotIntId = d.AnalytLotIntId
							 and atab.AdditionalAttribId = 'InformBRegId'

	   exec bpEGAIS_Document_UpdStatusExciseStamp @Document_Object = @Document_Object, @DocumentDate = @DocumentDate, @DocumentNumber = @DocumentNumber

	   exec bpExciseStampTurnover_SetAnalytLotAttribute @Document_Object = @Document_Object, @DocumentDate = @DocumentDate, @DocumentNumber = @DocumentNumber
    end

	if @IsWriteToTable = 0
	begin
		select @DocumentIntId as DocumentIntId, '' as DocumentUnitType, 
			@DocumentShippingDate as DocumentShippingDate, @Shipper_ClientRegId as Shipper_ClientRegId,
			@Consignee_ClientRegId as Consignee_ClientRegId, '' as Tran_CAR,
			'' as Tran_Customer, '' as Tran_Driver, 
			'' as Tran_LoadPoint, '' as Tran_UnloadPoint,
			'' as Tran_Forwarder, ''  as Tran_Company
	end

	if (@IsWriteToTable = 1 and @IsOldBarCode <> 1)
	begin

		begin transaction EGAIS_DOCUMENT_Write
		
		begin try

        delete from EGAIS_Document where IntId = @DocumentIntId
        delete from EGAIS_DocumentHeader where IntId = @DocumentIntId
        delete from EGAIS_DocumentTransport where IntId = @DocumentIntId
        delete from EGAIS_DocumentLine where IntId = @DocumentIntId

		insert EGAIS_Document (IntId, DocumentIntId, WayBill_Identity, DocumentType, Direction, PrimaryDocumentIntId, [Status], SourceXML, ResponseXML, CompanyId, CompanyName,INN,AddressId,Location)
		select @DocumentIntId as IntId, @DocumentIntId, null as WayBill_Identity, 'RepProducedProduct' as DocumentType, 1 as Direction, null as PrimaryDocumentIntId, 'New' as [Status], null as SourceXML, null as ResponseXML,
			@CompanyId, @CompanyName, @INN, @AddressId, @Location
		
		insert EGAIS_DocumentHeader (IntId, DocumentNumber, DocumentDate, DocumentUnitType, DocumentShippingDate, Shipper_ClientRegId, Consignee_ClientRegId)
		select @DocumentIntId as IntId, coalesce(@SrcDocumentNumber, @DocumentNumber), convert(varchar(10), @DocumentDate, 120), ''
        ,convert(varchar(10), convert(smalldatetime, @DocumentShippingDate), 120), @Shipper_ClientRegId, @Consignee_ClientRegId
		
		insert EGAIS_DocumentTransport (Tran_CAR, Tran_COMPANY, Tran_CUSTOMER, Tran_DRIVER, Tran_FORWARDER, Tran_LOADPOINT, Tran_UNLOADPOINT, IntId)
		select '', '', '', '', '', '', '', @DocumentIntId as IntId
		
		insert EGAIS_DocumentLine (AlcCode, InformARegId, InformBRegId, OriginalQuantity, Price, Producer_ClientRegId, Quantity, RealQuantity, IntId, Position_Identity, LineNumber, BottlingDate, FSMType)
		select 
			dl.AlcCode, dl.InformARegId, dl.InformBRegId
			, dl.Quantity as OriginalQuantity, dl.Price
			, ew.ClientRegId as Producer_ClientRegId 
			, dl.Quantity, dl.Quantity as RealQuantity, @DocumentIntId as IntId
--			, row_number() OVER(ORDER BY dl.Position_Identity ASC)
			, dl.Position_Identity
			, dl.LineNumber, convert(nvarchar(50), dl.DateB), dl.FSMType
		from #DocumentLine dl
		join EGAIS_Ware ew
		  on ew.AlcCode = dl.AlcCode
		where dl.AlcCode is not null


--		select* from EGAIS_DocumentLine where IntId=@DocumentIntId

		declare @ProducedDate smalldatetime
		
		select @ProducedDate = convert(smalldatetime, at1.Value) from document d
			join analytLotLink alli on d.documentintid=alli.documentintid
			join analytLotAttribute at1 on at1.AnalytLotIntId=alli.AnalytLotIntId and at1.AdditionalAttribId='DateB'
		where d.DocumentIntId=@DocumentIntId

if @Document_Object = 'MovingNote' and @DocumentTypeId = 'CodeExchange'
begin
		select @ProducedDate=convert(smalldatetime, at1.Value) from document d
			join analytLotLink alli on d.documentintid=alli.documentintid
			join analytLotAttribute at1 on at1.AnalytLotIntId=alli.AnalytLotIntId and at1.AdditionalAttribId='ProdDate'
		where d.DocumentIntId=@DocumentIntId
		and alli.Direction = 1
end

		declare @SourceXML nvarchar(max), @ContentResource nvarchar(max)

if not exists(select 1 from EGAIS_DocumentLineMarkRange dm where dm.IntId = @DocumentIntId)
begin
		select @SourceXML = 
			'<?xml version="1.0"?>
			<ns:Documents Version="1.0"
				xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2"
 				xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"
				xmlns:rpp="http://fsrar.ru/WEGAIS/RepProducedProduct_v3"
				xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
 				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3"
				>
			<ns:Owner>
				<ns:FSRAR_ID>' + edh.Shipper_ClientRegId + '</ns:FSRAR_ID>
			</ns:Owner>
			<ns:Document>
				<ns:RepProducedProduct_v3>
					<rpp:Identity>' + convert(varchar(50), @DocumentIntId) + '</rpp:Identity>
						<rpp:Header>
							<rpp:Type>OperProduction</rpp:Type>
							<rpp:NUMBER>'+convert(varchar(50), edh.DocumentNumber)+'</rpp:NUMBER>
							<rpp:Date>' + convert(varchar(50), edh.DocumentShippingDate, 112) + '</rpp:Date>
							<rpp:ProducedDate>' + coalesce(convert(varchar(10), @ProducedDate, 120), convert(varchar(50), edh.DocumentShippingDate, 112)) + '</rpp:ProducedDate>
							<rpp:Producer>
 								<oref:UL>
									<oref:ClientRegId>'+edh.Shipper_ClientRegId+'</oref:ClientRegId>
									<oref:FullName>'+Shipper.FullName+'</oref:FullName>
									<oref:ShortName>'+Shipper.ShortName+'</oref:ShortName>
									<oref:INN>'+Shipper.INN+'</oref:INN>
									<oref:KPP>'+Shipper.KPP+'</oref:KPP>
									<oref:address>
										<oref:Country>'+Shipper.Country+'</oref:Country>
										<oref:RegionCode>'+Shipper.RegionCode+'</oref:RegionCode>
										<oref:description>'+Shipper.description+'</oref:description> 
									</oref:address> 
								</oref:UL> 
							</rpp:Producer> 
							<rpp:Note>Производственный отчет</rpp:Note>
						</rpp:Header>
						<rpp:Content>'
		from EGAIS_Document ed
		join EGAIS_DocumentHeader edh
  		on edh.IntId = ed.IntId
		join EGAIS_Company_2 Shipper with (NOLOCK)
  		on Shipper.ClientRegId = edh.Shipper_ClientRegId
		join EGAIS_Company_2 Consignee with (NOLOCK)
  		on Consignee.ClientRegId = edh.Consignee_ClientRegId
		join EGAIS_DocumentTransport edt
  		on edt.IntId = ed.IntId
		where ed.IntId = @DocumentIntId



		declare @AlcCode varchar(50), @Producer_ClientRegId varchar(50), @Quantity varchar(50), @Position_Identity varchar(50), @FSMType varchar(3)
		declare Walker  cursor LOCAL STATIC for
		select 
				AlcCode, (Producer_ClientRegId), 
				convert(varchar(50),(Quantity)), convert(varchar(50),(Position_Identity)), isnull(convert(varchar(3), FSMType),'')
			 from EGAIS_DocumentLine 
			where IntId = @DocumentIntId
	--	group by AlcCode

		open Walker
		fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		while @@fetch_status = 0
		begin 

		if @IsSingle = 0
		begin
		    SELECT @iXml = (
		    SELECT '<ce:amc>'+ es.StampBarCode + '</ce:amc>' + char(13)+char(10)
		    FROM [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSetLine] as esl on esl.DescendantId = es.StampId
		    join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStampSet] as ess on ess.StampSetId = esl.ParentId		
		    join #DocumentLine dl on dl.AnalytLotIntId = es.AnalytLotIntId
		    where ess.IsDisassembled = 0
		    FOR XML PATH);
		end
		else
		if @IsSingle = 1
		begin
		    SELECT @iXml = (
		    SELECT '<ce:amc>'+ es.StampBarCode + '</ce:amc>' + char(13)+char(10)
		    FROM [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es	
		    join #DocumentLine dl on dl.AnalytLotIntId = es.AnalytLotIntId
		    FOR XML PATH);
		end
		
		select @s = @iXml.value('string(/)','nvarchar(max)');

			select @SourceXML = @SourceXML +
				'	<rpp:Position>
						<rpp:ProductCode>'+convert(varchar(50), @AlcCode)+'</rpp:ProductCode>
						<rpp:Quantity>'+convert(varchar(50), @Quantity)+'</rpp:Quantity>
						<rpp:Party>'+isnull(dl.PartNumber,'')+'</rpp:Party>
						<rpp:Identity>'+@Position_Identity+'</rpp:Identity>
						<rpp:Comment1>Комментарий строки</rpp:Comment1>'
			from #DocumentLine dl 
			where  dl.Position_identity = @Position_Identity

			if exists(select 1 from #DocumentLIne dl
			          join [MSK-HQ-MNT01\ERP_MAIN].[ExciseStamp].[dbo].[ExciseStamp] es on es.AnalytLotIntId = dl.AnalytLotIntId)
               begin
				select @SourceXML = @SourceXML + '<rpp:MarkInfo>' + @s + '</rpp:MarkInfo>'
			   end

			select @SourceXML = @SourceXML + '</rpp:Position>'

			fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		end
		close walker
		deallocate walker

		select @SourceXML = @SourceXML + 
						'</rpp:Content>'
			
		select @ContentResource = ''
		if exists (select 1 from EGAIS_DocumentLineContentResource where IntId = @DocumentIntId)
		begin

			select @ContentResource = '<rpp:ContentResource>'
				
			select @ContentResource = @ContentResource +'
				<rpp:Resource>
					<rpp:IdentityRes>'+convert(varchar(50), CR.IdentityRes)+'</rpp:IdentityRes>
					<rpp:Product>
						<pref:UnitType>'+convert(varchar(50), W.WareType)+'</pref:UnitType>
						<pref:Type>'+case when convert(varchar(50), W.ProductVCode) = '321' then 'ССП' when convert(varchar(50), W.ProductVCode) = '020' then 'Спирт' else 'АП' end +'</pref:Type>
						<pref:FullName>'+isnull(W.FullName,'')+'</pref:FullName>
						<pref:AlcCode>'+W.AlcCode+'</pref:AlcCode> 
						'+ case when W.WareType = 'Unpacked' then '' else '<pref:Capacity>'+isnull(convert(varchar(50), W.Capacity), '0')+'</pref:Capacity>' end +'
						<pref:AlcVolume>'+convert(varchar(50), W.AlcVolume)+'</pref:AlcVolume> 
						<pref:ProductVCode>'+convert(varchar(50), W.ProductVCode)+'</pref:ProductVCode>
						<pref:Producer>
							<oref:UL>
								<oref:ClientRegId>'+convert(varchar(50), ECR.Producer_ClientRegId)+'</oref:ClientRegId>
								<oref:FullName>'+isnull(convert(varchar(255), C.FullName), '')+'</oref:FullName>
								<oref:INN>'+isnull(convert(varchar(50), C.INN), '')+'</oref:INN>
								<oref:KPP>'+isnull(convert(varchar(50), C.KPP), '')+'</oref:KPP>
								<oref:address>
									<oref:Country>'+isnull(convert(varchar(50), C.Country), '643')+'</oref:Country>
									<oref:RegionCode>'+isnull(convert(varchar(50), C.RegionCode), '')+'</oref:RegionCode>
									<oref:description>'+isnull(convert(varchar(255), C.description), '')+'</oref:description>
								</oref:address>
							</oref:UL>
						</pref:Producer>
 					</rpp:Product>' 
					+ case when CR.InformF2RegId is not null then '<rpp:RegForm2>'+isnull(convert(varchar(50), CR.InformF2RegId), '')+'</rpp:RegForm2>' else '' end +
					'<rpp:Quantity>'+Replace(isnull(convert(varchar(50), CR.Quantity),'0'), ',', '.')+'</rpp:Quantity>
 				</rpp:Resource>'
			from EGAIS_DocumentLineContentResource CR
				left join EGAIS_Ware W on W.AlcCode = CR.AlcCode
				left join EGAIS_CompanyRests ECR on ECR.AlcCode = CR.AlcCode and ECR.InformARegId = CR.InformF1RegId and ECR.InformBRegId = CR.InformF2RegId and 
						ECR.FSRAR_ID = @Consignee_ClientRegId
				left join EGAIS_Company_2 C on C.ClientRegId = ECR.Producer_ClientRegId
			where CR.IntId = @DocumentIntId

			select  @ContentResource = @ContentResource + '</rpp:ContentResource>'

		end

		select @SourceXML = @SourceXML + isnull(@ContentResource,'')


		select @SourceXML = @SourceXML + 
						'</ns:RepProducedProduct_v3>
					</ns:Document>
				</ns:Documents>
			'
        select @Version = 'v3'
end

if exists(select 1 from EGAIS_DocumentLineMarkRange dm where dm.IntId = @DocumentIntId)
begin
		select @SourceXML = 
			'<?xml version="1.0"?>
			<ns:Documents Version="1.0"
				xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2"
 				xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"
				xmlns:rpp="http://fsrar.ru/WEGAIS/RepProducedProduct"
				xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
 				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				>
			<ns:Owner>
				<ns:FSRAR_ID>' + edh.Shipper_ClientRegId + '</ns:FSRAR_ID>
			</ns:Owner>
			<ns:Document>
				<ns:RepProducedProduct>
					<rpp:Identity>' + convert(varchar(50), @DocumentIntId) + '</rpp:Identity>
						<rpp:Header>
							<rpp:Type>OperProduction</rpp:Type>
							<rpp:NUMBER>'+convert(varchar(50), edh.DocumentNumber)+'</rpp:NUMBER>
							<rpp:Date>' + convert(varchar(50), edh.DocumentShippingDate, 112) + '</rpp:Date>
							<rpp:ProducedDate>' + coalesce(convert(varchar(10), @ProducedDate, 120), convert(varchar(50), edh.DocumentShippingDate, 112)) + '</rpp:ProducedDate>
							<rpp:Producer>
 								<oref:UL>
									<oref:ClientRegId>'+edh.Shipper_ClientRegId+'</oref:ClientRegId>
									<oref:INN>'+Shipper.INN+'</oref:INN>
									<oref:KPP>'+Shipper.KPP+'</oref:KPP>
									<oref:FullName>'+Shipper.FullName+'</oref:FullName>
									<oref:ShortName>'+Shipper.ShortName+'</oref:ShortName>
									<oref:address>
										<oref:Country>'+Shipper.Country+'</oref:Country>
										<oref:RegionCode>'+Shipper.RegionCode+'</oref:RegionCode>
										<oref:description>'+Shipper.description+'</oref:description> 
									</oref:address> 
								</oref:UL> 
							</rpp:Producer>
							<rpp:Note>Производственный отчет</rpp:Note>
						</rpp:Header>
						<rpp:Content>'
		from EGAIS_Document ed
		join EGAIS_DocumentHeader edh
  		on edh.IntId = ed.IntId
		join EGAIS_Company_2 Shipper with (NOLOCK)
  		on Shipper.ClientRegId = edh.Shipper_ClientRegId
		join EGAIS_Company_2 Consignee with (NOLOCK)
  		on Consignee.ClientRegId = edh.Consignee_ClientRegId
		join EGAIS_DocumentTransport edt
  		on edt.IntId = ed.IntId
		where ed.IntId = @DocumentIntId

		

	--	declare @AlcCode varchar(50), @Producer_ClientRegId varchar(50), @Quantity varchar(50), @Position_Identity varchar(50), @FSMType varchar(3)
		declare Walker  cursor LOCAL STATIC for
		select 
				AlcCode, (Producer_ClientRegId), 
				convert(varchar(50),(Quantity)), convert(varchar(50),(Position_Identity)), isnull(convert(varchar(3), FSMType),'')
			 from EGAIS_DocumentLine 
			where IntId = @DocumentIntId
	--	group by AlcCode

		open Walker
		fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		while @@fetch_status = 0
		begin 
			
			declare @Ranges nvarchar(max), @IsRangesExists int
			select @IsRangesExists = case when exists(select 1 from EGAIS_DocumentLineMarkRange M 
														where M.IntId = @DocumentIntId and 
					  									M.Position_Identity = @Position_Identity
												) then 1
										else 0
									end

			select @Ranges = '<rpp:MarkInfo>'+
							'	<pref:Type>'+convert(varchar(3),@FSMType)+'</pref:Type>'+
							'	<pref:Ranges>'

			select @Ranges = @Ranges + '		<pref:Range>
									   				<pref:Identity>'+convert(varchar(50), M.Range_Identity)+'</pref:Identity> 
									   				<pref:Rank>'+convert(varchar(50), M.MarkRank)+'</pref:Rank> 
									   				<pref:Start>'+convert(varchar(50), M.MarkStart)+'</pref:Start> 
									   				<pref:Last>'+convert(varchar(50), M.MarkLast)+'</pref:Last> 
									   			</pref:Range>'
				from EGAIS_DocumentLineMarkRange M 
				where M.IntId = @DocumentIntId and 
					  M.Position_Identity = @Position_Identity
			
			select @Ranges = @Ranges + '	</pref:Ranges>
										 </rpp:MarkInfo>'

			
	
			select @SourceXML = @SourceXML + ''+
				'	<rpp:Position>
						<rpp:ProductCode>'+convert(varchar(50), @AlcCode)+'</rpp:ProductCode>
						<rpp:Quantity>'+convert(varchar(50), @Quantity)+'</rpp:Quantity>
						<rpp:Party>'+isnull(dl.PartNumber,'')+'</rpp:Party>
						<rpp:Identity>'+@Position_Identity+'</rpp:Identity>
						<rpp:Comment1>Комментарий строки</rpp:Comment1> 
					'+ case when @IsRangesExists = 1 then @Ranges else '' end + '
				 	</rpp:Position>'
			from #DocumentLIne dl where  dl.Position_identity = @Position_Identity
	
			fetch next from Walker into @AlcCode, @Producer_ClientRegId, @Quantity, @Position_Identity, @FSMType
		end
		close walker
		deallocate walker

		select @SourceXML = @SourceXML + 
						'</rpp:Content>'

			
		select @ContentResource = ''
		if exists (select 1 from EGAIS_DocumentLineContentResource where IntId = @DocumentIntId)
		begin
		
			select @ContentResource = '<rpp:ContentResource>'
				
			select @ContentResource = @ContentResource +'
				<rpp:Resource>
					<rpp:IdentityRes>'+convert(varchar(50), CR.IdentityRes)+'</rpp:IdentityRes>
					<rpp:Product>
						<pref:FullName>'+isnull(W.FullName,'')+'</pref:FullName>
						<pref:AlcCode>'+W.AlcCode+'</pref:AlcCode> 
						'+ case when W.WareType = 'Unpacked' then '' else '<pref:Capacity>'+isnull(convert(varchar(50), W.Capacity), '0')+'</pref:Capacity>' end +'
						<pref:UnitType>'+convert(varchar(50), W.WareType)+'</pref:UnitType>
						<pref:AlcVolume>'+convert(varchar(50), W.AlcVolume)+'</pref:AlcVolume> 
						<pref:ProductVCode>'+convert(varchar(50), W.ProductVCode)+'</pref:ProductVCode>
						<pref:Producer>
							<oref:UL>
								<oref:ClientRegId>'+convert(varchar(50), ECR.Producer_ClientRegId)+'</oref:ClientRegId>
								<oref:INN>'+isnull(convert(varchar(50), C.INN), '')+'</oref:INN>
								<oref:KPP>'+isnull(convert(varchar(50), C.KPP), '')+'</oref:KPP>
								<oref:FullName>'+isnull(convert(varchar(255), C.FullName), '')+'</oref:FullName>
								<oref:ShortName>'+isnull(convert(varchar(255), C.ShortName), '')+'</oref:ShortName>
								<oref:address>
									<oref:Country>'+isnull(convert(varchar(50), C.Country), '643')+'</oref:Country>
									<oref:RegionCode>'+isnull(convert(varchar(50), C.RegionCode), '')+'</oref:RegionCode>
									<oref:description>'+isnull(convert(varchar(255), C.description), '')+'</oref:description>
								</oref:address>
							</oref:UL>
						</pref:Producer>
 					</rpp:Product>
					' + case when CR.InformF2RegId is not null then '<rpp:RegForm2>'+isnull(convert(varchar(50), CR.InformF2RegId), '')+'</rpp:RegForm2>' else '' end +'
					<rpp:Quantity>'+Replace(isnull(convert(varchar(50), CR.Quantity),'0'), ',', '.')+'</rpp:Quantity>
 				</rpp:Resource>'
			from EGAIS_DocumentLineContentResource CR
				left join EGAIS_Ware W on W.AlcCode = CR.AlcCode
				left join EGAIS_CompanyRests ECR on ECR.AlcCode = CR.AlcCode and ECR.InformARegId = CR.InformF1RegId and ECR.InformBRegId = CR.InformF2RegId and 
						ECR.FSRAR_ID = @Consignee_ClientRegId
				left join EGAIS_Company_2 C on C.ClientRegId = ECR.Producer_ClientRegId
			where CR.IntId = @DocumentIntId

			select  @ContentResource = @ContentResource + '</rpp:ContentResource>'

		end

		select @SourceXML = @SourceXML + isnull(@ContentResource,'')


		select @SourceXML = @SourceXML + 
						'</ns:RepProducedProduct>
					</ns:Document>
				</ns:Documents>
			'
        select @Version = 'v2' 
end

		update EGAIS_Document set
			SourceXML = @SourceXML
           ,Version = @Version
		where IntId = @DocumentIntId

		end try	

		begin catch


 			SELECT 
        		ERROR_NUMBER() AS ErrorNumber
        		,ERROR_SEVERITY() AS ErrorSeverity
        		,ERROR_STATE() AS ErrorState
        		,ERROR_PROCEDURE() AS ErrorProcedure
        		,ERROR_LINE() AS ErrorLine
        		,ERROR_MESSAGE() AS ErrorMessage;

			if @@trancount>0
				rollback tran EGAIS_DOCUMENT_Write

		end catch

		if @@trancount>0
			commit tran EGAIS_DOCUMENT_Write

	end
		
	
end*/


GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Document_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Document_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
    

	select *
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Document 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Document_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Document_Insert]( @Document_Object nvarchar(50)=NULL, @DocumentDate smalldatetime=NULL, @DocumentNumber nvarchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


	declare
		@Method nvarchar(255)
		,@Expression nvarchar(max)

	select @Method = etl.Method 
		from  [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl
				on etl.Document_Object = d.Document_Object
					and etl.DocumentTypeId = d.DocumentTypeId
	where d.Document_Object = @Document_Object
		and d.DocumentDate = @DocumentDate
		and d.DocumentNumber = @DocumentNumber

	set @Expression = N'exec ' + @Method + ' @Document_Object, @DocumentDate, @DocumentNumber';

	exec sp_executesql @Expression, N'@Document_Object nvarchar(55), @DocumentDate smalldatetime, @DocumentNumber nvarchar(55)'
			,@Document_Object = @Document_Object
			,@DocumentDate = @DocumentDate
			,@DocumentNumber = @DocumentNumber;
						
		
	
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Document_Insert_ProdReceipt]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Document_Insert_ProdReceipt]( @Document_Object varchar(50)=NULL, @DocumentDate smalldatetime=NULL, @DocumentNumber varchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      
	
	declare 
		@DocumentIntId int
		,@DocumentTypeId varchar(55)
		,@SSPQuantity decimal(16,4)

	create table #RAR_DocumentLine
	(
		Position_Identity int
		,LineNumber int
		,Type varchar(50)
		,AlcCode varchar(50)
		,Producer_ClientRegId varchar(50)
		,Quantity decimal(16, 4)
		,Price decimal(16, 4)
		,InformARegId varchar(50)
		,InformBRegId varchar(50)
		,PackId varchar(50)
		,Party varchar(50)
		,WareId varchar(50)
		,WareName varchar(255)
		,UnitId varchar(50)
		,UnitName varchar(255)
		,WareTaxCode varchar(50)
		,PRInterCompanyId varchar(50)
		,DateB nvarchar(50)
		,PartNumber nvarchar(50)
		,FSMType nvarchar(3)
		,AnalytLotIntId int
	)
	
		select 
			@DocumentIntId = d.DocumentIntId
			,@DocumentTypeId = d.DocumentTypeId
		from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d
			where d.Document_Object = @Document_Object
				and d.DocumentDate = @DocumentDate
				and d.DocumentNumber = @DocumentNumber  

	
		if @Document_Object = 'ProdReceipt' and @DocumentTypeId in ('ProductFGD', 'ProductFGN')
			begin
				if exists(select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Document rd where rd.DocumentIntId = @DocumentIntId and rd.Status = 0)
					begin
						delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Document where DocumentIntId = @DocumentIntId
						delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_DocumentLine where DocumentIntId = @DocumentIntId
					end

				insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Document(DocumentIntId, Status)
					values(@DocumentIntId, 0)

				select @SSPQuantity = alk2.Quantity
					from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d 
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotLink alk 
							on alk.DocumentIntId = d.DocumentIntId
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLot al 
							on al.AnalytLotIntId = alk.AnalytLotIntId
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLot al2 
							on al2.WareId = al.WareId
						    	and al2.PartNumber = al.PartNumber
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotLink alk2 
							on alk2.AnalytLotIntId = al2.AnalytLotIntId
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Document d2 
							on d2.DocumentIntId = alk2.DocumentIntId
					where d.DocumentIntid = @DocumentIntid
						and alk.Direction = 1
						and (d2.Document_Object = 'ProdReceipt' and d2.DocumentTypeId = 'Product')


				insert into #RAR_DocumentLine(
								Position_Identity
								,LineNumber
								,WareId
								,WareName
								,UnitId
								,UnitName
								,Quantity
								,Price
								,AlcCode
								,InformARegId
								,InformBRegId
								,DateB
								,PartNumber
								,FSMType
								,AnalytLotIntId)
					 select 
					  	ROW_NUMBER() over(order by alli.AnalytLotIntId asc) as LineNumber
						,ROW_NUMBER() over(order by alli.AnalytLotIntId asc) as LineNumber
					  	,W.WareId
					  	,W.WareName#Rus
					  	,U.UnitId
					  	,U.UnitName#Rus 
					  	,sum(case when EW.WareType = 'Unpacked' then alli.Quantity * cuf.FactorValue / cufdal.FactorValue else alli.Quantity end) + isnull(@SSPQuantity, 0)
					  	,case when EW.WareType = 'Unpacked' then cnl.DiscountPrice / (cuf.FactorValue / cufdal.FactorValue) else cnl.DiscountPrice end
				        ,coalesce(ALA_W.Value, caf.Value, CAA1.Value) as AlcCode
					  	,NULL as InformARegId
					  	,NULL as InformBRegId,
					  	convert(nvarchar(50), ltrim(rtrim(Ala3.Value)))
					  	,A.PartNumber
					  	,coalesce(convert(varchar(3), ltrim(rtrim(CAA_FSM.Value))), '') 
					  	,alli.AnalytLotIntId
					from [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotLink alli with(nolock)
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLot A with(nolock) 
							on A.AnalytLotIntId = Alli.AnalytLotIntId
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CustNoteLine cnl with(nolock) 	
							on CNL.CustNOte_Object = @Document_Object 
								and CNL.CustNoteDate = @DocumentDate 
								and CNL.CustNoteNumber = @DocumentNumber 
								and alli.LineNumber = cnl.LineNumber
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Ware W with(nolock) 
							on W.WareId = a.WareId 
								and W.IsLotControl = 1
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA1 with(nolock) 
							on CAA1.AdditionalAttribId = 'WARE_EGAIS' 
								and CAA1.Class_Object = 'Ware' 
								and CAA1.ClassId = W.WareId
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.EGAIS_Ware EW with(NOLOCK) 
							on EW.AlcCode = ltrim(rtrim(CAA1.Value))
						join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.Unit U with(nolock) 
							on U.UnitId = CNL.UnitId
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA1 with(nolock) 
							on AlA1.AnalytLotIntId = alli.AnalytLotIntId 
								and AlA1.AdditionalAttribId = 'InformARegId'
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA2 with(nolock) 
							on AlA2.AnalytLotIntId = alli.AnalytLotIntId 
								and AlA2.AdditionalAttribId = 'InformBRegId'
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA3 with(nolock) 
							on AlA3.AnalytLotIntId = alli.AnalytLotIntId 
								and AlA3.AdditionalAttribId = 'DateB'
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.AnalytLotAttribute AlA_W with(nolock) 
							on AlA_W.AnalytLotIntId = alli.AnalytLotIntId 
								and AlA_W.AdditionalAttribId in ('AlcCode','WL906')
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAdditionalAttrib CAA_FSM with(nolock) 
							on CAA_FSM.AdditionalAttribId = 'EGAIS_FSMType' 
								and CAA_FSM.Class_Object = 'Ware' 
								and CAA_FSM.ClassId = W.WareId
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUF with(nolock) 
							on CUF.WareId = W.WareId 
								and CUF.UnitId = U.UnitId
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.CrossUnitFactor CUFDAL with(nolock) 
							on CUFDAL.WareId = W.WareId 
								and CUFDAL.UnitId = 'dal'
						left join [MSK-HQ-MNT01\ERP_MAIN].mch.dbo.ClassAttribHist caf with(nolock) 
							on caf.ClassId = w.WareId 
						        and caf.AttribId = 'WARE_EGAIS' 
								and caf.Class_Object = 'Ware' 
								and ala3.Value between caf.BeginDate and caf.EndDate
								and caf.Value is not null
						where alli.DocumentIntId = @DocumentIntId 
						  and alli.Direction = 1
					    group by W.WareId
					         ,W.WareName#Rus
					         ,U.UnitId
					         ,U.UnitName#Rus
					         ,ALA_W.Value
					         ,caf.Value
					         ,CAA1.Value
					         ,Ala3.Value
					         ,A.PartNumber
					         ,CAA_FSM.Value 
					         ,alli.AnalytLotIntId
					         ,EW.WareType
						     ,cnl.DiscountPrice
						     ,cuf.FactorValue
						     ,cufdal.FactorValue
				

				insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_DocumentLine(
								DocumentIntId
								,Position_Identity
								,AlcCode
								,Quantity
								,RealQuantity
								,Price
								,InformARegId
								,InformBRegId
								,AnalytLotIntId)
					select 
						@DocumentIntId
						,Position_Identity
						,AlcCode
						,Quantity
						,Quantity
						,Price
						,InformARegId
						,InformBRegId
						,AnalytLotIntId
					from #RAR_DocumentLine
			end
	
		
				 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Document_SendDocumentToUTM]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Document_SendDocumentToUTM]( @DocumentIntId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Status smallint = 0 

	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_DocumentLine(
								DocumentIntId
								)
					select 
						@DocumentIntId

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_FormA_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_FormA_Insert]( @BottlingDate datetime=NULL, @ConsigneeRAR_CompanyId int=NULL, @DocumentDate datetime=NULL, @DocumentNumber varchar(50)=NULL, @FixDate datetime=NULL, @FixNumber varchar(50)=NULL, @InformProduction varchar(50)=NULL, @Quantity decimal(16,4)=NULL, @RAR_WareId int=NULL, @ShipperRAR_CompanyId int=NULL, @UTMId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	
	if not exists(select top 1* 
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_FormA fa
				where fa.InformProduction = @InformProduction
					and fa.BottlingDate = @BottlingDate
					and fa.UTMId = @UTMId)
		begin

			if(@BottlingDate is null)
				set @BottlingDate = ''

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_FormA(
								InformProduction
								,BottlingDate
								,DocumentDate
								,DocumentNumber
								,FixNumber
								,FixDate
								,ShipperRAR_CompanyId
								,ConsigneeRAR_CompanyId
								,RAR_WareId
								,Quantity
								,UTMId)
				values(
					@InformProduction
					,@BottlingDate
					,@DocumentDate
					,@DocumentNumber
					,@FixNumber
					,@FixDate
					,@ShipperRAR_CompanyId
					,@ConsigneeRAR_CompanyId
					,@RAR_WareId
					,@Quantity
					,@UTMId)	

		end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_FormA_ParseReplyFormA]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_FormA_ParseReplyFormA]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@InformProduction varchar(50)
		,@BottlingDate datetime
		,@DocumentNumber varchar(50)
		,@DocumentDate datetime
		,@FixNumber varchar(50)
		,@FixDate datetime
		,@ShipperFSRAR_Id varchar(50)
		,@ConsigneeFSRAR_Id varchar(50)
		,@AlcCode varchar(100)
		,@Quantity decimal(16, 4)
		,@ShipperRAR_CompanyId int
		,@ConsigneeRAR_CompanyId int
		,@RAR_WareId int
		,@UTMId int


	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@UTMId = ud.UTM_Id
	from UTM_Data ud
		join UTM u
			on u.UTMId = ud.UTM_Id  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1


	if(isnull(@Content, '') = '')
		return 1


	exec sp_xml_preparedocument @Descriptor out, @Content, '<root  
															 	xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef"
															 	xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" 
																xmlns:rfa="http://fsrar.ru/WEGAIS/ReplyFormA"
																xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" />'


	begin try
		begin transaction

			select 
				@InformProduction = InformProduction
				,@BottlingDate = BottlingDate
				,@DocumentNumber = DocumentNumber 
				,@DocumentDate = DocumentDate
				,@FixNumber = FixNumber
				,@FixDate = FixDate
				,@ShipperFSRAR_Id = ShipperFSRAR_Id
				,@ConsigneeFSRAR_Id = ConsigneeFSRAR_Id
				,@AlcCode = AlcCode
				,@Quantity = Quantity
			from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyFormA', 1)
				with 
					(
						InformProduction varchar(50) './rfa:InformARegId'
						,BottlingDate datetime './rfa:BottlingDate'
						,DocumentNumber varchar(50)  './rfa:TTNNumber'
						,DocumentDate datetime './rfa:TTNDate'
						,FixNumber varchar(50)  './rfa:EGAISNumber'
						,FixDate datetime './rfa:EGAISDate'
						,ShipperFSRAR_Id varchar(50)  './rfa:Shipper/oref:ClientRegId'
						,ConsigneeFSRAR_Id varchar(50) './rfa:Consignee/oref:ClientRegId'
						,AlcCode varchar(50) './rfa:Product/pref:AlcCode'
						,Quantity decimal(16,4)  './rfa:Quantity'
					);


			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Company_GetRAR_CompanyId
						@FSRAR_Id = @ShipperFSRAR_Id
						,@RAR_CompanyId = @ShipperRAR_CompanyId out

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Company_GetRAR_CompanyId
						@FSRAR_Id = @ConsigneeFSRAR_Id
						,@RAR_CompanyId = @ConsigneeRAR_CompanyId out

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Ware_GetRAR_WareId
						@AlcCode = @AlcCode
						,@RAR_WareId = @RAR_WareId out 
			
			
			/*if not exists(select top 1* 
							from _EG.RAR_FormA fa 
						where fa.InformProduction = @InformProduction 
							and fa.BottlingDate = @BottlingDate)*/
				--begin		
					

					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_FormA_Insert
								@InformProduction = @InformProduction
								,@BottlingDate = @BottlingDate
								,@DocumentDate = @DocumentDate
								,@DocumentNumber = @DocumentNumber
								,@FixNumber = @FixNumber
								,@FixDate = @FixDate
								,@ShipperRAR_CompanyId = @ShipperRAR_CompanyId
								,@ConsigneeRAR_CompanyId = @ConsigneeRAR_CompanyId
								,@RAR_WareId = @RAR_WareId
								,@Quantity = @Quantity
								,@UTMId = @UTMId

				--end


			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'

		commit transaction
	end try			
	begin catch
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage

		rollback transaction
	end catch


GO
/****** Object:  StoredProcedure [dbo].[bpRAR_FormA_SelectBottlingDate]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_FormA_SelectBottlingDate]( @UTMId int=NULL, @RAR_WareId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	select *
		from RAR_FormA fa
 	where fa.RAR_WareId = @RAR_WareId
		and fa.UTMId = @UTMId 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_FormB_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_FormB_Insert]( @AlcCode varchar=NULL, @ConsigneeFSRAR_Id varchar(50)=NULL, @DocumentDate datetime=NULL, @DocumentNumber varchar(100)=NULL, @InformMotion varchar(50)=NULL, @ProducerFSRAR_Id varchar(50)=NULL, @Quantity decimal(16,4)=NULL, @ShipperFSRAR_Id varchar(50)=NULL, @ShippingDate datetime=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_FormB(
					InformMotion 
					,DocumentNumber 
					,DocumentDate 
					,ShippingDate 
					,ShipperFSRAR_Id
					,ConsigneeFSRAR_Id 
					,AlcCode 
					,ProducerFSRAR_Id 
					,Quantity)
		values( 
			@InformMotion 
			,@DocumentNumber 
			,@DocumentDate 
			,@ShippingDate 
			,@ShipperFSRAR_Id 
			,@ConsigneeFSRAR_Id 
			,@AlcCode 
			,@ProducerFSRAR_Id 
			,@Quantity) 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_FormB_ParseReplyFormB]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_FormB_ParseReplyFormB]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	
	declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@InformMotion varchar(50)
		,@DocumentNumber varchar(50)
		,@DocumentDate datetime
		,@ShippingDate datetime
		,@ShipperFSRAR_Id varchar(50)
		,@ConsigneeFSRAR_Id varchar(50)
		,@AlcCode varchar(100)
		,@ProducerFSRAR_Id varchar(50)
		,@Quantity decimal(16, 4)


	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.UTMId = ud.UTM_Id  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1


	if(coalesce(@Content, '') = '')
		return 1


	exec sp_xml_preparedocument @Descriptor out, @Content, '<root  
															 	xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef"
															 	xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" 
																xmlns:rfb="http://fsrar.ru/WEGAIS/ReplyFormB"
																xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" />'

	begin try
		begin transaction
			
				select 
					@InformMotion = InformMotion
					,@DocumentNumber = DocumentNumber
					,@DocumentDate = DocumentDate
					,@ShippingDate = ShippingDate
					,@ShipperFSRAR_Id = ShipperFSRAR_Id
					,@ConsigneeFSRAR_Id = ConsigneeFSRAR_Id
					,@AlcCode = AlcCode
					,@ProducerFSRAR_Id = ProducerFSRAR_Id
					,@Quantity = Quantity
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyFormB', 1)
					with 
						(
							InformMotion varchar(50) './rfb:InformBRegId'
							,DocumentNumber varchar(50) './rfb:TTNNumber'
							,DocumentDate datetime './rfb:TTNDate'
							,ShippingDate datetime './rfb:ShippingDate'
							,ShipperFSRAR_Id varchar(50) './rfb:Shipper/oref:ClientRegId'
							,ConsigneeFSRAR_Id varchar(50) './rfb:Consignee/oref:ClientRegId'
							,AlcCode varchar(100) './rfb:Product/pref:AlcCode'
							,ProducerFSRAR_Id varchar(50) './rfb:Product/pref:Producer/oref:ClientRegId'
							,Quantity decimal(16, 4) './rfb:Quantity'
						);


				if exists(select top 1* from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_FormB fb where fb.InformMotion = @InformMotion and fb.AlcCode = @AlcCode)
					begin
		
						update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_FormB
							set 
								DocumentNumber = @DocumentNumber  
								,DocumentDate = @DocumentDate
								,ShippingDate = @ShippingDate
								,ShipperFSRAR_Id = @ShipperFSRAR_Id
								,ConsigneeFSRAR_Id = @ConsigneeFSRAR_Id
								,ProducerFSRAR_Id = @ProducerFSRAR_Id 
								,Quantity =	@Quantity
						where InformMotion = @InformMotion

					end
				else
					begin
					
						exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_FormB_Insert
									@InformMotion = @InformMotion
									,@DocumentNumber = @DocumentNumber
									,@DocumentDate = @DocumentDate
									,@ShippingDate = @ShippingDate
									,@ShipperFSRAR_Id = @ShipperFSRAR_Id
									,@ConsigneeFSRAR_Id = @ConsigneeFSRAR_Id
									,@AlcCode = @AlcCode
									,@ProducerFSRAR_Id = @ProducerFSRAR_Id
									,@Quantity = @Quantity

					end

			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'

		commit transaction
	end try			
	begin catch
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage

		rollback transaction
	end catch

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_MotionInfo_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_MotionInfo_Insert]( @DocumentDate datetime=NULL, @DocumentNumber varchar(100)=NULL, @FixDate datetime=NULL, @FixNumber varchar(50)=NULL, @RAR_CustNoteId int=NULL, @RAR_MotionInfoId int=NULL OUTPUT, @RegNumber varchar(50)=NULL, @ReplyId varchar(100)=NULL, @UTM_Id int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	begin try
		begin transaction

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo(
							DocumentNumber
							,DocumentDate
							,FixNumber
							,FixDate
							,RegNumber
							,ReplyId
							,RAR_CustNoteId
							,UTM_Id)
				values(
					@DocumentNumber
					,@DocumentDate
					,@FixNumber
					,@FixDate
					,@RegNumber
					,@ReplyId
					,@RAR_CustNoteId
					,@UTM_Id)

			set @RAR_MotionInfoId = @@Identity;

		commit transaction
	end try
		begin catch
			select 
			     ERROR_NUMBER() AS ErrorNumber
		        ,ERROR_SEVERITY() AS ErrorSeverity
		        ,ERROR_STATE() AS ErrorState
		        ,ERROR_PROCEDURE() AS ErrorProcedure
		        ,ERROR_LINE() AS ErrorLine
		        ,ERROR_MESSAGE() AS ErrorMessage;

			rollback transaction
	end catch

	 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_MotionInfo_ParseForm2RegInfo]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_MotionInfo_ParseForm2RegInfo]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	 declare 
		@Descriptor int
		,@ReplyId varchar(100)
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@WBRegId varchar(50)
		,@EGAISFixNumber varchar(50)
		,@EGAISFixDate datetime
		,@WBNUMBER varchar(50)
		,@WBDate datetime
		,@InformF2RegId varchar(50)
		,@Position_Identity int
		,@RAR_CustNoteId int
		,@RAR_MotionInfoId int
		,@Identity int
		,@WayBill_Identity varchar(255)
		,@UTM_Id int


	create table #MotionInfoLine(
					RAR_CustNoteId int
					,Position_Identity int
					,InformF2RegId varchar(50))

	
	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ReplyId = ud.ReplyId
		,@ExchangeTypeCode = ud.ExchangeTypeCode
		,@UTM_Id = ud.UTM_Id
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1


	exec sp_xml_preparedocument @Descriptor out, @Content, '<root
																xmlns:wbr="http://fsrar.ru/WEGAIS/TTNInformF2Reg"
																xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"
																xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2" 
																xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" />'


	--begin try
		--begin transaction

			select 
				@WBRegId = WBRegId
				,@EGAISFixNumber = EGAISFixNumber
				,@EGAISFixDate = cast(EGAISFixDate as datetime) 
				,@WBNUMBER = WBNUMBER
				,@WBDate = cast(WBDate as datetime)
				,@WayBill_Identity = WayBill_Identity
			from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:TTNInformF2Reg/wbr:Header', 1)
				with(
						WBRegId varchar(50) './wbr:WBRegId'
						,EGAISFixNumber varchar(50) './wbr:EGAISFixNumber'
						,EGAISFixDate datetime './wbr:EGAISFixDate'
						,WBNUMBER varchar(50) './wbr:WBNUMBER'
						,WBDate datetime './wbr:WBDate'
						,WayBill_Identity varchar(255) './wbr:Identity'
					)
			

			insert into #MotionInfoLine(
							Position_Identity							
							,InformF2RegId)
				select
					Position_Identity					
					,InformF2RegId
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:TTNInformF2Reg/wbr:Content/wbr:Position', 1)
					with 
						(	
							Position_Identity int './wbr:Identity' 							
							,InformF2RegId varchar(50) './wbr:InformF2RegId'					
						);

			
			begin try
				set @Identity = convert(int, @WayBill_Identity)
			end try
			begin catch
				set @Identity = NULL
			end catch


			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_MotionInfo_Insert
				@DocumentNumber = @WBNUMBER
				,@DocumentDate = @WBDate
				,@FixNumber = @EGAISFixNumber
				,@FixDate = @EGAISFixDate
				,@RegNumber = @WBRegId
				,@ReplyId = @ReplyId
				,@RAR_CustNoteId = @Identity
				,@UTM_Id = @UTM_Id
				,@RAR_MotionInfoId = @RAR_MotionInfoId out	
		
			declare MotionInfo_Cursor cursor for   
				select
					Position_Identity
					,InformF2RegId 
				from #MotionInfoLine
		
			open MotionInfo_Cursor
		
			fetch next from MotionInfo_Cursor   
				into
					@Position_Identity
					,@InformF2RegId
		
			while @@fetch_status = 0  
				begin
		
					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_MotionInfoLine_Insert
							@RAR_MotionInfoId = @RAR_MotionInfoId
							,@Position_Identity = @Position_Identity
							,@InformMotion = @InformF2RegId
		
					fetch next from MotionInfo_Cursor   
						into
							@Position_Identity
							,@InformF2RegId
		
				end
	
		close MotionInfo_Cursor
			deallocate MotionInfo_Cursor

		
		exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
					@RowId = @RowId
					,@Status = 'Accepted'

		--update _EG.UTM_Data set Status = 'Accepted' where RowId = @RowId

		/*commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch*/
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_MotionInfoHistoryReestr_J_DeleteOldHistory]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_MotionInfoHistoryReestr_J_DeleteOldHistory]( @Period tinyint )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          


	delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfoHistoryReestr
		where datediff(day, CreateTime, getdate()) > @Period
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_MotionInfoHistoryReestr_ParseHistoryFormB]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_MotionInfoHistoryReestr_ParseHistoryFormB]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


SET ANSI_NULLS ON
SET ANSI_WARNINGS ON
set concat_null_yields_null on
set ANSI_padding on


declare 
	@XMLContent xml
	,@InformMotion varchar(50)


	select  
		@XMLContent = replace(ud.Content, 'utf-8', 'utf-16')
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Direction = 1

	begin try
		begin transaction

			;with XMLNAMESPACES (  
					 'http://fsrar.ru/WEGAIS/ReplyHistFormB' as hf
					 ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns)

			select 
				@InformMotion = InformMotion.value('hf:InformBRegId[1]', 'varchar(50)')
			from @XMLContent.nodes('/ns:Documents/ns:Document/ns:ReplyHistFormB') as InformMotion (InformMotion)

			if(isnull(@InformMotion, '') <> '')
				begin

					if object_id(N'tempdb..#MotionInfoHistory', N'U') is not null
						drop table #MotionInfoHistory

					create table #MotionInfoHistory(
												InformMotion varchar(50)
												,DocType varchar(50)
												,RegId varchar(50)
												,OperationName varchar(255)
												,OperationDate datetime
												,Quantity decimal(16,4))

					;with XMLNAMESPACES (  
								 'http://fsrar.ru/WEGAIS/ReplyHistFormB' as hf
								 ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns)

					insert into #MotionInfoHistory(
											InformMotion
											,DocType 
											,RegId 
											,OperationName 
											,OperationDate 
											,Quantity)			
						select
							 @InformMotion
							,DocType = History.value('hf:DocType[1]', 'varchar(50)')
							,RegId = History.value('hf:DocId[1]', 'varchar(50)')
							,OperationName = History.value('hf:Operation[1]', 'varchar(255)')					
							,OperationDate = History.value('hf:OperDate[1]', 'datetime')
							,Quantity = History.value('hf:Quantity[1]', 'decimal(16,4)')
						from @XMLContent.nodes('/ns:Documents/ns:Document/ns:ReplyHistFormB/hf:HistoryB/hf:OperationB') as History (History)		
							order by OperationDate


					if exists(select top 1* 
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfoHistoryReestr r
							where r.InformMotion = @InformMotion)
						begin

							delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfoHistoryReestr
								where InformMotion = @InformMotion

						end

					declare @CreateTime datetime = getdate();

					insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfoHistoryReestr(
										InformMotion
										,DocType 
										,RegId 
										,OperationName 
										,OperationDate 
										,Quantity
										,CreateTime)
						select
							h.InformMotion
							,h.DocType 
							,h.RegId 
							,h.OperationName 
							,h.OperationDate 
							,h.Quantity
							,@CreateTime	
						from #MotionInfoHistory h
							order by h.OperationDate


					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
								@RowId = @RowId
								,@Status = 'Accepted'
								
				end

		commit transaction
	end try
	begin catch

		select 
		    ERROR_NUMBER() AS ErrorNumber
		    ,ERROR_SEVERITY() AS ErrorSeverity
		    ,ERROR_STATE() AS ErrorState
		    ,ERROR_PROCEDURE() AS ErrorProcedure
		    ,ERROR_LINE() AS ErrorLine
		    ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction

	end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_MotionInfoLine_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_MotionInfoLine_Insert]( @InformMotion varchar(50)=NULL, @Position_Identity int=NULL, @RAR_MotionInfoId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfoLine(
					RAR_MotionInfoId
					,Position_Identity
					,InformMotion)
		values(
			@RAR_MotionInfoId
			,@Position_Identity	
			,@InformMotion)
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_MotionInfoMoveReestr_ParseParentHistForm2]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_MotionInfoMoveReestr_ParseParentHistForm2]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

set ANSI_NULLS on
set ANSI_WARNINGS on
set concat_null_yields_null on
set ANSI_padding on


declare 
	@Descriptor int
	,@XMLContent xml
	,@InformMotion varchar(50)


	select  
		@XMLContent = replace(ud.Content, 'utf-8', 'utf-16')
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Direction = 1

	if @XMLContent is null
		return 1


	begin try
		begin transaction

			declare @TargetInformMotion varchar(64)

			;with XMLNAMESPACES (  
						'http://fsrar.ru/WEGAIS/ReplyParentHistForm2' as hf
					   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
					   ,'http://www.w3.org/2001/XMLSchema-instance' as xsi)

			select 
				@TargetInformMotion  = Position.value('hf:InformF2RegId[1]', 'varchar(64)')				
			from @XMLContent.nodes('/ns:Documents/ns:Document/ns:ReplyParentHistForm2') as Position (Position)

			if not exists(select top 1 r.TargetInformMotion from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfoMoveReestr r where r.TargetInformMotion = @TargetInformMotion)
				begin

					;with XMLNAMESPACES (  
									'http://fsrar.ru/WEGAIS/ReplyParentHistForm2' as hf
								   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
								   ,'http://www.w3.org/2001/XMLSchema-instance' as xsi)
			
			
					insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfoMoveReestr(
														TargetInformMotion
														,[Level]
														,InformMotion
														,ParentInformMotion
														,ShipperFSRAR_Id
														,ConsigneeFSRAR_Id
														,RegId
														,Quantity)
						select 
							TargetInformMotion = @TargetInformMotion
							,[Level] = step.value('hf:lev[1]', 'int')
							,InformMotion = step.value('hf:Form2[1]', 'varchar(64)')
							,ParentInformMotion = step.value('hf:parentForm2[1]', 'varchar(64)')
							,ShipperFSRAR_Id = step.value('hf:Shipper[1]', 'varchar(64)')
							,ConsigneeFSRAR_Id = step.value('hf:Consignee[1]', 'varchar(64)')
							,RegId = step.value('hf:WBRegId[1]', 'varchar(64)')
							,Quantity = step.value('hf:amount[1]', 'decimal(16,4)')
						from @XMLContent.nodes('/ns:Documents/ns:Document/ns:ReplyParentHistForm2/hf:ParentHist/hf:step') as step (step)				
							order by [Level]

				end
		
		
				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'
		
			commit transaction
		end try
		begin catch
		
			select 
		        ERROR_NUMBER() AS ErrorNumber
		        ,ERROR_SEVERITY() AS ErrorSeverity
		        ,ERROR_STATE() AS ErrorState
		        ,ERROR_PROCEDURE() AS ErrorProcedure
		        ,ERROR_LINE() AS ErrorLine
		        ,ERROR_MESSAGE() AS ErrorMessage;
		
			rollback transaction
		end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_MotionInfoMoveReestr_ParseTTNHistoryF2Reg]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_MotionInfoMoveReestr_ParseTTNHistoryF2Reg]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

set ANSI_NULLS on
set ANSI_WARNINGS on
set concat_null_yields_null on
set ANSI_padding on


exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
			@RowId = @RowId
			,@Status = 'NotProcessed'

/*declare 
	@Descriptor int
	,@XMLContent xml
	,@InformMotion varchar(50)


	select  
		@XMLContent = replace(ud.Content, 'utf-8', 'utf-16')
	from _EG.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Direction = 1

	if @XMLContent is null
		return 1


	begin try
		begin transaction

			declare @RegId varchar(64)

			;with XMLNAMESPACES (  
						'http://fsrar.ru/WEGAIS/TTNHistoryF2Reg' as wbr
					   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
					   ,'http://www.w3.org/2001/XMLSchema-instance' as xsi)

			select 
				@RegId  = Position.value('wbr:WBRegId[1]', 'varchar(64)')				
			from @XMLContent.nodes('/ns:Documents/ns:Document/ns:TTNHistoryF2Reg/wbr:Header') as Position (Position)

			;with XMLNAMESPACES (  
						'http://fsrar.ru/WEGAIS/TTNHistoryF2Reg' as wbr
					   ,'http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01' as ns
					   ,'http://www.w3.org/2001/XMLSchema-instance' as xsi)


		insert into _EG.RAR_MotionInfoMoveReestr(
											RegId
											,[Identity]
											,[Level]
											,InformMotion
											,ParentInformMotion
											,ShipperFSRAR_Id
											,ConsigneeFSRAR_Id
											,SourceRegId
											,Quantity)
			select 
				RegId = @RegId
				,[Identity] = Position.value('wbr:Identity[1]', 'int')
				,[Level] = step.value('wbr:lev[1]', 'int')
				,InformMotion = step.value('wbr:Form2[1]', 'varchar(64)')
				,ParentInformMotion = step.value('wbr:parentForm2[1]', 'varchar(64)')
				,ShipperFSRAR_Id = step.value('wbr:Shipper[1]', 'varchar(64)')
				,ConsigneeFSRAR_Id = step.value('wbr:Consignee[1]', 'varchar(64)')
				,sourceRegId = step.value('wbr:WBRegId[1]', 'varchar(64)')
				,Quantity = step.value('wbr:amount[1]', 'decimal(16,4)')
			from @XMLContent.nodes('/ns:Documents/ns:Document/ns:TTNHistoryF2Reg/wbr:Content/wbr:Position') as Position (Position)
				outer apply Position.nodes('wbr:HistF2') as HistF2 (HistF2)
				outer apply HistF2.nodes('wbr:step') as step (step)					
			order by [Identity], [Level]


			exec _EG.bpUTM_Data_SetStatus
					@RowId = @RowId
					,@Status = 'Accepted'

		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch*/


GO
/****** Object:  StoredProcedure [dbo].[bpRAR_ProductionInfo_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_ProductionInfo_Insert]( @RAR_CustNoteId int, @Position_Identity int, @ProductRepId varchar(100), @ReplyId varchar(100), @InformProduction varchar(50), @InformMotion varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare @RAR_ProdInfoId int

	begin try
		begin transaction

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_ProductionInfo(
							ProductRepId
							,RAR_CustNoteId
							,ReplyId)
				values(
					@ProductRepId
					,@RAR_CustNoteId
					,@ReplyId)
				
			set @RAR_ProdInfoId = @@Identity;
		
			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_ProductionInfoLine(
							RAR_ProdInfoId
							,Position_Identity
							,InformProduction
							,InformMotion)
				values(
					@RAR_ProdInfoId
					,@Position_Identity
					,@InformProduction
					,@InformMotion)
	
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNoteLine_UpdateInform
					@RAR_CustNoteId
					,@Position_Identity
					,@InformProduction
					,@InformMotion

		commit transaction				
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;

		rollback transaction
	end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_ProductionInfo_ParseForm1RegInfo]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_ProductionInfo_ParseForm1RegInfo]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare 
		@Descriptor int
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@RepRegId varchar(50)
		,@InformF1RegId varchar(50)
		,@InformF2RegId varchar(50)
		,@Position_Identity int
		,@RAR_CustNoteId int
		,@ReplyId varchar(100)
		,@UTMId int


	create table #ProductionInfo(
					RAR_CustNoteId int
					,Position_Identity int
					,RepRegId varchar(50)
					,InformF1RegId varchar(50)
					,InformF2RegId varchar(50))


	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
		,@ReplyId = ud.ReplyId
		,@UTMId = ud.UTM_Id 
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1  
			
	
	exec sp_xml_preparedocument @Descriptor out, @Content, '<root
																xmlns:wbr="http://fsrar.ru/WEGAIS/RepInformF1Reg"
																xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"
																xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2"
																xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" />'
	

	begin try
		begin transaction
	
			insert into #ProductionInfo
				select
					RAR_CustNoteId 
					,Position_Identity
					,RepRegId
					,InformF1RegId
					,InformF2RegId 
				from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:RepInformF1Reg', 1)
					with 
						(	
							RAR_CustNoteId int './wbr:Header/wbr:Identity'
							,Position_Identity int './wbr:Content/wbr:Position/wbr:Identity' 
							,RepRegId varchar(50) './wbr:Header/wbr:RepRegId'
							,InformF1RegId varchar(50) './wbr:Content/wbr:Position/wbr:InformF1RegId'
							,InformF2RegId varchar(50) './wbr:Content/wbr:Position/wbr:InformF2RegId'						
						);
		
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 'Accepted' where RowId = @RowId
	
		commit transaction			
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch
			
			
	declare ProductionInfo_Cursor cursor for   
		select * from #ProductionInfo
	
	open ProductionInfo_Cursor
	
	fetch next from ProductionInfo_Cursor   
		into
			@RAR_CustNoteId
			,@Position_Identity
			,@RepRegId
			,@InformF1RegId
			,@InformF2RegId
	
	while @@fetch_status = 0  
		begin
			
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_ProductionInfo_Insert
						@RAR_CustNoteId = @RAR_CustNoteId
						,@Position_Identity = @Position_Identity
						,@ProductRepId = @RepRegId
						,@ReplyId = @ReplyId
						,@InformProduction = @InformF1RegId
						,@InformMotion = @InformF2RegId

			exec mch.dbo.bpRAR_FormA_SendQueryFormA
							@UTMId = @UTMId
							,@InformProduction = @InformF1RegId
	
	
			fetch next from ProductionInfo_Cursor  
				into
					@RAR_CustNoteId
					,@Position_Identity
					,@RepRegId
					,@InformF1RegId
					,@InformF2RegId
		end
	
	close ProductionInfo_Cursor
		deallocate ProductionInfo_Cursor
 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RejectRepProducedAct_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_RejectRepProducedAct_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	select * from  [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RejectRepProducedAct 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RejectRepProducedAct_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_RejectRepProducedAct_Insert]( @RAR_CustNoteId int=NULL, @RAR_RejectRepProducedActId int=NULL OUTPUT, @RegId varchar(50)=NULL, @ReplyId varchar(50)=NULL, @RowId uniqueidentifier=NULL, @Status varchar(50)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RejectRepProducedAct(
					RAR_CustNoteId
					,RegId
					,ReplyId
					,RowId
					,Status
					,ActDate)
		values(
			@RAR_CustNoteId
			,@RegId
			,@ReplyId
			,@RowId
			,@Status
			,getdate())


	set @RAR_RejectRepProducedActId = @@identity;	
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RejectRepProducedAct_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_RejectRepProducedAct_SetStatus]( @ReplyId varchar(50), @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RejectRepProducedAct
		set Status = @Status
	where ReplyId = @ReplyId 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RepealWBAct_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_RepealWBAct_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RepealWBAct_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_RepealWBAct_Insert]( @ActDate datetime=NULL, @ActNumber varchar(50)=NULL, @Direction smallint=NULL, @FSRAR_Id varchar(50)=NULL, @RAR_CustNoteId int=NULL, @RAR_RepealWBActId int=NULL OUTPUT, @RegId varchar(50)=NULL, @ReplyId varchar(50)=NULL, @RowId uniqueidentifier=NULL, @Status varchar(50)=0, @UTMId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	 insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct(
					ActDate
					,ActNumber
					,FSRAR_Id
					,RegId
					,Status
					,UTMId
					,RowId
					,ReplyId
					,Direction
					,RAR_CustNoteId)
		values(
			@ActDate
			,@ActNumber
			,@FSRAR_Id
			,@RegId
			,@Status
			,@UTMId
			,@RowId
			,@ReplyId
			,@Direction
			,@RAR_CustNoteId)

	set @RAR_RepealWBActId = @@Identity;
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RepealWBAct_ParseRequestRepealWB]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_RepealWBAct_ParseRequestRepealWB]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	 declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@UTMId int
		,@Status nvarchar(50) = 'New'
		,@Direction smallint = 1
	

	select 
		@Content = replace(ud.Content, 'utf-8', 'utf-16') 
		,@UTMId = ud.UTM_Id	
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
	where ud.RowId = @RowId
		and ud.Status = @Status
		and ud.Direction = @Direction
	
	
	exec sp_xml_preparedocument @Descriptor out, @Content, '<root 
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
																xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"  
																xmlns:qp="http://fsrar.ru/WEGAIS/RequestRepealWB" />'
	
	
	begin try
		begin transaction
	
			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct(
							FSRAR_Id
							,ActNumber
							,ActDate
							,RegId
							,Status
							,UTMId
							,RowId
							,Direction)
				select
					FSRAR_Id
					,ActNumber
					,ActDate
					,RegId
					,@Status
					,@UTMId
					,@RowId
					,@Direction	
				from openxml(@Descriptor, N'ns:Documents/ns:Document/ns:RequestRepealWB', 1)
					with 
						(
							FSRAR_Id nvarchar(50) './qp:ClientId'
							,ActNumber nvarchar(50)'./qp:RequestNumber'
							,ActDate datetime './qp:RequestDate'
							,RegId nvarchar(50) './qp:WBRegId'
						);
	
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'

		commit transaction
	end try
		begin catch
	
			select 
		        ERROR_NUMBER() AS ErrorNumber
		        ,ERROR_SEVERITY() AS ErrorSeverity
		        ,ERROR_STATE() AS ErrorState
		        ,ERROR_PROCEDURE() AS ErrorProcedure
		        ,ERROR_LINE() AS ErrorLine
		        ,ERROR_MESSAGE() AS ErrorMessage;
	
			rollback transaction
		end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RepealWBAct_SendRequestRepealWB]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_RepealWBAct_SendRequestRepealWB]( @RAR_CustNoteId int )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	 declare 
		@FSRAR_Id varchar(50)
		,@RegId varchar(50)
		,@Content nvarchar(max)
		,@ClassId varchar(50) = 'RequestRepealWB'
		,@ExchangeTypeCode varchar(50)	
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@ActDate datetime
		,@Direction smallint = -1
		,@Status smallint = 0


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@RegId = mi.RegNumber
		,@UTM_Id = u.Id
		,@UTM_Path = u.URL + et.UTM_Path
		,@ExchangeTypeCode = et.ExchangeTypeCode
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RRAR_CustNote cn
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLink cnl
			on cnl.RAR_CustNoteId = cn.RAR_CustNoteId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RUTM_Data ud
			on ud.RowId = cnl.RowId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RUTM u
			on u.Id = ud.UTM_Id
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
			on mi.DocumentNumber = cn.DocumentNumber
				and mi.DocumentDate = cn.DocumentDate	
				and mi.ReplyId is null
				and cn.DocumentIntId is null	
		left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RUTM_ExchangeClass ec
			on ec.ClassId = @ClassId
		left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RUTM_ExchangeType et
			on et.Id = ec.DefaultTypeId
				and et.Direction = @Direction
	where cn.RAR_CustNoteId = @RAR_CustNoteId


	set @ActDate = getdate();

	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents Version="1.0"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
								xmlns:qp="http://fsrar.ru/WEGAIS/RequestRepealWB">
								<ns:Owner>
									<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:RequestRepealWB>
										<qp:ClientId>' + coalesce(@FSRAR_Id, '') + '</qp:ClientId>
										<qp:RequestNumber>' + convert(varchar(50), @RAR_CustNoteId) + '</qp:RequestNumber>
										<qp:RequestDate>' + convert(varchar(50), @ActDate, 126) + '</qp:RequestDate>
										<qp:WBRegId>' + coalesce(@RegId, '') + '</qp:WBRegId>
									</ns:RequestRepealWB>
								</ns:Document>
							</ns:Documents>'

	
	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_RepealWBAct.SendRequestRepealWB'                and Item=0), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_RepealWBAct.SendRequestRepealWB'                and Item=1), 'Ошибка отправки запроса! Отсутствует путь для типа обмена в УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@RegId, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_RepealWBAct.SendRequestRepealWB'                and Item=2), 'Ошибка отправки запроса! Отсутствует регистрационный номер ТТН')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			begin try
				begin transaction

					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,@UTM_Path
						,getdate()
						,@Direction
						,@UTM_Id
						,@Status
						,@ExchangeTypeCode

				commit transaction

			end try
			begin catch
				
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;

				rollback transaction

			end catch
		end 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RepealWBAct_SetRowId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_RepealWBAct_SetRowId]( @RAR_RepealWBActId int=NULL, @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct
		set RowId = @RowId
	where RAR_RepealWBActId = @RAR_RepealWBActId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_RepealWBAct_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_RepealWBAct_SetStatus]( @RAR_RepealWBActId int=NULL, @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct
		set Status = @Status
	where RAR_RepealWBActId = @RAR_RepealWBActId

	
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ticket_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ticket_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket order by TicketDate desc
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ticket_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_Ticket_Insert]( @DocType varchar(50)=NULL, @Identity nvarchar(50)=NULL, @OperationComment nvarchar(3000)=NULL, @OperationDate datetime=NULL, @OperationName nvarchar(50)=NULL, @OperationResult nvarchar(50)=NULL, @RAR_TicketId int=NULL, @RegId varchar(50)=NULL, @ReplyId nvarchar(50)=NULL, @TicketDate datetime=NULL, @UTM_Id int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ticket_ParseTicket]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ticket_ParseTicket]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@ExchangeTypeCode varchar(50)
		,@RAR_TicketId int
		,@UTM_Id int
		,@DocType nvarchar(50)
		

		select 
			@Content = replace(ud.Content, 'utf-8', 'utf-16')
			,@ExchangeTypeCode = ud.ExchangeTypeCode
			,@UTM_Id = ud.UTM_Id 
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
			where ud.RowId = @RowId
				and ud.Status = 'New'
				and ud.Direction = 1

		if(isnull(@Content, '') = '')
			return 1;  

			declare @Namespace nvarchar(max)
			select @Namespace = EgaisExchange.dbo.bpUTM_NamespaceLink_GetNamespaceList(@ExchangeTypeCode)
			select @Namespace = '<root ' + @Namespace + '/>'  	

			exec sp_xml_preparedocument @Descriptor out, @Content, @Namespace
			
			begin try
				begin transaction

					declare @rootPath nvarchar(256)
					select @rootPath = '/ns:Documents/ns:Document/ns:' + @ExchangeTypeCode

					select @DocType = DocType
						from openxml(@Descriptor, @rootPath, 1)
							with 
								(
									DocType nvarchar(50) './tc:DocType'
								); 

					if(@DocType <> 'AsiiuTimeSign' and @DocType <> 'AsiiuSign')
						begin

							insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket(
											TicketDate
											,[Identity]
											,ReplyId
											,RowId
											,RegId
											,UTM_Id
											,DocType
											,OperationName
											,OperationResult
											,OperationDate
											,OperationComment)
								select
									TicketDate
									,[Identity]
									,TransportId
									,@RowId
									,RegId
									,@UTM_Id
									,@DocType
									,OperationName
									,coalesce(OperationResult, Conclusion)
									,coalesce(OperationDate, ConclusionDate)
									,coalesce(OperationComment, Comments)
								from openxml(@Descriptor, N'ns:Documents/ns:Document/ns:Ticket', 1)
									with 
										(
											TicketDate datetime './tc:TicketDate'
											,[Identity] nvarchar(50) './tc:Identity'
											,TransportId nvarchar(50) './tc:TransportId'
											,RegId nvarchar(50) './tc:RegID'
											--,DocType nvarchar(50) './tc:DocType'
						
											,Conclusion nvarchar(50) './tc:Result/tc:Conclusion'
											,ConclusionDate datetime './tc:Result/tc:ConclusionDate'
											,Comments nvarchar(255) './tc:Result/tc:Comments'
						
											,OperationName nvarchar(50) './tc:OperationResult/tc:OperationName'
											,OperationResult nvarchar(50) './tc:OperationResult/tc:OperationResult'
											,OperationDate datetime './tc:OperationResult/tc:OperationDate'
											,OperationComment nvarchar(3000) './tc:OperationResult/tc:OperationComment'
										);
		
							set @RAR_TicketId = @@Identity;

							if(@RAR_TicketId is not null)
								begin
		
									exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Ticket_UpdateStatus
												@RAR_TicketId = @RAR_TicketId
		
								end

						end

					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
								@RowId = @RowId
								,@Status = 'Accepted'


				commit transaction
			end try
			begin catch
				rollback transaction
				
				-- Логирование -------------------------------------------
				declare
					@ErrorNumber int = ERROR_NUMBER()
					,@ErrorSeverity int = ERROR_SEVERITY()
					,@ErrorState int = ERROR_STATE()
					,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE()
					,@ErrorLine int = ERROR_LINE()
					,@ErrorMessage nvarchar(256) = ERROR_MESSAGE()
					,@Method nvarchar(128) = object_name(@@ProcId)
				
				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_ExceptionLog
							@ObjectId = NULL
							,@RowId = @RowId
							,@Operation = 'parseTicket'
							,@Method = @Method
							,@ErrorNumber = @ErrorNumber
							,@ErrorSeverity = @ErrorSeverity
							,@ErrorState = @ErrorState
							,@ErrorProcedure = @ErrorProcedure
							,@ErrorLine = @ErrorLine
							,@ErrorMessage = @ErrorMessage
				
			end catch

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ticket_ParseWayBillTicket]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ticket_ParseWayBillTicket]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare 
		@Descriptor int
		,@Content nvarchar(max)
		,@ExchangeTypeCode varchar(50)
		,@Namespace varchar(511)
		,@Path varchar(50)
		,@RAR_TicketId int
		,@UTM_Id int
	

	select 
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
		,@UTM_Id = ud.UTM_Id 
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
	where ud.RowId = @RowId
		and ud.Status = 'New'
		and ud.Direction = 1 

	if(isnull(@Content, '') = '')
		return 1;


	exec sp_xml_preparedocument @Descriptor out, @Content, '<root   
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
																xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" 
																xmlns:wt="http://fsrar.ru/WEGAIS/ConfirmTicket" />'


	begin try
		begin transaction

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket(
								OperationResult
								,[Identity]
								,TicketDate
								,RegId
								,OperationComment
								,DocType
								,UTM_Id)
				select
					IsConfirm
					,TicketNumber
					,TicketDate
					,WBRegId
					,Note
					,@ExchangeTypeCode
					,@UTM_Id
				from openxml(@Descriptor, N'ns:Documents/ns:Document/ns:ConfirmTicket/wt:Header', 1)
					with 
						(
							IsConfirm nvarchar(50) './wt:IsConfirm'
							,TicketNumber nvarchar(50) './wt:TicketNumber'
							,TicketDate datetime './wt:TicketDate'
							,WBRegId nvarchar(50) './wt:WBRegId'
							,Note nvarchar(255) './wt:Note'				
						);

				set @RAR_TicketId = @@Identity

				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 'Accepted' where RowId = @RowId

				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Ticket_UpdateStatus
							@RAR_TicketId = @RAR_TicketId

		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;

		rollback transaction
	end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ticket_UpdateCustNoteStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ticket_UpdateCustNoteStatus]( @RAR_TicketId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare
		@ClassId nvarchar(50)
		,@DocType nvarchar(50)
		,@OperationName nvarchar(50)
		,@OperationResult nvarchar(50)
		,@ReplyId nvarchar(50)
		,@RAR_CustNoteId int 
		,@RAR_WayBillActId int
		,@Status nvarchar(50)
		,@IsAccept nvarchar(50)

	/*select 
		@ClassId = et.UTM_ExchangeClass_ClassId
		,@DocType = t.DocType
		,@OperationName = t.OperationName
		,@OperationResult = t.OperationResult
		,@ReplyId = t.ReplyId
		,@RAR_CustNoteId = cn.RAR_CustNoteId
	from _EG.RAR_Ticket t
		join _EG.UTM_ExchangeType et
			on et.ExchangeTypeCode = t.DocType
		join _EG.RAR_CustNote cn
			on cn.ReplyId = t.ReplyId
	where t.RAR_TicketId = @RAR_TicketId*/

	select 
		@ClassId = et.UTM_ExchangeClass_ClassId
		,@DocType = t.DocType
		,@OperationName = t.OperationName
		,@OperationResult = t.OperationResult
		,@ReplyId = t.ReplyId
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.ExchangeTypeCode = t.DocType
				and et.Direction = 1
	where t.RAR_TicketId = @RAR_TicketId


	if @ClassId in ('RepProducedProduct', 'WayBill', 'ActWriteOff')
		begin
			
			select @RAR_CustNoteId = cn.RAR_CustNoteId	
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
			where cn.ReplyId = @ReplyId	

			if(@OperationName = 'Confirm' and @OperationResult = 'Accepted')
				set @Status = 'Recorded'

			if(@OperationName is null and @OperationResult = 'Rejected')
				set @Status = 'Error'

			if(@OperationName = 'UnConfirm' and @OperationResult = 'Accepted')
				set @Status = 'Rejected'

			
				if isnull(@Status, '') <> ''
					begin

						exec bpRAR_CustNote_SetStatus
								@RAR_CustNoteId
								,@Status = @Status

					end

		end

	if @ClassId in ('WayBillAct')
		begin
			
			select 
				@RAR_WayBillActId = wba.RAR_WayBillActId
				,@RAR_CustNoteId = wba.RAR_CustNoteId
				,@IsAccept = wba.IsAccept
			from RAR_WayBillAct wba
				where wba.ReplyId = @ReplyId

			if isnull(@OperationResult, '') <> ''
				begin
			
					exec bpRAR_WayBillAct_SetStatus
							@RAR_WayBillActId = @RAR_WayBillActId 
							,@Status = @OperationResult


					if(@IsAccept = 'Accepted' and @OperationResult = 'Accepted')
						begin

							exec bpRAR_CustNote_SetStatus
								@RAR_CustNoteId
								,@Status = @Status	

						end		
				end

		end

	if @ClassId in ('QueryRejectRepProduced')
		begin
			
			if(@OperationName = 'Confirm' and @OperationResult = 'Accepted')
				set @Status = 'Repealed'

		end



GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ticket_UpdateStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ticket_UpdateStatus]( @RAR_TicketId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare
		@ClassId nvarchar(50)
		,@DocType nvarchar(50)
		,@OperationName nvarchar(50)
		,@OperationResult nvarchar(50)
		,@OperationComment nvarchar(255)
		,@OperationDate datetime
		,@TicketDate datetime 
		,@ReplyId nvarchar(50)
		,@RegId nvarchar(50)
		,@RAR_CustNoteId int 
		,@RAR_WayBillActId int
		,@RAR_RepealWBActId int
		,@Status nvarchar(50)
		,@IsAccept nvarchar(50)
		,@UTM_Id int
		,@CreateTime datetime


	begin try
		begin transaction

			select top 1
				@DocType = t.DocType
				,@OperationName = t.OperationName
				,@OperationResult = t.OperationResult
				,@OperationComment = t.OperationComment
				,@OperationDate = t.OperationDate
				,@TicketDate = t.TicketDate
				,@ReplyId = t.ReplyId
				,@RegId = t.RegId
				,@UTM_Id = t.UTM_Id
				,@CreateTime = ud.CreateTime
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
				left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
					on ud.RowId = t.RowId
			where t.RAR_TicketId = @RAR_TicketId


			select @ClassId = et.UTM_ExchangeClass_ClassId
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
						on et.ExchangeTypeCode = ud.ExchangeTypeCode
							and et.Direction = -1
			where ud.ReplyId = @ReplyId
				and ud.Direction = -1
	
			if @ClassId in ('RepProducedProduct', 'WayBill', 'ActWriteOff')
				begin
					
					if(@DocType = 'WAYBILL')
						begin

							select @RAR_CustNoteId = cn.RAR_CustNoteId
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
									join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
										on cn.DocumentNumber = mi.DocumentNumber
											and cn.DocumentDate = mi.DocumentDate
									join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
										on ud.RowId = cn.RowId
											and ud.UTM_Id = mi.UTM_Id
							where mi.RegNumber = @RegId 
								and mi.UTM_Id = @UTM_Id

						end
					else
						begin

							select @RAR_CustNoteId = cn.RAR_CustNoteId
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
									join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
										on cn.RowId = ud.RowId
							where ud.ReplyId = @ReplyId
								and ud.UTM_Id = @UTM_Id 
								and ud.ExchangeTypeCode = @DocType

						end	
		

					if(@OperationName = 'Confirm' and @OperationResult = 'Accepted')
						set @Status = 'Recorded'
					else if(@OperationName = 'Confirm' and @OperationResult = 'Rejected')
						set @Status = 'Rejected'
					else if(@OperationName is null and @OperationResult = 'Accepted')
						set @Status = @OperationResult
					else if(@OperationName is null and @OperationResult = 'Rejected')
						set @Status = 'Error'
					else if(@OperationName = 'UnConfirm' and @OperationResult = 'Accepted')
						set @Status = 'Rejected'
				

							if(@OperationName is null and @OperationResult = 'Accepted' and exists(select top 1* 
																										from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
																									where t.ReplyId = @ReplyId
																										and t.RegId = @RegId
																										and t.UTM_Id = @UTM_Id))
								or(@OperationName = 'Confirm' and @OperationResult = 'Accepted' and exists(select top 1* 
																										from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
																									where t.ReplyId = @ReplyId
																										and t.RegId = @RegId
																										and t.UTM_Id = @UTM_Id
																										and t.OperationName = 'Confirm'
																										and t.OperationResult = 'Accepted'
																										and t.RAR_TicketId <> @RAR_TicketId))
								begin
									
									select @Status = NULL;

								end
							else
								begin

									if isnull(@Status, '') <> ''
										begin
						
											exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
														@RAR_CustNoteId
														,@Status = @Status
						
										end

								end
				end
		
			if @ClassId = 'WayBillAct' or @ClassId = 'ConfirmTicket'
				begin
					
					if(@OperationName is null and @OperationResult = 'Accepted')
						set @Status = @OperationResult
					if(@OperationName = 'Confirm' and @OperationResult = 'Accepted')
						set @Status = 'Confirmed'
					if(@OperationName = 'UnConfirm' and @OperationResult = 'Accepted')
						set @Status = 'Rejected'
					if(@OperationName = 'ConfirmImportTicket' and @OperationResult = 'Rejected')
						set @Status = 'Rejected'
		

					select 
						@RAR_WayBillActId = wba.RAR_WayBillActId
						,@RAR_CustNoteId = wba.RAR_CustNoteId
						,@IsAccept = wba.IsAccept
					from RAR_WayBillAct wba
						where wba.ReplyId = @ReplyId

				if(@OperationName is null and @OperationResult = 'Accepted' and exists(select top 1* 
																							from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
																						where t.ReplyId = @ReplyId
																							and t.RegId = @RegId
																							and t.UTM_Id = @UTM_Id))
						begin
							
							select @Status = NULL;
	
						end
					else
						begin
		
							if isnull(@OperationResult, '') <> ''
								begin
							
									exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WayBillAct_SetStatus
												@RAR_WayBillActId = @RAR_WayBillActId 
												,@Status = @OperationResult
				
				
									if(@IsAccept = 'Accepted' and @OperationResult = 'Accepted')
										or(@IsAccept = 'Differences' and @OperationResult = 'Accepted')
										begin

											if(@IsAccept = 'Differences')
												set @Status = @IsAccept
				
											exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
														@RAR_CustNoteId
														,@Status = @Status	
				
										end		
								end

						end
		
				end
		
			if @ClassId = 'QueryRejectRepProduced'
				begin
					
					if(@OperationName = 'Confirm' and @OperationResult = 'Accepted')
						begin
						
							set @Status = 'Repealed'
		
							select @RAR_CustNoteId = rpa.RAR_CustNoteId
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RejectRepProducedAct rpa
							where rpa.ReplyId = @ReplyId
		
							exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
										@RAR_CustNoteId
										,@Status = @Status
		
						end
					else if(@OperationName is null)
						set @Status = @OperationResult
					
		
					if(@Status is not null and @ReplyId is not null)
						begin
		
							exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_RejectRepProducedAct_SetStatus
										@Status = @Status
										,@ReplyId = @ReplyId
		
						end
		
					
				end

			if @ClassId = 'RequestRepealWB'
				begin
					
					select 
						@RAR_RepealWBActId = wa.RAR_RepealWBActId 
						,@RAR_CustNoteId = wa.RAR_CustNoteId
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct wa
						where wa.ReplyId = @ReplyId


					if(@OperationName is null and @OperationResult = 'Accepted')
						begin
						
							exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_RepealWBAct_SetStatus
										@RAR_RepealWBActId = @RAR_RepealWBActId
										,@Status = @OperationResult


							exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
										@RAR_CustNoteId = @RAR_CustNoteId
										,@Status = 'Repealed'
		
						end
					else if(@OperationName is null)
						set @Status = @OperationResult
					
				end

			if @ClassId = 'ConfirmRepealWB'
				begin

					select 
						@RAR_CustNoteId = cn.RAR_CustNoteId
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct wb
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBActStatus wbs
							on wbs.Status = wb.Status
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
							on mi.RegNumber = wb.RegId
								and mi.UTM_Id = wb.UTMId
						join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
							on cn.RAR_CustNoteId = mi.RAR_CustNoteId
					where wb.ReplyId = @ReplyId
			
					if(@OperationName = 'UnConfirm' and @OperationResult = 'Accepted')
						begin

							exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_RepealWBAct_SetStatus
										@RAR_RepealWBActId = @RAR_RepealWBActId
										,@Status = @OperationResult


							exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
										@RAR_CustNoteId = @RAR_CustNoteId
										,@Status = 'Repealed'
	
						end
					

				end

			if(@DocType = 'WayBillTicket')
				begin

					select
						@RAR_WayBillActId = wba.RAR_WayBillActId
						,@RAR_CustNoteId = wba.RAR_CustNoteId
						,@IsAccept = wba.IsAccept
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct wba
						where wba.RegId = @RegId
							and wba.UTMId = @UTM_Id

					
					if(isnull(@RAR_CustNoteId, 0) <> 0)
						begin

							if(@IsAccept = 'Differences' and @OperationResult = 'Accepted')
								set @Status = 'Differences'				
		
							if(isnull(@Status, '') <> '')
								begin

									exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_CustNote_SetStatus
												@RAR_CustNoteId = @RAR_CustNoteId
												,@Status = @Status

								end

							if(@OperationName is null and @OperationResult = 'Accepted')
								set @Status = @OperationResult

							if(isnull(@Status, '') <> '')
								begin
				
									exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WayBillAct_SetStatus
												@RAR_WayBillActId = @RAR_WayBillActId
												,@Status = @Status	
				
								end	

						end
					 
				end

			if(@ClassId in('ActChargeOn', 'ActFixBarCode', 'ActUnFixBarCode'))
				begin
					 
					declare @RAR_BalanceActId int

					if(@OperationName is null and @OperationResult = 'Accepted')
						set @Status = @OperationResult
					if(@OperationName is null and @OperationResult = 'Rejected')
						set @Status = @OperationResult
					if(@OperationName = 'Confirm' and @OperationResult = 'Accepted')
						set @Status = 'Recorded'
					if(@OperationName = 'UnConfirm' and @OperationResult = 'Accepted')
						set @Status = 'Rejected'
					if(@OperationName = 'PreparedToConfirm' and @OperationResult = 'Rejected')
						set @Status = 'Rejected'
					if(@OperationName = 'Confirm' and @OperationResult = 'Rejected')
						set @Status = @OperationResult
					if(@ClassId = 'ActUnFixBarCode' and @OperationName = 'Confirm' and @OperationResult = 'Accepted')
						set @Status = 'Canceled'
			

					select @RAR_BalanceActId = ba.RAR_BalanceActId
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_BalanceAct ba
					where ba.ReplyId = @ReplyId

					if(@RAR_BalanceActId is not null and @Status is not null)
						begin

							if not exists(select top 1* 
								from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t 
							where t.ReplyId = @ReplyId
								and t.RegId = @RegId
								and t.UTM_Id = @UTM_Id
								and (t.TicketDate > @TicketDate or t.OperationDate > @OperationDate))
								begin

									exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_BalanceAct_SetStatus
												@RAR_BalanceActId = @RAR_BalanceActId
												,@Status = @Status

								end
						
							if(@ClassId in('ActFixBarCode', 'ActUnFixBarCode'))
								begin
	
									declare @StampStatus smallint = 0
									
									if(@ClassId = 'ActFixBarCode')
										set @StampStatus = 1;

									if(@Status = 'Recorded' and @OperationName = 'Confirm' and @OperationResult = 'Accepted')
										begin
		
											exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_BalanceAct_UpdateStampStatus
														@RAR_BalanceActId = @RAR_BalanceActId
														,@StampStatus = @StampStatus
		
										end
	
								end

						end

				end
			if(@ClassId = 'RequestAddProducts')
				begin

					declare @RAR_WareAddRequestReestrId int

					select 
						@RAR_WareAddRequestReestrId = war.RAR_WareAddRequestReestrId
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WareAddRequestReestr war
						where war.ReplyId = @ReplyId

					if(@OperationName is null and @OperationResult = 'Accepted')
						set @Status = @OperationResult
					if((@OperationName is null or @OperationName = 'Confirm') and @OperationResult = 'Rejected')
						set @Status = @OperationResult
					if(@OperationName = 'Confirm' and @OperationResult = 'Accepted')
						set @Status = 'Recorded'


					if(isnull(@Status, '') <> '')
						begin

							declare @AlcCode varchar(50)

							if(@Status = 'Recorded')
								select @AlcCode = ltrim(rtrim(right(@OperationComment, len(@OperationComment) - charindex(':',@OperationComment))));

							if not exists(select r.RAR_WareAddRequestReestrId
											from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WareAddRequestReestr r
										where r.RAR_WareAddRequestReestrId = @RAR_WareAddRequestReestrId
											and r.Status = 'Recorded')
								begin

									exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WareAddRequestReestr_SetRequestResult
												@RAR_WareAddRequestReestrId = @RAR_WareAddRequestReestrId
												,@Status = @Status
												,@AlcCode = @AlcCode

								end
	
						end
					
				end

		commit transaction
	end try
	begin catch
		rollback transaction

			-- Логирование -------------------------------------------
				declare
					@ErrorNumber int = ERROR_NUMBER()
					,@ErrorSeverity int = ERROR_SEVERITY()
					,@ErrorState int = ERROR_STATE()
					,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE()
					,@ErrorLine int = ERROR_LINE()
					,@ErrorMessage nvarchar(256) = ERROR_MESSAGE()
					,@Method nvarchar(128) = object_name(@@ProcId)
				
				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_ExceptionLog
							@ObjectId = @RAR_TicketId
							,@RowId = NULL
							,@Operation = 'updateStatus'
							,@Method = @Method
							,@ErrorNumber = @ErrorNumber
							,@ErrorSeverity = @ErrorSeverity
							,@ErrorState = @ErrorState
							,@ErrorProcedure = @ErrorProcedure
							,@ErrorLine = @ErrorLine
							,@ErrorMessage = @ErrorMessage

	end catch
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_Edit]( @AlcCode varchar(100)=NULL, @Description varchar(500)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/        

select *
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware ew
where (@AlcCode is null or ew.AlcCode = @AlcCode)
	and (@Description is null or ew.Description like '%' + @Description + '%')
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_GetRAR_WareId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_Ware_GetRAR_WareId]( @AlcCode varchar(50), @RAR_WareId int=NULL OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	select @RAR_WareId = rw.RAR_WareId
		from RAR_Ware rw
	where rw.AlcCode = @AlcCode 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_Insert]( @AlcCode varchar(100)=NULL, @AlcTypeCode varchar(10)=NULL, @AlcVolume decimal(16,4)=NULL, @Capacity decimal(16,4)=NULL, @CreateTime datetime=NULL, @FSRAR_Id varchar(50)=NULL, @RAR_WareId int=NULL, @UnitType varchar(50)=NULL, @WareName varchar(1000)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware(	
						FSRAR_Id
						,AlcCode
						,WareName
						,UnitType
						,AlcVolume
						,Capacity
						,AlcTypeCode
						,CreateTime)
		values(
			@FSRAR_Id
			,@AlcCode
			,@WareName
			,@UnitType
			,@AlcVolume
			,@Capacity
			,@AlcTypeCode
			,@CreateTime)
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_IsExistsWare]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_IsExistsWare]( @AlcCode varchar(256), @IsExists bit=0 OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	if exists(select rw.AlcCode 
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw
				where rw.AlcCode = @AlcCode)
		set @IsExists = 1;


GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_ParseReply]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_ParseReply]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	declare 
		@Descriptor int
		,@Namespace varchar(max)
		,@XmlPath nvarchar(1000)
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@CreateTime datetime
		,@ClientRegId varchar(50)
		,@AlcCode varchar(100)
		,@FullName varchar(1000)
		,@UnitType varchar(50)
		,@AlcVolume decimal(16,4)
		,@Capacity decimal(16,4)
		,@ProductVCode varchar(10)
		 

	create table #Ware(
					ClientRegId varchar(50)
					,AlcCode varchar(100)
					,FullName varchar(1000)
					,UnitType varchar(50)
					,AlcVolume decimal(16,4)
					,Capacity decimal(16,4)
					,ProductVCode varchar(10))

 
	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ExchangeTypeCode
		,@CreateTime = ud.CreateTime  
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1  
 			

	select @Namespace =  '<root' +
						case @ExchangeTypeCode when 'ReplySpirit_v2' then 
						+ ' xmlns:rs="http://fsrar.ru/WEGAIS/ReplySpirit_v2"'
						+ ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
						when 'ReplyAP_v2' then 
						+ ' xmlns:rap="http://fsrar.ru/WEGAIS/ReplyAP_v2"'
						when 'ReplySSP_v2' then
						+ ' xmlns:rap="http://fsrar.ru/WEGAIS/ReplySSP_v2"'
						end
						+ ' xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2"'
						+ ' xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2"'									
						+ ' xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" />'
	
	exec sp_xml_preparedocument @Descriptor out, @Content, @Namespace

	begin try
		begin transaction
	
			select @XmlPath = N'/ns:Documents/ns:Document/ns:' + case @ExchangeTypeCode when 'ReplySpirit_v2' then 'ReplySpirit_v2/rs:Products/rs:Product'
																						when 'ReplyAP_v2' then 'ReplyAP_v2/rap:Products/rap:Product'
																						when 'ReplySSP_v2' then 'ReplySSP_v2/rap:Products/rap:Product' end
	
			insert into #Ware
				select 
					ClientRegId
					,AlcCode
					,FullName
					,UnitType
					,AlcVolume
					,Capacity
					,ProductVCode 
				from openxml(@Descriptor, @XmlPath, 1)
					with 
						(
							FullName varchar(1000) './pref:FullName'
							,AlcCode varchar(100) './pref:AlcCode'
							,Capacity decimal(16,4) './pref:Capacity'
							,UnitType varchar(50) './pref:UnitType'
							,AlcVolume decimal(16,4) './pref:AlcVolume'
							,ProductVCode varchar(10) './pref:ProductVCode'	
							,ClientRegId varchar(50) './pref:Producer/oref:UL/oref:ClientRegId'
						);
	
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'
			
			--update _EG.UTM_Data set Status = 'Accepted' where RowId = @RowId and Status = 'New'
				
		commit transaction
	end try			
	begin catch

		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;

		rollback transaction
	end catch			


	declare Ware_Cursor cursor for
		select * from #Ware
	
	open Ware_Cursor

	fetch next from Ware_Cursor
		into
			@ClientRegId
			,@AlcCode
			,@FullName
			,@UnitType
			,@AlcVolume
			,@Capacity
			,@ProductVCode
	
	while @@fetch_status = 0  
		begin
			if exists(select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw where rw.AlcCode = @AlcCode)
					begin
						update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware 
							set 
								FSRAR_Id = @ClientRegId
								,WareName = @FullName
								,UnitType = @UnitType
								,AlcVolume = @AlcVolume
								,Capacity = @Capacity
								,AlcTypeCode = @ProductVCode
								,CreateTime = @CreateTime
						where AlcCode = @AlcCode
					end
				else
					begin

						exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_Ware_Insert
									@FSRAR_Id = @ClientRegId
									,@AlcCode = @AlcCode
									,@WareName = @FullName
									,@UnitType = @UnitType
									,@AlcVolume = @AlcVolume
									,@Capacity = @Capacity
									,@AlcTypeCode = @ProductVCode
									,@CreateTime = @CreateTime

						/*insert into _EG.RAR_Ware(	
										FSRAR_Id
										,AlcCode
										,WareName
										,UnitType
										,AlcVolume
										,Capacity
										,AlcTypeCode
										,CreateTime)
							values(
								@ClientRegId
								,@AlcCode
								,@FullName
								,@UnitType
								,@AlcVolume
								,@Capacity
								,@ProductVCode
								,@CreateTime)*/
					end

				fetch next from Ware_Cursor
					into
						@ClientRegId
						,@AlcCode
						,@FullName
						,@UnitType
						,@AlcVolume
						,@Capacity
						,@ProductVCode
		end

	close Ware_Cursor
		deallocate Ware_Cursor














 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_ParseReplyAP]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_ParseReplyAP]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Descriptor int
		,@TypeCode varchar(50) = 'ReplyAP_v2'
		,@RowId uniqueidentifier
		,@Content nvarchar(max)
		,@CreateTime datetime
		,@ClientRegId varchar(50)
		,@AlcCode varchar(100)
		,@FullName varchar(1000)
		,@UnitType varchar(50)
		,@AlcVolume decimal(16,4)
		,@Capacity decimal(16,4)
		,@ProductVCode varchar(10)

	create table #Ware(
					ClientRegId varchar(50)
					,AlcCode varchar(100)
					,FullName varchar(1000)
					,UnitType varchar(50)
					,AlcVolume decimal(16,4)
					,Capacity decimal(16,4)
					,ProductVCode varchar(10))

	
	declare newWare_Cursor cursor for   
		select ud.RowId, replace(ud.Content, 'utf-8', 'utf-16')  
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.Status = 0 and ud.ExchangeTypeCode = @TypeCode and ud.Direction = 1 
	  
	open newWare_Cursor  
	 	
	fetch next from newWare_Cursor   
		into @RowId, @Content
  	
	while @@fetch_status = 0  
		begin 
			set @CreateTime = (select ud.CreateTime from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud where ud.RowId = @RowId)
			
			exec sp_xml_preparedocument @Descriptor out, @Content, '<root 
																		xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2" 
																		xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2" 
																		xmlns:rap="http://fsrar.ru/WEGAIS/ReplyAP_v2" 
																		xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" />' 
			begin transaction
				insert into #Ware
					select 
						ClientRegId
						,AlcCode
						,FullName
						,UnitType
						,AlcVolume
						,Capacity
						,ProductVCode 
					from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplyAP_v2/rap:Products/rap:Product', 1)
						with 
							(
								FullName varchar(1000) './pref:FullName'
								,AlcCode varchar(100) './pref:AlcCode'
								,Capacity decimal(16,4) './pref:Capacity'
								,UnitType varchar(50) './pref:UnitType'
								,AlcVolume decimal(16,4) './pref:AlcVolume'
								,ProductVCode varchar(10) './pref:ProductVCode'	
								,ClientRegId varchar(50) './pref:Producer/oref:UL/oref:ClientRegId'
							);

				if (@@error <> 0)
        			rollback

				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 1 where RowId = @RowId


				if (@@error <> 0)
        			rollback
			
			commit transaction
		
			fetch next from newWare_Cursor   
				into @RowId, @Content
		end	

	close newWare_Cursor
	deallocate newWare_Cursor


	declare Ware_Cursor cursor for
		select * from #Ware
	
	open Ware_Cursor

	fetch next from Ware_Cursor
		into
			@ClientRegId
			,@AlcCode
			,@FullName
			,@UnitType
			,@AlcVolume
			,@Capacity
			,@ProductVCode
	
	while @@fetch_status = 0  
		begin
			if exists(select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw where rw.AlcCode = @AlcCode)
					begin
						update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware 
							set 
								FSRAR_Id = @ClientRegId
								,AlcCode = @AlcCode
								,WareName = @FullName
								,UnitType = @UnitType
								,AlcVolume = @AlcVolume
								,Capacity = @Capacity
								,AlcTypeCode = @ProductVCode
								,CreateTime = @CreateTime
						where AlcCode = @AlcCode
					end
				else
					begin
						insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware(	
									FSRAR_Id
									,AlcCode
									,WareName
									,UnitType
									,AlcVolume
									,Capacity
									,AlcTypeCode
									,CreateTime)
							values(
								@ClientRegId
								,@AlcCode
								,@FullName
								,@UnitType
								,@AlcVolume
								,@Capacity
								,@ProductVCode
								,@CreateTime)
					end

				fetch next from Ware_Cursor
					into
						@ClientRegId
						,@AlcCode
						,@FullName
						,@UnitType
						,@AlcVolume
						,@Capacity
						,@ProductVCode
		end

		close Ware_Cursor
		deallocate Ware_Cursor















GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_ParseReplySpirit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_ParseReplySpirit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Descriptor int
		,@TypeCode varchar(50) = 'ReplySpirit_v2'
		,@RowId uniqueidentifier
		,@Content nvarchar(max)
		,@CreateTime datetime
		,@AlcCode varchar(100)
		,@FullName varchar(1000)
		,@UnitType varchar(50)
		,@AlcVolume decimal(16,4)
		,@ProductVCode varchar(10)

	create table #Ware(
					AlcCode varchar(100)
					,FullName varchar(1000)
					,UnitType varchar(50)
					,AlcVolume decimal(16,4)
					,ProductVCode varchar(10))

	
	declare newWare_Cursor cursor for   
		select ud.RowId, replace(ud.Content, 'utf-8', 'utf-16')  
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.Status = 0 and ud.ExchangeTypeCode = @TypeCode and ud.Direction = 1 
	  
	open newWare_Cursor  
	 	
	fetch next from newWare_Cursor   
		into @RowId, @Content
  	
	while @@fetch_status = 0  
		begin 
			set @CreateTime = (select ud.CreateTime from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud where ud.RowId = @RowId)
			
			exec sp_xml_preparedocument @Descriptor out, @Content, '<root 
																		xmlns:rs="http://fsrar.ru/WEGAIS/ReplySpirit_v2" 
																		xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef_v2" 
																		xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef_v2" 
																		xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
																		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" />' 
			begin transaction
				insert into #Ware
					select 
						AlcCode
						,FullName
						,UnitType
						,AlcVolume
						,ProductVCode 
					from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:ReplySpirit_v2/rs:Products/rs:Product', 1)
						with 
							(
								FullName varchar(1000) './pref:FullName'
								,AlcCode varchar(100) './pref:AlcCode'
								,UnitType varchar(50) './pref:UnitType'
								,AlcVolume decimal(16,4) './pref:AlcVolume'
								,ProductVCode varchar(10) './pref:ProductVCode'	
							);

				if (@@error <> 0)
        			rollback

				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data set Status = 1 where RowId = @RowId


				if (@@error <> 0)
        			rollback
			
			commit transaction
		
			fetch next from newWare_Cursor   
				into @RowId, @Content
		end	

	close newWare_Cursor
	deallocate newWare_Cursor


	declare Ware_Cursor cursor for
		select * from #Ware
	
	open Ware_Cursor

	fetch next from Ware_Cursor
		into
			@AlcCode
			,@FullName
			,@UnitType
			,@AlcVolume
			,@ProductVCode
	
	while @@fetch_status = 0  
		begin
			if exists(select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware rw where rw.AlcCode = @AlcCode)
					begin
						update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware 
							set 
								AlcCode = @AlcCode
								,WareName = @FullName
								,UnitType = @UnitType
								,AlcVolume = @AlcVolume
								,AlcTypeCode = @ProductVCode
								,CreateTime = @CreateTime
						where AlcCode = @AlcCode
					end
				else
					begin
						insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ware(	
									AlcCode
									,WareName
									,UnitType
									,AlcVolume
									,AlcTypeCode
									,CreateTime)
							values(
								@AlcCode
								,@FullName
								,@UnitType
								,@AlcVolume
								,@ProductVCode
								,@CreateTime)
					end

				fetch next from Ware_Cursor
					into
						@AlcCode
						,@FullName
						,@UnitType
						,@AlcVolume
						,@ProductVCode
		end

		close Ware_Cursor
		deallocate Ware_Cursor














 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_SendQuery]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_SendQuery]( @AlcCode varchar(100), @FSRAR_Id varchar(50), @CodeType int, @RowId uniqueidentifier OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


	declare 
		@Content nvarchar(max)
		,@ClassId varchar(50)
		,@ExchangeTypeCode varchar(50)		
		,@UTM_Path varchar(255)
		,@Direction smallint = -1
		,@Status smallint = 0

	declare 
		@QueryAP varchar(50) = 'QueryAP'
		,@QuerySSP varchar(50) = 'QuerySSP'
		,@QuerySP varchar(50) = 'QuerySP'

	declare @TableRowId table(RowId uniqueidentifier)

	if isnull(@FSRAR_Id,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQuery'                and Item=0), 'Не указан ФСРАР ИД инициатора запроса!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@AlcCode,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQuery'                and Item=1), 'Не указан алкокод продукции!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@CodeType, 0) = 0
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQuery'                and Item=2), 'Не указан код типа обмена в ЕГАИС!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end


	select @ClassId = case @CodeType when 1 then @QueryAP when 2 then @QuerySP else @QuerySSP end


	exec bpUTM_ExchangeClass_GetDefaultType
			@ClassId
			,@ExchangeTypeCode out


	select @Content = '<?xml version="1.0" encoding="UTF-8"?>' + char(13) +
							'<ns:Documents Version="1.0"' + char(13)+
								'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + char(13)+
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13)+
								case @ExchangeTypeCode when 'QuerySSP_v2' then +
								'xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef"' + char(13)
								 when 'QuerySP_v2' then +
								'xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef"' + char(13)
								end
								+ 'xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters">' + char(13)+
									'<ns:Owner>' + char(13)+
										'<ns:FSRAR_ID>' + @FSRAR_Id + '</ns:FSRAR_ID>' + char(13)+
									'</ns:Owner>' + char(13)+
										'<ns:Document>' + char(13)+
											'<ns:' + @ExchangeTypeCode + '>' + char(13)+
											'<qp:Parameters>' + char(13)+
												'<qp:Parameter>' + char(13)+
													'<qp:Name>КОД</qp:Name>' + char(13)+
													'<qp:Value>' + @AlcCode + '</qp:Value>' + char(13)+
												'</qp:Parameter>' + char(13)+
											'</qp:Parameters>' + char(13)+
											'</ns:' + @ExchangeTypeCode + '>' + char(13)+
										'</ns:Document>' + char(13)+
							'</ns:Documents>'

	if isnull(@Content,'') = ''
		begin
			return 1
		end
	else
		begin
			select @UTM_Path = udt.UTM_Path 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType udt 
			where udt.ExchangeTypeCode = @ExchangeTypeCode
				and udt.Direction = @Direction
			
			if isnull(@UTM_Path, '') = ''
				begin
					return 1
				end
			else
				begin
					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					output inserted.RowId into @TableRowId 
					select
						@Content
						,u.URL + @UTM_Path
						,getdate()
						,@Direction
						,u.Id
						,@Status
						,@ExchangeTypeCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						where u.FSRAR_Id = @FSRAR_Id
							and u.IsActive = 1	
				end					
		end

	select @RowId = RowId from @TableRowId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_SendQueryAP]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_SendQueryAP]( @AlcCode varchar(100), @FSRAR_Id varchar(50), @RowId uniqueidentifier OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Content nvarchar(max)		
		,@ExchangeTypeCode varchar(50) = 'QueryAP_v2'
		,@UTM_Path varchar(255)
		,@Direction smallint = -1
		,@Status smallint = 0 

	declare @TableRowId table(RowId uniqueidentifier)

	if isnull(@FSRAR_Id,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQueryAP'                and Item=0), 'Не указан ФСРАР ИД инициатора запроса!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@AlcCode,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQueryAP'                and Item=1), 'Не указан алкокод продукции!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	select @Content = '<?xml version="1.0" encoding="UTF-8"?>' + char(13)+
							'<ns:Documents Version="1.0"' + char(13)+
								'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + char(13)+
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13)+
								'xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters">' + char(13)+
									'<ns:Owner>' + char(13)+
										'<ns:FSRAR_ID>' + @FSRAR_Id + '</ns:FSRAR_ID>' + char(13)+
									'</ns:Owner>' + char(13)+
										'<ns:Document>' + char(13)+
											'<ns:QueryAP_v2>' + char(13)+
											'<qp:Parameters>' + char(13)+
												'<qp:Parameter>' + char(13)+
													'<qp:Name>КОД</qp:Name>' + char(13)+
													'<qp:Value>' + @AlcCode + '</qp:Value>' + char(13)+
												'</qp:Parameter>' + char(13)+
											'</qp:Parameters>' + char(13)+
											'</ns:QueryAP_v2>' + char(13)+
										'</ns:Document>' + char(13)+
							'</ns:Documents>'

	if isnull(@Content,'') = ''
		begin
			return 1
		end
	else
		begin
			select @UTM_Path = udt.UTM_Path 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType udt 
			where udt.ExchangeTypeCode = @ExchangeTypeCode
				and udt.Direction = @Direction
			
			if isnull(@UTM_Path, '') = ''
				begin
					return 1
				end
			else
				begin
					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					output inserted.RowId into @TableRowId 
					select
						@Content
						,u.URL + @UTM_Path
						,getdate()
						,@Direction
						,u.Id
						,@Status
						,@ExchangeTypeCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						where u.FSRAR_Id = @FSRAR_Id	
				end					
		end

	select @RowId = RowId from @TableRowId

	

GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_SendQuerySP]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_SendQuerySP]( @AlcCode varchar(100), @FSRAR_Id varchar(50), @RowId uniqueidentifier OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Content nvarchar(max)		
		,@ExchangeTypeCode varchar(50) = 'QuerySP_v2'
		,@UTM_Path varchar(255)
		,@Direction smallint = -1
		,@Status smallint = 0

	declare @TableRowId table(RowId uniqueidentifier)

	if isnull(@FSRAR_Id,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQuerySP'                and Item=0), 'Не указан ФСРАР ИД инициатора запроса!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@AlcCode,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQuerySP'                and Item=1), 'Не указан алкокод продукции!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	select @Content = '<?xml version="1.0" ?>' + char(13)+
							'<ns:Documents Version="1.0"' + char(13)+
								'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + char(13)+
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13)+
								'xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef"' + char(13)+
								'xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters">' + char(13)+
									'<ns:Owner>' + char(13)+
										'<ns:FSRAR_ID>' + @FSRAR_Id + '</ns:FSRAR_ID>' + char(13)+
									'</ns:Owner>' + char(13)+
									'<ns:Document>' + char(13)+
										'<ns:QuerySP_v2>' + char(13)+
											'<qp:Parameters>' + char(13)+
												'<qp:Parameter>' + char(13)+
													'<qp:Name>КОД</qp:Name>' + char(13)+
													'<qp:Value>' + @AlcCode + '</qp:Value>' + char(13)+
												'</qp:Parameter>' + char(13)+
											'</qp:Parameters>' + char(13)+
										'</ns:QuerySP_v2>' + char(13)+
									'</ns:Document>' + char(13)+
							'</ns:Documents>'

	if isnull(@Content,'') = ''
		begin
			return 1
		end
	else
		begin
			select @UTM_Path = udt.UTM_Path 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType udt 
			where udt.ExchangeTypeCode = @ExchangeTypeCode
				and udt.Direction = @Direction
			
			if isnull(@UTM_Path, '') = ''
				begin
					return 1
				end
			else
				begin
					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					output inserted.RowId into @TableRowId 
					select
						@Content
						,u.URL + @UTM_Path
						,getdate()
						,@Direction
						,u.Id
						,@Status
						,@ExchangeTypeCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						where u.FSRAR_Id = @FSRAR_Id	
				end					
		end

	select @RowId = RowId from @TableRowId 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_Ware_SendQuerySSP]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_Ware_SendQuerySSP]( @AlcCode varchar(100), @FSRAR_Id varchar(50), @RowId uniqueidentifier OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare 
		@Content nvarchar(max)		
		,@ExchangeTypeCode varchar(50) = 'QuerySSP_v2'
		,@UTM_Path varchar(255)
		,@Direction smallint = -1
		,@Status smallint = 0

	declare @TableRowId table(RowId uniqueidentifier)

	if isnull(@FSRAR_Id,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQuerySSP'                and Item=0), 'Не указан ФСРАР ИД инициатора запроса!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	if isnull(@AlcCode,'') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_Ware.SendQuerySSP'                and Item=1), 'Не указан алкокод продукции!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end 

	select @Content = '<?xml version="1.0" ?>' + char(13)+
							'<ns:Documents Version="1.0"' + char(13)+
								'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + char(13)+
								'xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"' + char(13)+
								'xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef"' + char(13)+
								'xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters">' + char(13)+
									'<ns:Owner>' + char(13)+
										'<ns:FSRAR_ID>' + @FSRAR_Id + '</ns:FSRAR_ID>' + char(13)+
									'</ns:Owner>' + char(13)+
									'<ns:Document>' + char(13)+
										'<ns:QuerySSP_v2>' + char(13)+
											'<qp:Parameters>' + char(13)+
												'<qp:Parameter>' + char(13)+
													'<qp:Name>КОД</qp:Name>' + char(13)+
													'<qp:Value>' + @AlcCode + '</qp:Value>' + char(13)+
												'</qp:Parameter>' + char(13)+
											'</qp:Parameters>' + char(13)+
										'</ns:QuerySSP_v2>' + char(13)+
									'</ns:Document>' + char(13)+
							'</ns:Documents>'

	if isnull(@Content,'') = ''
		begin
			return 1
		end
	else
		begin
			select @UTM_Path = udt.UTM_Path 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType udt 
			where udt.ExchangeTypeCode = @ExchangeTypeCode
				and udt.Direction = @Direction
			
			if isnull(@UTM_Path, '') = ''
				begin
					return 1
				end
			else
				begin
					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					output inserted.RowId into @TableRowId 
					select
						@Content
						,u.URL + @UTM_Path
						,getdate()
						,@Direction
						,u.Id
						,@Status
						,@ExchangeTypeCode
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						where u.FSRAR_Id = @FSRAR_Id	
				end					
		end

	select @RowId = RowId from @TableRowId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WareAddRequestReestr_SetRequestResult]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_WareAddRequestReestr_SetRequestResult]( @RAR_WareAddRequestReestrId int=NULL, @Status varchar(50), @AlcCode varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WareAddRequestReestr
		set 
			Status = @Status
			,AlcCode = @AlcCode
	where RAR_WareAddRequestReestrId = @RAR_WareAddRequestReestrId 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WareAddRequestReestr_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WareAddRequestReestr_SetStatus]( @RAR_WareAddRequestReestrId int=NULL, @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WareAddRequestReestr
		set Status = @Status
	where RAR_WareAddRequestReestrId = @RAR_WareAddRequestReestrId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WareAddRequestReestr_UpdateReplyId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WareAddRequestReestr_UpdateReplyId]( @ReplyId varchar(50), @RowId uniqueidentifier=NULL, @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          


	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WareAddRequestReestr
		set 
			ReplyId = @ReplyId
			,Status = @Status
	where RowId = @RowId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillAct_Insert]( @ActDate datetime=NULL, @ActNumber varchar(50)=NULL, @CreateTime datetime=NULL, @Direction smallint=NULL, @FSRAR_Id varchar(50)=NULL, @IsAccept varchar(50)=NULL, @Note varchar(1000)=NULL, @RAR_CustNoteId int=NULL, @RAR_WayBillActId int=NULL OUTPUT, @RegId varchar(50)=NULL, @ReplyId nvarchar(50)=NULL, @RowId uniqueidentifier=NULL, @Status varchar(255)=NULL, @UTMId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	if not exists(select top 1 a.RegId 
					from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct a
				where a.RAR_CustNoteId = @RAR_CustNoteId
					and a.RegId = @RegId
					and a.ActNumber = @ActNumber
					and a.ActDate = @ActDate
					and a.IsAccept = @IsAccept)	
		begin

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct(
							ActDate
							,ActNumber
							,CreateTime
							,Direction
							,FSRAR_Id
							,IsAccept
							,Note
							,RegId
							,Status
							,RAR_CustNoteId
							,RowId
							,UTMId)
				values(
					@ActDate
					,@ActNumber
					,getdate()
					,@Direction
					,@FSRAR_Id
					,@IsAccept
					,@Note
					,@RegId
					,@Status
					,@RAR_CustNoteId
					,@RowId
					,@UTMId)
		
			set @RAR_WayBillActId = @@Identity;
		end		
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_ParseWayBillAct]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillAct_ParseWayBillAct]( @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


set CONCAT_NULL_YIELDS_NULL on
set ANSI_WARNINGS on
set ANSI_PADDING on

	
	declare 
		@RAR_CustNoteId int
		,@Descriptor int
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@XmlContent xml
		,@IsAccept varchar(50)
		,@WBRegId varchar(50)
		,@ActDate datetime	
		,@Note varchar(50)
		,@ActNumber varchar(50)
		,@FSRAR_Id varchar(50)
		,@Direction smallint = 1
		,@Status nvarchar(255)
		,@RAR_WayBillActId int
		,@UTMId int


	create table #WayBillActLine(
					Position_Identity int,
					InformMotion nvarchar(50),
					RealQuantity int)


	create table #WayBillActExciseStamp(
					Position_Identity int, 
					StampBarCode nvarchar(500))

	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
		,@UTMId = ud.UTM_Id
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1
	

	if(isnull(@Content, '') = '')
		return 1;

	if(charindex('CP866', @Content) <> 0)
		select @Content = replace(@Content, 'CP866', 'utf-16')

	
	exec sp_xml_preparedocument @Descriptor out, @Content, '<root
																xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
																xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
																xmlns:wa= "http://fsrar.ru/WEGAIS/ActTTNSingle_v3" 
																xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" />'


	begin try
		begin transaction

			select 
				@FSRAR_Id = FSRAR_Id
				,@IsAccept = IsAccept
				,@WBRegId = WBRegId
				,@Note = Note
				,@ActDate = ActDate
				,@ActNumber = ActNumber
			from openxml(@Descriptor, N'/ns:Documents', 1)
				with(
						FSRAR_Id varchar(50) './ns:Owner/ns:FSRAR_ID'
						,IsAccept varchar(50) './ns:Document/ns:WayBillAct_v3/wa:Header/wa:IsAccept'
						,WBRegId varchar(50) './ns:Document/ns:WayBillAct_v3/wa:Header/wa:WBRegId'
						,Note varchar(50) './ns:Document/ns:WayBillAct_v3/wa:Header/wa:Note'	
						,ActDate datetime './ns:Document/ns:WayBillAct_v3/wa:Header/wa:ActDate'
						,ActNumber varchar(50) './ns:Document/ns:WayBillAct_v3/wa:Header/wa:ACTNUMBER'						
					)

			
			/*select @RAR_CustNoteId = cn.RAR_CustNoteId
							from _EG.RAR_Ticket t
								join _EG.RAR_CustNote cn
									on cn.ReplyId = t.ReplyId
							where t.DocType = 'WayBill_v3'
								and t.OperationResult = 'Accepted'
								and t.OperationName = 'Confirm'
								and t.RegId = @WBRegId
								and t.TicketDate = (select max(t2.TicketDate) 
														from _EG.RAR_Ticket t2 
													where t2.DocType = 'WayBill_v3' 
														and t2.OperationResult = 'Accepted' 
														and t.OperationName = 'Confirm' 
														and t.RegId = @WBRegId)*/

			select @RAR_CustNoteId = cn.RAR_CustNoteId
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
						on cn.RAR_CustNoteId = mi.RAR_CustNoteId
			where mi.RegNumber = @WBRegId

			
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WayBillAct_Insert
					@ActDate = @ActDate
					,@ActNumber = @ActNumber
					,@Direction = @Direction
					,@FSRAR_Id = @FSRAR_Id
					,@IsAccept = @IsAccept
					,@RegId = @WBRegId
					,@Note = @Note
					,@Status = 'New'
					,@RAR_CustNoteId = @RAR_CustNoteId
					,@RowId = @RowId
					,@UTMId = @UTMId
					,@RAR_WayBillActId = @RAR_WayBillActId out


			if(@IsAccept = 'Differences')
				begin
					
					insert into #WayBillActLine(
									Position_Identity
									,InformMotion
									,RealQuantity)
						select 
							[Identity]
							,InformF2RegId
							,RealQuantity
						from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:WayBillAct_v3/wa:Content/wa:Position', 1)
							with(
									[Identity] int './wa:Identity'
									,InformF2RegId varchar(50) './wa:InformF2RegId'
									,RealQuantity decimal(16,4) './wa:RealQuantity'			
								)

			
					select @XmlContent = @Content

					;with xmlnamespaces('http://fsrar.ru/WEGAIS/ActTTNSingle_v3' as wa, 'http://fsrar.ru/WEGAIS/CommonV3' as ce) 
						   insert into #WayBillActExciseStamp(Position_Identity, StampBarCode)
							   select 
									el.value('.','varchar(500)') as el
   									,e1.value('.','varchar(500)') as e1
							   from @XmlContent.nodes('//wa:Identity') r(el)
								   outer apply @XmlContent.nodes('//wa:MarkInfo') as t(e)
								   outer apply @XmlContent.nodes('//wa:MarkInfo/ce:amc') as t1(e1)
							   where e.value('..','varchar(500)') = el.value('..','varchar(500)')
									and e1.value('..','varchar(500)') = e.value('.','varchar(500)')

					insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillActLine(
									RAR_WayBillActId
									,Position_Identity
									,RealQuantity
									,InformMotion)
						select
							@RAR_WayBillActId
							,Position_Identity
							,RealQuantity
							,InformMotion		
						from #WayBillActLine
					

					if exists(select top 1 * from #WayBillActExciseStamp)
						begin
			
							insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillActExciseStamp(
											RAR_WayBillActId
											,Position_Identity
											,StampBarCode)
								select 
									@RAR_WayBillActId
									,Position_Identity
									,StampBarCode
								from #WayBillActExciseStamp
	
						end

				end

		
			if(@WBRegId is not null)
				begin	
					select @Status = @IsAccept 
				end
	
		
			if(@IsAccept = 'Accepted')
				set @Status = 'Confirmed'


			exec bpRAR_CustNote_SetStatus
					@RAR_CustNoteId = @RAR_CustNoteId
					,@Status = @Status


			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'


		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch  

if @IsAccept in ('Differences', 'Rejected')
begin
	exec mch.dbo.bpRAR_WayBillAct_CreateCustReturn @RegId = @WBRegId
end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_ParseWayBillAct_v1]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillAct_ParseWayBillAct_v1]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


set CONCAT_NULL_YIELDS_NULL on
set ANSI_WARNINGS on
set ANSI_PADDING on

	
	declare 
		@RAR_CustNoteId int
		,@Descriptor int
		,@ExchangeTypeCode varchar(50)
		,@Content nvarchar(max)
		,@XmlContent xml
		,@IsAccept varchar(50)
		,@WBRegId varchar(50)
		,@ActDate datetime	
		,@Note varchar(50)
		,@ActNumber varchar(50)
		,@FSRAR_Id varchar(50)
		,@Direction smallint = 1
		,@Status nvarchar(255)
		,@RAR_WayBillActId int
		,@UTMId int


	create table #WayBillActLine(
					Position_Identity int,
					InformMotion nvarchar(50),
					RealQuantity int)


	create table #WayBillActExciseStamp(
					Position_Identity int, 
					StampBarCode nvarchar(500))

	select  
		@Content = replace(ud.Content, 'utf-8', 'utf-16')
		,@ExchangeTypeCode = ud.ExchangeTypeCode
		,@UTMId = ud.UTM_Id
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud  
		where ud.RowId = @RowId 
			and ud.Status = 'New'
			and ud.Direction = 1
	

	if(isnull(@Content, '') = '')
		return 1;

	if(charindex('CP866', @Content) <> 0)
		select @Content = replace(@Content, 'CP866', 'utf-16')


	begin try
		begin transaction

			exec sp_xml_preparedocument @Descriptor out, @Content, '<root  xmlns:pref2="http://fsrar.ru/WEGAIS/ProductRef_v2" xmlns:asiut="http://fsrar.ru/WEGAIS/AsiiuTime" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:rraco="http://fsrar.ru/WEGAIS/RequestRepealACO" xmlns:qf2="http://fsrar.ru/WEGAIS/QueryFormF1F2" xmlns:wa2="http://fsrar.ru/WEGAIS/ActTTNSingle_v2" xmlns:wa3="http://fsrar.ru/WEGAIS/ActTTNSingle_v3" xmlns:wbr2="http://fsrar.ru/WEGAIS/TTNInformF2Reg" xmlns:rap2="http://fsrar.ru/WEGAIS/ReplyAP_v2" xmlns:rssp="http://fsrar.ru/WEGAIS/ReplySSP" xmlns:rrawo="http://fsrar.ru/WEGAIS/RequestRepealAWO" xmlns:tc="http://fsrar.ru/WEGAIS/Ticket" xmlns:rst="http://fsrar.ru/WEGAIS/ReplyRests" xmlns:aint2="http://fsrar.ru/WEGAIS/ActInventoryInformF2Reg" xmlns:iab="http://fsrar.ru/WEGAIS/ActInventoryABInfo" xmlns:afbc="http://fsrar.ru/WEGAIS/ActFixBarCode" xmlns:rsts2="http://fsrar.ru/WEGAIS/ReplyRestsShop_v2" xmlns:rfa2="http://fsrar.ru/WEGAIS/ReplyForm1" xmlns:rrwb="http://fsrar.ru/WEGAIS/RequestRepealWB" xmlns:aufbc="http://fsrar.ru/WEGAIS/ActUnFixBarCode" xmlns:ainp2="http://fsrar.ru/WEGAIS/ActChargeOn_v2" xmlns:nattn="http://fsrar.ru/WEGAIS/ReplyNoAnswerTTN" xmlns:ctc="http://fsrar.ru/WEGAIS/ConfirmTicket" xmlns:oref="http://fsrar.ru/WEGAIS/ClientRef" xmlns:awr="http://fsrar.ru/WEGAIS/ActWriteOff_v3" xmlns:ripf1="http://fsrar.ru/WEGAIS/RepInformF1Reg" xmlns:rhrs="http://fsrar.ru/WEGAIS/ReplyHistoryShop" xmlns:rstm="http://fsrar.ru/WEGAIS/ReplyRests_Mini" xmlns:oref2="http://fsrar.ru/WEGAIS/ClientRef_v2" xmlns:ain="http://fsrar.ru/WEGAIS/ActInventorySingle" xmlns:rs="http://fsrar.ru/WEGAIS/ReplySpirit" xmlns:wb="http://fsrar.ru/WEGAIS/TTNSingle" xmlns:wa="http://fsrar.ru/WEGAIS/ActTTNSingle" xmlns:ainp="http://fsrar.ru/WEGAIS/ActChargeOn" xmlns:wbr="http://fsrar.ru/WEGAIS/TTNInformBReg" xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" xmlns:pref="http://fsrar.ru/WEGAIS/ProductRef" xmlns:aint="http://fsrar.ru/WEGAIS/ActInventoryInformBReg" xmlns:awr2="http://fsrar.ru/WEGAIS/ActWriteOff_v2" xmlns:ains2="http://fsrar.ru/WEGAIS/ActChargeOnShop_v2" xmlns:awr3="http://fsrar.ru/WEGAIS/ActWriteOff_v3" xmlns:awrs2="http://fsrar.ru/WEGAIS/ActWriteOffShop_v2" xmlns:qbc="http://fsrar.ru/WEGAIS/QueryBarcode" xmlns:rfhb2="http://fsrar.ru/WEGAIS/ReplyHistForm2" xmlns:rsp2="http://fsrar.ru/WEGAIS/ReplySpirit_v2" xmlns:qrri="http://fsrar.ru/WEGAIS/QueryRejectRepImported" xmlns:rc2="http://fsrar.ru/WEGAIS/ReplyClient_v2" xmlns:rap="http://fsrar.ru/WEGAIS/ReplyAP" xmlns:rf="http://fsrar.ru/WEGAIS/ReplyFilter" xmlns:wbhr2="http://fsrar.ru/WEGAIS/TTNHistoryF2Reg" xmlns:rfa="http://fsrar.ru/WEGAIS/ReplyFormA" xmlns:asiu="http://fsrar.ru/WEGAIS/Asiiu" xmlns:rc="http://fsrar.ru/WEGAIS/ReplyClient" xmlns:rfb="http://fsrar.ru/WEGAIS/ReplyFormB" xmlns:qrrp="http://fsrar.ru/WEGAIS/QueryRejectRepProduced" xmlns:rssp2="http://fsrar.ru/WEGAIS/ReplySSP_v2" xmlns:rfb2="http://fsrar.ru/WEGAIS/ReplyForm2" xmlns:rsbc="http://fsrar.ru/WEGAIS/ReplyRestBCode" xmlns:tfs="http://fsrar.ru/WEGAIS/TransferFromShop" xmlns:rbc="http://fsrar.ru/WEGAIS/ReplyBarcode" xmlns:iab2="http://fsrar.ru/WEGAIS/ActInventoryF1F2Info" xmlns:cee="http://fsrar.ru/WEGAIS/CommonV3" xmlns:rs2="http://fsrar.ru/WEGAIS/ReplySpirit_v2" xmlns:rwoc="http://fsrar.ru/WEGAIS/ReplyWriteOffCheque" xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters" xmlns:wb2="http://fsrar.ru/WEGAIS/TTNSingle_v2" xmlns:qf="http://fsrar.ru/WEGAIS/QueryFilter" xmlns:wb3="http://fsrar.ru/WEGAIS/TTNSingle_v3" xmlns:tts="http://fsrar.ru/WEGAIS/TransferToShop" xmlns:wbfu="http://fsrar.ru/WEGAIS/InfoVersionTTN" xmlns:rst2="http://fsrar.ru/WEGAIS/ReplyRests_v2" xmlns:ns0="http://fsrar.ru/WEGAIS/ActWriteOff" xmlns:crwb="http://fsrar.ru/WEGAIS/ConfirmRepealWB" xmlns:rstsm="http://fsrar.ru/WEGAIS/ReplyRestsShop_Mini" xmlns:rpi3="http://fsrar.ru/WEGAIS/RepImportedProduct_v3" />'

			select 
				@FSRAR_Id = FSRAR_Id
				,@IsAccept = IsAccept
				,@WBRegId = WBRegId
				,@Note = Note
				,@ActDate = ActDate
				,@ActNumber = ActNumber
			from openxml(@Descriptor, N'/ns:Documents', 1)
				with(
						FSRAR_Id varchar(50) './ns:Owner/ns:FSRAR_ID'
						,IsAccept varchar(50) './ns:Document/ns:WayBillAct/wa:Header/wa:IsAccept'
						,WBRegId varchar(50) './ns:Document/ns:WayBillAct/wa:Header/wa:WBRegId'
						,Note varchar(50) './ns:Document/ns:WayBillAct/wa:Header/wa:Note'	
						,ActDate datetime './ns:Document/ns:WayBillAct/wa:Header/wa:ActDate'
						,ActNumber varchar(50) './ns:Document/ns:WayBillAct/wa:Header/wa:ACTNUMBER'						
					)
			

			select @RAR_CustNoteId = cn.RAR_CustNoteId
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
						on cn.RAR_CustNoteId = mi.RAR_CustNoteId
			where mi.RegNumber = @WBRegId

			
			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WayBillAct_Insert
					@ActDate = @ActDate
					,@ActNumber = @ActNumber
					,@Direction = @Direction
					,@FSRAR_Id = @FSRAR_Id
					,@IsAccept = @IsAccept
					,@RegId = @WBRegId
					,@Note = @Note
					,@Status = 'New'
					,@RAR_CustNoteId = @RAR_CustNoteId
					,@RowId = @RowId
					,@UTMId = @UTMId
					,@RAR_WayBillActId = @RAR_WayBillActId out


			-- Эта часть кода не оптимизирована по v1
			/*if(@IsAccept = 'Differences')
				begin
					
					insert into #WayBillActLine(
									Position_Identity
									,InformMotion
									,RealQuantity)
						select 
							[Identity]
							,InformF2RegId
							,RealQuantity
						from openxml(@Descriptor, N'/ns:Documents/ns:Document/ns:WayBillAct_v3/wa:Content/wa:Position', 1)
							with(
									[Identity] int './wa:Identity'
									,InformF2RegId varchar(50) './wa:InformF2RegId'
									,RealQuantity decimal(16,4) './wa:RealQuantity'			
								)

			
					select @XmlContent = @Content

					;with xmlnamespaces('http://fsrar.ru/WEGAIS/ActTTNSingle_v3' as wa, 'http://fsrar.ru/WEGAIS/CommonV3' as ce) 
						   insert into #WayBillActExciseStamp(Position_Identity, StampBarCode)
							   select 
									el.value('.','varchar(500)') as el
   									,e1.value('.','varchar(500)') as e1
							   from @XmlContent.nodes('//wa:Identity') r(el)
								   outer apply @XmlContent.nodes('//wa:MarkInfo') as t(e)
								   outer apply @XmlContent.nodes('//wa:MarkInfo/ce:amc') as t1(e1)
							   where e.value('..','varchar(500)') = el.value('..','varchar(500)')
									and e1.value('..','varchar(500)') = e.value('.','varchar(500)')

					insert into _EG.RAR_WayBillActLine(
									RAR_WayBillActId
									,Position_Identity
									,RealQuantity
									,InformMotion)
						select
							@RAR_WayBillActId
							,Position_Identity
							,RealQuantity
							,InformMotion		
						from #WayBillActLine
					

					if exists(select top 1 * from #WayBillActExciseStamp)
						begin
			
							insert into _EG.RAR_WayBillActExciseStamp(
											RAR_WayBillActId
											,Position_Identity
											,StampBarCode)
								select 
									@RAR_WayBillActId
									,Position_Identity
									,StampBarCode
								from #WayBillActExciseStamp
	
						end

				end*/

		
			if(@WBRegId is not null)
				begin	
					select @Status = @IsAccept 
				end
	
		
			if(@IsAccept = 'Accepted')
				set @Status = 'Confirmed'


			exec bpRAR_CustNote_SetStatus
					@RAR_CustNoteId = @RAR_CustNoteId
					,@Status = @Status


			exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_Data_SetStatus
						@RowId = @RowId
						,@Status = 'Accepted'


		commit transaction
	end try
	begin catch
	
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;
	
		rollback transaction
	end catch  

if @IsAccept in ('Differences', 'Rejected')
begin
	exec mch.dbo.bpRAR_WayBillAct_CreateCustReturn @RegId = @WBRegId
end
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_SendConfirmTicket]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillAct_SendConfirmTicket]( @CustNoteId int, @IsConfirm smallint=1 )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@Content nvarchar(max)
		,@ActDate datetime
		,@RegNumber varchar(50)
		,@FSRAR_Id varchar(50)
		,@ExchangeTypeCode varchar(50)
		,@ClassId varchar(50) =	'ConfirmTicket'
		,@URL varchar(255)
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@Direction smallint = -1
		,@Status smallint = 0
		,@Accept varchar(50) 


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@RegNumber = t.RegId
		,@ExchangeTypeCode = et.ExchangeTypeCode
		,@UTM_Path = et.UTM_Path
		,@URL = u.URL
		,@UTM_Id = u.Id
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteLink cnl
			on cnl.CustNoteId = cn.CustNoteId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
			on ud.RowId = cnl.RowId
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.Id = ud.UTM_Id
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_Ticket t
			on t.ReplyId = cnl.ReplyId
				and OperationName = 'Confirm'
				and OperationResult = 'Accepted'
		left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
			on ec.ClassId = @ClassId
		left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.Id = ec.DefaultTypeId
	where cn.CustNoteId = @CustNoteId


	set @ActDate = getdate()

	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
							<ns:Documents Version="1.0"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
								xmlns:wt= "http://fsrar.ru/WEGAIS/ConfirmTicket" >
								<ns:Owner>
									<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
								</ns:Owner>
								<ns:Document>
									<ns:ConfirmTicket>
										<wt:Header>
											<wt:IsConfirm>' + case @IsConfirm when 0 then 'Accepted' when 1 then 'Rejected' end + '</wt:IsConfirm>
											<wt:TicketNumber>' + convert(varchar(50), @CustNoteId) + '</wt:TicketNumber>
											<wt:TicketDate>' + convert(varchar(50), @ActDate, 23) + '</wt:TicketDate>
											<wt:WBRegId>' + coalesce(@RegNumber, '') + '</wt:WBRegId>
											<wt:Note>OK!</wt:Note>
										</wt:Header>
									</ns:ConfirmTicket>
								</ns:Document>
							</ns:Documents>'


	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendConfirmTicket'                and Item=0), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@URL, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendConfirmTicket'                and Item=1), 'Ошибка отправки запроса! Отсутствует URL для отправки')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendConfirmTicket'                and Item=2), 'Ошибка отправки запроса! Отсутствует путь для типа обмена в УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@RegNumber, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendConfirmTicket'                and Item=3), 'Ошибка отправки запроса! Отсутствует регистрационный номер ТТН')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			begin try
				begin transaction

					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,@URL + @UTM_Path
						,getdate()
						,@Direction
						,@UTM_Id
						,@Status
						,@ExchangeTypeCode

				commit transaction

			end try
			begin catch
				
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;

				rollback transaction

			end catch
		end 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_SendWayBillAct]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillAct_SendWayBillAct]( @CustNoteId int, @IsAccept smallint=1 )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	declare 
		@Content nvarchar(max)
		,@ActDate datetime
		,@RegNumber varchar(50)
		,@FSRAR_Id varchar(50)
		,@ExchangeTypeCode varchar(50)
		,@ClassId varchar(50) =	'WayBillAct'
		,@URL varchar(255)
		,@UTM_Path varchar(255)
		,@UTM_Id int 
		,@Direction smallint = -1
		,@Status smallint = 0
		,@Accept varchar(50)
			

	select 
		@ExchangeTypeCode = et.ExchangeTypeCode
		,@UTM_Path = et.UTM_Path
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.Id = ec.DefaultTypeId
	where ec.ClassId = @ClassId


	select 
		@FSRAR_Id = u.FSRAR_Id
		,@UTM_Id = u.Id
		,@URL = u.URL 
	from RAR_CustNote cn
		join RAR_CustNoteLink cnl
			on cnl.CustNoteId = cn.CustNoteId
		join UTM_Data ud
			on ud.RowId = cnl.RowId
		join UTM u 
			on u.Id = ud.UTM_Id
	where cn.CustNoteId = @CustNoteId


	/*if exists(select * from _EG.UTM u where u.FSRAR_Id = @ConsigneeFSRAR_Id)
		begin
			select @RegNumber = (select top 1 mi.RegNumber from _EG.RAR_MotionInfo mi where mi.CustNoteId = @CustNoteId)	
		end
	else
		begin
			select @RegNumber = (select top 1 mi.RegNumber 
									from _EG.RAR_CustNote cn
										join _EG.RAR_MotionInfo mi
											on mi.DocumentNumber = cn.DocumentNumber
												and mi.DocumentDate = cn.DocumentDate
												and mi.ReplyId is null
								where cn.CustNoteId = @CustNoteId)
		end*/

	
	select @RegNumber = (select top 1 mi.RegNumber 
									from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
										join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_MotionInfo mi
											on mi.DocumentNumber = cn.DocumentNumber
												and mi.DocumentDate = cn.DocumentDate
												and mi.ReplyId is null
								where cn.CustNoteId = @CustNoteId)


	if(@IsAccept <> 2)	
		begin

			set @ActDate = getdate();
		
		 	select @Content = '<?xml version="1.0" encoding="UTF-8"?>
									<ns:Documents Version="1.0"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
										xmlns:ns= "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"
										xmlns:wa= "http://fsrar.ru/WEGAIS/ActTTNSingle_v3"
										xmlns:ce="http://fsrar.ru/WEGAIS/CommonV3" >
										<ns:Owner>
											<ns:FSRAR_ID>' + coalesce(@FSRAR_Id, '') + '</ns:FSRAR_ID>
										</ns:Owner>
										<ns:Document>
											<ns:WayBillAct_v3>
												<wa:Header>
													<wa:IsAccept>' + case @IsAccept when 1 then 'Accepted' when 0 then 'Rejected' end + '</wa:IsAccept>
													<wa:ACTNUMBER>' + convert(varchar(50), @CustNoteId) + '</wa:ACTNUMBER>
													<wa:ActDate>' + convert(varchar(50), @ActDate, 23) + '</wa:ActDate>
													<wa:WBRegId>' + coalesce(@RegNumber, '') +'</wa:WBRegId>
													<wa:Note>' + case @IsAccept when 1 then 'Ok!' when 0 then 'No!' end + '</wa:Note>
												</wa:Header>
												<wa:Content>
												</wa:Content>
											</ns:WayBillAct_v3>
										</ns:Document>
									</ns:Documents>'

		end


	if isnull(@ExchangeTypeCode, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendWayBillAct'                and Item=0), 'Ошибка отправки запроса! Отсутствует код типа обмена с УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@URL, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendWayBillAct'                and Item=1), 'Ошибка отправки запроса! Отсутствует URL для отправки')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@UTM_Path, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendWayBillAct'                and Item=2), 'Ошибка отправки запроса! Отсутствует путь для типа обмена в УТМ')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@RegNumber, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='RAR_WayBillAct.SendWayBillAct'                and Item=3), 'Ошибка отправки запроса! Отсутствует регистрационный номер ТТН')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if isnull(@Content, '') = ''
		begin
			return 1
		end
	else
		begin
			begin try
				begin transaction

					insert into UTM_Data(
						Content
						,URL
						,CreateTime
						,Direction
						,UTM_ID
						,Status
						,ExchangeTypeCode)
					select 
						@Content
						,@URL + @UTM_Path
						,getdate()
						,@Direction
						,@UTM_Id
						,@Status
						,@ExchangeTypeCode


					select @Accept = case @IsAccept when 0 then 'Rejected' when 1 then 'Accepted' when 2 then 'Differences' end

										
					/*exec _EG.bpRAR_CustNote_SetStatus
								@CustNoteId = @CustNoteId
								,@Status = 2*/
				
		
					exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WayBillAct_Insert
								@ActDate = @ActDate
								,@ActNumber = @CustNoteId
								,@Direction = @Direction
								,@FSRAR_Id = @FSRAR_Id
								,@IsAccept = @Accept
								,@RegId = @RegNumber
								,@Status = @Status
								,@CustNoteId = @CustNoteId
		
				commit transaction

			end try
			begin catch
				
				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage;

				rollback transaction

			end catch
		end  
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_SetRowId]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_WayBillAct_SetRowId]( @RAR_WayBillActId int=NULL, @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct
		set RowId = @RowId
	where RAR_WayBillActId = @RAR_WayBillActId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_WayBillAct_SetStatus]( @RAR_WayBillActId int=NULL, @Status varchar(255) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct
		set Status = @Status
	where RAR_WayBillActId = @RAR_WayBillActId 
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_ViewBarCode]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillAct_ViewBarCode]( @RAR_WayBillActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select ws.RAR_WayBillActId
      ,ws.StampBarCode
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct w
join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillActExciseStamp ws on ws.RAR_WayBillActId = w.RAR_WayBillActId
where w.RAR_WayBillActId = @RAR_WayBillActId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_ViewHistory]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpRAR_WayBillAct_ViewHistory]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/     
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillAct_ViewMembers]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillAct_ViewMembers]( @RAR_WayBillActId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select MemberType = 'Грузополучатель'
	 ,c.FSRAR_Id
	 ,ShortName = isnull(c.SubstitutionName, c.ShortName)
	 ,c.TaxCode
	 ,c.TaxReason
	 ,c.Location
from RAR_WayBillAct w
join RAR_Company c on c.FSRAR_Id = w.FSRAR_Id
where w.RAR_WayBillActId = @RAR_WayBillActId
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillActStatus_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillActStatus_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

select * from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillActStatus
GO
/****** Object:  StoredProcedure [dbo].[bpRAR_WayBillActStatus_SelectOne]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpRAR_WayBillActStatus_SelectOne]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

select s.RAR_WayBillActId
		,s.Status
		,s.Description
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillActStatus s
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_Delete]( @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	
	 delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data where RowId = @RowId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
	
	select * 
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud

GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_Insert]( @RAR_CustNoteId int, @Content nvarchar(max)=NULL, @ExchangeTypeCode varchar(55), @RowId uniqueidentifier OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	 declare
		@URL varchar(255)
		,@UTM_Id int
		,@Status varchar(50) = 'New'
		,@UserId varchar(128)


	select @UserId = ( select coalesce(    case when __xc.bo_UserName is null then __xc.bo_UserName else SUBSTRING(__xc.bo_UserName,CHARINDEX('\',__xc.bo_UserName)+1,LEN(__xc.bo_UserName)) end,    SUBSTRING(__s.login_name,CHARINDEX('\',__s.login_name)+1,LEN(__s.login_name)) )  from sys.dm_exec_sessions __s left join xBOConnection __xc on __s.session_id=__xc.spid and __s.login_time=__xc.login_time where __s.session_id=@@spid )

	declare @TableRowId table(RowId uniqueidentifier)


	select 
		@UTM_Id = u.UTMId
		,@URL = u.URL + et.UTM_Path 
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote rcn
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
			on u.FSRAR_Id = rcn.ShipperFSRAR_Id 
				and u.IsActive = 1
				and u.IsTest = 0
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.ExchangeTypeCode = @ExchangeTypeCode
				and et.Direction = -1
	where rcn.RAR_CustNoteId = @RAR_CustNoteId


	if(isnull(@ExchangeTypeCode, '') <> '') and (isnull(@URL, '') <> '' and (isnull(@UTM_Id, 0) <> 0))
		begin

			if (@ExchangeTypeCode in('RepProducedProduct_v3'))
				set @Status = 'NotReady'
			--if (@ExchangeTypeCode = 'ActWriteOff_v3')
				--set @Status = 'NotReady'

			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data(
						CreateTime
						,Direction
						,ExchangeTypeCode
						,UTM_Id
						,URL
						,Content
						,Status
						,UserId)
				output inserted.RowId into @TableRowId 
				select
					getdate()
					,-1
					,@ExchangeTypeCode
					,@UTM_Id
					,@URL
					,@Content
					,@Status
					,@UserId

			select @RowId = RowId from @TableRowId
		end
	
	

	/*select	@ExchangeTypeCode as code
	select	@URL as url
	select	@UTM_Id as id*/
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_InsertRequest]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_InsertRequest]( @Content nvarchar(max)=NULL, @ExchangeTypeCode varchar(55), @RowId uniqueidentifier OUTPUT, @UTMId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	 declare
		@URL varchar(255)
		,@Status varchar(50) = 'New'
		,@UserId varchar(128)


	select @UserId = ( select coalesce(    case when __xc.bo_UserName is null then __xc.bo_UserName else SUBSTRING(__xc.bo_UserName,CHARINDEX('\',__xc.bo_UserName)+1,LEN(__xc.bo_UserName)) end,    SUBSTRING(__s.login_name,CHARINDEX('\',__s.login_name)+1,LEN(__s.login_name)) )  from sys.dm_exec_sessions __s left join xBOConnection __xc on __s.session_id=__xc.spid and __s.login_time=__xc.login_time where __s.session_id=@@spid )

	declare @TableRowId table(RowId uniqueidentifier)


	select 
		@URL = u.URL + et.UTM_Path 
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u			
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.ExchangeTypeCode = @ExchangeTypeCode
				and et.Direction = -1
	where u.UTMId = @UTMId
		and u.IsActive = 1


	if(isnull(@ExchangeTypeCode, '') <> '') and (isnull(@URL, '') <> '' and (isnull(@UTMId, 0) <> 0))
		begin

			if (@ExchangeTypeCode = 'RepProducedProduct_v3')
				set @Status = 'NotReady'


			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data(
						CreateTime
						,Direction
						,ExchangeTypeCode
						,UTM_Id
						,URL
						,Content
						,Status
						,UserId)
				output inserted.RowId into @TableRowId 
				select
					getdate()
					,-1
					,@ExchangeTypeCode
					,@UTMId
					,@URL
					,@Content
					,@Status
					,@UserId

			select @RowId = RowId from @TableRowId
		end
	
	
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_J_Add]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_J_Add]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      
	
	
	declare 
		@RAR_CustNoteId int
		,@DocumentIntId int
		,@VersionWB varchar(64)
		,@ExchangeTypeCode varchar(50)
		,@Method nvarchar(255)
		,@Expression nvarchar(max)


	if object_id(N'tempdb..#rar_CustNote', N'U') is not null
		drop table #rar_CustNote

	create table #rar_CustNote(
				RAR_CustNoteId int
				,DocumentIntId int
				,VersionWB varchar(64))

	declare @CurrentDate smalldatetime	
	select @CurrentDate = convert(smalldatetime, convert(varchar(50), current_timestamp, 112))

	insert into #rar_CustNote(
					RAR_CustNoteId  
	                ,DocumentIntId 
                    ,VersionWB)  
		select distinct 
			cn.RAR_CustNoteId
			,cn.DocumentIntId
			,cna.Value
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
			left join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNoteAttribute cna
				on cna.RAR_CustNoteId = cn.RAR_CustNoteId
					and cna.AttributeId = 'VersionWB'
			where cn.Direction = -1
				and cn.Status = 'New'
				and ((cn.ClassId in('WayBill', 'WBReturnFromMe', 'ActWriteOff') and cn.ActionDate = @CurrentDate)
					or(cn.ClassId in('OperProduction', 'RepProducedProduct') and cn.ActionDate between dateadd(day, -3, @CurrentDate) and @CurrentDate))


	begin try
 
		update cn
			set cn.Status = 'Awaiting'
		from #rar_CustNote cnn
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
				on cn.RAR_CustNoteId = cnn.RAR_CustNoteId

		declare CustNote_Cursor cursor for
			select distinct cn.RAR_CustNoteId, cn.DocumentIntId, cn.VersionWB
				from #rar_CustNote cn

		open CustNote_Cursor
	
		fetch next from CustNote_Cursor
			into @RAR_CustNoteId, @DocumentIntId, @VersionWB
	
		while @@fetch_status = 0
			begin
				
				if(isnull(@VersionWB, '') = '' and @DocumentIntId is not null)
					begin
						select
							@ExchangeTypeCode = et.ExchangeTypeCode 
							,@Method = et.Method
						from mch.dbo.Document d
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl
								on etl.Document_Object = d.Document_Object
									and etl.DocumentTypeId = d.DocumentTypeId
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
								on ec.ClassId = etl.UTM_ExchangeClass_ClassId
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
								on et.UTM_ExchangeTypeId = ec.DefaultTypeId
						where d.DocumentIntId = @DocumentIntId
					end
				else if(isnull(@VersionWB, '') <> '' and @DocumentIntId is not null)
					begin

						select
							 @ExchangeTypeCode = et.ExchangeTypeCode 
							,@Method = et.Method
						from mch.dbo.Document d
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink etl
								on etl.Document_Object = d.Document_Object
									and etl.DocumentTypeId = d.DocumentTypeId
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
								on et.ExchangeTypeCode = @VersionWB	
									and et.UTM_ExchangeClass_ClassId = etl.UTM_ExchangeClass_ClassId	
									and et.Direction = -1
						where d.DocumentIntId = @DocumentIntId 

					end
				else if(@DocumentIntId is null)
					begin

						select 
							@ExchangeTypeCode = uet.ExchangeTypeCode 
							,@Method = uet.Method
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass uec
								on uec.ClassId = cn.ClassId
							join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType uet
								on uet.UTM_ExchangeTypeId = uec.DefaultTypeId
						where cn.RAR_CustNoteId = @RAR_CustNoteId

					end
								

				if not exists(
					select 1 
						from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote cn
							where cn.ActionDate > @CurrentDate
							  and cn.RAR_CustNoteId = @RAR_CustNoteId
							  and cn.ClassId in ('WayBill', 'WBReturnFromMe'))
			    begin

					if isnull(@Method, '') <> ''
						begin
							set @Expression = N'exec ' + @Method + ' @RAR_CustNoteId, @ExchangeTypeCode';
				
							exec sp_executesql @Expression, N'@RAR_CustNoteId int, @ExchangeTypeCode varchar(50)'
									,@RAR_CustNoteId = @RAR_CustNoteId
									,@ExchangeTypeCode = @ExchangeTypeCode;
						end
			    end
	
				fetch next from CustNote_Cursor
					into @RAR_CustNoteId, @DocumentIntId, @VersionWB
	
			end
	
		close CustNote_Cursor
			deallocate CustNote_Cursor

	end try
	begin catch
	
		close CustNote_Cursor
		deallocate CustNote_Cursor

	end catch
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_J_Parse]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_J_Parse]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    
	
	declare
		@Method nvarchar(255)
		,@Expression nvarchar(max) 
		,@RowId uniqueidentifier
		,@ExchangeTypeCode varchar(50)

	--set ansi_warnings off;

	declare UTMData_Cursor	cursor for
		select 
			RowId	
			,ExchangeTypeCode
		from UTM_Data WITH(NOLOCK)
			where Direction = 1
				and Status = 'New'
		order by CreateTime 
	
	open UTMData_Cursor
	
	fetch next from UTMData_Cursor
			into
				@RowId
				,@ExchangeTypeCode
	
	while @@fetch_status = 0  
		begin
		
			begin try

				set @Method = NULL;

				select @Method = et.Method 
					from UTM_ExchangeType et 
				where et.ExchangeTypeCode = @ExchangeTypeCode
					and et.Direction = 1
					and et.Method is not null
		
				if(coalesce(@Method, '') <> '')
					begin
															
						set @Expression = N'exec ' + @Method + ' @RowId';	
	
						exec sp_executesql @Expression, N'@RowId uniqueidentifier'
								,@RowId = @RowId;
			
					end

			end try
			begin catch

				select 
			        ERROR_NUMBER() AS ErrorNumber
			        ,ERROR_SEVERITY() AS ErrorSeverity
			        ,ERROR_STATE() AS ErrorState
			        ,ERROR_PROCEDURE() AS ErrorProcedure
			        ,ERROR_LINE() AS ErrorLine
			        ,ERROR_MESSAGE() AS ErrorMessage

			end catch
	
			fetch next from UTMData_Cursor
				into
					@RowId
					,@ExchangeTypeCode
	
		end
	
	close UTMData_Cursor
			deallocate UTMData_Cursor 

	set ansi_warnings on;
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_S_Add]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_S_Add]( @UTM_Id int=NULL, @Content nvarchar(max), @ReplyId varchar(50)=NULL, @URL varchar(255), @ExchangeTypeCode varchar(55) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    
/*insert UTM_Data(UTM_Id,
	Direction,
	Content,
	CreateTime,
	Status)
select UTM_Id = @UTM_Id,
	Direction = 1,
	Content = @Content,
	CreateTime = getdate(),
	Status = 1*/


/*if isnull(@UTM_Id, '') = ''
	begin
		set @UTM_Id = (select ud.UTM_Id from UTM_Data ud where ud.ReplyId = @ReplyId and ud.Direction = -1)	
	end

if isnull(@UTM_Id, '') = '' return 1*/


if not exists(select * from UTM_Data ud WITH(NOLOCK) where ud.ReplyId = @ReplyId and ud.URL = @URL and ud.ExchangeTypeCode = @ExchangeTypeCode)
	begin
		insert UTM_Data(
				Content
				,ReplyId
				,URL
				,CreateTime
				,Direction
				,UTM_ID
				,Status
				,ExchangeTypeCode)
		values(
			@Content
			,@ReplyId
			,@URL
			,getdate()
			,1
			,@UTM_Id
			,'New'
			,@ExchangeTypeCode)
	end


	
	 
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_S_Get]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_S_Get]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	
	if object_id(N'tempdb..#utm_data', N'U') is not null
		drop table #utm_data

	create table #utm_data(
				RowId uniqueidentifier
				,Content nvarchar(max)
				,[URL] nvarchar(255))


	begin try
		begin transaction

			insert into #utm_data
				select top 100
					ud.RowId 
					,ud.Content
					,ud.URL	
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud WITH(NOLOCK)
					join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
						on u.UTMId = ud.UTM_Id 
				where ud.Status = 'New'
					and ud.Direction = -1
					and ud.Content is not null
					and u.IsActive = 1
				order by ud.CreateTime
			
			update ud	
				set Status = 'Awaiting'
			from #utm_data udn
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
					on ud.RowId = udn.RowId
			
		
			select 
				udn.RowId 
				,udn.Content
				,udn.URL
			from #utm_data udn

		commit transaction	
		
	end try
	begin catch
		
		select 
	        ERROR_NUMBER() AS ErrorNumber
	        ,ERROR_SEVERITY() AS ErrorSeverity
	        ,ERROR_STATE() AS ErrorState
	        ,ERROR_PROCEDURE() AS ErrorProcedure
	        ,ERROR_LINE() AS ErrorLine
	        ,ERROR_MESSAGE() AS ErrorMessage;

		rollback transaction
	end catch
	
	/*select top 100 ud.*, UrlUtm = u.URL 	
		from UTM_Data ud
			join UTM u
				on u.UTMId = ud.UTM_Id 
	where ud.Status = 'New'
		and ud.Direction = -1
		and ud.Content is not null
		and u.IsActive = 1
	order by ud.CreateTime*/
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_S_GetNew]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_S_GetNew]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    select * from UTM_Data ud where ud.Status = 0 
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_S_GetNewData]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_S_GetNewData]( @UTMId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	
	if object_id(N'tempdb..#utm_data', N'U') is not null
		drop table #utm_data

	create table #utm_data(
				RowId uniqueidentifier
				,Content nvarchar(max)
				,[URL] nvarchar(255))


	begin transaction

		insert into #utm_data
			select top 25
				ud.RowId 
				,ud.Content
				,ud.URL	
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud WITH(NOLOCK)
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
					on u.UTMId = ud.UTM_Id 
			where ud.UTM_Id = @UTMId
				and ud.Status = 'New'
				and ud.Direction = -1
				and ud.Content is not null
				and u.IsActive = 1
			order by ud.CreateTime
		
		update ud	
			set Status = 'Awaiting'
		from #utm_data udn
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud
				on ud.RowId = udn.RowId
		
		
		select 
			udn.RowId 
			,udn.Content
			,udn.URL
		from #utm_data udn

	commit transaction	
		
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_S_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_S_SetStatus]( @RowId uniqueidentifier=NULL, @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

 
	declare 
		@ClassId nvarchar(50)
		,@ReplyId nvarchar(50) = NULL


	begin transaction
			
		select @ClassId = ec.ClassId
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud WITH(NOLOCK)
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
					on et.ExchangeTypeCode = ud.ExchangeTypeCode
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
					on ec.ClassId = et.UTM_ExchangeClass_ClassId
		where ud.RowId = @RowId
		
		
		update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data 
			set 
				ReplyId = @ReplyId
				,Status = @Status 
		where RowId = @RowId 
	
					
		if(@ClassId in ('RepProducedProduct', 'WayBill', 'ActWriteOff'))
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
					set 
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId					
		
			end			
		else if(@ClassId = 'RequestRepealWB')
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct
					set 
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId
		
			end
		else if(@ClassId = 'ConfirmRepealWB')
			begin
	
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct
					set ReplyId = @ReplyId
				where RowId = @RowId
	
			end
		else if(@ClassId = 'WayBillAct')
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct
					set 
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId
		
			end
		else if(@ClassId = 'QueryRejectRepProduced')
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RejectRepProducedAct
					set		
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId
		
			end
		else if(@ClassId in ('ActChargeOn', 'ActFixBarCode', 'ActUnFixBarCode'))
			begin
	
				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_BalanceAct_UpdateReplyId
							@RowId = @RowId
							,@ReplyId = @ReplyId
							,@Status = @Status
	
			end
		else if(@ClassId = 'RequestAddProducts')
			begin
	
				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WareAddRequestReestr_UpdateReplyId
							@RowId = @RowId
							,@ReplyId = @ReplyId
							,@Status = @Status
		
			end
	
	
		-- Логирование -------------------------------------------
		create table #OperationLog(
						Param varchar(50)
						,Value varchar(255))
		
		insert into #OperationLog(
						Param
						,Value)
			values
				('Method', object_name(@@ProcId))
				,('Status', isnull(@Status, ''))
				,('ReplyId', isnull(@ReplyId, ''))
				,('ClassId', isnull(@ClassId, ''))
								
		declare 
			@ObjectId varchar(50) = NULL
			,@Operation varchar(50) = 'update'
			,@MonUserId varchar(50)
		
		select @MonUserId = ( select coalesce(    case when __xc.bo_UserName is null then __xc.bo_UserName else SUBSTRING(__xc.bo_UserName,CHARINDEX('\',__xc.bo_UserName)+1,LEN(__xc.bo_UserName)) end,    SUBSTRING(__s.login_name,CHARINDEX('\',__s.login_name)+1,LEN(__s.login_name)) )  from sys.dm_exec_sessions __s left join xBOConnection __xc on __s.session_id=__xc.spid and __s.login_time=__xc.login_time where __s.session_id=@@spid );
		
		exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_Insert
					@ObjectId = @ObjectId
					,@RowId = @RowId
					,@Operation = @Operation
					,@MonUserId = @MonUserId
		
		if object_id(N'tempdb..#OperationLog', N'U') is not null
			drop table #OperationLog
		----------------------------------------------------------

	commit transaction

GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_S_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_S_Update]( @RowId uniqueidentifier, @ReplyId varchar(3000)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      


	declare 
		@ClassId nvarchar(50)
		,@Status nvarchar(50) = 'Sent'


	begin transaction
			
		select @ClassId = ec.ClassId
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data ud WITH(NOLOCK)
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
					on et.ExchangeTypeCode = ud.ExchangeTypeCode
				join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
					on ec.ClassId = et.UTM_ExchangeClass_ClassId
		where ud.RowId = @RowId
		
		
		update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data 
			set 
				ReplyId = @ReplyId
				,Status = 'Accepted' 
		where RowId = @RowId 			
		
		
		if(@ClassId in ('RepProducedProduct', 'WayBill', 'ActWriteOff'))
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_CustNote
					set 
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId
		
			end			
		else if(@ClassId = 'RequestRepealWB')
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct
					set 
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId
		
			end
		else if(@ClassId = 'ConfirmRepealWB')
			begin

				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RepealWBAct
					set ReplyId = @ReplyId
				where RowId = @RowId

			end
		else if(@ClassId in('WayBillAct', 'ConfirmTicket'))
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_WayBillAct
					set 
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId
		
			end
		else if(@ClassId = 'QueryRejectRepProduced')
			begin
				
				update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.RAR_RejectRepProducedAct
					set		
						ReplyId = @ReplyId
						,Status = @Status
				where RowId = @RowId
		
			end
		else if(@ClassId in ('ActChargeOn', 'ActFixBarCode', 'ActUnFixBarCode'))
			begin

				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_BalanceAct_UpdateReplyId
							@RowId = @RowId
							,@ReplyId = @ReplyId
							,@Status = @Status

			end
		else if(@ClassId = 'RequestAddProducts')
			begin

				exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpRAR_WareAddRequestReestr_UpdateReplyId
							@RowId = @RowId
							,@ReplyId = @ReplyId
							,@Status = @Status
		
			end

		
		-- Логирование -------------------------------------------
		create table #OperationLog(
						Param varchar(50)
						,Value varchar(255))
		
		insert into #OperationLog(
						Param
						,Value)
			values
				('Method', object_name(@@ProcId))
				,('Status', isnull(@Status, ''))
				,('ReplyId', isnull(@ReplyId, ''))
				,('ClassId', isnull(@ClassId, ''))
								
		declare 
			@ObjectId varchar(50) = NULL
			,@Operation varchar(50) = 'update'
			,@MonUserId varchar(50)
		
		select @MonUserId = ( select coalesce(    case when __xc.bo_UserName is null then __xc.bo_UserName else SUBSTRING(__xc.bo_UserName,CHARINDEX('\',__xc.bo_UserName)+1,LEN(__xc.bo_UserName)) end,    SUBSTRING(__s.login_name,CHARINDEX('\',__s.login_name)+1,LEN(__s.login_name)) )  from sys.dm_exec_sessions __s left join xBOConnection __xc on __s.session_id=__xc.spid and __s.login_time=__xc.login_time where __s.session_id=@@spid );
		
		exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_Insert
					@ObjectId = @ObjectId
					,@RowId = @RowId
					,@Operation = @Operation
					,@MonUserId = @MonUserId
		
		if object_id(N'tempdb..#OperationLog', N'U') is not null
			drop table #OperationLog
		----------------------------------------------------------

	commit transaction
	
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Data_SetStatus]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Data_SetStatus]( @RowId uniqueidentifier=NULL, @Status varchar(50) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      

	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Data
		set Status = @Status
	where RowId = @RowId  

GO
/****** Object:  StoredProcedure [dbo].[bpUTM_DataContent_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpUTM_DataContent_Insert]( @UniqueId int, @Content nvarchar(max) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


	 insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_DataContent(UniqueId, Content)
		values(@UniqueId, @Content)
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Edit]( @InterCompanyId varchar(15)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    
      

select 
	u.UTMId
	,u.FSRAR_Id
	,u.TaxCode
	,u.TaxReason
	,u.Description
	,u.URL
	,case u.IsActive when 1 then 'Active' else 'No active' end as IsActive 
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_ExchangeClass_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_ExchangeClass_Delete]( @ClassId varchar(50)=NULL, @ClassName varchar(50)=NULL, @DefaultTypeId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	declare @ExchangeTypeCode varchar(50)
	 
	select top 1 @ExchangeTypeCode = et.ExchangeTypeCode 
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
				on et.UTM_ExchangeClass_ClassId = ec.ClassId
		where ec.ClassId = @ClassId
	
	
	if isnull(@ExchangeTypeCode, '') <> ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_ExchangeClass.Delete'                and Item=0), 'Удаление запрещено! Класс обмена используется с типом обмена УТМ: ' + @ExchangeTypeCode)  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	
	delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass where ClassId = @ClassId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_ExchangeClass_GetDefaultType]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_ExchangeClass_GetDefaultType]( @ClassId varchar(255), @ExchangeTypeCode varchar(50) OUTPUT )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	
	select 
		@ExchangeTypeCode = et.ExchangeTypeCode 
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.UTM_ExchangeTypeId = ec.DefaultTypeId 
	where ec.ClassId = @ClassId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_ExchangeClass_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_ExchangeClass_Insert]( @ClassId varchar(50)=NULL, @ClassName varchar(50)=NULL, @DefaultTypeId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


	if isnull(@ClassName, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_ExchangeClass.Insert'                and Item=0), 'Не указано название класса обмена')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
	
	if isnull(@ClassId, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_ExchangeClass.Insert'                and Item=1), 'Не указан код класса обмена')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	if exists(select * 
				from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass ec
				where ec.ClassId = @ClassId
					or ec.ClassName = @ClassName)
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_ExchangeClass.Insert'                and Item=2), 'Запись с таким кодом обмена уже существует.')  raiserror(@__r__msg,15,2) with seterror  end
				return 1
		end	 

	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeClass(
		ClassId
		,ClassName
		,DefaultTypeId)
	values(
		@ClassId
		,@ClassName
		,@DefaultTypeId) 
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_ExchangeClass_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_ExchangeClass_Update]( @ClassId varchar(50)=NULL, @ClassName varchar(50)=NULL, @DefaultTypeId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      


	if isnull(@ClassName, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_ExchangeClass.Update'                and Item=0), 'Не указано название класса обмена')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
	
	if isnull(@ClassId, '') = ''
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_ExchangeClass.Update'                and Item=1), 'Не указан код класса обмена')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end

	update UTM_ExchangeClass
		set 
			ClassId = @ClassId
			,ClassName = @ClassName
			,DefaultTypeId = @DefaultTypeId
		where ClassId = @ClassId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_ExchangeType_SelectOne]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_ExchangeType_SelectOne]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select
	et.UTM_ExchangeTypeId
	,et.Description
	,et.ExchangeTypeCode
from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
	order by et.ExchangeTypeCode 
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_ExchangeTypeLink_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_ExchangeTypeLink_Delete]( @Document_Object varchar(55)=NULL, @DocumentTypeId varchar(55)=NULL, @UTM_ExchangeType_Id int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	delete 
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeTypeLink
	where Document_Object = @Document_Object
		and DocumentTypeId = @DocumentTypeId
		and UTM_ExchangeType_Id = @UTM_ExchangeType_Id
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_ExchangeVersion_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_ExchangeVersion_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

	select 
		ev.UTM_ExchangeClass_ClassId
		,ev.Version
		,ev.UTM_ExchangeType_Id
		,et.ExchangeTypeCode
		,ev.Description 
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeVersion ev
		join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_ExchangeType et
			on et.UTM_ExchangeTypeId = ev.UTM_ExchangeType_Id
	order by ev.UTM_ExchangeClass_ClassId, ev.Version
	 
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Get]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Get]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/    select * from UTM u where u.UTM_id = 3
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Insert]( @Description varchar(255)=NULL, @FSRAR_Id varchar(50)=NULL, @IsActive bit=NULL, @TaxCode varchar(15)=NULL, @TaxReason varchar(50)=NULL, @URL varchar(255)=NULL, @UTMId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

if isnull(@Description, '') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Insert'                and Item=0), 'Не указано описание УТМ')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end

if isnull(@FSRAR_Id, '') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Insert'                and Item=1), 'Не указан код ФСРАР')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end

if isnull(@TaxCode, '') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Insert'                and Item=2), 'Не указан ИНН')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end

if isnull(@TaxReason, '') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Insert'                and Item=3), 'Не указан КПП')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end

if isnull(@URL, '') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Insert'                and Item=4), 'Не указан URL')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end

if isnull(@IsActive, 0) = 0
begin
	select @IsActive = 0
end

if exists(select *
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM
			where FSRAR_Id = @FSRAR_Id)
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Insert'                and Item=5), 'УТМ с ФСРАР %s уже заведен')  raiserror(@__r__msg,15,2, @FSRAR_Id) with seterror  end
	return 1
end

if exists(select *
			from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM
			where URL = @URL)
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Insert'                and Item=6), 'УТМ с URL %s уже заведен')  raiserror(@__r__msg,15,2,@URL) with seterror  end
	return 1
end

insert [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM (Description
	,FSRAR_Id
	,TaxCode
	,TaxReason
	,URL
	,IsActive)
select @Description
	,@FSRAR_Id
	,@TaxCode
	,@TaxReason
	,@URL
	,@IsActive
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Namespace_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Namespace_Delete]( @UTM_NamespaceId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

delete from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace
	where UTM_NamespaceId = @UTM_NamespaceId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Namespace_Describe]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpUTM_Namespace_Describe]( @UTM_NamespaceId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select *
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace n
where n.UTM_NamespaceId = @UTM_NamespaceId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Namespace_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Namespace_Edit]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

select *
	from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Namespace_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Namespace_Insert]( @Namespace varchar(256) )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     

	declare @IsExists bit = 0
	select @IsExists = EgaisExchange.dbo.bpUTM_Namespace_IsExists(@Namespace)

	if(isnull(@IsExists, 0) = 0)
		begin
			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace([Namespace])
				select @Namespace
		end
	else
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_Namespace.Insert'                and Item=0), 'Пространство имен уже существует в таблице!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
			
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Namespace_SelectOne]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpUTM_Namespace_SelectOne]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select n.UTM_NamespaceId, n.Namespace
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace n
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Namespace_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Namespace_Update]( @Namespace varchar(256)=NULL, @UTM_NamespaceId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     

	declare @IsExists bit = 0
	select @IsExists = EgaisExchange.dbo.bpUTM_Namespace_IsExists(@Namespace)

	if(isnull(@IsExists, 0) = 0)
		begin
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace
				set Namespace = @Namespace
			where UTM_NamespaceId = @UTM_NamespaceId
		end
	else
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_Namespace.Update'                and Item=0), 'Пространство имен уже существует в таблице!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_NamespaceLink_Delete]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpUTM_NamespaceLink_Delete]( @ExchangeTypeCode varchar(64)=NULL, @UTM_NamespaceId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	delete from  [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_NamespaceLink
		where ExchangeTypeCode = @ExchangeTypeCode
			and UTM_NamespaceId = @UTM_NamespaceId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_NamespaceLink_Describe]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpUTM_NamespaceLink_Describe]( @ExchangeTypeCode varchar(64)=NULL, @UTM_NamespaceId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select l.ExchangeTypeCode, n.Namespace
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_NamespaceLink l
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace n
				on n.UTM_NamespaceId = l.UTM_NamespaceId
	where l.ExchangeTypeCode = @ExchangeTypeCode
		and l.UTM_NamespaceId = @UTM_NamespaceId
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_NamespaceLink_Edit]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_NamespaceLink_Edit]( @ExchangeTypeCode varchar(64)=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select l.ExchangeTypeCode, l.UTM_NamespaceId, n.Namespace
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_NamespaceLink l
			join [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_Namespace n
				on n.UTM_NamespaceId = l.UTM_NamespaceId
	where @ExchangeTypeCode is null or l.ExchangeTypeCode = @ExchangeTypeCode
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_NamespaceLink_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[bpUTM_NamespaceLink_Insert]( @ExchangeTypeCode varchar(64)=NULL, @UTM_NamespaceId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     

	declare @IsExists bit = 0
	select @IsExists = EgaisExchange.dbo.bpUTM_NamespaceLink_IsExists(@ExchangeTypeCode, @UTM_NamespaceId)

	if(isnull(@IsExists, 0) = 0)
		begin
			insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_NamespaceLink(ExchangeTypeCode, UTM_NamespaceId)
				select @ExchangeTypeCode, @UTM_NamespaceId
		end
	else
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_NamespaceLink.Insert'                and Item=0), 'Запись уже существует в таблице!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
			
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_NamespaceLink_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_NamespaceLink_Update]( @ExchangeTypeCode varchar(64)=NULL, @OldExchangeTypeCode varchar(64)=NULL, @OldUTM_NamespaceId int=NULL, @UTM_NamespaceId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     

	declare @IsExists bit = 0
	select @IsExists = EgaisExchange.dbo.bpUTM_NamespaceLink_IsExists(@ExchangeTypeCode, @UTM_NamespaceId)

	if(isnull(@IsExists, 0) = 0)
		begin
			update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_NamespaceLink
				set 
					ExchangeTypeCode = @ExchangeTypeCode
					,UTM_NamespaceId = @UTM_NamespaceId
				where ExchangeTypeCode = @OldExchangeTypeCode
					and UTM_NamespaceId = @OldUTM_NamespaceId
		end
	else
		begin
			begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM_NamespaceLink.Update'                and Item=0), 'Запись уже существует в таблице!')  raiserror(@__r__msg,15,2) with seterror  end
			return 1
		end
			
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_OperationLog_ExceptionLog]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_OperationLog_ExceptionLog]( @ObjectId int, @Operation varchar(64), @Method varchar(128), @ErrorNumber int, @ErrorSeverity int, @ErrorState int, @ErrorProcedure varchar(128), @ErrorLine int, @ErrorMessage varchar(256), @RowId uniqueidentifier )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          
                                                                                                                                                                                                                                        declare @__r__msg varchar(1000)                                                                                                     


-- Логирование -------------------------------------------
create table #OperationLog(
				Param varchar(50)
				,Value varchar(255))

insert into #OperationLog(
				Param
				,Value)
	values
		('Method', @Method)
		,('ERROR_NUMBER', convert(varchar(255), @ErrorNumber))
		,('ERROR_SEVERITY', convert(varchar(255), @ErrorSeverity))
		,('ERROR_STATE', convert(varchar(255), @ErrorState))
		,('ERROR_PROCEDURE', convert(varchar(255), @ErrorProcedure))
		,('ERROR_LINE', convert(varchar(255), @ErrorLine))
		,('ERROR_MESSAGE', convert(varchar(255), @ErrorMessage))


declare @MonUserId varchar(50)
select MonUserId = ( select coalesce(    case when __xc.bo_UserName is null then __xc.bo_UserName else SUBSTRING(__xc.bo_UserName,CHARINDEX('\',__xc.bo_UserName)+1,LEN(__xc.bo_UserName)) end,    SUBSTRING(__s.login_name,CHARINDEX('\',__s.login_name)+1,LEN(__s.login_name)) )  from sys.dm_exec_sessions __s left join xBOConnection __xc on __s.session_id=__xc.spid and __s.login_time=__xc.login_time where __s.session_id=@@spid );

exec [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.bpUTM_OperationLog_Insert
			@ObjectId = @ObjectId
			,@Operation = @Operation
			,@MonUserId = @MonUserId				
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_OperationLog_Insert]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_OperationLog_Insert]( @ObjectId int=NULL, @Operation varchar(50)=NULL, @MonUserId varchar(50)=NULL, @RowId uniqueidentifier=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                     
      
	

	declare @OperationParams nvarchar(max) = ''

	select 
		 @OperationParams += isnull(ol.Param, '') + ': ' + isnull(ol.Value, '') + ', '
	from #OperationLog ol

	select @OperationParams = left(@OperationParams, len(@OperationParams) - 1)

	insert into [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM_OperationLog(
						ObjectId
						,Operation
						,OperationDate
						,OperationParams
						,MonUserId
						,RowId)
		values(
			@ObjectId        
			,@Operation      
            ,getdate()  
            ,@OperationParams
            ,@MonUserId
			,@RowId)     

	if object_id(N'tempdb..#OperationLog', N'U') is not null
		drop table #OperationLog
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_S_Get]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_S_Get]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select * 
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
	where u.URL is not NULL
     -- and u.UTMId not in (88, 89, 90, 91)
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_S_GetActiveUTM]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_S_GetActiveUTM]/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          

	select * 
		from [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM u
	where u.IsActive = 1
		and u.URL is not NULL 
        --and u.UTMId not in (88, 89, 90, 91)
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_S_UpdateUTMState]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_S_UpdateUTMState]( @UTMId int=NULL, @IsActive bit )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/          


	update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM
		set IsActive = @IsActive
	where UTMId = @UTMId

	 
GO
/****** Object:  StoredProcedure [dbo].[bpUTM_Update]    Script Date: 11.06.2020 14:54:32 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[bpUTM_Update]( @Description varchar(255)=NULL, @FSRAR_Id varchar(50)=NULL, @IsActive bit=NULL, @TaxCode varchar(15)=NULL, @TaxReason varchar(50)=NULL, @URL varchar(255)=NULL, @UTMId int=NULL )/*<proc_option_tag>*/  AS /*</proc_option_tag>*/                                                                               /* global system settings */          /* #define _BASECOST */        /* #define _DiscountTypeFactor */    /* #define _RemoteCall_v1 */                                              /**/    /**/                                                                                                                                                                                                                                            declare @__r__msg varchar(1000)                                                                                                   
      

if isnull(@FSRAR_Id, '') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Update'                and Item=0), 'Не указан ФСРАР ИД для УТМ!')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end
		
if isnull(@TaxCode,'') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Update'                and Item=1), 'Не указан ИНН для УТМ!')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end

if isnull(@TaxReason,'') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Update'                and Item=2), 'Не указан КПП для УТМ!')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end

if isnull(@URL,'') = ''
begin
	begin                      select @__r__msg=isnull((select msg            from xBOMessage m                          join sys.dm_exec_sessions __s on __s.session_id=@@spid                          join xBOConnection c on __s.session_id=c.spid and __s.login_time=c.login_time and m.langid=c.bo_LangUId           where BOName='UTM.Update'                and Item=3), 'Не указан URL для УТМ!')  raiserror(@__r__msg,15,2) with seterror  end
	return 1
end


update [MSK-HQ-MNT01\ERP_MAIN].EgaisExchange.dbo.UTM
	set 
		FSRAR_Id = @FSRAR_Id
		,TaxCode = @TaxCode
		,TaxReason = @TaxReason
		,Description = @Description
		,URL = @URL
		,IsActive = @IsActive
	where UTMId = @UTMId 
GO
USE [master]
GO
ALTER DATABASE [EgaisExchange] SET  READ_WRITE 
GO
