public class DAO_TPA_Commercial_Review extends fflib_SObjectDomain{
/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TPA_Commercial_Review(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TPA_Commercial_Review(sObjectList);
        }
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) { 
            DAOH_TPA_Commercial_Review.onBeforeUpdate((List<TPA_Commercial_Review__c>)Records, existingRecords.values(), new Map<Id, TPA_Commercial_Review__c>((List<TPA_Commercial_Review__c>)Records), (Map<Id, TPA_Commercial_Review__c>)existingRecords);
        }
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPA_Commercial_Review.onAfterUpdate((List<TPA_Commercial_Review__c>)Records, existingRecords.values(), new Map<Id, TPA_Commercial_Review__c>((List<TPA_Commercial_Review__c>)Records), (Map<Id, TPA_Commercial_Review__c>)existingRecords);
        }
    }
    public override void onBeforeInsert() { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPA_Commercial_Review.onBeforeInsert((List<TPA_Commercial_Review__c>)Records);
        }
    }
}