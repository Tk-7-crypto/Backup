/**
 * This is Contract trigger handler class.
 * version : 1.0
 */
public class DAO_Contract extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<Contract>
     */
    public DAO_Contract(List<Contract> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Contract(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Contract trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Contract.setContractFields(records, null);
        DAOH_Contract.linkToParentContract(records, null);
        DAOH_Contract.updateContractFields(records, null);
        DAOH_Contract.updateContractsBasedOnOppFields(records);
        DAOH_Contract.setContractFieldsFromParentContractFields(records, null);
        DAOH_Contract.updateContractFieldValues(records, null);
    }
    
    /**
     * This method is used for before update of the Contract trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {  
        DAOH_Contract.setContractFields(records, (Map<Id, Contract>)existingRecords);
        DAOH_Contract.linkToParentContract(records, (Map<Id, Contract>)existingRecords);
        DAOH_Contract.updateContractFields(records,  (Map<Id, Contract>)existingRecords);
        DAOH_Contract_PRM.updateContract(records, (Map<Id, Contract>)existingRecords);
        DAOH_Contract.updateContractFieldsValue(records, (Map<Id, Contract>)existingRecords);
        DAOH_Contract.setContractFieldsFromParentContractFields(records, (Map<Id, Contract>)existingRecords);
        DAOH_Contract.updateContractFieldValues(records, (Map<Id, Contract>)existingRecords);
    }

    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        DAOH_Contract.createContractLifeCycleRecord(records, (Map<Id, Contract>)existingRecords);
        DAOH_Contract_PRM.updateParentContract(records, (Map<Id, Contract>)existingRecords);
        DAOH_Contract.updateSurveyPIC(records, (Map<Id, Contract>)existingRecords);
    }

    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert() {
        DAOH_Contract.createContractLifeCycleRecord(records, null);
        DAOH_Contract.setParentContractFieldsOnCNF(records);
        DAOH_Contract.updateContract(records);
        ID jobID = System.enqueueJob(new QUE_CRM_ContractBoxFoldersJob(records));
        System.debug(jobId);
        DAOH_Contract_PRM.insertContract(records, null);
        DAOH_Contract.updateSurveyPIC(records, null);
    } 
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_Contract.checkRecordDeletion(records);
        DAOH_Contract.createOutboundMessageDeletionQueue((List<Contract>)Records);
    }
}