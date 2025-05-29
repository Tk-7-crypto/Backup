public class DAO_TpaSecondaryDataAsset extends fflib_SObjectDomain {

	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TpaSecondaryDataAsset(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TpaSecondaryDataAsset(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the TPA Request trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        	DAOH_TpaSecondaryDataAsset.onAfterInsert((List<TPA_Secondary_Data_Asset__c>)Records);
        }
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TpaSecondaryDataAsset.onBeforeDelete((List<TPA_Secondary_Data_Asset__c>)Records, new Map<Id, TPA_Secondary_Data_Asset__c>((List<TPA_Secondary_Data_Asset__c>)Records));
        }
    }
}