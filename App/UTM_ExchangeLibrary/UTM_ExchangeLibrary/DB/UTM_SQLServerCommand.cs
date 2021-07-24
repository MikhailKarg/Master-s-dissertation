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
    internal class UTM_SQLServerCommand : IUTM_DBCommand
    {
        protected SqlConnection connection;
        protected SqlCommand command;
        public void BuildCommand(string connectionString, string procedureName, int commandTimeout)
        {
            try
            {
                connection = new SqlConnection(connectionString);
                command = new SqlCommand(procedureName, connection);
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = commandTimeout;
            }
            catch { }
        }
        public void AddCommandParameter(string parameterName, string value)
        {
            try
            {
                command.Parameters.Add(new SqlParameter { ParameterName = parameterName, Value = value });
            }
            catch { }
        }
        public List<UTM_ExecutedCommandData> Exec()
        {
            List<UTM_ExecutedCommandData> dataList = new List<UTM_ExecutedCommandData>();
            IDictionary<string, string> row;

            try 
            {
                using (connection)
                {
                    connection.Open();

                    SqlDataReader reader = command.ExecuteReader();

                    if (reader.HasRows)
                    {
                        int fieldCount = reader.FieldCount;

                        while (reader.Read())
                        {
                            row = new Dictionary<string, string>();

                            for (var i = 0; i < fieldCount; i++)
                            {
                                row.Add(reader.GetName(i), (string)reader.GetValue(i));
                            }

                            dataList.Add(new UTM_ExecutedCommandData(row));
                        }
                    }
                }
            }
            catch (Exception ex) { }

            return dataList;
        }
    }
}
