@isTest
public class TST_BCH_CRM_USRenewalsAutomation {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact con = UTL_TestData.createContact(acc.Id);
        insert con;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Name = 'Test';
        opp.Proposal_Sent_Date__c = system.today() - 2;
        insert opp;
        opp.Opportunity_Number__c = '123123';
		opp.Is_this_a_Renewable_Opportunity__c  = 'Yes';
        opp.In_Hand_Stage_Entry__c = system.today()-1;
        update opp;
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 1);
        insert userList;
        OpportunityContactRole ocr = UTL_TestData.createOpportunityContactRole(con.Id, opp.Id);
        insert ocr;
        Product2 product2 = UTL_TestData.createProduct();
        insert product2;
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2.Id);
        insert pbe;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbe.Id);
        insert oli;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(Oli.Id);
        insert olis;
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.Id);
        insert proxyProject;
        Proxy_SCM_Agreement__c proxySCMAgreement = UTL_TestData.createProxySCMAgreement(opp.Id);
        insert proxySCMAgreement;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        for(Integer index = 0; index < addressList.size(); index++) {
            addressList[index].MDM_Validation_Status__c = 'Validated';
            addressList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        //CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
    }
    
    static testMethod void testexecute() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c,StageName,Opportunity_Auto_Number__c FROM Opportunity LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            Test.startTest();
            Id batchId = Database.executeBatch(new BCH_CRM_USRenewalsAutomation(opp.id),1);
            Test.stopTest();
        }
    }
}