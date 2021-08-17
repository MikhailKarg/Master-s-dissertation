using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary;
using UTM_ExchangeLibrary.DBMappers;
using UTM_ExchangeLibrary.Interfaces;
using UTM_ExchangeLibrary.Log;

namespace UTM_ExchangeConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            string logPath = ConfigurationManager.AppSettings.Get("LogPath");
            UTM_Log log = new UTM_Log(logPath, LogLevel.Debug);

            IUTM_ServiceSettings settings = UTM_ServiceSettingsBuilder.GetServiceSettings(log);

            List<UTM> utmServers = UTMMapper.GetUTMServers(settings, log);

            byte isActive = 0;

            foreach (UTM u in utmServers)
            {
                u.IsActive = isActive;
                u.SetUTMState(settings, log);
            }

                //log.Log(LogLevel.Info, "testLog3");
                //log.LogException(LogLevel.Info, new Exception("Ошибка в режиме отладки"));

            //List<UTM_Data> readyUTM_Data = UTM_DataMapper.GetReadyUTM_Data(connectionString, getReadyUTM_DataExpression, sqlCommandTimeout, 1);

            //foreach (var ud in readyUTM_Data) 
            //{
            //    ud.UpdateReply_Id(connectionString, utm_DataUpdateReply_IdExpression, sqlCommandTimeout, "testReply_id", statusCode);
            //}

            /*
              1) поиск настройки в dictionary - ,бывают исключения +
              2) Логирование
              3) передача статуса в БД  +
              4) Направление документа 
                
             */

            //UTM_Data data = (UTM_Data)UTM_Data.GetBuilder()
            //    .SetData("testDataInsert")
            //    .SetReply_Id("testId")
            //    .SetURL("testURL")
            //    .SetUTM_Id(2)
            //    .SetExchangeTypeCode("WayBill_v3")
            //    .Build();

            //data.Insert(connectionString, utm_DataInsertExpression, sqlCommandTimeout);

            //List<UTM_Data> UTM_DataList;
            //List<UTM> UTMList;

            //if (!string.IsNullOrWhiteSpace(proc_ReadyUTM_Data))
            //{
            //    UTM_DataList = UTM_DataMapper.GetReadyUTM_Data(connectionString, proc_GetUTM, sqlCommandTimeout);
            //}

            //if (!string.IsNullOrWhiteSpace(proc_GetUTM))
            //{
            //    UTMList = UTMMapper.GetUTM(connectionString, proc_ReadyUTM_Data, sqlCommandTimeout);
            //}

            Console.ReadKey();
        }
    }
}
