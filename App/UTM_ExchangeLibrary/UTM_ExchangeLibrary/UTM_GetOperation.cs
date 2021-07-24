using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary
{
    public class UTM_GetOperation : UTM_HttpOperation
    {
        public UTM_GetOperation(int HTTPTimeout, string URL, string Method = "GET", ICredentials Credentials = null, bool KeepAlive = true, string ContentType = null)
            : base(HTTPTimeout, URL, Method, Credentials, KeepAlive, ContentType) { }

        public override string Exec()
        {
            string result = null;

            using (StreamReader streamReader = new StreamReader(httpWebRequest.GetResponse().GetResponseStream(), Encoding.UTF8))
            {
                result = streamReader.ReadToEnd();
            }

            return result;
        }
    }
}
