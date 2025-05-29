/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for AccountContactRelation
 */
public class SLT_AccountContactRelation extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            AccountContactRelation.Id
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AccountContactRelation.sObjectType;
    }
    
    /**
     * This method used to get AccountContactRelation by Id
     * @return  List<AccountContactRelation>
     */
    public List<AccountContactRelation> getAccountContactRelations(List<Account> sfdcGoldenAccountList, List<Account> survivorAccountList) {
        String query = newQueryFactory(true).setCondition('isDirect = false and ((Contact.accountid in :sfdcGoldenAccountList and Accountid in :survivorAccountList) OR (Contact.accountid in :survivorAccountList and Accountid in :sfdcGoldenAccountList))').toSOQL();
        System.debug(query);
        return (List<AccountContactRelation>) Database.query(query);
    }
    
    /**
     * This method is used to get fields for the Employee Component
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> getAccountContactRelations(Set<String> fieldSet, Id accountId, string contactType, boolean isActive) {
        String query = newQueryFactory(true).selectFields(fieldSet).setCondition('Account.Id = :accountId AND Contact_Type__c = :contactType AND IsActive = :isActive').toSOQL();
        return (List<AccountContactRelation>) Database.query(query);
    }
    
    
    public List<AccountContactRelation> getAccountContactRelationsforOWF(Set<String> fieldSet, Id accountId, string contactType, boolean isActive) {
        String query = newQueryFactory(true).selectFields(fieldSet).setCondition('Account.Id != null AND Contact_Type__c != null AND Account.Id = :accountId AND Contact_Type__c = :contactType AND IsActive = :isActive').toSOQL();
        return (List<AccountContactRelation>) Database.query(query);
    }
    
    public List<AccountContactRelation> getAccountContactRelationsforOWFUsingSubGroupAndFunction(Set<String> fieldSet, Id accountId, string contactType, boolean isActive, Set<String> function, Set<String> subGroup) {
        String query = newQueryFactory(true).selectFields(fieldSet).setCondition('Account.Id != null AND Contact_Type__c != null AND Account.Id = :accountId AND Contact_Type__c = :contactType AND IsActive = :isActive And Function__c IN: function And Contact.Sub_Group__c In: subGroup').toSOQL();
        return (List<AccountContactRelation>) Database.query(query);
    }
	
	/**
     * This method used to get AccountContactRelation by account Id and condition
     * @return  List<AccountContactRelation>
     */
    public List<AccountContactRelation> getAccountContactRelationsWithCondition(Set<String> fieldSet, Set<Id> accountIdSet, String condition) {
        condition = 'Account.Id IN: accountIdSet AND ' + condition;
        String query = newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL();
        return (List<AccountContactRelation>) Database.query(query);
    }
}