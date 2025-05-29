/**
 * This is CDA_Request__c trigger handler class.
 * version : 1.0
 */
 public class DAO_CDARequest extends fflib_SObjectDomain {

    /**
    * Constructor of this class
    * @params sObjectList List<SObject>
    */
    public DAO_CDARequest(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CDARequest(sObjectList);
        }
    }

    /**
    * This method is used for before insert of the CDA_Request__c trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_CDARequest.updateFieldsWhileInsert((List<CDA_Request__c>)Records, 'before');
    }

    /**
     *This method is used for after insert of the CDA_Request__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_CDARequest.updateFieldsWhileInsert((List<CDA_Request__c>)Records, 'after');
    }

    /**
    * This method is used for before update of the CDA_Request__c trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_CDARequest.updateFieldsBeforeUpdate((List<CDA_Request__c>)Records, new Map<Id, CDA_Request__c>((List<CDA_Request__c>)Records), (Map<Id, CDA_Request__c>) existingRecords);
    }

    /**
    * This method is used for after update of the CDA_Request__c trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        DAOH_CDARequest.createCDAAccount((List<CDA_Request__c>)Records);
        DAOH_CDARequest.updateCDAAccount((List<CDA_Request__c>)Records);
    }
}