using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.DBMappers;
using UTM_ExchangeLibrary.Interfaces;
using UTM_ExchangeLibrary.XMLParsers;

namespace UTM_ExchangeLibrary
{
    public class UTM_Exchange
    {
        protected IUTM_ServiceSettings Settings;
        protected IUTM_Log Log;
        protected IUTM_DBCommand DBCommand;
        protected int HTTPTimeout;
         
        public UTM_Exchange(IUTM_ServiceSettings settings, IUTM_Log log, IUTM_DBCommand dbCommand)
        {
            Settings = settings;
            Log = log;
            DBCommand = dbCommand;

            HTTPTimeout = Convert.ToInt32(Settings.GetServiceSetting("HTTPTimeout"));        
        }
        protected void Get(UTM utm)
        {
            try
            {
                string pathToDataFromUTM = Settings.GetServiceSetting("PathToDataFromUTM");

                if (!string.IsNullOrWhiteSpace(pathToDataFromUTM))
                {
                    string dataListURL = utm.IP + pathToDataFromUTM;
                    string getDataListOperationResult;

                    UTM_HttpOperation getDataListOperation = new UTM_GetOperation(Log, HTTPTimeout, dataListURL);
                    getDataListOperationResult = getDataListOperation.Exec();

                    List<UTM_ExchangeData> utm_data = UTM_XMLParser.ParseResponsesFromUTM(getDataListOperationResult, Log);

                    foreach (UTM_ExchangeData ud in utm_data)
                    {
                        string dataURL = ud.URL;
                        string getDataOperationResult;

                        UTM_HttpOperation getDataOperation = new UTM_GetOperation(Log, HTTPTimeout, dataURL);
                        getDataOperationResult = getDataOperation.Exec();

                        ud.Data = getDataOperationResult;
                        ud.UTM_Id = utm.Id;
                        ud.Insert(Settings, Log, DBCommand);
                    }
                }                  
            }
            catch (Exception ex)
            {
                Log.LogException(ex);
            }
        }
        public async Task GetAsync(UTM utm)
        {
            await Task.Run(() => Get(utm));
        }
        protected void Send(UTM utm)
        {
            try
            {
                string boundary = Settings.GetServiceSetting("HTTPRequestBoundary");
                boundary += DateTime.Now.Ticks.ToString("x");

                List<UTM_ExchangeData> readyUTM_Data = UTM_ExchangeDataMapper.GetReadyUTM_Data(Settings, utm.Id, Log, DBCommand);

                foreach (UTM_ExchangeData ud in readyUTM_Data)
                {
                    UTM_HttpOperation sendReadyUTM_DataOperation = new UTM_SendOperation(Log, HTTPTimeout, ud.URL, ud.Data, ud.DataGUID, boundary);

                    string sendReadyUTM_DataResult = sendReadyUTM_DataOperation.Exec();
                    string reply_Id = UTM_XMLParser.ParseResponseFromUTM(sendReadyUTM_DataResult, Log);

                    ud.Reply_Id = reply_Id;

                    if (!string.IsNullOrWhiteSpace(reply_Id))
                    {
                        ud.UpdateReply_Id(Settings, Log, DBCommand);
                    }
                }
            }
            catch (Exception ex)
            {
                Log.LogException(ex);
            }
        }
        public async Task SendAsync(UTM utm)
        {
            await Task.Run(() => Send(utm));
        }
        public void ScanUTMState()
        {
            try 
            {
                List<UTM> utmServers = UTMMapper.GetUTMServers(Settings, Log, DBCommand);

                foreach (UTM u in utmServers)
                {
                    try
                    {
                        byte isActive = 0;
                        string getUTMStateOperationResult;
                        string URL = u.TransferProtocol +  u.IP;

                        UTM_HttpOperation getUTMStateOperation = new UTM_GetOperation(Log, HTTPTimeout, URL);
                        getUTMStateOperationResult = getUTMStateOperation.Exec();

                        if (!string.IsNullOrWhiteSpace(getUTMStateOperationResult))
                        {
                            isActive = 1;
                        }

                        u.IsActive = isActive;
                        u.SetUTMState(Settings, Log, DBCommand);
                    }
                    catch(Exception ex) 
                    {
                        Log.LogException(ex);
                    }
                }
            }
            catch(Exception ex)
            {
                Log.LogException(ex);
            }
        }
    }
}
