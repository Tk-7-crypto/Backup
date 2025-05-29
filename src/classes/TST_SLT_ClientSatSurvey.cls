/*
* Version       : 1.0
* Description   : This test class is used for Select Client Sat Survey
*/
@isTest
private class TST_SLT_ClientSatSurvey {
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void setup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Client_Sat_Survey__c clientSatSurvey = UTL_TestData.createClientSatSurveyRecord('Test Survey', 'Yes', cnt.Id, opp.Id);
        clientSatSurvey.Survey_Send_Date__c = System.today();
        clientSatSurvey.Survey_Initiation_Status__c = 'Survey Approved';
        clientSatSurvey.Survey_Method__c = 'Web Survey';
        insert clientSatSurvey;
    }
    
    @IsTest
    private static void testGetClientSurveyByOpportunityAndCreatedDate() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Date Date6Back = Date.today().addMonths(-6); 
        Test.startTest();
            List<Client_Sat_Survey__c> surveyList = 
                new SLT_ClientSatSurvey().getClientSurveyByOpportunityAndCreatedDate(new Set<Id>{opp.Id}, Date6Back);
        Test.stopTest();
        
        System.assertEquals(1, surveyList.size(), 'Got Survey Record');
    }
    
    @IsTest
    private static void testGetClientSurveyById() {
        Client_Sat_Survey__c clientSurvey = [SELECT id FROM Client_Sat_Survey__c];
        Date Date6Back = Date.today().addMonths(-6); 
        Test.startTest();
            List<Client_Sat_Survey__c> surveyList = 
                new SLT_ClientSatSurvey().getClientSurveyById(new Set<Id>{clientSurvey.Id});
        Test.stopTest();
        
        System.assertEquals(1, surveyList.size(), 'Got Survey Record By Id');
    }

    @IsTest
    private static void testGetClientSurveyByIdAndStatus() {
        Client_Sat_Survey__c clientSurvey = [SELECT id FROM Client_Sat_Survey__c];
        Date Date6Back = Date.today().addMonths(-6); 
        Test.startTest();
            List<Client_Sat_Survey__c> surveyList = 
                new SLT_ClientSatSurvey().getClientSurveyByIdAndStatus(new Set<Id>{clientSurvey.Id}, new List<String> {CON_Qualtrics.SURVEY_APPROVED});
        Test.stopTest();
        
        System.assertEquals(1, surveyList.size(), 'Got Survey Record By Id');
    }
}