using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace UTM_ExchangeLibrary
{
    public abstract class UTM_HttpOperation
    {
        protected HttpWebRequest httpWebRequest;
        public UTM_HttpOperation(int httpTimeout, string url, string method, ICredentials credentials, bool keepAlive, string contentType)
        {
            httpWebRequest = (HttpWebRequest)WebRequest.Create(url);
            httpWebRequest.Timeout = httpTimeout;
            httpWebRequest.ContentType = contentType;
            httpWebRequest.Method = method;
            httpWebRequest.KeepAlive = keepAlive;
            httpWebRequest.Credentials = credentials;
        }
        public abstract string Exec();
    }
}
