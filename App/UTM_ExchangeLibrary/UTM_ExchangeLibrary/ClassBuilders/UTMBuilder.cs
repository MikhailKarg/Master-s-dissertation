using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary
{
    public class UTMBuilder : IUTM_ObjectBuilder
    {
        private UTM utm;

        public UTMBuilder()
        {
            utm = new UTM();
        }
        public IUTM_ObjectBuilder SetId(int id)
        {
            utm.Id = id;
            return this;
        }
        public IUTM_ObjectBuilder SetIP(string ip)
        {
            utm.IP = ip;
            return this;
        }
        public IUTM_ObjectBuilder SetActive(bool isActive)
        {
            utm.IsActive = isActive;
            return this;
        }
        public UTM_Object Build()
        {
            return utm;
        }
    }
}
