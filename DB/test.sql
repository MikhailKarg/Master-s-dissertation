select *
from srv.ExchangeClasses



select *
from srv.ExchangeTypes




select *
from srv.ExchangeTypeActions

select *
from srv.UTM

insert into srv.UTM(FSRAR_Id, TaxCode, TaxReason, IP, IsActive, Description)
values
	('10000000580', '7729101200', '772901001', '192.168.6.230:8080', 0, 'Очаково - ТЕСТОВЫЙ УТМ'),
	('10060695471', '7732002489', '772945002', '192.168.6.232:8080', 0, 'Надежда - ТЕСТОВЫЙ УТМ')


select *
from srv.UTM_Data

alter table srv.UTM_Data drop column Direction

insert into srv.UTM_Data(
					ExchangeType_Id
					,UTM_Id
					,Data
					,URL
					,Status_Id)
values(106, 1, 'TEST1', 'http:', 10), (106, 1, 'TEST2', 'http:', 10), (106, 1, 'TEST3', 'http:', 10)

select *
from srv.Settings

update srv.Settings
set SettingName = 'proc_GetUTM'
where Id = 4

insert into srv.Settings(SettingName, SettingValue, Description)
values('GetUTM', '[srv].[GetUTM]', 'УТМ')

select *
from srv.Statuses

insert into srv.Statuses(ExternalCode, Description)
values('ERROR', 'Ошибка')


exec [srv].[GetReadyUTM_Data]
exec [srv].[GetUTM]