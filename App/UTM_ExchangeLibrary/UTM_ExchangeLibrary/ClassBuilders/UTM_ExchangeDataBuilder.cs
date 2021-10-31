
namespace UTM_ExchangeLibrary
{
    public class UTM_ExchangeDataBuilder : IUTM_ObjectBuilder
    {
        private UTM_ExchangeData UTM_ExchangeData;
        public UTM_ExchangeDataBuilder()
        {
            UTM_ExchangeData = new UTM_ExchangeData();
        }
        public UTM_ExchangeDataBuilder SetId(int id)
        {
            UTM_ExchangeData.Id = id;
            return this;
        }
        public UTM_ExchangeDataBuilder SetURL(string url)
        {
            UTM_ExchangeData.URL = url;
            UTM_ExchangeData.ExchangeTypeCode = GetExchangeTypeCodeFromURL(url);
            return this;
        }
        public UTM_ExchangeDataBuilder SetReply_Id(string reply_Id)
        {
            UTM_ExchangeData.Reply_Id = reply_Id;
            return this;
        }
        public UTM_ExchangeDataBuilder SetData(string data)
        {
            UTM_ExchangeData.Data = data;
            return this;
        }
        public UTM_ExchangeDataBuilder SetDataGUID(string dataGUID)
        {
            UTM_ExchangeData.DataGUID = dataGUID;
            return this;
        }
        public UTM_ExchangeDataBuilder SetExchangeTypeCode(string exchangeTypeCode)
        {
            UTM_ExchangeData.ExchangeTypeCode = exchangeTypeCode;
            return this;
        }
        public UTM_ExchangeDataBuilder SetUTM_Id(int utm_Id)
        {
            UTM_ExchangeData.UTM_Id = utm_Id;
            return this;
        }
        public UTM_Object Build()
        {
            return UTM_ExchangeData;
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
