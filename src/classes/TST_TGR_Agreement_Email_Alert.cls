@isTest
private class TST_TGR_Agreement_Email_Alert {
    @testSetup
    static void dataSetup(){
        Agreement_Email_Alert__c emailAlert = new Agreement_Email_Alert__c();
        emailAlert.Alerting_Email__c = 'test@test.com';
        insert emailAlert;
    }
    
    @isTest
    static void test(){
        Agreement_Email_Alert__c emailAlert = [Select Id from Agreement_Email_Alert__c limit 1];
        Test.startTest();
        update emailAlert;
        Test.stopTest();
    }
}