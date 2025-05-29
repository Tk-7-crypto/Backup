@isTest
public class TST_BCH_CRM_SendEmailLostfor30days {
    
    @testSetup
    static void dataSetup() {
        Profile profile1 = [SELECT Id FROM Profile WHERE Name =: 'System Administrator' LIMIT 1];
        String UserName = 'testUser1@testGroupUpdate.com';
        User testUser1 = new User(ProfileId = profile1.Id, UserName = UserName,
                                  Email = 'test@iqvia.com', EmailenCodingKey = 'UTF-8', LocalesIdKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', TimeZonesIdKey = 'America/Los_Angeles', Alias = 'extUser',IsActive = true,
                                  LastName = 'lastname', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '090909091002' , Region__c = 'Europe/Middle East/Africa EMEA');
        insert testUser1;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opportunityRecord = UTL_TestData.createOpportunity(acc.id);
        opportunityRecord.OwnerId = testUser1.id;
        opportunityRecord.StageName = '7b. Closed Lost';
        opportunityRecord.Line_of_Business__c = 'Clinical';
        opportunityRecord.Loss_Type__c = 'Loss details to be confirmed';
        insert opportunityRecord;
        opportunityRecord.X7b_Closed_Lost_Stage_Entry__c = Date.Valueof(System.today().addDays(-30));
        update opportunityRecord;
    }
    
    static testMethod void testexecute() {
        String UserName = 'testUser1@testGroupUpdate.com';
        User user1 = [Select id from User where UserName =: UserName limit 1];
        Test.startTest();
        Id batchId = Database.executeBatch(new BCH_CRM_SendEmailLostfor30days('Select id from User Where Id =  \''+user1.id+'\''),1);
        Test.stopTest();
    }

}