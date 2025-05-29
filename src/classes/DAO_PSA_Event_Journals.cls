public class DAO_PSA_Event_Journals extends fflib_SObjectDomain{

    
    /**
     * Constructor of this class
     * @params sObjectList List<Search_Strategy__c>
     */
    public DAO_PSA_Event_Journals(List<Event_Journals__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_PSA_Event_Journals(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Event_Journals trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Event_Journals.createLREJRelationshipRecord((List<Event_Journals__c>)Records, null);
        DAOH_PSA_Event_Journals.insertAuditLogOnUpdate((List<Event_Journals__c>)Records, null);
    }
    
    /**
    * This method is used for before insert of the Event_Journals trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_PSA_Event_Journals.setDefaultFieldsValueOfReviewDate((List<Event_Journals__c>) records, null);        
    }
    
    /**
    * This method is used for before update of the Event_Journals trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Event_Journals.setDefaultFieldsValue((List<Event_Journals__c>) records, (Map<Id,Event_Journals__c>) existingRecords);  
        DAOH_PSA_Event_Journals.setDefaultFieldsValueOfReviewDate((List<Event_Journals__c>) records, (Map<Id,Event_Journals__c>) existingRecords);  
    }
    
    /**
     * This method is used for after update of the Event_Journals trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Event_Journals.insertAuditLogOnUpdate((List<Event_Journals__c>)Records, (Map<Id,Event_Journals__c>) existingRecords);
    }
    
    /**
     * This method is used for after Delete of the Event_Journals trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Event_Journals.deleteLREJRelationshipRecord((List<Event_Journals__c>)Records, null);
        DAOH_PSA_Event_Journals.insertAuditLog((List<Event_Journals__c>)Records,'DELETE');
    }
    
    /**
     * This method is used for after undelete of the Event_Journals trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Event_Journals.insertAuditLog((List<Event_Journals__c>)Records,'UNDELETE');
    }
  
}
