using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace UTM_ExchangeService
{
    [RunInstaller(true)]
    public partial class UTM_ExchangeServiceInstaller : Installer
    {
        ServiceInstaller serviceInstaller;
        ServiceProcessInstaller processInstaller;

        public UTM_ExchangeServiceInstaller()
        {
            InitializeComponent();
            serviceInstaller = new ServiceInstaller();
            processInstaller = new ServiceProcessInstaller();

            processInstaller.Account = ServiceAccount.LocalSystem;
            serviceInstaller.StartType = ServiceStartMode.Manual;
            serviceInstaller.ServiceName = "UTM_ExchangeService";
            serviceInstaller.Description = "Service for transferring information on the turnover and retail sale of alcoholic products from wholesale and retail organizations to the EGAIS db";
            Installers.Add(processInstaller);
            Installers.Add(serviceInstaller);
        }
    }
}
