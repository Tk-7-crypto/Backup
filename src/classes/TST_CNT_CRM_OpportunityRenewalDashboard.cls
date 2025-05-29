@isTest
public class TST_CNT_CRM_OpportunityRenewalDashboard {
    
    @testSetup
    public static void dataSetup(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        product.Item_Category_Group__c = 'test';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        OpportunityLineItemSchedule olis =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id); 
        insert olis;
        Renewal_Task__c rt = UTL_TestData.createRenewalTask(Opp.Id);
        insert rt;
        User u = UTL_TestData.createUser('System Administrator', 1)[0];
        u.LastName = 'Test Reassign User';
        insert u;
    }
    
    @isTest
    static void testGenerateRenewalTaskJson(){
        Test.StartTest();
        List<CNT_CRM_OpportunityRenewalDashboard.renewalTaskWrapper> rtw = CNT_CRM_OpportunityRenewalDashboard.generateRenewalTaskJson(null);
        Test.StopTest();
    }
    
    @isTest
    static void testSearchRenwalTasks(){
        Test.StartTest();
        Opportunity opp = [SELECT Id, Name, Account.Name, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<CNT_CRM_OpportunityRenewalDashboard.renewalTaskWrapper> rtw = CNT_CRM_OpportunityRenewalDashboard.searchRenwalTasks(opp.Opportunity_Number__c, opp.Name, opp.Account.Name, '', '');
        Test.StopTest();
    }
    
    @isTest
    static void testDeactiveRenewalTask(){
        Test.StartTest();
        Renewal_Task__c rt = [SELECT Id FROM Renewal_Task__c LIMIT 1];
        List<String> idList = new List<String>{rt.Id};
            String result = CNT_CRM_OpportunityRenewalDashboard.deactiveRenewalTask(idList);
        Test.StopTest();
    }
    
    @isTest
    static void testReassignRenewalTask(){
        Test.StartTest();
        Renewal_Task__c rt = [SELECT Id FROM Renewal_Task__c LIMIT 1];
        List<String> idList = new List<String>{rt.Id};
            String reassignUserId = [SELECT id FROM User WHERE LastName = 'Test Reassign User' LIMIT 1].Id;
        String result = CNT_CRM_OpportunityRenewalDashboard.reassignRenewalTask(reassignUserId, idList);
        Test.StopTest();
    }
    
    @isTest
    static void testFindUsersBySearchKey(){
        Test.StartTest();
        List<UTL_LookupSearchResult> searchResult = CNT_CRM_OpportunityRenewalDashboard.findUsersBySearchKey('Test Reassign');
        Test.StopTest();
    }
    
    @isTest
    static void testhandleSubmit1(){
        Test.StartTest();
        Renewal_Task__c rt = [SELECT Id, CurrencyIsoCode, Owner_Country__c FROM Renewal_Task__c];
        rt.Cloning_Status__c = 'Detail Clone';
        rt.No_Renew_Reason__c = '';
        rt.Targeted_Close_Date__c = system.today();
        rt.Data_Period_Shift__c = 12;
        rt.Price_Increase__c = 10;
        rt.Round_Up__c = true;
        List<Renewal_Task_Change_Detail__c> rtcd = new List<Renewal_Task_Change_Detail__c>();
        for(OpportunityLineItem oli: [SELECT Id FROM OpportunityLineItem]){
            Renewal_Task_Change_Detail__c rtc = new Renewal_Task_Change_Detail__c();
            rtc.Opportunity_Line_Item_Id__c = oli.Id;
            rtc.Dropped_Reason__c = null;
            rtcd.add(rtc);
        }
        String searchResult = CNT_CRM_OpportunityRenewalDashboard.handleSubmit(rt, rtcd);
        Test.StopTest();
    }
    
    @isTest
    static void testhandleSubmit2(){
        Test.StartTest();
        Renewal_Task__c rt = [SELECT Id, CurrencyIsoCode, Owner_Country__c FROM Renewal_Task__c];
        rt.Cloning_Status__c = 'Basic Clone';
        rt.No_Renew_Reason__c = '';
        rt.Targeted_Close_Date__c = system.today();
        rt.Data_Period_Shift__c = 12;
        rt.Price_Increase__c = 10;
        rt.Round_Up__c = true;
        List<Renewal_Task_Change_Detail__c> rtcd = new List<Renewal_Task_Change_Detail__c>();
        for(OpportunityLineItem oli: [SELECT Id FROM OpportunityLineItem]){
            Renewal_Task_Change_Detail__c rtc = new Renewal_Task_Change_Detail__c();
            rtc.Opportunity_Line_Item_Id__c = oli.Id;
            rtc.Dropped_Reason__c = 'Other';
            rtcd.add(rtc);
        }
        String searchResult = CNT_CRM_OpportunityRenewalDashboard.handleSubmit(rt, rtcd);
        Test.StopTest();
    }
    
    @isTest
    static void testhandleSubmit3(){
        Test.StartTest();
        Renewal_Task__c rt = [SELECT Id, CurrencyIsoCode, Owner_Country__c FROM Renewal_Task__c];
        rt.Cloning_Status__c = 'No Renew';
        rt.No_Renew_Reason__c = 'Other';
        List<Renewal_Task_Change_Detail__c> rtcd = new List<Renewal_Task_Change_Detail__c>();
        String searchResult = CNT_CRM_OpportunityRenewalDashboard.handleSubmit(rt, rtcd);
        Test.StopTest();
    }
}