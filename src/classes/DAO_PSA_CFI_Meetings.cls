public class DAO_PSA_CFI_Meetings extends fflib_SObjectDomain{
    /**
     * Constructor of this class
     * @params sObjectList List<CFI_Meetings__c>
     */
    public DAO_PSA_CFI_Meetings(List<CFI_Meetings__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_PSA_CFI_Meetings(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the CFI_Meetings trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_CFI_Meetings.insertAuditLogOnUpdate((List<CFI_Meetings__c>)Records, null);
    }
    
    /**
    * This method is used for before insert of the CFI_Meetings trigger.
    * @return void
    */
    public override void onBeforeInsert() {        
    }
    
    /**
    * This method is used for before update of the CFI_Meetings trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
    }
    
    /**
     * This method is used for after update of the CFI_Meetings trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_CFI_Meetings.insertAuditLogOnUpdate((List<CFI_Meetings__c>)Records, (Map<Id,CFI_Meetings__c>) existingRecords);
    }
    
    /**
     * This method is used for after Delete of the CFI_Meetings trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_CFI_Meetings.insertAuditLog((List<CFI_Meetings__c>)Records,'DELETE');
    }
    
    /**
     * This method is used for after undelete of the CFI_Meetings trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_CFI_Meetings.insertAuditLog((List<CFI_Meetings__c>)Records,'UNDELETE');
    }
}
