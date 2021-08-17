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
        void BuildCommand(IUTM_ServiceSettings serviceSettings, string sqlExpression, IUTM_Log log);
        void AddCommandParameter(string parameterName, string value);
        List<UTM_ExecutedCommandData> Exec();
    }
}
