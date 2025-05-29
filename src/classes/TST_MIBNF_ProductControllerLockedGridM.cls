@isTest
public class TST_MIBNF_ProductControllerLockedGridM {
    
    @testSetup 
    static void setupTestData(){
        UTL_ExecutionControl.stopTriggerExecution = true;
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        User u = BNF_Test_Data.createUser();
        Account TestAccount = BNF_Test_Data.createAccount();
        Contact cnt = UTL_TestData.createContact(TestAccount.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = u.id;
        insert cnt;
        
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        UTL_ExecutionControl.stopTriggerExecution = false;
        Opportunity opp = BNF_Test_Data.createOpp();
        
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        Revenue_Analyst__c TestLocalRA = BNF_Test_Data.createRA();
        MIBNF2__c TestMIBNF = BNF_Test_Data.createMIBNF();
        Profit_Centre__c pseregion = CommanUtilityTestFunction.setUpRegion();
        pseregion.Profit_Center_Code_Chain__c = 'test(TOTGEO)test';
        insert pseregion;
    }
    
    @isTest
    static void testFetchAllDetailsOnLoad1() {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id ,Product_Start_Date__c,Project_End_Date__c,Revised_Revenue_Schedule__c,PricebookEntry.Product2.Material_Type__c,Billing_Frequency__c,PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.Offering_Type__c,
                                   List_Price__c,PricebookEntry.ProductCode,Delivery_Date__c,Product_End_Date__c,Revenue_Type__c,Billing_Date__c,Proj_Rpt_Frequency__c,Revised_Price__c,TotalPrice,Surcharge_Text__c, Discount_Reason__c,
                                   Opportunity.CEQActiveRelease__c,Sale_Type__c,Billing_Schedule__r.Total_Billing_Amount__c,Nbr_of_Users__c,PricebookEntry.Product2.Material_Group_1__c,ProfitCenter__c FROM OpportunityLineItem LIMIT 1];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oli);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oli.Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        Map<String,Object> returnMap = MIBNF_ProductControllerLockedGridM.fetchAllDetailsOnLoad(TestMIBNF_Comp.Id);
        Test.stopTest();
        System.assertEquals(true,returnMap.get('bnfRecord') != null);
    }
    
    @isTest
    static void testFetchAllDetailsOnLoad2() {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id ,Product_Start_Date__c,Project_End_Date__c,Revised_Revenue_Schedule__c,PricebookEntry.Product2.Material_Type__c,Billing_Frequency__c,PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.Offering_Type__c,
                                   List_Price__c,PricebookEntry.ProductCode,Delivery_Date__c,Product_End_Date__c,Revenue_Type__c,Billing_Date__c,Proj_Rpt_Frequency__c,Revised_Price__c,TotalPrice,Surcharge_Text__c, Discount_Reason__c,
                                   Opportunity.CEQActiveRelease__c,Sale_Type__c,Billing_Schedule__r.Total_Billing_Amount__c,Nbr_of_Users__c,PricebookEntry.Product2.Material_Group_1__c,ProfitCenter__c FROM OpportunityLineItem LIMIT 1];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oli);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oli.Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        Product2 p = [SELECT Id FROM Product2 Limit 1];
        p.Therapy_Class__c = '24';
        p.Delivery_Media__c =null;
        p.Delivery_Frequency__c = null;
        update p;
        
        oli.surcharge_text__c = 'test';
        oli.Revised_Revenue_Schedule__c ='x';
        update oli;
        
        Map<String,Object> returnMap = MIBNF_ProductControllerLockedGridM.fetchAllDetailsOnLoad(TestMIBNF_Comp.Id);
        Test.stopTest();
        System.assertEquals(true,returnMap.get('bnfRecord') != null);
    }
    
    @isTest
    static void testSaveOli1() {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id ,Product_Start_Date__c,Project_End_Date__c,Revised_Revenue_Schedule__c,PricebookEntry.Product2.Material_Type__c,Billing_Frequency__c,PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.Offering_Type__c,
                                   List_Price__c,PricebookEntry.ProductCode,Delivery_Date__c,Product_End_Date__c,Revenue_Type__c,Billing_Date__c,Proj_Rpt_Frequency__c,Revised_Price__c,TotalPrice,Surcharge_Text__c, Discount_Reason__c,
                                   Opportunity.CEQActiveRelease__c,Sale_Type__c,Billing_Schedule__r.Total_Billing_Amount__c,Nbr_of_Users__c,PricebookEntry.Product2.Material_Group_1__c,ProfitCenter__c FROM OpportunityLineItem LIMIT 1];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oli);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oli.Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        oli.Billing_Date__c = Date.today() + 2;
        oli.Delivery_Date__c =oli.Product_End_Date__c + 2;
        oli.Surcharge_Text__c = 'test';
        
        TestMIBNF_Comp = [SELECT Id,Name,MIBNF__c, Addendum__c,MIBNF__r.Sales_Org_Code__c,MIBNF__r.Contract_End_Date__c,MIBNF__r.Contract_Start_Date__c FROM MIBNF_Component__c LIMIT 1];
        Map<String,Object> returnMap = MIBNF_ProductControllerLockedGridM.saveOLI(TestMIBNF_Comp, oli);
        Test.stopTest();
        System.debug('1');
        System.debug(returnMap.get('error'));
        System.debug(returnMap.get('success'));
        System.assertEquals(true,returnMap.get('success')!= null);
    }
    
    @isTest
    static void testSaveOli2() {
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [Select Id ,Product_Start_Date__c,Project_End_Date__c,Revised_Revenue_Schedule__c,PricebookEntry.Product2.Material_Type__c,Billing_Frequency__c,PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.Offering_Type__c,
                                   List_Price__c,PricebookEntry.ProductCode,Delivery_Date__c,Product_End_Date__c,Revenue_Type__c,Billing_Date__c,Proj_Rpt_Frequency__c,Revised_Price__c,TotalPrice,Surcharge_Text__c, Discount_Reason__c,
                                   Opportunity.CEQActiveRelease__c,Sale_Type__c,Billing_Schedule__r.Total_Billing_Amount__c,Nbr_of_Users__c,PricebookEntry.Product2.Material_Group_1__c,ProfitCenter__c from OpportunityLineItem Limit 1];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        MIBNF2__c TestMIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oli);
        insert TestMI_BNFLineItem;
        Billing_Schedule__c billingSchedule = UTL_TestData.createBillingSchedule(oli.Id);
        insert billingSchedule;
        Billing_Schedule_Item__c billingScheduleItem = UTL_TestData.createBillingScheduleItem(billingSchedule.Id);
        insert billingScheduleItem;
        
        BNF_Settings__c bnfsetting= BNF_Settings__c.getInstance(UserInfo.getUserId());
        bnfsetting.Enable_Material_Validation__c = true;
        bnfsetting.Enable_Customer_Validation__c = true;
        bnfsetting.BNF_Opportunity_Threshold__c = Integer.valueOf(opp.Opportunity_Number__c)-10;
        bnfsetting.Enable_BNF_Surcharge__c=true;
        bnfsetting.Enable_Billing_Schedule_Validation__c = true;
        bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        insert bnfsetting;
        
        oli.Billing_Date__c = null;
        oli.Delivery_Date__c= null;
        oli.Sale_Type__c= null;
        oli.Revenue_Type__c= null;
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        
        TestMIBNF_Comp = [SELECT Id,Name,MIBNF__c, Addendum__c,MIBNF__r.Sales_Org_Code__c,MIBNF__r.Contract_End_Date__c,MIBNF__r.Contract_Start_Date__c FROM MIBNF_Component__c LIMIT 1];
        Map<String,Object> returnMap = MIBNF_ProductControllerLockedGridM.saveOLI(TestMIBNF_Comp, oli);
        
        Test.stopTest();
        System.debug('2');
        System.debug(returnMap.get('error'));
        System.debug(returnMap.get('success'));
        System.assertEquals(true,returnMap.get('error')!= null);
    }
}