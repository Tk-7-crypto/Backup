/**
 * This is Partner Contact (Partner_Contact__c) trigger handler class.
 * version : 1.0 
 */
public class DAO_Partner_Contact extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Partner_Contact__c>
     */
    public DAO_Partner_Contact(List<Partner_Contact__c> sObjectList) {
        super(sObjectList);

    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Partner_Contact(sObjectList);
        } 
    }
    
     /**
     * This method is used for before of the Partner_Contact__c  trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_PSA_Partner_Contact.setDeactivatedDate((List<Partner_Contact__c>)Records, null);
    }
    
     /**
     * This method is used for before update of the Partner_Contact__c  trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Partner_Contact.setDeactivatedDate((List<Partner_Contact__c>)Records, (Map<Id,Partner_Contact__c>) existingRecords);
    }
    
    /**
     * This method is used for after insert of the Partner_Contact__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Partner_Contact.insertAuditLogOnUpdate((List<Partner_Contact__c>)Records, null);
    }

    /**
     * This method is used for after update of the Partner_Contact__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Partner_Contact.insertAuditLogOnUpdate((List<Partner_Contact__c>)Records, (Map<Id,Partner_Contact__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the Partner_Contact__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Partner_Contact.insertAuditLog((List<Partner_Contact__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Partner_Contact__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Partner_Contact.insertAuditLog((List<Partner_Contact__c>)Records,'UNDELETE');
    }
}