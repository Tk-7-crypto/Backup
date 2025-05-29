@isTest
public class TST_SCH_CRM_DeleteSurvey {
    @TestSetUp static void setup(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opportunitynew = UTL_TestData.createOpportunity(acc.Id);  
        opportunitynew.StageName = CON_CRM.IN_HAND_STAGE; 
        insert opportunitynew;
    }
    @IsTest
    static void testSurveyRecpientdelete() {     
        List<Contact> listOfContact = new List<Contact>();
        Contact surveyContact = new Contact();
        surveyContact.firstName = 'testfirstname';
        surveyContact.lastName = 'test';
        listOfContact.add(surveyContact);
        insert listOfContact;
        Opportunity opp = [Select Id from opportunity where stageName =:CON_CRM.IN_HAND_STAGE limit 1];
        List<Client_Sat_Survey__c> listOfClientSatSurvey = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c survey = new Client_Sat_Survey__c();
        survey.Survey_Recipient_1__c = surveyContact.Id;
        survey.Opportunity__c = opp.Id;
        survey.Survey_Send_Date__c = Date.today();
        survey.Survey_Language_for_Recipient_1__c = Client_Sat_Survey__c.Survey_Language_for_Recipient_1__c.getDescribe().getPicklistValues()[1].getValue();
        listOfClientSatSurvey.add(survey);
        insert listOfClientSatSurvey;
        Test.startTest();
        String cronExp = '0 0 13 * * ?';
        System.schedule('SCH_CRM_DeleteSurveyTest', cronExp, new SCH_CRM_DeleteSurvey());
        Test.stopTest();
    }
}