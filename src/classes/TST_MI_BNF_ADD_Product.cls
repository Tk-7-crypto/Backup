/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TST_MI_BNF_ADD_Product {
    
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
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
    }
    
    static testMethod void SaveTest() {
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        
        MIBNF2__c TestMIBNF = [SELECT id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oliList[0]);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oliList[0].Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        ApexPages.CurrentPage().getParameters().put('prdids' , oliList[1].id + ',' + oliList[3].id);
        ApexPages.CurrentPage().getParameters().put('minfid' , TestMIBNF.id);
        
        MI_BNF_ADD_Product controller = new MI_BNF_ADD_Product();
        controller.selectedInvoice=TestMIBNF_Comp.Id;
        PageReference pageRef=controller.Save();
        Test.stopTest();
        
    }
    
    static testMethod void Cancel() {
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oliList[0]);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oliList[0].Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        ApexPages.CurrentPage().getParameters().put('prdids' , oliList[0].id + ',' + oliList[2].id);
        ApexPages.CurrentPage().getParameters().put('minfid' , TestMIBNF.id);
        
        MI_BNF_ADD_Product controller = new MI_BNF_ADD_Product();
        controller.selectedInvoice=TestMIBNF_Comp.Id;
        PageReference pageRef=controller.Cancel();
        Test.stopTest();
    }
}