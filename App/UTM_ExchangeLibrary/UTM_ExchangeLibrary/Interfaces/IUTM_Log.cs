using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.Log;

namespace UTM_ExchangeLibrary.Interfaces
{
    public interface IUTM_Log
    {
        void Log(string message);
        void LogException(Exception ex);
    }
}
