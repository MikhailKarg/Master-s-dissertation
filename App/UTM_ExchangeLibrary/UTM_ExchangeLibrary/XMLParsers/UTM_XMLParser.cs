using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.XMLParsers
{
    internal class UTM_XMLParser
    {
        internal static string ParseResponseFromUTM(string response, IUTM_Log log)
        {
            string result = null;

            if (!string.IsNullOrWhiteSpace(response))
            {
                try
                {
                    XDocument xdoc = XDocument.Parse(response);
                    result = xdoc.Root.Element("url")?.Value;
                }
                catch (Exception ex)
                {
                    log.LogException(ex);
                }
            }

            return result;
        }
        internal static List<UTM_Data> ParseResponsesFromUTM(string response, IUTM_Log log)
        {
            List<UTM_Data> UTM_DataList = new List<UTM_Data>();

            if (!string.IsNullOrWhiteSpace(response))
            {
                try
                {
                    XDocument xdoc = XDocument.Parse(response);
                    
                    foreach (var i in xdoc.Element("A").Elements("url"))
                    {
                        XAttribute AttrReplyId = i.Attribute("replyId");

                        string replyId = null;
                        string url = null;

                        if (AttrReplyId != null)
                        {
                            replyId = AttrReplyId.Value;
                            url = i.Value;
                        }

                        UTM_DataList.Add((UTM_Data)UTM_Data.GetBuilder().SetURL(url).SetReply_Id(replyId).Build());
                    }
                }
                catch (Exception ex)
                {
                    log.LogException(ex);
                }
            }

            return UTM_DataList;
        }
    }
}
