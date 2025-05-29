/**
 * This is RA Request (RA_Request__c) trigger handler class.
 * version : 1.0
 */
public class DAO_RA_Request extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<RA_Request__c>
     */
    public DAO_RA_Request(List<RA_Request__c> sObjectList) {
        super(sObjectList);

    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_RA_Request(sObjectList);
        } 
    }
    
    /**
     * This method is used for after insert of the RA_Request__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_RA_Request.insertAuditLogOnUpdate((List<RA_Request__c>)Records, null);
    }

    /**
     * This method is used for after update of the RA_Request__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_RA_Request.insertAuditLogOnUpdate((List<RA_Request__c>)Records, (Map<Id,RA_Request__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the RA_Request__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_RA_Request.insertAuditLog((List<RA_Request__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the RA_Request__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_RA_Request.insertAuditLog((List<RA_Request__c>)Records,'UNDELETE');
    }
}