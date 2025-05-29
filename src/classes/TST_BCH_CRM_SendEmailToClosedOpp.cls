@isTest
public class TST_BCH_CRM_SendEmailToClosedOpp {
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
        insert opportunityRecord;
    }
    
    @isTest
    public static void testexecute() {
       
        User user1 = [Select id from User where Email = 'test@iqvia.com' limit 1];
        
        Opportunity opps= [Select id,FPI_Date__c,Path_Probability__c,StageName,Line_of_Business__c,Loss_Type__c from Opportunity where OwnerId =: user1.id limit 1];
        
        opps.StageName = '7b. Closed Lost';
        opps.Line_of_Business__c = 'Clinical';
        opps.Loss_Type__c = 'Non-competitive bid';
        opps.FPI_Date__c = Date.today().ADDMONTHS(9);
        opps.Path_Probability__c = 'Potential';
        
        update opps;
        
        
        Test.startTest();
        Id batchId = Database.executeBatch(new BCH_CRM_SendEmailToClosedOpp('Select id from User Where Id =  \''+user1.id+'\''),1);
        Test.stopTest();
    }

}