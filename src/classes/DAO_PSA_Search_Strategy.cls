/**
* This is Search Strategy trigger DAO class.
* version : 1.0
*/
public class DAO_PSA_Search_Strategy extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<Search_Strategy__c>
     */
    public DAO_PSA_Search_Strategy(List<Search_Strategy__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_PSA_Search_Strategy(sObjectList);
        }
    }
    
     /**
     * This method is used for before update of the Search_Strategy trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_PSA_Search_Strategy.setDefaultFieldsValue((List<Search_Strategy__c>) records, null);        
    }
    
    /**
    * This method is used for before update of the Search_Strategy trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Search_Strategy.setDefaultFieldsValue((List<Search_Strategy__c>) records, (Map<Id,Search_Strategy__c>) existingRecords);        
    }
    
    /**
     * This method is used for after insert of the Search_Strategy trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Search_Strategy.createLRSSRelationshipRecord((List<Search_Strategy__c>)Records, null);
        DAOH_PSA_Search_Strategy.synchronizeProjectEvent((List<Search_Strategy__c>)Records, null);
        DAOH_PSA_Search_Strategy.insertAuditLogOnUpdate((List<Search_Strategy__c>)Records, null);
    }
    /**
     * This method is used for after Update of the Search_Strategy trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Search_Strategy.synchronizeProjectEvent((List<Search_Strategy__c>) records, (Map<Id,Search_Strategy__c>) existingRecords);  
        DAOH_PSA_Search_Strategy.insertAuditLogOnUpdate((List<Search_Strategy__c>)Records, (Map<Id,Search_Strategy__c>) existingRecords);
    }
    
    /**
     * This method is used for after Delete of the Search_Strategy trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Search_Strategy.deleteLRSSRelationshipRecord((List<Search_Strategy__c>)Records, null);
        DAOH_PSA_Search_Strategy.insertAuditLog((List<Search_Strategy__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Event_Journals trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Search_Strategy.insertAuditLog((List<Search_Strategy__c>)Records,'UNDELETE');
    }
}
