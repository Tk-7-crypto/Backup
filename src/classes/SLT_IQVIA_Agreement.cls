public class SLT_IQVIA_Agreement extends fflib_SObjectSelector{
    public String orderByField = 'CreatedDate';
        /**
      */
	public SLT_IQVIA_Agreement()
	{
	}
	
	/**
      */
    public SLT_IQVIA_Agreement(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return IQVIA_Agreement__c.sObjectType;
    }
    
    
        /**
    * This method used to get field list of sobject.
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            IQVIA_Agreement__c.Id, IQVIA_Agreement__c.Name
        };
    }
    
       
    //Method to override OrderBy
     
    public override String getOrderBy() {
        return orderByField;
    }
    
    /**
     * This method used to get All IQVIA Agreement Fields by Id
     */
    public List<IQVIA_Agreement__c> selectById(Set<Id> idSet){

        return (List<IQVIA_Agreement__c>) selectSObjectsById(idSet);
    }
    /**
     * This method used to get Agreement by Id
     * @return  List<IQVIA_Agreement__c>
     */
    public List<IQVIA_Agreement__c> getIQVIAAgreementFieldsById(Set<Id> idSet, Set<String> fieldSet) {
        return (List<IQVIA_Agreement__c>) Database.query(
            									 newQueryFactory(true).
               									 selectFields(fieldSet).
               									 setCondition('Id in: idSet').
               									 toSOQL());
    }

    /**
     * This method is used to get Agreement by Id
     * @return IQVIA_Agreement__c
     */
    public IQVIA_Agreement__c getIQVIAAgreementDetails(Id agreementId, Set<String> fieldSet){
        return (IQVIA_Agreement__c) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ID = :agreementId').toSOQL());
    }
	
    /**
    * This method returns IQVIA agreement list on the basis of conditions
    * @param Set<String> fieldSet
    * @param Set<String> strSet
    * @param Set<Id> agrIds
    * @param String condition
    * @return List<IQVIA_Agreement__c>
    */
    public List<IQVIA_Agreement__c> getAgreementListByConditions(Set<String> fieldSet, Set<String> strSet, Set<Id> agrIds,
        String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fieldSet);
        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());  
    }
}