@isTest
public class TST_BNF_schedule_Controller {
	@testSetup static void setupTestData(){
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        Current_Release_Version__c currentReleaseVersion = BNF_Test_Data.createCurrentReleaseVersionSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        BNF2__c TestBNF = BNF_Test_Data.createBNF();
    }
    
    public static testMethod void testMyController() {
		BNF2__c TestBNF = [Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c][0];
     	OpportunityLineItem oli = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
        							TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem][0];
        
        Test.starttest();
      
        PageReference pageRef = new PageReference('Page.BNF_Billing_Schedule');
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(TestBNF);
        BNF_schedule_Controller extension = new BNF_schedule_Controller(controller);
        
        BNF_Settings__c bnfSetting =BNF_Settings__c.getOrgDefaults();
        bnfSetting.BNF_Opportunity_Threshold__c = 9456453;
        upsert bnfSetting;
        BNF_schedule_Controller extension1 = new BNF_schedule_Controller(controller);
        
        bnfSetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfSetting;
        BNF_schedule_Controller extension2 = new BNF_schedule_Controller(controller);
        
        Test.stoptest();

    }
}