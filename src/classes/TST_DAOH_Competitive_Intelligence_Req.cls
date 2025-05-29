/**
* This test class is used to test all methods in Competitive Intelligence Request  trigger.
* version : 1.0
*/
@isTest
Private class TST_DAOH_Competitive_Intelligence_Req {
    /*
     * Method to use for set dummy data.
     */ 
    @testSetup
    static void dataSetup() {
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
    @isTest
    static void test() {
        Test.startTest();
        Competitive_Intelligence_Request__c comReq = [Select id from Competitive_Intelligence_Request__c limit 1];
        comReq.Status__c = 'Completed';
        update comReq;
        Test.stopTest();
    }
}