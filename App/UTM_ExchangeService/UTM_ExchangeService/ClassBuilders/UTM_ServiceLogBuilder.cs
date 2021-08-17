using System.Configuration;
using UTM_ExchangeLibrary.Interfaces;
using UTM_ExchangeLibrary.Log;

namespace UTM_ExchangeService.ClassBuilders
{
    public class UTM_ServiceLogBuilder
    {
        IUTM_Log ServiceLog { get; }
        static UTM_ServiceLogBuilder ServiceLogBuilder;
        protected UTM_ServiceLogBuilder(string logPath)
        {
            ServiceLog = new UTM_Log(logPath, LogLevel.Debug);
        }

        public static IUTM_Log GetServiceLog()
        {
            if (ServiceLogBuilder == null)
            {
                string logPath = ConfigurationManager.AppSettings.Get("LogPath");

                if (!string.IsNullOrWhiteSpace(logPath))
                {
                    ServiceLogBuilder = new UTM_ServiceLogBuilder(logPath);
                }
            }
           
            return ServiceLogBuilder.ServiceLog;
        }
    }
}
