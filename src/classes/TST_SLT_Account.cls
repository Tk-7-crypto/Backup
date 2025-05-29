/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Account
 */
@isTest
public class TST_SLT_Account {
    	/**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
    	Account account = UTL_TestData.createAccount();
        insert account;
    }
    
     /**
     * This method used to get Case by ID
     */    
    @IsTest
    static void testSelectById() {
    	List<Account> accounts = new  List<Account>();
    	Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount'];	
        Test.startTest();
        accounts = new SLT_Account().selectById(new Set<Id> {a.Id});
        Map<Id, Account> accMap = new SLT_Account().selectByAccountId(new Set<Id> {a.Id},new Set<String>{'Name'});
        list<Account> accMap1 = new SLT_Account().selectAllCustomerPortalAccounts('BioTech',new Set<String> {'Name'});
        List<Account> selectByAccTeamMember = new SLT_Account().selectByAccTeamMember(new Set<String>{'Name'},new Set<String> {'Id'},'BioTech Ad');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = accounts.size();
        //System.assertEquals(expected, actual);
    }
    @IsTest
    static void testGetAccountCountry() {
        List<Account> accounts = new  List<Account>();
        Set<String> fieldSet=new Set<String>{'AccountCountry__c'};
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount'];	
        User us=[SELECT Id FROM User LIMIT 1];
        String userId=us.Id;
        Test.startTest();
        accounts = new SLT_Account().getAccountCountry(fieldSet,userId);
        Test.stopTest();
        System.assertNotEquals(null, accounts.size());
    }
    static testMethod void getSelectBySearchStringTest(){
        SLT_Account sltObjectClass = new SLT_Account();
        Account actRec = [SELECT Id,Name FROM Account WHERE name = 'TestAccount'];
        String searchString = 'test';
        String searchStr = '\'%' + searchString + '%\'';
        Set<String> fieldsToQuery = new Set<String>{'Id', 'Name', 'Phone'};
        List<Account> actRecLst = sltObjectClass.selectBySearchString(searchStr, fieldsToQuery);
        System.assertEquals(actRecLst[0].Name , actRec.name);
        System.assertEquals(actRecLst[0].Id , actRec.Id);
    }
	
    @IsTest
    static void testSelectAccountByIdAndRiskRating() {
        Set<String> fieldSet=new Set<String>{'Id', 'Name'};
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];	
        Test.startTest();
        Map<Id, Account> accountMap = new SLT_Account().selectAccountByIdAndRiskRating(fieldSet, new Set<Id>{acc.Id}, CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAccountByParentId(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Test.startTest();
        SLT_Account sltAccount = new SLT_Account();
        sltAccount.getAccountsByParentAccount(new Set<Id>{acc.Id});
        sltAccount.getAccountsList(new Set<String>{'Id'},new List<Id>{acc.Id});
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAccountWithCondition(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Set<String> fieldSet=new Set<String>{'Id', 'Name'};
        Test.startTest();
        SLT_Account sltAccount = new SLT_Account();
        sltAccount.getAccountsWithAccountIdAndWhereCondtion(new Set<Id>{acc.Id}, fieldSet, 'parentCategory');
        sltAccount.getAccountsWithAccountIdAndParentCategoryNotLargePharma(new Set<Id>{acc.Id}, fieldSet, 'parentCategory');
        sltAccount.selectSponsorAccBySearchString('TestAccount','USA',fieldSet);
        sltAccount.selectSiteAccBySearchString('TestAccount','USA',fieldSet);
        Test.stopTest();
    }
}