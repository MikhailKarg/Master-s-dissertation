using System;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary
{
    public class UTM_ExchangeData : UTM_Object
    {
        public string URL { get; set; }
        public string Reply_Id { get; set; }
        public string Data { get; set; }
        public string DataGUID { get; set; }
        public string ExchangeTypeCode { get; set; }
        public int UTM_Id { get; set; }
        public void Insert(IUTM_ServiceSettings serviceSettings, IUTM_Log log, IUTM_DBCommand dbCommand) 
        {
            string SqlExpression = "proc_ExchangeDataInsert";

            IUTM_DBCommand UTM_DataInsert = dbCommand;

            UTM_DataInsert.BuildCommand(serviceSettings, SqlExpression, log);
            UTM_DataInsert.AddCommandParameter("ExchangeTypeCode", ExchangeTypeCode);
            UTM_DataInsert.AddCommandParameter("UTM_Id", Convert.ToString(UTM_Id));
            UTM_DataInsert.AddCommandParameter("Data", Data);
            UTM_DataInsert.AddCommandParameter("URL", URL);
            UTM_DataInsert.AddCommandParameter("Reply_Id", Reply_Id);
            UTM_DataInsert.AddCommandParameter("Direction", "1");

            UTM_DataInsert.Exec();
        }
        public void UpdateReply_Id(IUTM_ServiceSettings serviceSettings, IUTM_Log log, IUTM_DBCommand dbCommand) 
        {
            string SqlExpression = "proc_ExchangeDataUpdateReply";

            string statusCode = serviceSettings.GetServiceSetting("SentStatusCode");

            IUTM_DBCommand UTM_DataUpdateReply_Id = dbCommand;

            UTM_DataUpdateReply_Id.BuildCommand(serviceSettings, SqlExpression, log);
            UTM_DataUpdateReply_Id.AddCommandParameter("ExchangeData_Id", Convert.ToString(Id));
            UTM_DataUpdateReply_Id.AddCommandParameter("Reply_Id", Reply_Id);
            UTM_DataUpdateReply_Id.AddCommandParameter("StatusCode", statusCode);

            UTM_DataUpdateReply_Id.Exec();
        }
        public static UTM_ExchangeDataBuilder GetBuilder()
        {
            return new UTM_ExchangeDataBuilder();
        }
    }
}
