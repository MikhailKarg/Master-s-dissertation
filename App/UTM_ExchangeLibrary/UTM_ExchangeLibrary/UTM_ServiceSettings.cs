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
    public class UTM_ServiceSettings : IUTM_ServiceSettings
    {
        protected IDictionary<string, string> ServiceSettings;
        protected string JSONSettingsPath { get; set; }
        protected string ConnectionString { get; set; }
        protected int SqlCommandTimeout { set; get;  }
        protected string GetSettingProcedure { get; set; }
        protected IUTM_Log Log;
        public UTM_ServiceSettings(string jsonSettingsPath, IUTM_Log log)
        {
            JSONSettingsPath = jsonSettingsPath;
            ServiceSettings = new Dictionary<string, string>();
            Log = log;

            GetServiceSettings();
        }
        protected void GetServiceSettings()
        {
            UTM_JSONServiceSettings JSONServiceSettings = GetJSONSettings(JSONSettingsPath);

            ConnectionString = JSONServiceSettings.ConnectionString;
            SqlCommandTimeout = JSONServiceSettings.SqlCommandTimeout;
            GetSettingProcedure = JSONServiceSettings.GetSettingProcedure;

            ServiceSettings.Add("ConnectionString", ConnectionString);
            ServiceSettings.Add("SqlCommandTimeout", Convert.ToString(SqlCommandTimeout));

            GetSettings();
        }
        protected UTM_JSONServiceSettings GetJSONSettings(string serviceSettingsPath)
        {
            try
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
            catch (Exception ex)
            {
                Log.LogException(ex);
                return null;
            }
        }
        protected void GetSettings()
        {
            if (!string.IsNullOrWhiteSpace(ConnectionString))
            {
                IUTM_DBCommand GetSettingsCommand = new UTM_SQLServerCommand();
                GetSettingsCommand.BuildCommand(this, GetSettingProcedure, Log);

                try
                {
                    ServiceSettings = ServiceSettings
                                        .Union(GetSettingsCommand.Exec()[0].Data)
                                        .ToDictionary(s => s.Key, s => s.Value);
                }
                catch (Exception ex)
                {
                    Log.LogException(ex);
                }
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
