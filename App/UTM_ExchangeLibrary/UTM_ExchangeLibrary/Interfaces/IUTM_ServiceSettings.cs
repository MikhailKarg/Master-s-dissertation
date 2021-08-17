using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary.Interfaces
{
    public interface IUTM_ServiceSettings 
    {
        string GetServiceSetting(string settingName);
    }
}
