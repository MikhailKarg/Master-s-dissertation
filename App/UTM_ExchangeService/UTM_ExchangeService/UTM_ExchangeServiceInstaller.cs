using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.Linq;
using System.Threading.Tasks;

namespace UTM_ExchangeService
{
    [RunInstaller(true)]
    public partial class UTM_ExchangeServiceInstaller : System.Configuration.Install.Installer
    {
        public UTM_ExchangeServiceInstaller()
        {
            InitializeComponent();
        }
    }
}
