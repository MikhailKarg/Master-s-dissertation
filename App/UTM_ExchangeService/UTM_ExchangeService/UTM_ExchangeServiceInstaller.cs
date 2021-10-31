using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace UTM_ExchangeService
{
    [RunInstaller(true)]
    public partial class UTM_ExchangeServiceInstaller : Installer
    {
        ServiceInstaller ServiceInstaller;
        ServiceProcessInstaller ProcessInstaller;

        public UTM_ExchangeServiceInstaller()
        {
            InitializeComponent();
            ServiceInstaller = new ServiceInstaller();
            ProcessInstaller = new ServiceProcessInstaller();

            ProcessInstaller.Account = ServiceAccount.LocalSystem;
            ServiceInstaller.StartType = ServiceStartMode.Manual;
            ServiceInstaller.ServiceName = "UTM_ExchangeService";
            ServiceInstaller.Description = "Service for transferring information on the turnover and retail sale of alcoholic products from wholesale and retail organizations to the EGAIS db";
            Installers.Add(ProcessInstaller);
            Installers.Add(ServiceInstaller);
        }
    }
}
