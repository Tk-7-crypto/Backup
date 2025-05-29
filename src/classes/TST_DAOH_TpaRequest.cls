@isTest
private class TST_DAOH_TpaRequest {
	private static TPA_Request__c tpaRequest1;
    private static Contact tpaContact;
    private static Address__c testAccount;
    private static Address__c testClientAccount;
    
    static testMethod void myUnitTest() {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test client',1211);
        testClientAccount.City__c = 'test billing city';
        testClientAccount.State__c = 'test billing state';
        update testClientAccount;
        
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
        tpaRequest1.Client_Address__c = testClientAccount.id;
        date strtDate = date.newInstance(2014, 1, 1);
        tpaRequest1.Data_Access_Start_Date__c = strtDate.addDays(-5);
        update tpaRequest1;
    }
}