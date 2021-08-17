using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary
{
    public abstract class UTM_HttpOperation
    {
        protected HttpWebRequest httpWebRequest;
        protected IUTM_Log Log;
        public UTM_HttpOperation(
            IUTM_Log log,
            int httpTimeout, 
            string url, 
            string method, 
            ICredentials credentials, 
            bool keepAlive, 
            string contentType)
        {
            httpWebRequest = (HttpWebRequest)WebRequest.Create(url);
            httpWebRequest.Timeout = httpTimeout;
            httpWebRequest.ContentType = contentType;
            httpWebRequest.Method = method;
            httpWebRequest.KeepAlive = keepAlive;
            httpWebRequest.Credentials = credentials;

            Log = log;
        }
        public abstract string Exec();
    }
}
