public class DAO_QueueUserRelationship extends fflib_SObjectDomain {
    
    public DAO_QueueUserRelationship(List<Case> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_QueueUserRelationship(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        DAOH_QueueUserRelationship.customEmailAddressValidation((List<Queue_User_Relationship__c>)Records);
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_QueueUserRelationship.customEmailAddressValidation((List<Queue_User_Relationship__c>)Records);
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_QueueUserRelationship.updateDefaultQueue((List<Queue_User_Relationship__c>)Records,(Map<Id, Queue_User_Relationship__c>)existingRecords);
    }

}