@isTest(SeeAllData=false)
private class TST_UTL_TPA_Class_LoginAPI { 

    @isTest static void test_login() {
        Privacy_Policy_TPA__c settingObj = UTL_TPA_SetupTestData.getPrivacyPolicySetting();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_TPA_MockHttpResponseGenerator());
        UTL_TPA_Class_LoginAPI.login(settingObj.ContractUserName__c, settingObj.ContractPassword__c);
        Test.stopTest();
    }
}