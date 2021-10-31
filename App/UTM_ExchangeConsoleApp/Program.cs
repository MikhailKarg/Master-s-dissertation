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

            Console.ReadKey();
        }
    }
}
