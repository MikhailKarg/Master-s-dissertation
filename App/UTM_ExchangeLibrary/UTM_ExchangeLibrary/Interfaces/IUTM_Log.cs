using System;

namespace UTM_ExchangeLibrary.Interfaces
{
    public interface IUTM_Log
    {
        void Log(string message);
        void LogException(Exception ex);
    }
}
