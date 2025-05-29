public class SLT_AccountCompetitor extends fflib_SObjectSelector {
    
    public Schema.SObjectType getSObjectType() {
        return Account_Competitor__c.sObjectType;
    }
    
    public override String getOrderBy() {
        return 'Account__c';
    } 
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    public List<Account_Competitor__c> getAccountCompetitors(Set<String>fieldset, String condition){
        return Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}