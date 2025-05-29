@isTest
public class TST_BCH_CRM_sendEmailToOppOwner {
    
    @IsTest
    static void testexecute() {
        
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
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opportunityRecord = UTL_TestData.createOpportunity(acc.id);
        opportunityRecord.OwnerId = testUser1.id;
        opportunityRecord.CloseDate = Date.today().addDays(-100);
        opportunityRecord.StageName = '1. Identifying Opportunity';
        insert opportunityRecord;
        
        
        Test.startTest();
        Id batchId = Database.executeBatch(new BCH_CRM_sendEmailToOppOwner('Select id from User Where Id =  \''+testUser1.id+'\''),1);
        Test.stopTest();
    }
}