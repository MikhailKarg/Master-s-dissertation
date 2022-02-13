using UTM_ExchangeLibrary;
using UTM_ExchangeLibrary.Interfaces;

namespace UTM_ExchangeService.ClassBuilders
{
    public class UTM_ExchangeBuilder
    {
        UTM_Exchange Exchange { get; }
        static UTM_ExchangeBuilder ExchangeBuilder;
        protected UTM_ExchangeBuilder(IUTM_ServiceSettings settings, IUTM_Log serviceLog, IUTM_DBCommand dbCommand)
        {
            Exchange = new UTM_Exchange(settings, serviceLog, dbCommand);
        }

        public static UTM_Exchange GetExchange(IUTM_ServiceSettings settings, IUTM_Log serviceLog, IUTM_DBCommand dbCommand)
        {
            if (ExchangeBuilder == null)
            {
                ExchangeBuilder = new UTM_ExchangeBuilder(settings, serviceLog, dbCommand);
            }

            return ExchangeBuilder.Exchange;
        }
    }
}
