using System.ServiceProcess;


namespace ExchangeUTM
{
    static class Program
    {
        /// <summary>
        /// Главная точка входа для приложения.
        /// </summary>
        static void Main()
        {
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[]
            {
                new ExchangeUTMService()
            };
            ServiceBase.Run(ServicesToRun);
        }
    }
}
