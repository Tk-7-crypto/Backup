@isTest
public class TST_BCH_CRM_CreateBoxAssociations_Opp {
    @isTest static void testCreateBoxAssociation_Opportunities() {
        Account acc = new Account(Name='TestAccount',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE'); 
        insert acc;
        Opportunity opp = new Opportunity(AccountId=acc.Id, StageName='3. Developing Proposal', Name='TestOpportunity', 
                                          CloseDate=System.today(), Quintiles_Opportunity_Box_ID__c='1234567890');
        insert opp;

        Test.startTest(); 
        	Database.executeBatch(new BCH_CRM_CreateBoxAssociations_Opp());
        Test.stopTest();
    }
}