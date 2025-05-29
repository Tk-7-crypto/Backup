/**
 * This is HA_Websites_Review__c trigger handler class.
 * version : 1.0
 */
public class DAO_HA_Websites_Review extends fflib_SObjectDomain{

    /**
     * Constructor of this class
     * @params sObjectList List<HA_Websites_Review__c>
     */
    public DAO_HA_Websites_Review(List<HA_Websites_Review__c> sObjectList){
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_HA_Websites_Review(sObjectList);
        }
    }

     /**
     * This method is used for after insert of the HA_Websites_Review__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_HA_Websites_Review.insertAuditLogOnUpdate((List<HA_Websites_Review__c>)Records, null);
    }
    
    /**
     * This method is used for after update of the HA_Websites_Review__c trigger.
     * @return  void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_PSA_HA_Websites_Review.insertAuditLogOnUpdate((List<HA_Websites_Review__c>)Records, (Map<Id,HA_Websites_Review__c>) existingRecords);
    }
    
    /**
     * This method is used for after delete of the HA_Websites_Review__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_HA_Websites_Review.insertAuditLog((List<HA_Websites_Review__c>)Records,'DELETE');
    }
    /**
     * This method is used for after undelete of the HA_Websites_Review__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_HA_Websites_Review.insertAuditLog((List<HA_Websites_Review__c>)Records,'UNDELETE');
    } 
}