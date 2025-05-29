/**
 * This is Contract Lift Cycle trigger handler class.
 * version : 1.0
 */
public class DAO_ContractLifecycle extends fflib_SObjectDomain {
 
    /**
     * Constructor of this class
     * @params sObjectList List<Contract_Lifecycle__c>
     */
    public DAO_ContractLifecycle(List<Contract_Lifecycle__c> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ContractLifecycle(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Contract Lifecycle trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_ContractLifecycle.setContractLifecycleFields(records, null);
    }
    
    /**
     * This method is used for before update of the Contract Lifecycle trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_ContractLifecycle.setContractLifecycleFields(records, (Map<Id, Contract_Lifecycle__c>)existingRecords);
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_ContractLifecycle.createOutboundMessageDeletionQueue((List<Contract_Lifecycle__c>)Records);
    }
}