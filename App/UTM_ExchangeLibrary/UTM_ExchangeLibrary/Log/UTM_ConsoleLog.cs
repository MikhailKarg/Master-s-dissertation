using System;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeLibrary.Log
{
    public class UTM_ConsoleLog : IUTM_Log
    {
        public void Log(string message)
        {
            Console.WriteLine("******************** " + DateTime.Now);
            Console.WriteLine(" ********************");

            Console.WriteLine(message);
        }

        public void LogException(Exception ex)
        {
            Console.WriteLine("******************** " + DateTime.Now);
            Console.WriteLine(" ********************");

            if (ex.InnerException != null)
            {
                Console.Write("Inner Exception Type: ");
                Console.WriteLine(ex.InnerException.GetType().ToString());
                Console.Write("Inner Exception: ");
                Console.WriteLine(ex.InnerException.Message);
                Console.Write("Inner Source: ");
                Console.WriteLine(ex.InnerException.Source);

                if (ex.InnerException.StackTrace != null)
                {
                    Console.Write("Inner Stack Trace: ");
                    Console.WriteLine(ex.InnerException.StackTrace);
                }
            }

            Console.Write("Exception Type: ");
            Console.WriteLine(ex.GetType().ToString());
            Console.WriteLine("Exception: " + ex.Message);
            Console.WriteLine("Source: " + ex.Source);
            Console.WriteLine("Stack Trace: ");

            if (ex.StackTrace != null)
            {
                Console.WriteLine(ex.StackTrace);
            }
        }
    }
}
