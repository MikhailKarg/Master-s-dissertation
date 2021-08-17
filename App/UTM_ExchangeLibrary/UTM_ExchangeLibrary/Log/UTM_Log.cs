using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.Log
{
    public class UTM_Log : IUTM_Log
    {
        private DirectoryInfo Directory;
        private object LogLocker = new object();
        private string LogPath;
        private LogLevel LogLevel;

        public UTM_Log(string logPath, LogLevel logLevel)
        {
            if (!string.IsNullOrWhiteSpace(logPath))
            {
                LogPath = logPath;
            }
            else 
            {
                LogPath = Path.GetTempPath();
            }

            Directory = new DirectoryInfo(LogPath);

            if (!Directory.Exists)
            {
                Directory.Create();
            }

            LogPath += @"\UTM_Log_" + DateTime.Today.ToShortDateString() + ".txt";
            LogLevel = logLevel;
        }
        public void Log(string message) 
        {
            lock (LogLocker)
            {
                using (StreamWriter sw = new StreamWriter(LogPath, true, Encoding.UTF8))
                {
                    sw.Write("******************** " + DateTime.Now);
                    sw.WriteLine(" ********************");

                    sw.WriteLine(LogLevel.ToString() + ":");
                    sw.WriteLine(message);

                    sw.WriteLine();
                }
            }
        }

        public void LogException(Exception ex)
        {
            lock (LogLocker)
            {
                using (StreamWriter sw = new StreamWriter(LogPath, true, Encoding.UTF8))
                {
                    sw.Write("******************** " + DateTime.Now);
                    sw.WriteLine(" ********************");
                    sw.WriteLine(LogLevel.ToString() + ":");

                    if (LogLevel == LogLevel.Debug)
                    {
                        if (ex.InnerException != null)
                        {
                            sw.Write("Inner Exception Type: ");
                            sw.WriteLine(ex.InnerException.GetType().ToString());
                            sw.Write("Inner Exception: ");
                            sw.WriteLine(ex.InnerException.Message);
                            sw.Write("Inner Source: ");
                            sw.WriteLine(ex.InnerException.Source);

                            if (ex.InnerException.StackTrace != null)
                            {
                                sw.WriteLine("Inner Stack Trace: ");
                            }

                            sw.WriteLine(ex.InnerException.StackTrace);
                        }

                        sw.Write("Exception Type: ");
                        sw.WriteLine(ex.GetType().ToString());
                        sw.WriteLine("Exception: " + ex.Message);
                        sw.WriteLine("Source: " + ex.Source);
                        sw.WriteLine("Stack Trace: ");

                        if (ex.StackTrace != null)
                        {
                            sw.WriteLine(ex.StackTrace);
                        }
                    }
                    else 
                    {
                        sw.WriteLine("Exception: " + ex.Message);
                    }
           
                    sw.WriteLine();
                }
            }
        }
    }
}
