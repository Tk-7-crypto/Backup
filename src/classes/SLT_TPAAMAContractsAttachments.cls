public class SLT_TPAAMAContractsAttachments extends fflib_SObjectSelector {

    public static SLT_TPAAMAContractsAttachments instance {
        get {
            if(instance == null) {
                instance = new SLT_TPAAMAContractsAttachments();
            }
            return instance;
        }
        set;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
      return new List<Schema.SObjectField>{
          TPA_Off_Notification_Account_Mapping__c.Id};
    }

    public Schema.SObjectType getSObjectType() {
        return AMA_Contracts_Attachments__c.sObjectType;
    }

    public List<AMA_Contracts_Attachments__c> selectByFilter(Set<String> fieldSet ,String filterCondition) {
        return (List<AMA_Contracts_Attachments__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }

    public List<AMA_Contracts_Attachments__c> selectByFilterOnly(String filterCondition){
      return (List<AMA_Contracts_Attachments__c>)Database.query(newQueryFactory(true).setCondition(filterCondition).toSOQL());

   }

   public List<AMA_Contracts_Attachments__c> selectByFilterWithLimit(String filterCondition, Integer recordLimit){
     return (List<AMA_Contracts_Attachments__c>)Database.query(newQueryFactory(true).setCondition(filterCondition).setLimit(recordLimit).toSOQL());
  }

}