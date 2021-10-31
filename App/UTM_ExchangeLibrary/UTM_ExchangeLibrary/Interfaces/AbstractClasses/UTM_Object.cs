
namespace UTM_ExchangeLibrary
{
    public abstract class UTM_Object
    {
        public int Id { get; set; }
        public string ConnectionString { get; set; }
        public string SqlExpression { get; set; }
        public int SqlCommandTimeout { get; set; }
    }
}
