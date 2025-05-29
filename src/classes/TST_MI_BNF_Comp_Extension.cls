@isTest
private class TST_MI_BNF_Comp_Extension {
    
    static void setupTestData(){
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
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
    }
    
    // Test Method for DeleteProduct
    static testMethod void DeleteProductTest() {
        setupTestData();
        Test.startTest();
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> addressList = [SELECT Id FROM Address__c];
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert TestMIBNF;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, addressList);
        insert TestMIBNF_Comp;
        
        MI_BNF_Comp_Extension controller = new MI_BNF_Comp_Extension();
        controller.setMIBNF_CompId(TestMIBNF_Comp.id);
        controller.getMIBNF_CompId();
        
        controller.setSelectedInvoice(oliList[0].Id);
        controller.getSelectedInvoice();
        controller.MIBNF_Status='New';
        
        controller.deleteproduct();
        List<MI_BNF_LineItem__c> mibnflineitemList = [Select id, MIBNF_Component__c,Opportunity_Line_Itemid__c,Total_Price__c from  MI_BNF_LineItem__c];
        controller.MIBNFLineItemList = mibnflineitemList;
        controller.OLIItemList = oliList;
        controller.loadData();
        Test.stopTest();
    }
    
    // Test Method for Disable delete button from layout
    static testMethod void DeleteProductDisableTest() {
        setupTestData();
        Test.startTest();
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> addressList = [SELECT Id FROM Address__c];
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert TestMIBNF;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, addressList);
        insert TestMIBNF_Comp;
        
        MI_BNF_Comp_Extension controller = new MI_BNF_Comp_Extension();
        controller.setMIBNF_CompId(TestMIBNF_Comp.id);
        controller.getMIBNF_CompId();
        
        controller.setSelectedInvoice(oliList[0].Id);
        controller.getSelectedInvoice();
        controller.MIBNF_Status='Submitted';
        controller.deleteproduct();
        controller.loadData();
        
        Test.stopTest();
    }
    
    // Test Method for DeleteProduct
    static testMethod void t1() {
        setupTestData();
        Test.startTest();
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> addressList = [SELECT Id FROM Address__c];
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert TestMIBNF;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, addressList);
        insert TestMIBNF_Comp;
        
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        ApexPages.standardController sc = new ApexPages.standardController(TestMIBNF_Comp);
        
        MI_BNF_Comp_Extension controller = new MI_BNF_Comp_Extension(sc);
        controller.loadData();
        
        Test.stopTest();  
    }
    
    // Test Method for DeleteProduct
    static testMethod void isRevisedCheck() {
        setupTestData();
        Test.startTest();
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> addressList = [SELECT Id FROM Address__c];
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert TestMIBNF;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, addressList);
        insert TestMIBNF_Comp;
        
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        ApexPages.standardController sc = new ApexPages.standardController(TestMIBNF_Comp);
        
        MI_BNF_Comp_Extension controller = new MI_BNF_Comp_Extension(sc);
        controller.loadData();
        Test.stopTest();  
    }
}