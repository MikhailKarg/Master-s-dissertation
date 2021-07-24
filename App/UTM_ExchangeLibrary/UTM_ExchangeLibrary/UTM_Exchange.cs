using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.DBMappers;
using UTM_ExchangeLibrary.XMLParsers;

namespace UTM_ExchangeLibrary
{
    public class UTM_Exchange
    {
        protected UTM_ServiceSettings Settings;

        protected string ConnectionString;
        protected int SqlCommandTimeout;
        protected int HTTPTimeout;

        protected string GetUTMExpression;
        public UTM_Exchange(UTM_ServiceSettings settings)
        {
            Settings = settings;

            ConnectionString = Settings.ConnectionString;
            SqlCommandTimeout = Settings.SqlCommandTimeout;
            HTTPTimeout = Convert.ToInt32(Settings.GetServiceSetting("HTTPTimeout"));

            GetUTMExpression = Settings.GetServiceSetting("proc_GetUTM");
        }
        protected void Get()
        {
            try
            {
                string pathToDataFromUTM = Settings.GetServiceSetting("PathToDataFromUTM");
                string utm_DataInsertExpression = Settings.GetServiceSetting("proc_UTM_DataInsert");

                if (!string.IsNullOrWhiteSpace(pathToDataFromUTM)
                    & !string.IsNullOrWhiteSpace(utm_DataInsertExpression))
                {
                    List<UTM> utmServers = UTMMapper.GetUTMServers(ConnectionString, GetUTMExpression, SqlCommandTimeout);

                    foreach (UTM u in utmServers)
                    {
                        if (u.IsActive)
                        {
                            try
                            {
                                string dataListURL = u.IP + pathToDataFromUTM;
                                string getDataListOperationResult;

                                UTM_HttpOperation getDataListOperation = new UTM_GetOperation(HTTPTimeout, dataListURL);
                                getDataListOperationResult = getDataListOperation.Exec();

                                List<UTM_Data> utm_data = UTM_XMLParser.ParseResponsesFromUTM(getDataListOperationResult);

                                foreach (UTM_Data ud in utm_data)
                                {
                                    string dataURL = ud.URL;
                                    string getDataOperationResult;

                                    UTM_HttpOperation getDataOperation = new UTM_GetOperation(HTTPTimeout, dataURL);
                                    getDataOperationResult = getDataOperation.Exec();

                                    ud.Data = getDataOperationResult;
                                    ud.UTM_Id = u.Id;
                                    ud.Insert(ConnectionString, utm_DataInsertExpression, SqlCommandTimeout);
                                }
                            }
                            catch { }
                        }
                    }
                }      
            }
            catch { }
        }
        public async Task GetAsync()
        {
            await Task.Run(() => Get());
        }
        protected void Send()
        {
            try
            {
                string getReadyUTM_DataExpression = Settings.GetServiceSetting("proc_GetReadyUTM_Data");
                string utm_DataUpdateReply_IdExpression = Settings.GetServiceSetting("proc_UTM_DataUpdateReply_Id");
                string statusCode = Settings.GetServiceSetting("SentStatusCode");

                if (!string.IsNullOrWhiteSpace(getReadyUTM_DataExpression))
                {
                    List<UTM> utmServers = UTMMapper.GetUTMServers(ConnectionString, GetUTMExpression, SqlCommandTimeout);
                    
                    string boundary = "---------------------------" + DateTime.Now.Ticks.ToString("x");

                    foreach (UTM u in utmServers)
                    {
                        if (u.IsActive)
                        {
                            try
                            {
                                List<UTM_Data> readyUTM_Data = UTM_DataMapper.GetReadyUTM_Data(ConnectionString, getReadyUTM_DataExpression, SqlCommandTimeout, u.Id);

                                foreach (UTM_Data ud in readyUTM_Data)
                                {
                                    UTM_HttpOperation sendReadyUTM_DataOperation = new UTM_SendOperation(HTTPTimeout, ud.URL, ud.Data, ud.DataGUID, boundary);
                                    string sendReadyUTM_DataResult = sendReadyUTM_DataOperation.Exec();
                                    string reply_Id = UTM_XMLParser.ParseResponseFromUTM(sendReadyUTM_DataResult);

                                    if (!string.IsNullOrWhiteSpace(reply_Id)) 
                                    {
                                        ud.UpdateReply_Id(ConnectionString, utm_DataUpdateReply_IdExpression, SqlCommandTimeout, reply_Id, statusCode);
                                    }
                                }
                            }
                            catch { }
                        }
                    }
                }
            }
            catch { }
        }
        public async Task SendAsync()
        {
            await Task.Run(() => Send());
        }
    }
}
