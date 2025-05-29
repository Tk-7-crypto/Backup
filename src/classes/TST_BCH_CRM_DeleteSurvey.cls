@isTest
public class TST_BCH_CRM_DeleteSurvey {
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
        BCH_CRM_DeleteSurvey uca = new BCH_CRM_DeleteSurvey();
        uca.datebefore7Days = Date.today();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }
}