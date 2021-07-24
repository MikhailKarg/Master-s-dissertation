using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary
{
    public class UTM_ServiceSettings : UTM_Object
    {
        protected IDictionary<string, string> ServiceSettings;
        protected string JSONSettingsPath { get; set; }
        public string ConnectionString { get; set; }
        public int SqlCommandTimeout { get; set; }
        protected string GetSettingProcedure { get; set; }
        public UTM_ServiceSettings(string jsonSettingsPath)
        {
            this.JSONSettingsPath = jsonSettingsPath;
            ServiceSettings = new Dictionary<string, string>();

            GetServiceSettings();
        }
        protected void GetServiceSettings()
        {
            UTM_JSONServiceSettings JSONServiceSettings = GetJSONSettings(JSONSettingsPath);

            ConnectionString = JSONServiceSettings.ConnectionString;
            SqlCommandTimeout = JSONServiceSettings.SqlCommandTimeout;
            GetSettingProcedure = JSONServiceSettings.GetSettingProcedure;

            GetSettings();
        }
        protected UTM_JSONServiceSettings GetJSONSettings(string serviceSettingsPath)
        {
            string jsonString = File.ReadAllText(serviceSettingsPath);

            if (!string.IsNullOrWhiteSpace(jsonString))
            {
                return JsonSerializer.Deserialize<UTM_JSONServiceSettings>(jsonString);
            }
            else
            {
                return null;
            }
        }
        protected void GetSettings()
        {
            if (!string.IsNullOrWhiteSpace(ConnectionString))
            {
                IUTM_DBCommand GetSettingsCommand = new UTM_SQLServerCommand();
                GetSettingsCommand.BuildCommand(ConnectionString, GetSettingProcedure, SqlCommandTimeout);

                ServiceSettings = GetSettingsCommand.Exec()[0].Data;
            }
        }
        public string GetServiceSetting(string settingName) 
        {
            if (ServiceSettings.ContainsKey(settingName)) 
            { 
                return ServiceSettings[settingName];
            }

            return null;
        }
    }
}
