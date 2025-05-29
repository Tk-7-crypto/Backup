@isTest
private class TST_SLT_Application {

    @isTest
    static void testGetApplicationByName() {
        Apttus_XApps__Application__c testApplication = UTL_TestData.createApplication();
        testApplication.Apttus_XApps__UniqueId__c = 'abcd';
        testApplication.Name = 'abcd';
        insert testApplication;
        List<Apttus_XApps__Application__c> applicationList;

        Test.startTest();
            applicationList = new SLT_Application().getApplicationByName(new Set<String>{'abcd'}, new Set<String>{'Id'});
        Test.stopTest();

        System.assertEquals(true, applicationList.size()>0, 'Should return application List');
    }
}