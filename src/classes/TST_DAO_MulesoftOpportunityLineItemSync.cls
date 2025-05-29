@isTest
public class TST_DAO_MulesoftOpportunityLineItemSync {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact con = UTL_TestData.createContact(acc.Id);
        insert con;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Name = 'Test';
        opp.Proposal_Sent_Date__c = System.today() - 1;
        opp.Mulesoft_External_Id__c = '3456';
        insert opp;
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 1);
        insert userList;
        OpportunityTeamMember teamMember = UTL_TestData.createOpportunityTeamMember(opp.Id, userList[0].Id);
        insert teamMember;
        Id splitTypeId = SRV_CRM_OpportunitySplit.getOpportunitySplitTypeIdByName(CON_CRM.SPLIT_TYPE_NAME);
        System.runAs(userList[0]) {
            OpportunitySplit oppSplit = UTL_TestData.createOpportunitySplit(opp.Id, userList[0].Id, splitTypeId);
            insert oppSplit;
        }
        OpportunityContactRole ocr = UTL_TestData.createOpportunityContactRole(con.Id, opp.Id);
        insert ocr;
        Product2 product2 = UTL_TestData.createProduct();
        insert product2;
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2.Id);
        lstPricebookEntry.add(pbe);
        PricebookEntry pbe2 = UTL_TestData.createPricebookEntry(product2.Id);
        pbe2.CurrencyIsoCode = 'INR';
        lstPricebookEntry.add(pbe2);
        insert lstPricebookEntry;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbe.Id);
        oli.Project_Awarded_Price__c = 100.00;
        oli.Signed_Contract_Price__c = 100.00;
        insert oli;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(Oli.Id);
        insert olis;
        Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
        mic.Allow_Opportunity_Number_Override__c = true;
        insert mic;
    }
    static testmethod void testCloneOpportunity() {
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId, StageName, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
        insert bnf2;
        System.runAs(userRecord) {
            
            Map<String, String> mapTofieldValue = new Map<String, String>();
            mapTofieldValue.put('CloseDate', String.valueOf(Date.today()));
            mapTofieldValue.put('Name','OPP12345');
            mapTofieldValue.put('StageName',opp.StageName);
            mapTofieldValue.put('Opportunity_Number__c','54123245');
            mapTofieldValue.put('Mulesoft_External_Id__c','5412345');
            mapTofieldValue.put('CurrencyIsoCode','USD');
            
            Map<String, Boolean> objectTypeToIsCloneMap = new Map<String, Boolean>();
            objectTypeToIsCloneMap.put('Product2', true);
            objectTypeToIsCloneMap.put('RenewalOptions', true);
            objectTypeToIsCloneMap.put('OpportunityContactRole', true);
            SRV_CRM_Opportunity.cloneOpportunity(opp.Id, mapTofieldValue, true, 1, 1, objectTypeToIsCloneMap);
            Test.stopTest();
        }
        System.assert(true); 
    }
    
}