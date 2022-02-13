using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using UTM_ExchangeLibrary;
using UTM_ExchangeLibrary.DBMappers;
using UTM_ExchangeLibrary.Interfaces;
using UTM_ExchangeService.ClassBuilders;

namespace UTM_ExchangeService
{
    public class UTM_ExchangeServiceBroker
    {
        protected IUTM_Log ServiceLog;
        protected IUTM_ServiceSettings Settings;
        protected IUTM_DBCommand DBCommand;
        protected UTM_Exchange Exchange;
        
        protected bool Enabled { get; set; }
        protected int ServiceTimeout { get; set; }

        protected List<Task> GetDataList = new List<Task>();
        protected List<Task> SendDataList = new List<Task>();

        public UTM_ExchangeServiceBroker()
        {
            ServiceLog = UTM_ServiceLogBuilder.GetServiceLog();
            Settings = UTM_ServiceSettingsBuilder.GetServiceSettings(ServiceLog);
            DBCommand = UTM_DBCommandBuilder.GetDBCommand();
            Exchange = UTM_ExchangeBuilder.GetExchange(Settings, ServiceLog, DBCommand);

            ServiceTimeout = Convert.ToInt32(Settings.GetServiceSetting("ServiceTimeout"));

            if (ServiceTimeout == 0)
            {
                ServiceTimeout = 10000;
            }

            Enabled = true;
        }

        private void ExchangeWait()
        {
            try
            {
                if (GetDataList.Count != 0)
                {
                    Task.WaitAll(GetDataList.ToArray());
                }

                if (SendDataList.Count != 0)
                {
                    Task.WaitAll(SendDataList.ToArray());
                }
            }
            catch (Exception ex)
            {
                ServiceLog.LogException(ex);
            }

            GetDataList.Clear();
            SendDataList.Clear();
        }
        public void Start()
        {
            ServiceLog.Log(("Запуск службы - ServiceTimeout: " + ServiceTimeout + " мс"));

            while (Enabled)
            {
                Exchange.ScanUTMState();

                List<UTM> utmServers = UTMMapper.GetUTMServers(Settings, ServiceLog, DBCommand);

                foreach (UTM u in utmServers)
                {
                    if (u.IsActive == 1)
                    {
                        try
                        {
                            GetDataList.Add(Exchange.GetAsync(u));
                            SendDataList.Add(Exchange.SendAsync(u));
                        }
                        catch (Exception ex)
                        {
                            ServiceLog.LogException(ex);
                        }
                    }
                }

                ExchangeWait();

                Thread.Sleep(ServiceTimeout);
            }
        }
        public void Stop()
        {
            Enabled = false;

            ExchangeWait();

            ServiceLog.Log("Работа службы остановлена");
        }
        public void Pause()
        {
            Enabled = false;

            ExchangeWait();

            ServiceLog.Log("Работа службы приостановлена");
        }
        public void Continue()
        {
            Enabled = true;

            ServiceLog.Log("Работа службы продолжена");
        }
        public void Shutdown()
        {
            Enabled = false;

            ExchangeWait();

            ServiceLog.Log("Произошло выключение или перезагрузка Windows!");
        }
    }
}
