public class DAO_Drug extends fflib_SObjectDomain{
    /**
     * Constructor of this class
     * @params sObjectList List<Drug__c>
     */
    public DAO_Drug(List<Drug__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Drug(sObjectList);
        } 
    }
    
     /**
     * This method is used for before insert of the Drug__c  trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Drug.preventDuplicateRecords((List<Drug__c>)Records, null);
    }

     /**
     * This method is used for after insert of the Drug__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Drug.insertAuditLogOnUpdate((List<Drug__c>)Records, null);
    }

     /**
     * This method is used for before update of the Drug__c  trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Drug.preventDuplicateRecords((List<Drug__c>)Records, (Map<Id,Drug__c>) existingRecords);
        /*
         *IQVIAPSA-4953 
         */
        DAOH_Drug.preventDeactiveDrug((List<Drug__c>)Records, (Map<Id,Drug__c>) existingRecords);
    }
    
    /**
     * This method is used for after update of the Drug__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Drug.updateSanofiProductsOnDrugUpdate((List<Drug__c>)Records, (Map<Id,Drug__c>) existingRecords);
        DAOH_Drug.insertAuditLogOnUpdate((List<Drug__c>)Records, (Map<Id,Drug__c>) existingRecords);
    }
    
     /**
     * This method is used for before delete of the Drug__c trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        DAOH_Drug.deleteFromSanofiProducts((List<Drug__c>)Records);
    }
    
    /**
     * This method is used for after delete of the Drug__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        //DAOH_Drug.deleteFromSanofiProducts((List<Drug__c>)Records);
        DAOH_Drug.insertAuditLog((List<Drug__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Drug__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_Drug.insertAuditLog((List<Drug__c>)Records,'UNDELETE');
        
    }
} 
