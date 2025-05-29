/**
* This is PSSF (PSSF__c) trigger handler class.
* version : 1.0
*/
public class DAO_PSSF extends fflib_SObjectDomain{
    
    /**
* Constructor of this class
* @params sObjectList List<PSSF__c>
*/
    public DAO_PSSF(List<PSSF__c> sObjectList){
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_PSSF(sObjectList);
        }
    }
    
    /**
* This method is used for before insert of the PSSF__c  trigger.
* @return void
*/
    public override void onBeforeInsert(){
        DAOH_PSA_PSSF.validateFieldsPSSF((List<PSSF__c>) records, null);
    } 
    
    /**
* This method is used for before update of the PSSF__c  trigger.
* @return void
*/
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_PSSF.validateFieldsPSSF((List<PSSF__c>) records, (Map<Id,PSSF__c>) existingRecords);
        DAOH_PSA_PSSF.ClonePSSFRecord((List<PSSF__c>) records, (Map<Id,PSSF__c>) existingRecords);
    }
    
     /**
     * This method is used for after insert of the PSSF__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_PSSF.synchronizeProjectEvents((List<PSSF__c>)Records, null);
        DAOH_PSA_PSSF.insertAuditLogOnUpdate((List<PSSF__c>)Records, null);
    }
    
    /**
     * This method is used for after update of the PSSF__c trigger.
     * @return  void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_PSSF.synchronizeProjectEvents((List<PSSF__c>)Records, null);
        DAOH_PSA_PSSF.insertAuditLogOnUpdate((List<PSSF__c>)Records, (Map<Id,PSSF__c>) existingRecords);
        DAOH_PSA_PSSF.updtRltdPJEToUpdtReciepients((List<PSSF__c>)Records, (Map<Id,PSSF__c>) existingRecords);
    }
    
    /**
     * This method is used for after delete of the PSSF (PSSF__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_PSSF.insertAuditLog((List<PSSF__c>)Records,'DELETE');
    }
    /**
     * This method is used for after undelete of the PSSF (PSSF__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_PSSF.synchronizeProjectEvents((List<PSSF__c>)Records, null);
        DAOH_PSA_PSSF.insertAuditLog((List<PSSF__c>)Records,'UNDELETE');
    }
}
