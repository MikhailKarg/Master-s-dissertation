using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary.DB
{
    public class UTM_ExecutedCommandData
    {
        public IDictionary<string, string> Data { get; set; }
        public UTM_ExecutedCommandData(IDictionary<string, string> data)
        {
            Data = data;
        }
    }
}
