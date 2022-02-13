using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Configuration;
using UTM_ExchangeLibrary;
using UTM_ExchangeLibrary.Interfaces;
using UTM_ExchangeLibrary.Log;

namespace UTM_ExchangeUnitTests
{
    [TestClass]
    public class UTMMapperTest
    {
        string logPath = @"";
        string jsonSettingpath = @"";

        [TestMethod]
        public void UTM_LogTest()
        {
            IUTM_Log log = new UTM_Log(logPath, LogLevel.Debug);

            Assert.IsNotNull(log);
        }

        [TestMethod]
        public void UTM_ServiceSettings_LogTest()
        {
            IUTM_Log log = new UTM_Log(logPath, LogLevel.Debug);
            UTM_ServiceSettings ServiceSettings = new UTM_ServiceSettings(jsonSettingpath, log);

            Assert.IsNotNull(ServiceSettings);
        }
    }
}
