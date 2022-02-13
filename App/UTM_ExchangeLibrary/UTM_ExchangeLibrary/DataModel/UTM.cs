using System;
using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;
using UTM_ExchangeLibrary.Interfaces.AbstractClasses;

namespace UTM_ExchangeLibrary
{
    public class UTM : UTM_Object
    {
        public string IP { get; set; }
        public string TransferProtocol { get; set; }
        public byte IsActive { get; set; }
        public void SetUTMState(IUTM_ServiceSettings serviceSettings, IUTM_Log log, IUTM_DBCommand dbCommand) 
        {
            string SqlExpression = "proc_SetUTMState";

            IUTM_DBCommand SetUTMStateCommand = dbCommand;

            SetUTMStateCommand.BuildCommand(serviceSettings, SqlExpression, log);
            SetUTMStateCommand.AddCommandParameter("UTM_Id", Convert.ToString(Id));
            SetUTMStateCommand.AddCommandParameter("IsActive", Convert.ToString(IsActive));

            SetUTMStateCommand.Exec();
        }
        public static UTMBuilder GetBuilder()
        {
            return new UTMBuilder();
        }
    }
}
