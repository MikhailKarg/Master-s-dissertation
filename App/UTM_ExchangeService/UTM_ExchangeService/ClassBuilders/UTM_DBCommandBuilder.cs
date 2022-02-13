using UTM_ExchangeLibrary.DB;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeService.ClassBuilders
{
    public class UTM_DBCommandBuilder
    {
        IUTM_DBCommand DBCommand { get; }
        static UTM_DBCommandBuilder DBCommandBuilder;

        protected UTM_DBCommandBuilder()
        {
            DBCommand = new UTM_SQLServerCommand();
        }

        public static IUTM_DBCommand GetDBCommand()
        {
            if (DBCommandBuilder == null)
            {
                DBCommandBuilder = new UTM_DBCommandBuilder();
            }

            return DBCommandBuilder.DBCommand;
        }
    }
}
