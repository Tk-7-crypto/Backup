/*
*   This class is used for handling the DocuSign_Envelope triggers. 
*/
public class DAO_DocuSign_Envelope extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<dsfs__DocuSign_Envelope__c>
     */
    public DAO_DocuSign_Envelope(List<dsfs__DocuSign_Envelope__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor class for construct new Instance of this Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_DocuSign_Envelope(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the dsfs__DocuSign_Envelope__c trigger.
     * @return void 
     */
    public override void onBeforeInsert() {
    }

    /**
     * This method is used for before insert of the dsfs__DocuSign_Envelope__c trigger.
     * @param Map<Id,SObject> existingRecords
     * @return void
     */
    public override void onAfterInsert() {
    }
}