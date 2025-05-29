@isTest
private class TST_CNT_CPQ_AccountDirectoryDetails {
    
    @testSetup
    static void setUpTestData() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Account_Directory__c accountDirectory = UTL_TestData.createAccountDirectoryData(CON_CPQ.ROLE_ADDITIONAL, account, CON_CPQ.CUSTOMER_NAME);
        insert accountDirectory;
    }
    
    @isTest
    static void testGetSelectOptions() { 
        List<String> optionsList = new List<String> ();
        
        Test.startTest();
        optionsList = CNT_CPQ_AccountDirectoryDetail.getSelectOptions(new Account_Directory__c(),CON_CPQ.ROLE_FIELD);
        Test.stopTest(); 
        
        System.assertEquals(optionsList.size() > 0, true, 'Picklist field value fetched successfully');
    }
    
    @isTest
    static void testGetValueSet() {
        List<String> optionsList1 = new List<String> ();
        List<String> optionsList2 = new List<String> ();
        
        Test.startTest();
        optionsList1 = CNT_CPQ_AccountDirectoryDetail.getValueSet(new Account_Directory__c(),CON_CPQ.CUSTOMER_NAME_FIELD);
        optionsList2 = CNT_CPQ_AccountDirectoryDetail.getValueSet(new Account_Directory__c(),CON_CPQ.ACCOUNT_FIELD);
        Test.stopTest();
        System.assertEquals(optionsList1.size() > 0, true, 'Picklist field value fetched successfully');
        System.assertEquals(optionsList2.size() > 0, true, 'Picklist field value fetched successfully');
    }
    
    @isTest
    static void testGetAccountDirectoryData() {
        
        Account account = [SELECT Id, Name From Account limit 1];
        Test.startTest();
            List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryWrapper> accountDirectoryWrapperList = CNT_CPQ_AccountDirectoryDetail.getAccountDirectoryData(CON_CPQ.ROLE_ADDITIONAL, account.Name, CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
        
        System.assertEquals(true, accountDirectoryWrapperList.size() > 0, 'Should return Account Directory Wrapper List');
    }

    @isTest
    static void testUpdateCountrySalesHead() {
    
        Account_Directory__c accountDirectory = [SELECT Id, Name FROM Account_Directory__c LIMIT 1];
        List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryCustomerWrapper> accountDirectoryCustomerWrapper = new List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryCustomerWrapper>();
        accountDirectoryCustomerWrapper.add(new CNT_CPQ_AccountDirectoryDetail.AccountDirectoryCustomerWrapper(accountDirectory));
        List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryWrapper> accountDirectoryWrapperList = new List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryWrapper>();
        accountDirectoryWrapperList.add(new CNT_CPQ_AccountDirectoryDetail.AccountDirectoryWrapper(CON_CPQ.COUNTRY,accountDirectoryCustomerWrapper,true,true));

        Test.startTest();            
            CNT_CPQ_AccountDirectoryDetail.updateAccountDirectory(JSON.serialize(accountDirectoryWrapperList));
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteCountrySalesHead() {
    
        Account_Directory__c accountDirectory = [SELECT Id, Name FROM Account_Directory__c LIMIT 1];
        List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryCustomerWrapper> accountDirectoryCustomerWrapper = new List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryCustomerWrapper>();
        accountDirectoryCustomerWrapper.add(new CNT_CPQ_AccountDirectoryDetail.AccountDirectoryCustomerWrapper(accountDirectory));
        List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryWrapper> accountDirectoryWrapperList = new List<CNT_CPQ_AccountDirectoryDetail.AccountDirectoryWrapper>();
        accountDirectoryWrapperList.add(new CNT_CPQ_AccountDirectoryDetail.AccountDirectoryWrapper(CON_CPQ.COUNTRY,accountDirectoryCustomerWrapper,true,true));

        Test.startTest();            
            CNT_CPQ_AccountDirectoryDetail.deleteAccountDirectory(JSON.serialize(accountDirectoryWrapperList));
        Test.stopTest();
    }

}