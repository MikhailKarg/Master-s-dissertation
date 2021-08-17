using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary
{
    public class UTM_ServiceSettingsBuilder
    {
        private UTM_ServiceSettings ServiceSettings { get; }
        private static UTM_ServiceSettingsBuilder ServiceSettingsBuilder;
        protected UTM_ServiceSettingsBuilder(string JSONSettingsPath, IUTM_Log log)
        {
            ServiceSettings = new UTM_ServiceSettings(JSONSettingsPath, log);
        }

        public static UTM_ServiceSettings GetServiceSettings(IUTM_Log log)
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
