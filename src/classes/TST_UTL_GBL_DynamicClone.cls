@IsTest
private class TST_UTL_GBL_DynamicClone {
	@IsTest
    private static void testCloneObjects() {
        Account account = UTL_TestData.createAccount();
        Insert account;
        
        Test.startTest();
        	Account clonedAccount = (Account)UTL_GBL_DynamicClone.cloneObjects(new List<sObject>{(sObject)account}, account.getsObjectType())[0];
        Test.stopTest();
        
        System.assertEquals(true, clonedAccount.Name == 'TestAccount', 'Should clone record');
    }
}