/**
 * This is Project_Log__c (Project_Log__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Project_Log extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Project_Log__c>
     */
    public DAO_Project_Log(List<pse__Proj__c> sObjectList) {
        super(sObjectList);

        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Project_Log(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Project_Log__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Project_Log.insertAuditLogOnUpdate((List<Project_Log__c>)Records, null);
    }

    /**
     * This method is used for after update of the Project_Log__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_PSA_Project_Log.insertAuditLogOnUpdate((List<Project_Log__c>)Records, (Map<Id,Project_Log__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the Project Log (Project_Log__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Project_Log.projectLogValidationsRDS((List<Project_Log__c>)Records, null);
        DAOH_PSA_Project_Log.insertAuditLog((List<Project_Log__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Project Log (Project_Log__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Project_Log.insertAuditLog((List<Project_Log__c>)Records,'UNDELETE');
    }
}