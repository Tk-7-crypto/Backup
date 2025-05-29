public class SLT_TPAOfferingNotificationMapping extends fflib_SObjectSelector {

    public static SLT_TPAOfferingNotificationMapping instance {
        get {
            if(instance == null) {
                instance = new SLT_TPAOfferingNotificationMapping();
            }
            return instance;
        }
        set;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    public Schema.SObjectType getSObjectType() {
        return TPA_Offering_Notification_Mapping__c.sObjectType;
    }

    public List<TPA_Offering_Notification_Mapping__c> selectByFilter(Set<String> fieldSet ,String filterCondition) {
        return (List<TPA_Offering_Notification_Mapping__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }

    public List<TPA_Offering_Notification_Mapping__c> getTPAOfferingNotificationMappingDataById(String id, Set<String> fieldSet){
    return (List<TPA_Offering_Notification_Mapping__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('id = \'' + id + '\' ').toSOQL());
  }

  public List<TPA_Offering_Notification_Mapping__c> selectWithLineItems(Set<String> fieldSet, Set<String> childFieldSet){
      fflib_QueryFactory query = newQueryFactory(true).selectFields(fieldSet);

      new SLT_TPAOffNotificationAccountMapping().
            addQueryFactorySubselect(query,'TPA_Off_Notification_Account_Mapping__r').selectFields(childFieldSet);

      return (List<TPA_Offering_Notification_Mapping__c>) Database.query( query.toSOQL() );
   }

}