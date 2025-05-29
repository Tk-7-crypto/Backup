@isTest
public class TST_MIBNF_schedule_Controller {
	@testSetup static void setupTestData(){
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        List<Address__c> TestAddress_Array = UTL_TestData.createAddresses(TestAccount);
        insert TestAddress_Array;
    }
    
    public static testMethod void testMyController() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        OpportunityLineItem oli = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
        							TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem][0];
        
        Test.starttest();
        
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oli);
        insert TestMI_BNFLineItem;
      
        PageReference pageRef = new PageReference('Page.MIBNF_Billing_Schedule');
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(TestMIBNF_Comp);
        MIBNF_schedule_Controller extension = new MIBNF_schedule_Controller(controller);
        
        BNF_Settings__c bnfSetting =BNF_Settings__c.getOrgDefaults();
        bnfSetting.BNF_Opportunity_Threshold__c = 9456453;
        upsert bnfSetting;
        MIBNF_schedule_Controller extension1 = new MIBNF_schedule_Controller(controller);
        
        bnfSetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfSetting;
        MIBNF_schedule_Controller extension2 = new MIBNF_schedule_Controller(controller);
        
        Test.stoptest();

    }
}