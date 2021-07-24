using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary
{
    public class UTM : UTM_Object
    {
        public string IP { get; set; }
        public bool IsActive { get; set; }
        public static UTMBuilder GetBuilder()
        {
            return new UTMBuilder();
        }
    }
}
