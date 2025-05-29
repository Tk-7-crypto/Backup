@isTest
private class TST_BCH_Qualtrics_CS_CreateSurveyForm {
    @TestSetup static void setup() {
        Profile profile1 = [SELECT Id FROM Profile WHERE Name =: 'System Administrator' LIMIT 1];
        String UserName = 'testUser1@testGroupUpdate.com'+UserInfo.getOrganizationId();
        User testUser1 = new User(ProfileId = profile1.Id, UserName = UserName,
                                  Email = 'externalUser@bluewolf.com', EmailenCodingKey = 'UTF-8', LocalesIdKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', TimeZonesIdKey = 'America/Los_Angeles', Alias = 'extUser',
                                  LastName = 'lastname', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '0909090918');
        insert testUser1;
    }
    
    @IsTest
    static void testsendMailNotification() { 
        BCH_Qualtrics_CS_CreateSurveyForm batchClass = new BCH_Qualtrics_CS_CreateSurveyForm();
        Test.startTest();
        BCH_Qualtrics_CS_CreateSurveyForm.sendMailNotification('Cannot create Survey');
        List<Workflow_Email_Record__c> workflow = [select id from Workflow_Email_Record__c LIMIT 1];
        Test.stopTest();
        
        system.assertEquals(1, workflow.size(), 'An email should be sent');
    }
    
    @IsTest
    static void testsendErrorMailNotification() { 
        
        BCH_Qualtrics_CS_CreateSurveyForm batchClass = new BCH_Qualtrics_CS_CreateSurveyForm();
        Test.startTest();
        BCH_Qualtrics_CS_CreateSurveyForm.sendErrorMailNotification('Cannot create Survey', 'test Group', 'test@test.com');
        List<Workflow_Email_Record__c> workflow = [select id from Workflow_Email_Record__c LIMIT 1];
        Test.stopTest();
        
        system.assertEquals(1, workflow.size(), 'An email should be sent');
    }
    
    @IsTest
    static void testForClientSetSurveyInsertResult() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Product X',ProductCode = 'Pro-X',isActive = true, Offering_Type__c ='Commercial Tech',Material_Type__c='ZREP',Offering_Segment__c='Commercial Solutions');
        prod.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
        List<user> users = [Select id from user limit 1];
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact con = UTL_TestData.createContact(acc.Id);
        con.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        con.Salesforce_User__c = users[0].Id;
        con.Survey_Opt_Out__c = false;
        insert con;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity opportunityRecord = new Opportunity(Name = 'Test Opportunity', StageName = '7a. Closed Won',Is_this_IQVIA_Biotech__c = 'No' ,CloseDate = Date.today(),
                                                        Actual_Close_Date__c = Date.today().addDays(-30),Conversion_Rate_To_USD__c = 1,  accountId = acc.Id, Potential_Competitor_1__c = comp.Id,
                                                        Survey_Recipient__c = con.Id, Awarded_Date__c = Date.today().addYears(-1).addDays(-2),Signed_Contract_Date__c = Date.today(),
                                                        Line_of_Business__c = 'Connected Devices',Contract_Start_Date__c = Date.today().addYears(-1), Contract_End_Date__c = Date.today(),
                                                        Previous_survey_sent_date__c = Date.today().addMonths(-6), Early_Engagement_COE__c = 'Not Applicable', Path_Probability__c = 'Verbal',Phase_P__c =  'Phase 1',
                                                        Expected_Project_Start_Date__c = Date.today().addYears(-1), Expected_Project_End_Date__c = Date.today(), Proposal_Sent_Date__c = system.today(),Indication_List__c = indication.Id,
                                                        Upcoming_Survey_Send_Date__c = Date.today(), Next_Survey_Send_Date__c = Date.today(),
                                                        US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today());
        Opportunity opportunitynew = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today(), Potential_Competitor_1__c = comp.Id,
                                                    Actual_Close_Date__c = Date.today().addDays(-30), Conversion_Rate_To_USD__c = 1,   accountId = acc.Id,
                                                    Survey_Recipient__c = con.Id ,Contract_Start_Date__c = Date.today().addYears(-1), Contract_End_Date__c = Date.today(),Phase_P__c =  'Phase 1',
                                                    Previous_survey_sent_date__c = Date.today().addMonths(-12), Early_Engagement_COE__c = 'Not Applicable', Path_Probability__c = 'Verbal',Indication_List__c = indication.Id,
                                                    Upcoming_Survey_Send_Date__c = Date.today(), Next_Survey_Send_Date__c = Date.today(),
                                                    US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today());
                                                     
        List<Opportunity> opportunityList = new List<Opportunity>{opportunityRecord, opportunitynew};
            insert opportunityList;
        Contact projectLead = UTL_TestData.createContact(acc.id);
        projectLead.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        projectLead.Salesforce_User__c = users[0].Id;
        insert projectLead;
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opportunitynew.Id, pse__IsServicesProductLine__c = true,Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 20000,
                                                               PricebookEntryId = pbEntry.Id,Project_Start_Date__c=Date.today().addYears(-2),
                                                               Project_End_Date__c=Date.today().addYears(2), Therapy_Area__c= 'Hepatitis C [21]', Product_Material_Type_Text__c = 'ZREP');
        OpportunityLineItem lineItem2 = new OpportunityLineItem(OpportunityId = opportunityRecord.Id, pse__IsServicesProductLine__c = true,Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 20000,
                                                               PricebookEntryId = pbEntry.Id,Project_Start_Date__c=Date.today().addYears(-2),
                                                               Project_End_Date__c=Date.today().addYears(2), Therapy_Area__c= 'Hepatitis C [21]', Product_Material_Type_Text__c = 'ZREP');
        List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>{lineItem, lineItem2};
        insert lineItemList;
        Test.startTest();
        BCH_Qualtrics_CS_CreateSurveyForm uca = new BCH_Qualtrics_CS_CreateSurveyForm();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        
        List<Client_Sat_Survey__c> listOfClientSurvey = [SELECT Id, Name,Opp_Engagement__c, Survey_Initiation_Status__c
                                                         FROM Client_Sat_Survey__c];
        
        System.assertNotEquals(true, listOfClientSurvey.isEmpty(), 'Survey is created');
    }
    
}