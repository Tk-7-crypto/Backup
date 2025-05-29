public class DAO_TPA_IMSDataAsset extends fflib_SObjectDomain {
/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TPA_IMSDataAsset(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TPA_IMSDataAsset(sObjectList);
        }
    }
    
     /**
     * This method is used for after update of the TPA Agreement Additional Field trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPA_IMSDataAsset.onAfterUpdate((List<IMS_Data_Asset__c>)Records, existingRecords.values(), new Map<Id, IMS_Data_Asset__c>((List<IMS_Data_Asset__c>)Records), (Map<Id, IMS_Data_Asset__c>)existingRecords);
        }
    }

}
