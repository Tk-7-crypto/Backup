/**
 * This is Agreement Notes (Agreement_Notes__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Agreement_Notes extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Agreement_Notes__c>
     */
    public DAO_Agreement_Notes(List<Agreement_Notes__c> sObjectList) {
        super(sObjectList);

        // methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    } 

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Agreement_Notes(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Agreement_Notes__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Agreement_Notes.insertAuditLogOnUpdate((List<Agreement_Notes__c>)Records, null);
    }

    /**
     * This method is used for after update of the Agreement_Notes__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_PSA_Agreement_Notes.insertAuditLogOnUpdate((List<Agreement_Notes__c>)Records, (Map<Id,Agreement_Notes__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the Agreement Notes (Agreement_Notes__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Agreement_Notes.insertAuditLog((List<Agreement_Notes__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Agreement Notes (Agreement_Notes__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Agreement_Notes.insertAuditLog((List<Agreement_Notes__c>)Records,'UNDELETE');
    }
}