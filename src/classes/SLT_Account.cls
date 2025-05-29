/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Account
 */
public without sharing class SLT_Account extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name,
            Account.ParentId,
            Account.AccountCountry__c,
            Account.CSH_SubType__c,
            Account.CustomerSegment__c,
            Account.Shared_Folder_Write_Permission__c,
            Account.Shared_Folder_Type__c,
            Account.Country_of_the_requester__c,
            Account.Disable_CSH_P1_Case_Creation__c,
            Account.DATA_Global_Support_CSH_Form__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }
    
    /**
     * This method used to get Account by Id
     * @return  List<Account>
     */
    public List<Account> selectById(Set<ID> idSet) {
        return (List<Account>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Account by Id
     * @return  Map<Id, Account>
     */
    public Map<Id, Account> selectByAccountId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Account>((List<Account>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get Accounts
     * @return  Map<Id, Account>
     */
    public Map<Id, Account> getAccounts(Set<String> fieldSet, String whereCondition) {
        return new Map<Id, Account>((List<Account>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition(whereCondition).toSOQL()));
    }
    
    public List<Account> selectAllCustomerPortalAccounts(String accCountry,Set<String> fieldSet) {
        return Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('AccountCountry__c =:accCountry and IsCustomerPortal = true').toSOQL());
    }
    public List<Account> selectByAccTeamMember(Set<String> accfieldSet, Set<String> teammemberField,String role) {
        fflib_QueryFactory accountQueryFactory = newQueryFactory(true);
        new SLT_AccountTeamMember().addQueryFactorySubselect(accountQueryFactory, CON_CRM.ACCOUNT_TEAMMEMBER, true).selectFields(teammemberField).setCondition('TeamMemberRole=: role');
        String queryString = accountQueryFactory.selectFields(accfieldSet).addOrdering('Name',fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        return Database.query(queryString);
    }
	/**
     * This method used to get Accounts
     * @return  List<Account>
     */
    public List<Account> getAccountsList(Set<String> fieldSet, List<Id> parentAccIds) {
        return ((List<Account>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Parent.Id IN : parentAccIds').toSOQL()));
        
    }
    public List<Account> getAccountCountry(Set<String> fieldSet,String userId)
    {
        return Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('ID =:userId').toSOQL());
    }    

    public List<Account> selectBySearchString(String searchString, Set<String> fieldSet) {
        return (List<Account>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name LIKE '+searchString+'').toSOQL());
    }
	
	/**
     * This method used to get Accounts
     * @return  Map<Id, Account>
     */
    public Map<Id, Account> getAccountsWithAccountIdAndWhereCondtion(Set<Id> accIdSet, Set<String> fieldSet, String parentCategory) {
        Date todayDate = system.today();
        return new Map<Id, Account>((List<Account>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id IN : accIdSet AND (Parent.Category__c != :parentCategory AND (Date_Risk_Expiry_Date__c < :todayDate OR Global_Date_Risk_Assessed__c = null))').toSOQL()));
    }
    
    /**
     * This method used to get Accounts
     * @return  Map<Id, Account>
     */
    public Map<Id, Account> getAccountsWithAccountIdAndParentCategoryNotLargePharma(Set<Id> accId, Set<String> fieldSet, String parentCategory) {
        return new Map<Id, Account>((List<Account>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id IN : accId AND (Parent.Category__c != :parentCategory)').toSOQL()));
    }
	
    /**
     * This method is used to get Accounts by Id and Risk Rating
     * @return  Map<Id, Account>
     */
    public Map<Id, Account> selectAccountByIdAndRiskRating(Set<String> fieldSet, Set<Id> idSet, String globalRiskRating) {
    	return new Map<Id, Account>((List<Account>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :idSet AND Global_Risk_Rating__c = :globalRiskRating').toSOQL()));    
    }
    
    /**
     * This method is used to get Accounts by parentId.
     * @param Set<Id> parentAccountIdSet Account's parent Id set
     * @return  Map<Id, Account>
     */ 
    public Map<Id, Account> getAccountsByParentAccount(Set<Id> parentAccountIdSet){
        return new Map<Id, Account>((List<Account>) Database.query(newQueryFactory(false).setCondition('ParentId IN : parentAccountIdSet').toSOQL()));
    }
    
    public List<Account> selectSponsorAccBySearchString(String searchString, String countryCode, Set<String> fieldSet) {
        return (List<Account>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name LIKE :searchString and AccountCountry__c =:countryCode and RDCategorization__c =\'Sponsor\' and AccountStatus__c = \'Active\'').toSOQL());
    }
    
    public List<Account> selectSiteAccBySearchString(String searchString, String countryCode, Set<String> fieldSet) {
        return (List<Account>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name LIKE :searchString and AccountCountry__c =:countryCode and RDCategorization__c =\'Site\' and AccountStatus__c = \'Active\'').toSOQL());
    }
}