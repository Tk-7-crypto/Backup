@isTest
private class TST_BCH_Qualtrics_CreateSurveyRcpOld {
    @TestSetUp static void setup(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opportunitynew = UTL_TestData.createOpportunity(acc.Id);  
        opportunitynew.StageName = CON_CRM.IN_HAND_STAGE; 
        insert opportunitynew;
        }
    @IsTest
    static void testSurveyRecpientDoesNotReturnResult() {     
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
        survey.Survey_Language_for_Recipient_1__c = Client_Sat_Survey__c.Survey_Language_for_Recipient_1__c.getDescribe().getPicklistValues()[1].getValue();
        listOfClientSatSurvey.add(survey);
        insert listOfClientSatSurvey;
        Test.startTest();
        BCH_Qualtrics_CreateSurveyRcpOld uca = new BCH_Qualtrics_CreateSurveyRcpOld();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        List<Client_Sat_Survey_Recipient__c> listOfSurveyRecipient = [Select Id, Name, Contact__c, First_Name__c, Survey_Send_Date__c,
                                                                      Last_Name__c, Qualtrics_Survey_Language__c, Survey_Type__c, Send_Survey__c
                                                                      from Client_Sat_Survey_Recipient__c];
        
        
        System.assertEquals(0, listOfSurveyRecipient.size(), 'Survey Recipient is inserted');
    }
    
    @IsTest
    static void testSurveyRecpientReturn1Result() {     
        List<Contact> listOfContact = new List<Contact>();
        Contact surveyContact = new Contact();
        surveyContact.firstName = 'testfirstname';
        surveyContact.lastName = 'test';
        listOfContact.add(surveyContact);
        insert listOfContact;
        Opportunity opp = [Select Id from opportunity where stageName =:CON_CRM.IN_HAND_STAGE limit 1];
        List<Client_Sat_Survey__c> listOfClientSatSurvey = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c survey = new Client_Sat_Survey__c();
        survey.Opportunity__c = opp.Id;
        survey.Send_Survey__c = 'Yes';
        survey.Survey_Send_Date__c = System.today();
        survey.Survey_Initiation_Status__c = 'Survey Approved';
        survey.Survey_Method__c = 'Web Survey';
        survey.Survey_Recipient_1__c = surveyContact.Id;
        survey.Survey_Language_for_Recipient_1__c = Client_Sat_Survey__c.Survey_Language_for_Recipient_1__c.getDescribe().getPicklistValues()[1].getValue();
        listOfClientSatSurvey.add(survey);
        insert listOfClientSatSurvey;
        Test.startTest();
        BCH_Qualtrics_CreateSurveyRcpOld uca = new BCH_Qualtrics_CreateSurveyRcpOld();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        List<Client_Sat_Survey_Recipient__c> listOfSurveyRecipient = [Select Id, Name, Contact__c, First_Name__c, Survey_Send_Date__c,
                                                                      Last_Name__c, Qualtrics_Survey_Language__c, Survey_Type__c, Send_Survey__c
                                                                      from Client_Sat_Survey_Recipient__c];
        
        
        System.assertEquals(1, listOfSurveyRecipient.size(), 'Survey Recipient is inserted');
        System.assertEquals(survey.Send_Survey__c, listOfSurveyRecipient[0].Send_Survey__c, 'Survey recipient is storing same value in survey');
        System.assertEquals(survey.Survey_Send_Date__c, listOfSurveyRecipient[0].Survey_Send_Date__c, 'Survey Recipient is storing same value in survey');
        System.assertEquals(surveyContact.LastName, listOfSurveyRecipient[0].Last_Name__c, 'Survey Recipient Name is same as contact');
    }
    
