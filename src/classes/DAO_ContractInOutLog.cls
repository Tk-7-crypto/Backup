/**
 * This is Contract In/Out Log trigger handler class.
 * version : 1.0
 */
public class DAO_ContractInOutLog extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Contract_In_Out_Log__c>
     */
    public DAO_ContractInOutLog(List<Contract_In_Out_Log__c> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ContractInOutLog(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Contract In/Out Log trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_ContractInOutLog.setContractInOutLogFields(records, null);
    }
    
    /**
     * This method is used for before update of the Contract In/Out Log trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_ContractInOutLog.setContractInOutLogFields(records, (Map<Id, Contract_In_Out_Log__c>)existingRecords);
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_ContractInOutLog.createOutboundMessageDeletionQueue((List<Contract_In_Out_Log__c>)Records);
    }
}