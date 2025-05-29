/**
 * This is DocuSign Envelope trigger handler class. 
 * version : 1.0 
 */
public class DAO_IQ_DocuSignEnvelope extends fflib_SObjectDomain{
	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_IQ_DocuSignEnvelope(List<SObject> sObjectList) {
        super(sObjectList);
    }
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_IQ_DocuSignEnvelope(sObjectList);
        }
    }
    /**
    * This method is used for after update of the Docusign Envelope trigger.
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        DAOH_CLM_IQ_DocuSignEnvelope.updateAgreementStatus((List<IQ_DocuSignEnvelope__c>) records,
            (Map<Id, IQ_DocuSignEnvelope__c>) existingRecords);
    } 
}