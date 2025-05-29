public class DAO_Account_Compliance extends fflib_SObjectDomain{
	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_Account_Compliance(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Account_Compliance(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the Account Compliance trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        	DAOH_Account_Compliance.onBeforeInsert((List<Account_Compliance__c>)Records);
        }
    }
    
    /**
     * This method is used for before update of the TPA Request trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_Account_Compliance.onBeforeUpdate((List<Account_Compliance__c>)Records, existingRecords.values(), new Map<Id, Account_Compliance__c>((List<Account_Compliance__c>)Records), (Map<Id, Account_Compliance__c>)existingRecords);
        }
    }

    /**
     * This method is used for after update of the TPA Request trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_Account_Compliance.onAfterUpdate((List<Account_Compliance__c>)Records, existingRecords.values(), new Map<Id, Account_Compliance__c>((List<Account_Compliance__c>)Records), (Map<Id, Account_Compliance__c>)existingRecords);
        }
    }

    /**
     * This method is used for after insert of the TPA Request trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        	DAOH_Account_Compliance.onAfterInsert((List<Account_Compliance__c>)Records);
        }
    }
}