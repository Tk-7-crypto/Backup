/**
* Selector class for Agreement Extension 
*/
public class SLT_Agreement_Clause extends fflib_SObjectSelector{
    /**
    constructor
    */
    public SLT_Agreement_Clause(){
    }
    
    /**
    param constructor
    */
    public SLT_Agreement_Clause(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to get field list of sobject.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus__Agreement_Clause__c.Id , Apttus__Agreement_Clause__c.Name, Apttus__Agreement_Clause__c.Apttus__Action__c,
                Apttus__Agreement_Clause__c.Apttus__Clause__c, Apttus__Agreement_Clause__c.Apttus__Agreement__c,
                Apttus__Agreement_Clause__c.Apttus__Category__c, Apttus__Agreement_Clause__c.Apttus__DiffText__c,
                Apttus__Agreement_Clause__c.Apttus__Text__c, Apttus__Agreement_Clause__c.Apttus__Template__c,
                Apttus__Agreement_Clause__c.Apttus__PrevText__c, Apttus__Agreement_Clause__c.Apttus__Template__c
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Apttus__Agreement_Clause__c.sObjectType;
    }
    
     /**
    * This method used to get Apttus__Agreement_Clause__c by condition
    * @param agreementClauseIdset is the set of agreement clause records
    * @param fieldSet is the set of field names
    * @param condition on which records are being fetched.
    * @param setRecTypes is the set of recordTypes which we are fetching
    * @return  Map<Id, Apttus__Agreement_Clause__c>
    */
    public Map<Id, Apttus__Agreement_Clause__c> getAgreementClauseDetails(Set<Id> agreementClauseIdset, 
        Set<String> fieldSet, String condition, Set<Id> setRecTypes) { 
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(fieldSet);
        queryFactory.setOrdering(Apttus__Agreement_Clause__c.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING, true);
        if(String.isNotBlank(condition)) {
            queryFactory.setCondition(condition);
        }
        return new Map<Id, Apttus__Agreement_Clause__c>((List<Apttus__Agreement_Clause__c>) Database.query(queryFactory.toSOQL()));
    }
}