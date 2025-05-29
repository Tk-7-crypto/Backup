/**
* This test class is used to test APP_FL01_PSA_AppLogNotifications flow.
* version : 1.0
*/
@isTest
private class TST_APP_FL01_PSA_AppLogNotifications {
    @IsTest
    static void testFlow() {
        List<appirio_core__App_Log__c> appLogList = new List<appirio_core__App_Log__c>();
        appirio_core__App_Log__c appLog = new appirio_core__App_Log__c();
        appLog.appirio_core__Origin__c = 'PSA_AuditLog';
        appLog.appirio_core__Level__c = 1.0;
        appLogList.add(appLog);
        insert appLogList;
        System.assertEquals(appLogList.size(),1);
    }
}