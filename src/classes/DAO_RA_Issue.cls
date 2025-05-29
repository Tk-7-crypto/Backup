/**
 * This is RA Issue (RA_Issue__c) trigger handler class.
 * version : 1.0
 */
public class DAO_RA_Issue extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<RA_Issue__c>
     */
    public DAO_RA_Issue(List<RA_Issue__c> sObjectList) {
        super(sObjectList);

    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_RA_Issue(sObjectList);
        } 
    }
    
    /**
     * This method is used for after insert of the RA_Issue__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_RA_Issue.insertAuditLogOnUpdate((List<RA_Issue__c>)Records, null);
    }

    /**
     * This method is used for after update of the RA_Issue__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_RA_Issue.insertAuditLogOnUpdate((List<RA_Issue__c>)Records, (Map<Id,RA_Issue__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the RA_Issue__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_RA_Issue.insertAuditLog((List<RA_Issue__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the RA_Issue__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_RA_Issue.insertAuditLog((List<RA_Issue__c>)Records,'UNDELETE');
    }
}