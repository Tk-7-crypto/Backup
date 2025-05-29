public class DAO_DocuSignEnvelopeDocument extends fflib_SObjectDomain {
	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_DocuSignEnvelopeDocument(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_DocuSignEnvelopeDocument(sObjectList);
        }
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_DocuSignEnvelopeDocument.onBeforeDelete((List<dsfs__DocuSign_Envelope_Document__c>)Records);
        }
    }

    /**
     * This method is used for before insert of the dsfs__DocuSign_Envelope_Document__c trigger.
     * @return void 
     */
    public override void onBeforeInsert() {
    }
}