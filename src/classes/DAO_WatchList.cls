public class DAO_WatchList extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_WatchList(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_WatchList(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Watch_List__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_WatchList.onAfterInsert((List<Watch_List__c>)Records);
        }
    }
    
    /**
     * This method is used for after update of the Watch_List__c trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_WatchList.onAfterUpdate((List<Watch_List__c>)Records, existingRecords.values(), new Map<Id, Watch_List__c>((List<Watch_List__c>)Records), (Map<Id, Watch_List__c>)existingRecords);
        }
    }
}