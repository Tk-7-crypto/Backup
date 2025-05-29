public class DAO_DocuSignRecipientStatus extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_DocuSignRecipientStatus(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_DocuSignRecipientStatus(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the dsfs__DocuSign_Recipient_Status__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_DocuSignRecipientStatus.onAfterInsert((List<dsfs__DocuSign_Recipient_Status__c>)Records, new Map<Id, dsfs__DocuSign_Recipient_Status__c>((List<dsfs__DocuSign_Recipient_Status__c>)Records));
    }
    
    /**
     * This method is used for after update of the dsfs__DocuSign_Recipient_Status__c trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        DAOH_DocuSignRecipientStatus.onAfterUpdate((List<dsfs__DocuSign_Recipient_Status__c>)Records, existingRecords.values(), new Map<Id, dsfs__DocuSign_Recipient_Status__c>((List<dsfs__DocuSign_Recipient_Status__c>)Records), (Map<Id, dsfs__DocuSign_Recipient_Status__c>)existingRecords);
    }
}