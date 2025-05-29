/**
* This test class is used to test all methods in Competitive Intelligence Request  trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_Competitive_Intelligence_Request {
    @isTest
    static void test() {
        Test.startTest();
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = 'Clinical';
        opp.StageName = CON_CRM.DEVELOPING_PROP_STAGE;
        opp.Amount = 6000000;
        opp.Early_Engagement_COE__c = 'Gastroenterology';
        insert opp;
        Competitive_Intelligence_Request__c comReq = new Competitive_Intelligence_Request__c();
        comReq.Opportunity__c = opp.Id;
        insert comReq;
        Test.stopTest();
    }
}