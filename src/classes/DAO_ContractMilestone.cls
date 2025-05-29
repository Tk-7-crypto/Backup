/**
 * This is ContractMilestone trigger handler class.
 * version : 1.0
 */
public class DAO_ContractMilestone extends fflib_SObjectDomain {
	
    /**
     * Constructor of this class
     * @params sObjectList List<Contract_Milestone__c>
     */
    public DAO_ContractMilestone(List<Contract_Milestone__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ContractMilestone(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the ContractMilestone trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_ContractMilestone.updateContracts(records);
        DAOH_ContractMilestone.setContractMileStoneFields(records, null);
    }
    
    /**
     * This method is used for before update of the ContractMilestone trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_ContractMilestone.setContractMileStoneFields(records, (Map<Id, Contract_Milestone__c>)existingRecords);
    }

    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        DAOH_ContractMilestone.updateContractMilestone(records);
    }

    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert() {
        DAOH_ContractMilestone.updateContractMilestone(records);
    } 
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_ContractMilestone.createOutboundMessageDeletionQueue((List<Contract_Milestone__c>)Records);
    }

}