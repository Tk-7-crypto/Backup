@isTest
public class TST_SCH_CRM_SendEmailToClosedOpp {
    
    @testSetup
    static void dataSetup() {
        
        Profile profile1 = [SELECT Id FROM Profile WHERE Name =: 'System Administrator' LIMIT 1];
        String UserName = 'testUser1@testGroupUpdate.com'+UserInfo.getOrganizationId();
        User testUser1 = new User(ProfileId = profile1.Id, UserName = UserName,
                                  Email = 'test@iqvia.com', EmailenCodingKey = 'UTF-8', LocalesIdKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', TimeZonesIdKey = 'America/Los_Angeles', Alias = 'extUser',IsActive = true,
                                  LastName = 'lastname', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '0909090918' , Region__c = 'Europe/Middle East/Africa EMEA');
        insert testUser1;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        
        CRM_Config__c settings = CRM_Config__c.getOrgDefaults();
        settings.Opportunity_FPI_date__c = Null;
        settings.Opportunity_Last_Modified_Date__c = Null;
        upsert settings CRM_Config__c.Id;

        
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Competitor__c testCompetitor = new Competitor__c();
        testCompetitor.Name = 'Test Competitor';
        
        insert testCompetitor;
        
        Opportunity opportunityRecord = UTL_TestData.createOpportunity(acc.id);
        opportunityRecord.OwnerId = testUser1.id;
        opportunityRecord.CloseDate = Date.today().ADDMONTHS(12);
        opportunityRecord.StageName = '1. Identifying Opportunity';
        opportunityRecord.Potential_Competitor_1__c = testCompetitor.id;
        opportunityRecord.StageName = '7b. Closed Lost';
        opportunityRecord.Line_of_Business__c = 'Clinical';
        opportunityRecord.Loss_Type__c = 'Non-competitive bid';
        opportunityRecord.FPI_Date__c = Date.today().ADDMONTHS(9);
        opportunityRecord.Path_Probability__c = 'Potential';
        insert opportunityRecord;
    }
    
    @IsTest
    static void schedulerTest(){
        User user1 = [Select id from User where Email = 'test@iqvia.com' limit 1];
        Test.startTest();
        SCH_CRM_SendEmailToClosedOpp sch = new SCH_CRM_SendEmailToClosedOpp();
        sch.scheduleBatch('Select id from User Where Id =  \''+user1.id+'\''); 
        Test.stopTest(); 
    }
}