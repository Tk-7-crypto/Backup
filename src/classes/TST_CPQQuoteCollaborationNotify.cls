@isTest
public class TST_CPQQuoteCollaborationNotify {

    @testSetup
    static void setup() {
        Account account = UTL_OCE_TestData.createaccount();
        insert account;

        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;

        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];

        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createQuote();
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.RecordTypeId = recordType.Id;
        proposal.Apttus_Proposal__Opportunity__c = opportunity.Id;
        proposal.Select_Pricing_Tool__c = 'AMESA';
        proposal.OwnerId = UserInfo.getUserId();
        insert proposal;

        Apttus_Config2__ProductConfiguration__c productConfiguration = new Apttus_Config2__ProductConfiguration__c(Name = 'test', Apttus_QPConfig__Proposald__c = proposal.Id);
        insert productConfiguration;
        
        Apttus_Config2__CollaborationRequest__c collabRequest = new Apttus_Config2__CollaborationRequest__c(OwnerId = UserInfo.getUserId(), Apttus_Config2__Status__c = 'New', Apttus_Config2__ChildConfigurationId__c = productConfiguration.Id);
        insert collabRequest;
    }
    
    @isTest
    static void testIfAssigned(){
        
        Apttus_Config2__CollaborationRequest__c collabRequest = [SELECT OwnerId, Apttus_Config2__Status__c, Apttus_Config2__Priority__c FROM Apttus_Config2__CollaborationRequest__c];
        
        Test.startTest();
        collabRequest.Apttus_Config2__Status__c = 'Submitted';
        update collabRequest;
        Test.stopTest();
        
    }
    @isTest
    static void testIfUpdated(){
        
        Apttus_Config2__CollaborationRequest__c collabRequest = [SELECT OwnerId, Apttus_Config2__Status__c, Apttus_Config2__Priority__c FROM Apttus_Config2__CollaborationRequest__c];

        Test.startTest();
        collabRequest.Apttus_Config2__Priority__c = 'P1';
        update collabRequest;
        Test.stopTest();
    }
    @isTest
    static void testIfCompleted(){
        
        Apttus_Config2__CollaborationRequest__c collabRequest = [SELECT OwnerId, Apttus_Config2__Status__c, Apttus_Config2__Priority__c FROM Apttus_Config2__CollaborationRequest__c];
        
        Test.startTest();
        collabRequest.Apttus_Config2__Status__c = 'Completed';
        update collabRequest;
        Test.stopTest();
    }
    @isTest
    static void testIfAccepted(){
        
        Apttus_Config2__CollaborationRequest__c collabRequest = [SELECT OwnerId, Apttus_Config2__Status__c, Apttus_Config2__Priority__c FROM Apttus_Config2__CollaborationRequest__c];
        
        Test.startTest();
        collabRequest.Apttus_Config2__Status__c = 'Accepted';
        update collabRequest;
        Test.stopTest();
    }
    @isTest
    static void testIfCancelled(){
        
        Apttus_Config2__CollaborationRequest__c collabRequest = [SELECT Id, OwnerId, Apttus_Config2__Status__c, Apttus_Config2__Priority__c FROM Apttus_Config2__CollaborationRequest__c];
        
        Test.startTest();
        delete collabRequest;
        Test.stopTest();
    }
}
