/*
*   This class is used for fetching record of the DocusignRecipient. 
*/
public class SLT_DocusignRecipient extends fflib_SObjectSelector {
    /**
     * constructor to initialise CRUD and FLS.
     */
    public SLT_DocusignRecipient() {
        super(false, false, false);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            dsfs__DocuSign_Envelope_Recipient__c.Id,
            dsfs__DocuSign_Envelope_Recipient__c.Name,
            dsfs__DocuSign_Envelope_Recipient__c.dsfs__Recipient_Email__c,
            dsfs__DocuSign_Envelope_Recipient__c.dsfs__DocuSign_Signer_Type__c,
            dsfs__DocuSign_Envelope_Recipient__c.dsfs__Routing_Order__c,
            dsfs__DocuSign_Envelope_Recipient__c.dsfs__DocuSign_Signature_Name__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return dsfs__DocuSign_Envelope_Recipient__c.sObjectType;
    }

    /**
     * This method used to get dsfs__DocuSign_Envelope_Recipient__c by Id
     * @return  List<dsfs__DocuSign_Envelope_Recipient__c>
     */
    public List<dsfs__DocuSign_Envelope_Recipient__c> selectById(Set<ID> idSet) {
        return (List<dsfs__DocuSign_Envelope_Recipient__c>) selectSObjectsById(idSet);
    }
}