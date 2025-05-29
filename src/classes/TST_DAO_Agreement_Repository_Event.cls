@IsTest
public class TST_DAO_Agreement_Repository_Event {
    @isTest
    private static void testAgreementRepositoryEvent() {
        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        IQVIA_Agreement__c agreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        agreement.Name = 'Test IQVIA Agreement';
        agreement.Account__c = account.Id;
        agreement.Services__c = 'FMV Navigator';
        insert agreement;
        
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '1. Identifying Opportunity';
        insert newOpportunity;
        
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(account);
        insert addressList;
        
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(newOpportunity, revenueAnalyst);
        insert TestMIBNF;
        
        MIBNF_Component__c mic= UTL_TestData.createMIBNF_Comp(TestMIBNF, addressList);
        mic.BNF_Status__c = 'New';
        insert mic;
        
        Test.startTest();
            List<Agreement_Repository_Event__e> events = new List<Agreement_Repository_Event__e>();
            Agreement_Repository_Event__e arEvent1 = new Agreement_Repository_Event__e(AR_Comments__c = 'Test1', Object_Name__c = 'IQVIA_Agreement__c', Record_Id__c = agreement.Id);
            Agreement_Repository_Event__e arEvent2 = new Agreement_Repository_Event__e(AR_Comments__c = 'Test2', Object_Name__c = 'Opportunity', Record_Id__c = newOpportunity.Id);
            Agreement_Repository_Event__e arEvent3 = new Agreement_Repository_Event__e(AR_Comments__c = 'Test3', Object_Name__c = 'MIBNF_Component__c', Record_Id__c = mic.Id);       
            events.add(arEvent1);
            events.add(arEvent2); 
            events.add(arEvent3); 
            EventBus.publish(events);        
        Test.stopTest();

        IQVIA_Agreement__c agr = [Select Id, Name, Agreement_Repository_Number__c From IQVIA_Agreement__c Where Name ='Test IQVIA Agreement' LIMIT 1];
        Opportunity opp = [Select Id, Name, AR_Comments__c From Opportunity Where stageName = '1. Identifying Opportunity' LIMIT 1];
        MIBNF_Component__c miBNf = [Select Id, AR_Comments__c From MIBNF_Component__c where BNF_Status__c = 'New'];       

        System.assertEquals('Test1', agr.Agreement_Repository_Number__c, 'Sould be same');
        System.assertEquals('Test2', opp.AR_Comments__c, 'Sould be same');
        System.assertEquals('Test3', miBNf.AR_Comments__c, 'Sould be same');            
    }
}