/**
 * This is Responsibilities and Maintenance (Responsibilities_and_Maintenance__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Responsibilities_and_Maint extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Responsibilities_and_Maintenance__c>
     */
    public DAO_Responsibilities_and_Maint(List<Responsibilities_and_Maintenance__c> sObjectList) {
        super(sObjectList);

        // methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    } 

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Responsibilities_and_Maint(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Responsibilities_and_Maintenance__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Responsibilities_and_Maint.insertAuditLogOnUpdate((List<Responsibilities_and_Maintenance__c>)Records, null);
    }

    /**
     * This method is used for after update of the Responsibilities_and_Maintenance__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_Responsibilities_and_Maint.insertAuditLogOnUpdate((List<Responsibilities_and_Maintenance__c>)Records, (Map<Id,Responsibilities_and_Maintenance__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the Project Contact (Responsibilities_and_Maintenance__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_Responsibilities_and_Maint.insertAuditLog((List<Responsibilities_and_Maintenance__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Project Contact (Responsibilities_and_Maintenance__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_Responsibilities_and_Maint.insertAuditLog((List<Responsibilities_and_Maintenance__c>)Records,'UNDELETE');
    }
}