    @IsTest
    static void testSurveyRecpientReturn2Result() {     
        List<Contact> listOfContact = new List<Contact>();
        Contact surveyContact = new Contact();
        surveyContact.firstName = 'testfirstname';
        surveyContact.lastName = 'test';
        listOfContact.add(surveyContact);
        Contact surveyContact1 = new Contact();
        surveyContact1.firstName = 'testfirstname';
        surveyContact1.lastName = 'test 1';
        listOfContact.add(surveyContact1);
        insert listOfContact;
        Opportunity opp = [Select Id from opportunity where stageName =:CON_CRM.IN_HAND_STAGE limit 1];
        List<Client_Sat_Survey__c> listOfClientSatSurvey = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c survey = new Client_Sat_Survey__c();
        survey.Opportunity__c = opp.Id;
        survey.Send_Survey__c = 'Yes';
        survey.Survey_Send_Date__c = System.today();
        survey.Survey_Initiation_Status__c = 'Survey Approved';
        survey.Survey_Method__c = 'Web Survey';
        survey.Survey_Recipient_1__c = surveyContact.Id;
        survey.Survey_Recipient_2__c = surveyContact1.Id;
        survey.Survey_Language_for_Recipient_1__c = Client_Sat_Survey__c.Survey_Language_for_Recipient_1__c.getDescribe().getPicklistValues()[1].getValue();
        listOfClientSatSurvey.add(survey);
        insert listOfClientSatSurvey;
        Test.startTest();
        BCH_Qualtrics_CreateSurveyRcpOld uca = new BCH_Qualtrics_CreateSurveyRcpOld();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        List<Client_Sat_Survey_Recipient__c> listOfSurveyRecipient = [Select Id, Name, Contact__c, First_Name__c, Survey_Send_Date__c,
                                                                      Last_Name__c, Qualtrics_Survey_Language__c, Survey_Type__c, Send_Survey__c
                                                                      from Client_Sat_Survey_Recipient__c];
        
        
        System.assertEquals(2, listOfSurveyRecipient.size(), 'Survey Recipient is inserted');
        System.assertEquals(survey.Send_Survey__c, listOfSurveyRecipient[0].Send_Survey__c, 'Survey recipient is storing same value in survey');
        System.assertEquals(survey.Survey_Send_Date__c, listOfSurveyRecipient[0].Survey_Send_Date__c, 'Survey Recipient is storing same value in survey');
        System.assertEquals(survey.Send_Survey__c, listOfSurveyRecipient[1].Send_Survey__c, 'Survey recipient is storing same value in survey');
    }
    
    @IsTest
    static void testSurveyRecpientReturn3Result() {     
        List<Contact> listOfContact = new List<Contact>();
        Contact surveyContact = new Contact();
        surveyContact.firstName = 'testfirstname';
        surveyContact.lastName = 'test';
        listOfContact.add(surveyContact);
        Contact surveyContact1 = new Contact();
        surveyContact1.firstName = 'testfirstname';
        surveyContact1.lastName = 'test 1';
        listOfContact.add(surveyContact1);
        Contact surveyContact2 = new Contact();
        surveyContact2.firstName = 'testfirstname';
        surveyContact2.lastName = 'test 2';
        listOfContact.add(surveyContact2);
        insert listOfContact;
        Opportunity opp = [Select Id from opportunity where stageName =:CON_CRM.IN_HAND_STAGE limit 1];
        List<Client_Sat_Survey__c> listOfClientSatSurvey = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c survey = new Client_Sat_Survey__c();
        survey.Opportunity__c = opp.Id;
        survey.Send_Survey__c = 'Yes';
        survey.Survey_Send_Date__c = System.today();
        survey.Survey_Initiation_Status__c = 'Survey Approved';
        survey.Survey_Method__c = 'Web Survey';
        survey.Survey_Recipient_1__c = surveyContact.Id;
        survey.Survey_Recipient_2__c = surveyContact1.Id;
        survey.Survey_Recipient_3__c = surveyContact2.Id;
        survey.Survey_Language_for_Recipient_1__c = Client_Sat_Survey__c.Survey_Language_for_Recipient_1__c.getDescribe().getPicklistValues()[1].getValue();
        listOfClientSatSurvey.add(survey);
        insert listOfClientSatSurvey;
        Test.startTest();
        BCH_Qualtrics_CreateSurveyRcpOld uca = new BCH_Qualtrics_CreateSurveyRcpOld();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        List<Client_Sat_Survey_Recipient__c> listOfSurveyRecipient = [Select Id, Name, Contact__c, First_Name__c, Survey_Send_Date__c,
                                                                      Last_Name__c, Qualtrics_Survey_Language__c, Survey_Type__c, Send_Survey__c
                                                                      from Client_Sat_Survey_Recipient__c];
        
        
        System.assertEquals(3, listOfSurveyRecipient.size(), 'Survey Recipient is inserted');
        System.assertEquals(survey.Send_Survey__c, listOfSurveyRecipient[0].Send_Survey__c, 'Survey recipient is storing same value in survey');
        System.assertEquals(survey.Survey_Send_Date__c, listOfSurveyRecipient[0].Survey_Send_Date__c, 'Survey Recipient is storing same value in survey');
   		System.assertEquals(survey.Send_Survey__c, listOfSurveyRecipient[1].Send_Survey__c, 'Survey recipient is storing same value in survey');
        System.assertEquals(survey.Send_Survey__c, listOfSurveyRecipient[2].Send_Survey__c, 'Survey recipient is storing same value in survey');
    }
}