public class SLT_AMAContractDetail extends fflib_SObjectSelector {

    public static SLT_AMAContractDetail instance {
        get {
            if(instance == null) {
                instance = new SLT_AMAContractDetail();
            }
            return instance;
        }
        set;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
      return new List<Schema.SObjectField>{
          AMA_Contract_Detail__c.Id};
    }

    public Schema.SObjectType getSObjectType() {
        return AMA_Contract_Detail__c.sObjectType;
    }

    public List<AMA_Contract_Detail__c> selectByFilterOnly(String filterCondition){
      return (List<AMA_Contract_Detail__c>)Database.query(newQueryFactory(true).setCondition(filterCondition).toSOQL());

   }

}