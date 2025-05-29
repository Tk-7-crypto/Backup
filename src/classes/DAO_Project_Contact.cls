/**
 * This is Project Contact (Project_Contact__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Project_Contact extends fflib_SObjectDomain {
     
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();
 
    /**
     * Constructor of this class
     * @params sObjectList List<Project_Contact__c>
     */
    public DAO_Project_Contact(List<Project_Contact__c> sObjectList) {
        super(sObjectList);

        // methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Project_Contact(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Project_Contact__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Project_Contact.insertAuditLogOnUpdate((List<Project_Contact__c>)Records, null);
    }

    /**
     * This method is used for after update of the Project_Contact__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_PSA_Project_Contact.insertAuditLogOnUpdate((List<Project_Contact__c>)Records, (Map<Id,Project_Contact__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the Project Contact (Project_Contact__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Project_Contact.insertAuditLog((List<Project_Contact__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Project Contact (Project_Contact__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Project_Contact.insertAuditLog((List<Project_Contact__c>)Records,'UNDELETE');
    }
}