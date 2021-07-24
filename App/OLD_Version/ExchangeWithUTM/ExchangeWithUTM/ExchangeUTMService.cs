using System.ServiceProcess;
using System.Threading;

namespace ExchangeUTM
{
    public partial class ExchangeUTMService : ServiceBase
    {
        ExchangeUTM exchangeUTM;
        public ExchangeUTMService()
        {
            InitializeComponent();
            CanStop = true;
            CanPauseAndContinue = true;
            CanShutdown = true;
            AutoLog = true;
        }

        protected override void OnStart(string[] args)
        {
            exchangeUTM = new ExchangeUTM();
            Thread exchangeUTMThread = new Thread(new ThreadStart(exchangeUTM.Start));
            exchangeUTMThread.Start();
        }
        protected override void OnStop()
        {
            exchangeUTM.Stop();
        }
        protected override void OnPause()
        {
            exchangeUTM.Pause();
        }
        protected override void OnContinue()
        {
            exchangeUTM.Continue();
        }
        protected override void OnShutdown()
        {
            exchangeUTM.Shutdown();
        }
    }
}
