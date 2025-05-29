/**
 * This is dsfs__DocuSign_Status__c trigger handler class.
 * version : 1.0
 */
 public class DAO_DocusignStatus extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<dsfs__DocuSign_Status__c>
     */
    public DAO_DocusignStatus(List<dsfs__DocuSign_Status__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_DocusignStatus(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the opportunity trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        //DAOH_DocusignStatus.bulkBefore((List<dsfs__DocuSign_Status__c>)Records);
        DAOH_DocusignStatus.handleDocusignStatusBeforeInsert((List<dsfs__DocuSign_Status__c>)Records);
    }

    /**
     * This method is used for before update of the opportunity trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        //DAOH_DocusignStatus.bulkBefore((List<dsfs__DocuSign_Status__c>)Records);
        DAOH_DocusignStatus.handleDocusignStatusBeforeUpdate((List<dsfs__DocuSign_Status__c>)Records, (Map<Id, dsfs__DocuSign_Status__c>)existingRecords);
    }

    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        DAOH_DocusignStatus.onAfterUpdate((List<dsfs__DocuSign_Status__c>)Records);
    }

    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert() {
        DAOH_DocusignStatus.updateDocuSign_SignedStatusRecords((List<dsfs__DocuSign_Status__c>)Records);
    }

    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {}

}
