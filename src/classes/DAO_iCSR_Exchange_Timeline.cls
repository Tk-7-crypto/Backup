/**
 * This is iCSR Exchange Timeline (iCSR_Exchange_Timeline__c) trigger handler class.
 * version : 1.0
 */
public class DAO_iCSR_Exchange_Timeline extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<iCSR_Exchange_Timeline__c>
     */
    public DAO_iCSR_Exchange_Timeline(List<iCSR_Exchange_Timeline__c> sObjectList) {
        super(sObjectList);

        // methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    } 

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_iCSR_Exchange_Timeline(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the iCSR_Exchange_Timeline__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_iCSR_Exchange_Timeline.insertAuditLogOnUpdate((List<iCSR_Exchange_Timeline__c>)Records, null);
    }

    /**
     * This method is used for after update of the iCSR_Exchange_Timeline__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_PSA_iCSR_Exchange_Timeline.insertAuditLogOnUpdate((List<iCSR_Exchange_Timeline__c>)Records, (Map<Id,iCSR_Exchange_Timeline__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the iCSR Exchange Timeline (iCSR_Exchange_Timeline__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_iCSR_Exchange_Timeline.insertAuditLog((List<iCSR_Exchange_Timeline__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the iCSR Exchange Timeline (iCSR_Exchange_Timeline__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_iCSR_Exchange_Timeline.insertAuditLog((List<iCSR_Exchange_Timeline__c>)Records,'UNDELETE');
    }
}