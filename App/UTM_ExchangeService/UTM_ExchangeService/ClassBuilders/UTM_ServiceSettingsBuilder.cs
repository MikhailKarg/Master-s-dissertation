using System.Configuration;
using UTM_ExchangeLibrary;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeService.ClassBuilders
{
    public class UTM_ServiceSettingsBuilder
    {
        IUTM_ServiceSettings ServiceSettings { get; }
        static UTM_ServiceSettingsBuilder ServiceSettingsBuilder;
        protected UTM_ServiceSettingsBuilder(string JSONSettingsPath, IUTM_Log log)
        {
            ServiceSettings = new UTM_ServiceSettings(JSONSettingsPath, log);
        }

        public static IUTM_ServiceSettings GetServiceSettings(IUTM_Log log)
        {
            if (ServiceSettingsBuilder == null)
            {
                string JSONSettingsPath = ConfigurationManager.AppSettings.Get("JSONSettingsPath");

                if (!string.IsNullOrWhiteSpace(JSONSettingsPath))
                {
                    ServiceSettingsBuilder = new UTM_ServiceSettingsBuilder(JSONSettingsPath, log);
                }
            }

            return ServiceSettingsBuilder.ServiceSettings;
        }
    }
}
