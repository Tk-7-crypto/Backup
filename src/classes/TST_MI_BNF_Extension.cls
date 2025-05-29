/**
Test Class for MI_BNF_Extension
Create By : Himanshu Parashar
Date: 08 Nov 2011 
Class : MI_BNF_Extension
*/
@isTest
private class TST_MI_BNF_Extension {
    
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
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        System.debug('Stage 1'+ Limits.getQueries());
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        System.debug('Stage 2'+ Limits.getQueries());
    } 
    
    
    //Test Method for MIBNF
    static testMethod void MIBNFTest() {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oliList[0]);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oliList[0].Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        ApexPages.StandardController sc = new ApexPages.StandardController(TestMIBNF);
        new MI_BNF_Extension();
        MI_BNF_Extension controller = new MI_BNF_Extension(sc);
        
        //updated by dheeraj kumar
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF_Comp.id );
        ApexPages.CurrentPage().getParameters().put('mibnfid' , TestMIBNF.id );
        MI_BNF_Comp_PDF compPDF = new MI_BNF_Comp_PDF();
        compPDF.getOpportunityLineItem();
        compPDF.GetBilling_Schedule_Items();
        compPDF.GetRevenue_Schedule_Items();
        system.Test.stopTest();
        
    }
    
    //Test Method for MIBNF
    static testMethod void MIBNFTestiframe() {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oliList[0]);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oliList[0].Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        // Refering MIBNF
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        new MI_BNF_Extension();
        MI_BNF_Extension controller = new MI_BNF_Extension();
        Test.stopTest();
        
    }
    
    // Test Method for MIBNF Component List
    static testMethod void MIBNF_CompTest()
    {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oliList[0]);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oliList[0].Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        ApexPages.StandardController sc = new ApexPages.StandardController(TestMIBNF);
        new MI_BNF_Extension();
        MI_BNF_Extension controller = new MI_BNF_Extension(sc);
        system.Test.stopTest();
    }
    
    // Test Method for MIBNF Component Creation using wizard
    static testMethod void MIBNF_CompNewRedirectTest()
    {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oliList[0]);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oliList[0].Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        ApexPages.StandardController sc = new ApexPages.StandardController(TestMIBNF);
        new MI_BNF_Extension();
        MI_BNF_Extension controller = new MI_BNF_Extension(sc);
        
        PageReference pg= controller.NewCBNF();
        system.Test.stopTest();
    }
    
    // Test Method for MIBNF Component Delete
    static testMethod void MIBNF_CompDelete()
    {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        ApexPages.StandardController sc = new ApexPages.StandardController(TestMIBNF);
        new MI_BNF_Extension();
        MI_BNF_Extension controller = new MI_BNF_Extension(sc);
        
        controller.setDeleteMIBNFCompID(TestMIBNF_Comp.id);
        controller.getDeleteMIBNFCompID();
        PageReference pg=controller.DeleteInvoice();
        
        system.Test.stopTest();
    }
    
    // Test Method for MIBNF Component Delete
    static testMethod void MIBNF_CompStopDelete()
    {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);
        //   PageReference pageRef = ApexPages.currentPage();
        //  test.setCurrentPageReference(pageRef);
        
        MI_BNF_Comp_Submit_Approval controller1 = new MI_BNF_Comp_Submit_Approval();
        
        PageReference pg=controller1.SubmitRequest();
        
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        ApexPages.StandardController sc = new ApexPages.StandardController(TestMIBNF);
        new MI_BNF_Extension();
        MI_BNF_Extension controller = new MI_BNF_Extension(sc);
        
        controller.setDeleteMIBNFCompID(TestMIBNF_Comp.id);
        controller.getDeleteMIBNFCompID();
        pg=controller.DeleteInvoice();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        system.Test.stopTest();
        
    }
    
    // Test Method for MIBNF Component Delete
    static testMethod void MIBNF_Delete()
    {
        
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=TestMIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=oliList[1].Id;
        MI_BNFLineItem.Total_Price__c=oliList[1].TotalPrice;
        insert MI_BNFLineItem;
        
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        ApexPages.StandardController sc = new ApexPages.StandardController(TestMIBNF);
        new MI_BNF_Extension();
        MI_BNF_Extension controller = new MI_BNF_Extension(sc);
        
        PageReference pg=controller.DeleteMIBNF();
        system.Test.stopTest();
    }
    // Test Method for Revenue Analyst field Error message
    static testMethod void revenueAnalystFieldMendatory()
    {
        Test.startTest();
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id, Opportunity__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF.id );
        MI_BNF_Extension controller = new MI_BNF_Extension();
        controller.revenueAnalystField();
        Test.stopTest();
    }
    
}