using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.DBMappers
{
    public class UTMMapper
    {
        public static List<UTM> GetUTMServers(string connectionString, string sqlExpression, int commandTimeout)
        {
            IUTM_DBCommand GetUTM_DataCommand = new UTM_SQLServerCommand();
            GetUTM_DataCommand.BuildCommand(connectionString, sqlExpression, commandTimeout);

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

                if (dictData.ContainsKey("IsActive"))
                {
                    builder.SetActive(Convert.ToBoolean(dictData["IsActive"]));
                }

                utmList.Add((UTM)builder.Build());
            }

            return utmList;
        }
    }
}
