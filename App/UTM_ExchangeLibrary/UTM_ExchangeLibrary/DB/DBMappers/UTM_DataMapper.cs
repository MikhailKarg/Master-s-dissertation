using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.DBMappers
{
    public class UTM_DataMapper
    {
        public static List<UTM_Data> GetReadyUTM_Data(string connectionString, string sqlExpression, int commandTimeout, int utm_id)
        {
            IUTM_DBCommand GetReadyUTM_DataCommand = new UTM_SQLServerCommand();

            GetReadyUTM_DataCommand.BuildCommand(connectionString, sqlExpression, commandTimeout);
            GetReadyUTM_DataCommand.AddCommandParameter("UTM_Id", Convert.ToString(utm_id));

            List<UTM_ExecutedCommandData> data = GetReadyUTM_DataCommand.Exec();
            List<UTM_Data> utm_DataList = new List<UTM_Data>();

            foreach (var i in data) 
            {
                UTM_DataBuilder builder = UTM_Data.GetBuilder();
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

                utm_DataList.Add((UTM_Data)builder.Build());
            }

            return utm_DataList;
        }
    }
}
