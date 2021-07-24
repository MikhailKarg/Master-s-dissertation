using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.DB;

namespace UTM_ExchangeLibrary.Interfaces
{
    public interface IUTM_DBCommand
    {
        void BuildCommand(string connectionString, string procedureName, int commandTimeout);
        void AddCommandParameter(string parameterName, string value);
        List<UTM_ExecutedCommandData> Exec();
    }
}
