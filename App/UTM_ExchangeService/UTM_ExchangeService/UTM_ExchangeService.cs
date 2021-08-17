using System.ServiceProcess;
using System.Threading;

namespace UTM_ExchangeService
{
    public partial class UTM_ExchangeService : ServiceBase
    {
        UTM_ExchangeServiceBroker ExchangeServiceBroker;
        public UTM_ExchangeService()
        {
            InitializeComponent();
            CanStop = true;
            CanPauseAndContinue = true;
            CanShutdown = true;
            AutoLog = true;
        }

        protected override void OnStart(string[] args)
        {
            ExchangeServiceBroker = new UTM_ExchangeServiceBroker();
            Thread exchangeServiceBrokerThread = new Thread(new ThreadStart(ExchangeServiceBroker.Start));
            exchangeServiceBrokerThread.Start();
        }
        protected override void OnStop()
        {
            ExchangeServiceBroker.Stop();
        }
        protected override void OnPause()
        {
            ExchangeServiceBroker.Pause();
        }
        protected override void OnContinue()
        {
            ExchangeServiceBroker.Continue();
        }
        protected override void OnShutdown()
        {
            ExchangeServiceBroker.Shutdown();
        }
    }
}
