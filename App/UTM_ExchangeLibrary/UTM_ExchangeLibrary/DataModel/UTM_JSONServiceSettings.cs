using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary
{
    public class UTM_JSONServiceSettings
    {
        public string ConnectionString { get; set; }
        public int SqlCommandTimeout { get; set; }
        public string GetSettingProcedure { get; set; }
    }
}
