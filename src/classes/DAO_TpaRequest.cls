public class DAO_TpaRequest extends fflib_SObjectDomain {

	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TpaRequest(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TpaRequest(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the TPA Request trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        	DAOH_TpaRequest.onBeforeInsert((List<TPA_Request__c>)Records);
        }
    }
    
    /**
     * This method is used for before insert of the TPA Request trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        	DAOH_TpaRequest.onAfterInsert((List<TPA_Request__c>)Records);
        }
    }
    
    /**
     * This method is used for before update of the TPA Request trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TpaRequest.onBeforeUpdate((List<TPA_Request__c>)Records, existingRecords.values(), new Map<Id, TPA_Request__c>((List<TPA_Request__c>)Records), (Map<Id, TPA_Request__c>)existingRecords);
        }
    }
    
    /**
     * This method is used for after update of the TPA Request trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TpaRequest.onAfterUpdate((List<TPA_Request__c>)Records, existingRecords.values(), new Map<Id, TPA_Request__c>((List<TPA_Request__c>)Records), (Map<Id, TPA_Request__c>)existingRecords);
        }
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TpaRequest.onBeforeDelete((List<TPA_Request__c>)Records);
        }
    }
}