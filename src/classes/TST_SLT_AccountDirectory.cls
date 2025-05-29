@isTest
public class TST_SLT_AccountDirectory {
    
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Account_Directory__c accountDirectory = UTL_TestData.createAccountDirectoryData(CON_CPQ.ROLE_ADDITIONAL, account, CON_CPQ.CUSTOMER_NAME);
        insert accountDirectory;
    }
    
    @IsTest
    static void testSelectById() {
        Account_Directory__c accountDirectory = [SELECT Id, Account__c, Account__r.name, Approver_Name__c, Role__c FROM Account_Directory__c limit 1];	
        List<Account_Directory__c> accountDirectoryList1 = new SLT_AccountDirectory().selectById(new Set<Id> {accountDirectory.Id});
        List<Account_Directory__c> accountDirectoryList2 = SLT_AccountDirectory.selectAccountDirectoryByCondition(accountDirectory.Role__c,accountDirectory.Account__r.Name,accountDirectory.Approver_Name__c);
        System.assertEquals(accountDirectoryList1.size() > 0, true);
        System.assertEquals(accountDirectoryList2.size() > 0, true);
    }
}