/*
*   This class is used for fetching record of the DocusignRecipientStatus. 
*/
public class SLT_DocusignRecipientStatus extends fflib_SObjectSelector {
    /**
     * constructor to initialise CRUD and FLS.
     */
    public SLT_DocusignRecipientStatus() {
        super(false, false, false);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            dsfs__DocuSign_Recipient_Status__c.Id,
            dsfs__DocuSign_Recipient_Status__c.Name,
            dsfs__DocuSign_Recipient_Status__c.dsfs__DocuSign_Recipient_Email__c,
            dsfs__DocuSign_Recipient_Status__c.dsfs__DocuSign_Routing_Order__c,
            dsfs__DocuSign_Recipient_Status__c.dsfs__DocuSign_Recipient_Id__c,
            dsfs__DocuSign_Recipient_Status__c.dsfs__Date_Signed__c,
            dsfs__DocuSign_Recipient_Status__c.dsfs__Date_Sent__c,
            dsfs__DocuSign_Recipient_Status__c.dsfs__Date_Declined__c,
            dsfs__DocuSign_Recipient_Status__c.dsfs__DocuSign_Recipient_Title__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return dsfs__DocuSign_Recipient_Status__c.sObjectType;
    }

    /**
     * This method used to get dsfs__DocuSign_Envelope_Recipient__c by Id
     * @return  List<dsfs__DocuSign_Recipient_Status__c>
     */
    public List<dsfs__DocuSign_Recipient_Status__c> selectById(Set<ID> idSet) {
        return (List<dsfs__DocuSign_Recipient_Status__c>) selectSObjectsById(idSet);
    }

    /**
     * This method used to get dsfs__DocuSign_Recipient_Status__c by docusign status ids
     * @return  List<dsfs__DocuSign_Recipient_Status__c>
     */
    public List<dsfs__DocuSign_Recipient_Status__c> selectByIdWithDocusignStatus(Set<String> fields,Set<Id> idSet,
        Set<Id> recordTypeIds,String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);
        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
}