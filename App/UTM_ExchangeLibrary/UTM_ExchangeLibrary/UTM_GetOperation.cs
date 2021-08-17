using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary
{
    public class UTM_GetOperation : UTM_HttpOperation
    {
        private IUTM_Log Log;
        public UTM_GetOperation(
            IUTM_Log log,
            int HTTPTimeout, 
            string URL, 
            string Method = "GET", 
            ICredentials Credentials = null, 
            bool KeepAlive = true, 
            string ContentType = null)
            : base(log, HTTPTimeout, URL, Method, Credentials, KeepAlive, ContentType) 
        {
            Log = log;
        }

        public override string Exec()
        {
            string result = null;

            try
            {
                using (StreamReader streamReader = new StreamReader(httpWebRequest.GetResponse().GetResponseStream(), Encoding.UTF8))
                {
                    result = streamReader.ReadToEnd();
                }
            }
            catch (Exception ex) 
            {
                Log.LogException(ex);
            }

            return result;
        }
    }
}
