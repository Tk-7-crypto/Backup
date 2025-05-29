public class SLT_TPAOffNotificationAccountMapping extends fflib_SObjectSelector {

    public static SLT_TPAOffNotificationAccountMapping instance {
        get {
            if(instance == null) {
                instance = new SLT_TPAOffNotificationAccountMapping();
            }
            return instance;
        }
        set;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            TPA_Off_Notification_Account_Mapping__c.Id,
            TPA_Off_Notification_Account_Mapping__c.Vendor_Account_Address__c };
    }

    public Schema.SObjectType getSObjectType() {
        return TPA_Off_Notification_Account_Mapping__c.sObjectType;
    }

    public List<TPA_Off_Notification_Account_Mapping__c> selectByFilter(Set<String> fieldSet ,String filterCondition) {
        return (List<TPA_Off_Notification_Account_Mapping__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }

    public List<TPA_Off_Notification_Account_Mapping__c> selectFieldsSetById(Set<String> fieldSet, Set<Id> recordIds){
      return (List<TPA_Off_Notification_Account_Mapping__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :recordIds').toSOQL());
   }

    public List<TPA_Off_Notification_Account_Mapping__c> selectById(Set<Id> recordIds){
      return (List<TPA_Off_Notification_Account_Mapping__c>) selectSObjectsById(recordIds);
   }

   public List<TPA_Off_Notification_Account_Mapping__c> selectByFilterOnly(String filterCondition){
     return (List<TPA_Off_Notification_Account_Mapping__c>)Database.query(newQueryFactory(true).setCondition(filterCondition).toSOQL());

  }

}