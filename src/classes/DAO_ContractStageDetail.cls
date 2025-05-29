/**
 * This is Contract trigger handler class.
 * version : 1.0
 */
public class DAO_ContractStageDetail extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<Contract_Stage_Detail__c>
     */
    public DAO_ContractStageDetail(List<Contract_Stage_Detail__c> sObjectList) {
        super(sObjectList);
        // Disable default Object Security checking 
        Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ContractStageDetail(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Contract Stage Detail trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_ContractStageDetail.setContractStageDetailFields(records, null);
    }
    
    /**
     * This method is used for before update of the Contract Stage Detail trigger.
     * @params  existingRecords Map<Id, SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_ContractStageDetail.setContractStageDetailFields(records, (Map<Id, Contract_Stage_Detail__c>)existingRecords);
    }

    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert() {
        DAOH_ContractStageDetail.updateContractLifeCycleRecord(records, null);
    } 
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_ContractStageDetail.createOutboundMessageDeletionQueue((List<Contract_Stage_Detail__c>)Records);
    }
}