/**
* Selector class for DocuSign_Auth_Data__c object
*/
public class SLT_DocuSign_Auth_Data extends fflib_SObjectSelector{

    /**
     * constructor to initialise CRUD and FLS.
     */
    public SLT_DocuSign_Auth_Data() {
        super(false, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            DocuSign_Auth_Data__c.Id,
			DocuSign_Auth_Data__c.Name,
			DocuSign_Auth_Data__c.Client_Id__c,
			DocuSign_Auth_Data__c.DocusignUser_Id__c,
			DocuSign_Auth_Data__c.Account_Id__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return DocuSign_Auth_Data__c.sObjectType;
    }
    
    /**
     * This method used to get DocuSign_Auth_Data__c by Id
     * @return  List<DocuSign_Auth_Data__c>
     */
    public List<DocuSign_Auth_Data__c> selectById(Set<ID> idSet) {
        return (List<DocuSign_Auth_Data__c>) selectSObjectsById(idSet);
    }

    /**
    * This method used to get DocuSign Auth Data by fields
    * @return  List<DocuSign_Auth_Data__c>
    */
    public List<DocuSign_Auth_Data__c> getDocusignAuthDataDetails(Set<String> fieldSet, Integer recordLimit) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        if (!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        if (recordLimit != null) {
            queryFactory.setLimit(recordLimit);
        }
        return (List<DocuSign_Auth_Data__c>) Database.query(queryFactory.toSOQL());
    }
    
    /**
    * This method used to get DocuSign Auth Data by fields and Accound Id
    * @return  List<DocuSign_Auth_Data__c>
    */
    public List<DocuSign_Auth_Data__c> getDocusignAuthDataDetailsByAccountId(Set<String> fieldSet, String appName, Integer recordLimit) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        if (!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        queryFactory.setCondition('Name =: appName');
        if (recordLimit != null) {
            queryFactory.setLimit(recordLimit);
        }
        return (List<DocuSign_Auth_Data__c>) Database.query(queryFactory.toSOQL());
    }
}