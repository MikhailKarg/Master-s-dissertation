create table srv.UTM_ServiceSettings(
							Id int primary key identity(1,1),
							SettingName nvarchar(128) not null,
							SettingValue nvarchar(128) not null,
							[Description] nvarchar(1024))

go

create nonclustered index IX_UTM_ServiceSettings_SettingName on srv.UTM_ServiceSettings(SettingName)