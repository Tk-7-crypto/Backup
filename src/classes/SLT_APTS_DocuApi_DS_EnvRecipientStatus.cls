/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for SLT_Apttus_DocuApi_DocuSignEnvelopeRecipientStatus
 */
public class SLT_APTS_DocuApi_DS_EnvRecipientStatus extends fflib_SObjectSelector{

    public SLT_APTS_DocuApi_DS_EnvRecipientStatus()
    {
    }
	
    public SLT_APTS_DocuApi_DS_EnvRecipientStatus(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
	
    /**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c.Id,
            Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c.Apttus_DocuApi__SignedDateTime__c,
            Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c.Apttus_DocuApi__Status__c,
            Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c.Apttus_DocuApi__DocuSignEnvelopeId__c,
            Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c.Apttus_DocuApi__RecipientName__c
        };
    }
	
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c.sObjectType;
    }
	
    /**
    *  This method is use to query Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c
	* @param Set idSet
	* @param Set fieldSet
	* @return List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>
    */
    public List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> getDocuSignEnvelopeByIdAndStatus(Set<Id> idSet, Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition('Id in: idSet');
        queryFactory.setOrdering(new fflib_QueryFactory.Ordering('Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c', 'CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING));
        
        return (List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>) Database.query(queryFactory.toSOQL());
    }
    
    /**
    *  This method is use to query Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c based on EnvelopeId
	* @param Id EnvelopeId
	* @param Set fieldSet
	* @return List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>
    */
    public List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> getDSEnvelopeRecipientStatusByEnvelopeId(Id EnvelopeId, Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition('Apttus_DocuApi__DocuSignEnvelopeId__c = :EnvelopeId');
        queryFactory.setOrdering(new fflib_QueryFactory.Ordering('Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c', 'CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING));
        
        return (List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>) Database.query(queryFactory.toSOQL());
    }
}