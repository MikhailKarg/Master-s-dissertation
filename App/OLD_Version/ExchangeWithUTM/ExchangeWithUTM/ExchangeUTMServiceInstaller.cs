using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace ExchangeUTM
{
    [RunInstaller(true)]
    public partial class ExchangeUTMServiceInstaller : Installer
    {
        ServiceInstaller serviceInstaller;
        ServiceProcessInstaller processInstaller;

        public ExchangeUTMServiceInstaller()
        {
            InitializeComponent();
            serviceInstaller = new ServiceInstaller();
            processInstaller = new ServiceProcessInstaller();

            processInstaller.Account = ServiceAccount.LocalSystem;
            serviceInstaller.StartType = ServiceStartMode.Manual;
            serviceInstaller.ServiceName = "ExchangeUTMService";           
            serviceInstaller.Description = "Service for transferring information on the turnover and retail sale of alcoholic products from wholesale and retail organizations to the EGAIS db";
            Installers.Add(processInstaller);
            Installers.Add(serviceInstaller);
        }
    }
}
