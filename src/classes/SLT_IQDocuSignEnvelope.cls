public class SLT_IQDocuSignEnvelope extends fflib_SObjectSelector{

	public SLT_IQDocuSignEnvelope()
	{
	}
    
	
	public SLT_IQDocuSignEnvelope(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
	
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return 'IsDeleted DESC';
    }
	/**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            IQ_DocuSignEnvelope__c.Id,
            IQ_DocuSignEnvelope__c.Agreement__c,
            IQ_DocuSignEnvelope__c.Docusign_AccountId__c,
            IQ_DocuSignEnvelope__c.NumberOfDocuments__c,
            IQ_DocuSignEnvelope__c.Agreement__r.OwnerId,
            IQ_DocuSignEnvelope__c.Docusign_App_Name__c
        };
    }
	
	/**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return IQ_DocuSignEnvelope__c.sObjectType;
    }
	
	
	/*
    * This method is use to query docusignEnvelope on the basis of Status and Idset
    * @param String status
	* @param Set idSet
	* @param Set fieldSet
	* @return List<IQ_DocuSignEnvelope__c>
    */
    public List<IQ_DocuSignEnvelope__c> getDocuSignEnvelopeByIdAndStatus(String status, Set<Id> idSet,
        Set<String> fieldSet) {
        return (List<IQ_DocuSignEnvelope__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Status__c =: status AND Id in:'+
                'idSet').toSOQL());
    }
    
    /**
    * This method is used to query docusignEnvelope on the basis of condition
    * @param String condition
    * @param String firstParam
    * @param String secondParam
    * @param Set<String> fieldSet
    * @param String orderField
    * @param String sortOrder 
    * @param Integer record
	* @return List<IQ_DocuSignEnvelope__c>
    */
    public List<IQ_DocuSignEnvelope__c> getDocusignEnvelopeByCondition(String condition, String firstParam, String secondParam, 
        Set<String> fieldSet, String orderField, String sortOrder, Integer record) {
        fflib_QueryFactory query = newQueryFactory();
        if(sortOrder == 'ASC') {
            query.addOrdering(orderField, fflib_QueryFactory.SortOrder.ASCENDING);    
        }    
        else if(sortOrder == 'DESC') {
            query.addOrdering(orderField, fflib_QueryFactory.SortOrder.DESCENDING);    
        }    
        return (List<IQ_DocuSignEnvelope__c>) Database.query(
            query.selectFields(fieldSet).setCondition(condition).setLimit(record).toSOQL());
    }
    
    /**
    * This method is used to query docusignEnvelope on the basis of condition
    * @param String condition
    * @param Set<Id> agreementIds
    * @param Set<String> fieldSet
	* @return List<IQ_DocuSignEnvelope__c>
    */
    public List<IQ_DocuSignEnvelope__c> getDocusignEnvelopeByConditionAndAgreementIds(String condition,
        Set<Id> agreementIds, Set<String> fieldSet) {
        fflib_QueryFactory query = newQueryFactory();
        return (List<IQ_DocuSignEnvelope__c>) Database.query(
            query.selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}