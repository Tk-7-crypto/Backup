/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for SLT_Apttus_DocuApi_DocuSignEnvelopeRecipientStatus
 */
public class SLT_IQ_DS_EnvRecipientStatus extends fflib_SObjectSelector{

    public SLT_IQ_DS_EnvRecipientStatus()
    {
    }
	
    public SLT_IQ_DS_EnvRecipientStatus(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
	
    /**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            IQ_DocuSignEnvelopeRecipientStatus__c.Id,
            IQ_DocuSignEnvelopeRecipientStatus__c.SignedDateTime__c,
            IQ_DocuSignEnvelopeRecipientStatus__c.Status__c,
            IQ_DocuSignEnvelopeRecipientStatus__c.DocuSignEnvelopeId__c,
            IQ_DocuSignEnvelopeRecipientStatus__c.RecipientName__c
        };
    }
	
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return IQ_DocuSignEnvelopeRecipientStatus__c.sObjectType;
    }
	
    /**
    *  This method is use to query IQ_DocuSignEnvelopeRecipientStatus__c
	* @param Set idSet
	* @param Set fieldSet
	* @return List<IQ_DocuSignEnvelopeRecipientStatus__c>
    */
    public List<IQ_DocuSignEnvelopeRecipientStatus__c> getDocuSignEnvelopeByIdAndStatus(Set<Id> idSet, Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition('Id in: idSet');
        queryFactory.setOrdering(new fflib_QueryFactory.Ordering('IQ_DocuSignEnvelopeRecipientStatus__c', 'CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING));
        
        return (List<IQ_DocuSignEnvelopeRecipientStatus__c>) Database.query(queryFactory.toSOQL());
    }
    
    /**
    *  This method is use to query IQ_DocuSignEnvelopeRecipientStatus__c based on EnvelopeId
	* @param Id EnvelopeId
	* @param Set fieldSet
	* @return List<IQ_DocuSignEnvelopeRecipientStatus__c>
    */
    public List<IQ_DocuSignEnvelopeRecipientStatus__c> getDSEnvelopeRecipientStatusByEnvelopeId(Id EnvelopeId, Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition('DocuSignEnvelopeId__c = :EnvelopeId');
        queryFactory.setOrdering(new fflib_QueryFactory.Ordering('IQ_DocuSignEnvelopeRecipientStatus__c', 'CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING));
        
        return (List<IQ_DocuSignEnvelopeRecipientStatus__c>) Database.query(queryFactory.toSOQL());
    }
}