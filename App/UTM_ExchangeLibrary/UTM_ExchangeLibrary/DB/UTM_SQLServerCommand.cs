using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.DB
{
    internal class UTM_SQLServerCommand : UTM_Object, IUTM_DBCommand 
    {
        protected SqlConnection Connection;
        protected SqlCommand Command;
        protected IUTM_Log Log;
        public void BuildCommand(IUTM_ServiceSettings serviceSettings, string sqlExpression, IUTM_Log log)
        {
            ConnectionString = serviceSettings.GetServiceSetting("ConnectionString");
            SqlCommandTimeout = Convert.ToInt32(serviceSettings.GetServiceSetting("SqlCommandTimeout"));
            SqlExpression = sqlExpression;

            try
            {
                Log = log;

                Connection = new SqlConnection(ConnectionString);
                Command = new SqlCommand(SqlExpression, Connection);
                Command.CommandType = CommandType.StoredProcedure;
                Command.CommandTimeout = SqlCommandTimeout;
            }
            catch(Exception ex) 
            {
                Log.LogException(ex);
            }
        }
        public void AddCommandParameter(string parameterName, string value)
        {
            try
            {
                Command.Parameters.Add(new SqlParameter { ParameterName = parameterName, Value = value });
            }
            catch (Exception ex)
            {
                Log.LogException(ex);
            }
        }
        public List<UTM_ExecutedCommandData> Exec()
        {
            List<UTM_ExecutedCommandData> dataList = new List<UTM_ExecutedCommandData>();
            IDictionary<string, string> datarow;

            try 
            {
                using (Connection)
                {
                    Connection.Open();

                    SqlDataReader reader = Command.ExecuteReader();

                    if (reader.HasRows)
                    {
                        int fieldCount = reader.FieldCount;

                        while (reader.Read())
                        {
                            datarow = new Dictionary<string, string>();

                            for (var i = 0; i < fieldCount; i++)
                            {
                                datarow.Add(reader.GetName(i), (string)reader.GetValue(i));
                            }

                            dataList.Add(new UTM_ExecutedCommandData(datarow));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Log.LogException(ex);
            }

            return dataList;
        }
    }
}
