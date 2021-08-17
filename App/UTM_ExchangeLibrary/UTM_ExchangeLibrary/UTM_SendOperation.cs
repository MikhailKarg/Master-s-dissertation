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
    public class UTM_SendOperation : UTM_HttpOperation
    {       
        private string Data;
        private string Filename;
        private string Boundary;
        private HttpWebResponse httpWebResponse;
        private IUTM_Log Log;
        public UTM_SendOperation(
            IUTM_Log log,
            int httpTimeout, 
            string url, 
            string data, 
            string filename, 
            string boundary, 
            string method = "POST", 
            ICredentials credentials = null, 
            bool keepAlive = true, 
            string contentType = null)
            : base(log, httpTimeout, url, method, credentials, keepAlive, contentType) 
        {
            Data = data;
            Filename = filename;
            Boundary = boundary;
            Log = log;
        }
        public override string Exec()
        {
            string response = null;

            try
            {
                using (Stream requestStream = httpWebRequest.GetRequestStream())
                {
                    byte[] boundaryBytesBegin = Encoding.ASCII.GetBytes("\r\n--" + Boundary + "\r\n");
                    requestStream.Write(boundaryBytesBegin, 0, boundaryBytesBegin.Length);

                    byte[] headersBytes = Encoding.UTF8.GetBytes(string.Format($"Content-Disposition: form-data; name=\"xml_file\"; filename=\"{Filename}\"\r\nContent-Type: text/xml\r\n\r\n"));
                    requestStream.Write(headersBytes, 0, headersBytes.Length);

                    byte[] bytesContent = Encoding.UTF8.GetBytes(Data);
                    requestStream.Write(bytesContent, 0, bytesContent.Length);

                    byte[] boundaryBytesEnd = Encoding.ASCII.GetBytes("\r\n--" + Boundary + "--\r\n");
                    requestStream.Write(boundaryBytesEnd, 0, boundaryBytesEnd.Length);
                }

                using (httpWebResponse = (HttpWebResponse)httpWebRequest.GetResponse())
                {
                    response = new StreamReader(httpWebResponse.GetResponseStream()).ReadToEnd();
                }
            }
            catch (Exception ex) 
            {
                Log.LogException(ex);
            }

            return response;
        }
    }
}
