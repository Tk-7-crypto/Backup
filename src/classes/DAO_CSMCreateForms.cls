public class DAO_CSMCreateForms extends fflib_SObjectDomain{
    
    /**
    * Constructor of this class
    * @params sObjectList List<CSM_Create_Forms__c>
    */
    public DAO_CSMCreateForms(List<CSM_Create_Forms__c> sObjectList) {
        super(sObjectList);
    }
    
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CSMCreateForms(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the CSM_Create_Forms__c trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_CSMCreateForms.checkOfferingRecords((List<CSM_Create_Forms__c>)Records);
    }
    /**
    * This method is used for after insert of the CSM_Create_Forms__c trigger.
    * @return void
    */
    public override void onAfterInsert() {
        DAOH_CSMCreateForms.updateTagOnCase((List<CSM_Create_Forms__c>)Records);
    }
    
    /**
    * This method is used for before update of the CSM_Create_Forms__c trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    }
    
    /**
    * This method is used for before delete of the CSM_Create_Forms__c trigger.
    * @return void
    */    
    public override void onBeforeDelete() {
    }
    
    
}
