using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary
{
    public class UTM_Data : UTM_Object
    {
        public string URL { get; set; }
        public string Reply_Id { get; set; }
        public string Data { get; set; }
        public string DataGUID { get; set; }
        public string ExchangeTypeCode { get; set; }
        public int UTM_Id { get; set; }
        public void Insert(string connectionString, string sqlExpression, int commandTimeout) 
        {
            IUTM_DBCommand UTM_DataInsert = new UTM_SQLServerCommand();

            UTM_DataInsert.BuildCommand(connectionString, sqlExpression, commandTimeout);
            UTM_DataInsert.AddCommandParameter("ExchangeTypeCode", ExchangeTypeCode);
            UTM_DataInsert.AddCommandParameter("UTM_Id", Convert.ToString(UTM_Id));
            UTM_DataInsert.AddCommandParameter("Data", Data);
            UTM_DataInsert.AddCommandParameter("URL", URL);
            UTM_DataInsert.AddCommandParameter("Reply_Id", Reply_Id);
            UTM_DataInsert.AddCommandParameter("Direction", "1");

            UTM_DataInsert.Exec();
        }
        public void UpdateReply_Id(string connectionString, string sqlExpression, int commandTimeout, string reply_Id, string statusCode) 
        {
            IUTM_DBCommand UTM_DataUpdateReply_Id = new UTM_SQLServerCommand();

            UTM_DataUpdateReply_Id.BuildCommand(connectionString, sqlExpression, commandTimeout);
            UTM_DataUpdateReply_Id.AddCommandParameter("UTM_Data_Id", Convert.ToString(Id));
            UTM_DataUpdateReply_Id.AddCommandParameter("Reply_Id", reply_Id);
            UTM_DataUpdateReply_Id.AddCommandParameter("StatusCode", statusCode);

            UTM_DataUpdateReply_Id.Exec();
        }
        public static UTM_DataBuilder GetBuilder()
        {
            return new UTM_DataBuilder();
        }
    }
}
