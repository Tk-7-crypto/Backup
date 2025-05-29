/**
 * This is Reconciliation (Reconciliation__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Reconciliation extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Reconciliation__c>
     */
    public DAO_Reconciliation(List<Reconciliation__c> sObjectList) {
        super(sObjectList);

        // methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Reconciliation(sObjectList);
        } 
    }
    
    /**
     * This method is used for after insert of the Reconciliation__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Reconciliation.insertAuditLogOnUpdate((List<Reconciliation__c>)Records, null);
    }

    /**
     * This method is used for after update of the Reconciliation__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_PSA_Reconciliation.insertAuditLogOnUpdate((List<Reconciliation__c>)Records, (Map<Id,Reconciliation__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the Reconciliation (Reconciliation__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Reconciliation.insertAuditLog((List<Reconciliation__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Reconciliation (Reconciliation__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Reconciliation.insertAuditLog((List<Reconciliation__c>)Records,'UNDELETE');
    }
}