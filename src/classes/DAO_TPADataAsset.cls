public class DAO_TPADataAsset extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TPADataAsset(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TPADataAsset(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the TPA Request trigger.
     * @return void
     */
    public override void onBeforeInsert() {}


    /**
     * This method is used for before update of the TPA Data Asset trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && UTL_TPA.executeDataAssetTrigger) { 
            DAOH_TPADataAsset.onBeforeUpdate((List<TPA_Data_Asset__c>)Records, existingRecords.values(), new Map<Id, TPA_Data_Asset__c>((List<TPA_Data_Asset__c>)Records), (Map<Id, TPA_Data_Asset__c>)existingRecords);
        }
    }

    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && UTL_TPA.executeDataAssetTrigger) {
            DAOH_TPADataAsset.onBeforeDelete((List<TPA_Data_Asset__c>)Records, new Map<Id, TPA_Data_Asset__c>((List<TPA_Data_Asset__c>)Records));
        }
    }
    
    /**
     * This method is used for before insert of the TPA Data Asset trigger.
     * @return void
     */
    public override void onAfterInsert() {}
    
    /**
     * This method is used for after update of the TPA Data Asset trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        // if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && UTL_TPA.executeDataAssetTrigger) {
        //     DAOH_TPADataAsset.onAfterUpdate((List<TPA_Data_Asset__c>)Records, existingRecords.values(), new Map<Id, TPA_Data_Asset__c>((List<TPA_Data_Asset__c>)Records), (Map<Id, TPA_Data_Asset__c>)existingRecords);
        // }
    }

    /**
     * Override method After Delete Call
     */
    public override void onAfterDelete() {
        // if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && UTL_TPA.executeDataAssetTrigger) {
        //     DAOH_TPADataAsset.onAfterDelete((List<TPA_Data_Asset__c>)Records);
        // }
    }
}