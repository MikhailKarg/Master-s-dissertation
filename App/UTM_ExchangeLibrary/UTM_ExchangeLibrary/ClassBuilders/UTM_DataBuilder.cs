using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary
{
    public class UTM_DataBuilder : IUTM_ObjectBuilder
    {
        private UTM_Data UTM_Data;
        public UTM_DataBuilder()
        {
            UTM_Data = new UTM_Data();
        }
        public UTM_DataBuilder SetId(int id)
        {
            UTM_Data.Id = id;
            return this;
        }
        public UTM_DataBuilder SetURL(string url)
        {
            UTM_Data.URL = url;
            UTM_Data.ExchangeTypeCode = GetExchangeTypeCodeFromURL(url);
            return this;
        }
        public UTM_DataBuilder SetReply_Id(string reply_Id)
        {
            UTM_Data.Reply_Id = reply_Id;
            return this;
        }
        public UTM_DataBuilder SetData(string data)
        {
            UTM_Data.Data = data;
            return this;
        }
        public UTM_DataBuilder SetDataGUID(string dataGUID)
        {
            UTM_Data.DataGUID = dataGUID;
            return this;
        }
        public UTM_DataBuilder SetExchangeTypeCode(string exchangeTypeCode)
        {
            UTM_Data.ExchangeTypeCode = exchangeTypeCode;
            return this;
        }
        public UTM_DataBuilder SetUTM_Id(int utm_Id)
        {
            UTM_Data.UTM_Id = utm_Id;
            return this;
        }
        public UTM_Object Build()
        {
            return UTM_Data;
        }
        protected string GetExchangeTypeCodeFromURL(string url)
        {
            try
            {
                char s = '/';

                int index = url.LastIndexOf(s);
                string interim = url.Remove(index);
                index = interim.LastIndexOf(s);

                return interim.Substring(++index);
            }
            catch 
            {
                return null;
            }
        }
    }
}
