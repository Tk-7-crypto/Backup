public class SLT_DocuSign_Envelope extends fflib_SObjectSelector {
    /**
     * constructor to initialise CRUD and FLS.
     */
    public SLT_DocuSign_Envelope() {
        super(false, false, false);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            dsfs__DocuSign_Envelope__c.Id,
            dsfs__DocuSign_Envelope__c.Name,
            dsfs__DocuSign_Envelope__c.dsfs__Document_Name__c,
            dsfs__DocuSign_Envelope__c.dsfs__DocumentID__c,
            dsfs__DocuSign_Envelope__c.dsfs__Source_Object__c,
            dsfs__DocuSign_Envelope__c.dsfs__DocuSign_Envelope_ID__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return dsfs__DocuSign_Envelope__c.sObjectType;
    }

    /**
     * This method used to get dsfs__DocuSign_Envelope__c by Id
     * @return  List<dsfs__DocuSign_Envelope__c>
     */
    public List<dsfs__DocuSign_Envelope__c> selectById(Set<ID> idSet) {
        return (List<dsfs__DocuSign_Envelope__c>) selectSObjectsById(idSet);
    }

    /**
    * This method used to get envelope by fields and Ids
    * @return  List<dsfs__DocuSign_Envelope__c>
    */
    public List<dsfs__DocuSign_Envelope__c> selectDocusignEnvelopeFieldsById(Set<String> fieldSet, Set<Id> idSet) {
        return new List<dsfs__DocuSign_Envelope__c>((List<dsfs__DocuSign_Envelope__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Id =: idSet').toSOQL()));
    }
}