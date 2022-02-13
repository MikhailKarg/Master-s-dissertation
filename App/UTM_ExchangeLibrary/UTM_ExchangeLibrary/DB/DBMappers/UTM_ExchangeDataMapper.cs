using System;
using System.Collections.Generic;
using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.DBMappers
{
    public class UTM_ExchangeDataMapper
    {
        public static List<UTM_ExchangeData> GetReadyUTM_Data(IUTM_ServiceSettings serviceSettings, int utm_id, IUTM_Log log, IUTM_DBCommand dbCommand)
        {
            string sqlExpression = "proc_GetReadyExchangeData";

            IUTM_DBCommand GetReadyUTM_DataCommand = dbCommand;

            GetReadyUTM_DataCommand.BuildCommand(serviceSettings, sqlExpression, log);
            GetReadyUTM_DataCommand.AddCommandParameter("UTM_Id", Convert.ToString(utm_id));

            List<UTM_ExecutedCommandData> data = GetReadyUTM_DataCommand.Exec();
            List<UTM_ExchangeData> utm_DataList = new List<UTM_ExchangeData>();

            foreach (var i in data) 
            {
                UTM_ExchangeDataBuilder builder = UTM_ExchangeData.GetBuilder();
                IDictionary<string, string> dictData = i.Data;

                if (dictData.ContainsKey("Id")) 
                {
                    builder.SetId(Convert.ToInt32(dictData["Id"]));
                }

                if (dictData.ContainsKey("ExchangeTypeCode"))
                {
                    builder.SetExchangeTypeCode(dictData["ExchangeTypeCode"]);
                }

                if (dictData.ContainsKey("UTM_Id"))
                {
                    builder.SetUTM_Id(Convert.ToInt32(dictData["UTM_Id"]));
                }

                if (dictData.ContainsKey("Data"))
                {
                    builder.SetData(dictData["Data"]);
                }

                if (dictData.ContainsKey("DataGUID"))
                {
                    builder.SetDataGUID(dictData["DataGUID"]);
                }

                utm_DataList.Add((UTM_ExchangeData)builder.Build());
            }

            return utm_DataList;
        }
    }
}
