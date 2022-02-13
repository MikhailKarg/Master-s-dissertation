using System;
using System.Collections.Generic;
using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.DBMappers
{
    public class UTMMapper
    {
        public static List<UTM> GetUTMServers(IUTM_ServiceSettings serviceSettings, IUTM_Log log, IUTM_DBCommand dbCommand)
        {
            string sqlExpression = "proc_GetUTM";

            IUTM_DBCommand GetUTM_DataCommand = dbCommand;

            GetUTM_DataCommand.BuildCommand(serviceSettings, sqlExpression, log);

            List<UTM_ExecutedCommandData> data = GetUTM_DataCommand.Exec();
            List<UTM> utmList = new List<UTM>();

            foreach (var i in data)
            {
                UTMBuilder builder = UTM.GetBuilder();
                IDictionary<string, string> dictData = i.Data;

                if (dictData.ContainsKey("Id"))
                {
                    builder.SetId(Convert.ToInt32(dictData["Id"]));
                }

                if (dictData.ContainsKey("IP"))
                {
                    builder.SetIP(dictData["IP"]);
                }

                if (dictData.ContainsKey("TransferProtocol"))
                {
                    builder.SetTransferProtocol(dictData["TransferProtocol"]);
                }

                if (dictData.ContainsKey("IsActive"))
                {
                    builder.SetActive(Convert.ToByte(dictData["IsActive"]));
                }

                utmList.Add((UTM)builder.Build());
            }

            return utmList;
        }
    }
}
