using System;
using System.Threading;
using System.Configuration;
using UTM_Interchange;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace ExchangeUTM
{
    public class ExchangeUTM
    {
        bool Enabled { get; set; }
        int Timeout { get; set; }

        List<Task> getting = null;
        List<Task> sending = null;

        public ExchangeUTM()
        {
            Enabled = true;

            try
            {
                Timeout = Convert.ToInt32(ConfigurationManager.AppSettings.Get("ServiceTimeout"));

                if (Timeout == 0)
                {
                    Timeout = 10000;
                }
            }
            catch(Exception ex)
            {
                Log log = new Log(ex);
            }
        }
        public void Start()
        {
            Log log = new Log(ConfigurationManager.AppSettings.Get("StartWork") + " - Service timeout: " + Timeout + " ms");

            while (Enabled)
            {              
                UTM_Scanner.ScanningUTM(); // Сканирование всех UTM на активность

                bool isDelete = Convert.ToBoolean(ConfigurationManager.AppSettings.Get("isDeleteAsiiuTicket"));

                if(isDelete)
                    Transport.DeleteAsiiuTicketFromUTM(); // Удаление файлов Асиу

                getting = Transport.GetXMLFromUTM(); // Получение и обработка входящих документов
                sending = Transport.SendXMLToUTM(); // Отправка готовых документов в УТМ

                try
                {
                    Task.WaitAll(getting.ToArray());
                    Task.WaitAll(sending.ToArray());
                }
                catch(Exception ex)
                {
                    Log errorlog = new Log(ex);
                }

                getting = null; 
                sending = null;
                Thread.Sleep(Timeout);
            }
        }
        public void Stop()
        {
            Enabled = false;

            try
            {
                Task.WaitAll(getting.ToArray());
                Task.WaitAll(sending.ToArray());              
            }
            catch (Exception ex)
            {
                Log errorlog = new Log(ex);
            }

            Log log = new Log(ConfigurationManager.AppSettings.Get("StopWork"));
        }
        public void Pause()
        {
            Enabled = false;

            try
            {
                Task.WaitAll(getting.ToArray());
                Task.WaitAll(sending.ToArray());
            }
            catch (Exception ex)
            {
                Log errorlog = new Log(ex);
            }

            Log log = new Log(ConfigurationManager.AppSettings.Get("PauseWork"));
        }
        public void Continue()
        {
            Enabled = true;
            Log log = new Log(ConfigurationManager.AppSettings.Get("ContinueWork"));           
        }
        public void Shutdown()
        {
            Enabled = false;

            try
            {
                Task.WaitAll(getting.ToArray());
                Task.WaitAll(sending.ToArray());
            }
            catch (Exception ex)
            {
                Log errorlog = new Log(ex);
            }

            Log log = new Log(ConfigurationManager.AppSettings.Get("ShutDownWindows"));
        }
    }
}
