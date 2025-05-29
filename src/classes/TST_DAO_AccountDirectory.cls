@isTest
private class TST_DAO_AccountDirectory {

    @testSetup
    static void setUpTestData() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Account_Directory__c accountDirectory = UTL_TestData.createAccountDirectoryData(CON_CPQ.ROLE_ADDITIONAL, account, CON_CPQ.CUSTOMER_NAME);
        insert accountDirectory;
    }
    
    @isTest
    static void testInActiveOldRecord() {
        Account acc = [SELECT Id, Name FROM Account];
        try{            
            Account_Directory__c accountDirectory = UTL_TestData.createAccountDirectoryData(CON_CPQ.ROLE_ADDITIONAL, acc, CON_CPQ.CUSTOMER_NAME);
            insert accountDirectory;   
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(CON_CPQ.ACCOUNT_DIRECTORY_ERROR) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);            
        }
    }

}