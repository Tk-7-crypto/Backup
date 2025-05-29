/**
 * This is RA Feedback (RA_Feedback__c) trigger handler class.
 * version : 1.0
 */
public class DAO_RA_Feedback extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<RA_Feedback__c>
     */
    public DAO_RA_Feedback(List<RA_Feedback__c> sObjectList) {
        super(sObjectList);

    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_RA_Feedback(sObjectList);
        } 
    }
    
    /**
     * This method is used for after insert of the RA_Feedback__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_RA_Feedback.insertAuditLogOnUpdate((List<RA_Feedback__c>)Records, null);
    }

    /**
     * This method is used for after update of the RA_Feedback__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_RA_Feedback.insertAuditLogOnUpdate((List<RA_Feedback__c>)Records, (Map<Id,RA_Feedback__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the RA_Feedback__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_RA_Feedback.insertAuditLog((List<RA_Feedback__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the RA_Feedback__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_RA_Feedback.insertAuditLog((List<RA_Feedback__c>)Records,'UNDELETE');
    }
}