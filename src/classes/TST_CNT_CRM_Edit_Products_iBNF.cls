@isTest
public class TST_CNT_CRM_Edit_Products_iBNF {
    
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        
        insert new Profit_Centre__c(name='xyz' ,ProfitCenterCode__c='USD', Profit_Center_Code_Chain__c = '(2W)->(ANDES)->(TOTGEO)->(OPRTN-R)');
        List<Product2> prods = new List<Product2>();
        Product2 prod = UTL_TestData.createProduct();
        prod.Material_Type__c = 'ZPUB';
        prod.Therapy_Class__c = '24';
        prod.Enabled_Sales_Orgs__c = 'CH03';
        prod.Material_Type__c = 'ZREP';
        prod.Material_Group_1__c = 'MAN';
        prod.Item_Category_Group__c = 'ZPLI';
        prods.add(prod);
        Product2 prod2 = UTL_TestData.createProduct();
        prod2.Material_Type__c = 'ZPUB';
        prod2.Enabled_Sales_Orgs__c = 'CH03';
        prod2.Item_Category_Group__c = 'ZLIC';
        prods.add(prod2);
        insert prods;
        
        PricebookEntry PE = UTL_TestData.createPricebookEntry(prod.Id);
        insert PE;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.StageName = '7a. Closed Won';
        insert opp;
        
        OpportunityLineItem oli =UTL_TestData.createOpportunityLineItem(opp.Id, PE.Id);
        insert oli;
        
        Revenue_Analyst__c ra = UTL_TestData.createRevenueAnalyst();
        insert ra;
        
        BNF2__c TestBnf = UTL_TestData.createBNFRecord(opp, oli, addressList, ra.Id);
        new BNF2__c(Opportunity__c=opp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        TestBnf.IMS_Sales_Org__c = '[CH03] IQVIA AG, Branch Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.RecordTypeId  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
        insert TestBnf;
    }
    
    @isTest
    public static void testFetchAllDetails(){
        Test.startTest();
        
        Id recId = [SELECT Id FROM BNF2__c LIMIT 1].Id;
        Map<String, Object> returnMap = CNT_CRM_Edit_Products_iBNF.fetchAllDetails(recId);
        List<OpportunityLineItem> olis = (List<OpportunityLineItem>) returnMap.get('opptyLineItem2');
        System.assertEquals(true, returnMap.get('bnf') != null);
        System.assertEquals(1 , olis.size());
        Test.stopTest();
        
    }
    
    @isTest
    public static void testFetchAllDetails2(){
        BNF_Settings__c bnfsettings = BNF_Test_Data.createBNFSetting();
        bnfsettings.Enable_Billing_Schedule_Validation__c = false;
        bnfsettings.BNF_Opportunity_Threshold__c = 1000;
        bnfsettings.Excluded_Products__c = 'ZQUI|TEst';
        upsert bnfsettings;
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_BNF_Trigger__c = true;
        upsert tcm;
        
        BNF_Test_Data.create_User_LocaleSetting();
        BNF2__C bnf = [SELECT Id, Name, RecordTypeId, Addendum__c, Opportunity__c, Contract_Start_Date__c, Contract_End_Date__c, Sales_Org_Code__c, Opportunity__r.Account.Region_Territory__c, Opportunity_Number__c, BNF_Status__c FROM BNF2__c LIMIT 1];
        List<OpportunityLineItem> olis=  [SELECT Id, PricebookEntry.Name, TotalPrice, PricebookEntry.ProductCode, Delivery_Country__c, WBS_R_Element__c, Product_Start_Date__c, Product_End_Date__c, Delivery_Media__c, Proj_Rpt_Frequency__c,
                                          Billing_Frequency__c, Sales_Text__c, Product_Invoice_Text__c, List_Price__c, Discount_Percentage_Formula__c, Discount_Amount_Formula__c, Discount_Reason__c, PO_line_item_number__c, Nbr_of_Users__c, Other_Ship_To__c,
                                          Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Therapy_Area__c, Audit_Subscription_Status__c, ProfitCenter__c, Revised_Price__c, Cancel__c, CurrencyIsoCode, Budget_Therapy_Area__c, 
                                          PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Delivery_Media__c, PricebookEntry.Product2.Delivery_Frequency__c, PricebookEntry.Product2.Therapy_Class__c, Opportunity.Therapy_Area__c,
                                          PricebookEntry.Product2.Material_Group_1__c, PricebookEntry.Product2.Item_Category_Group__c, Other_Ship_To_Address__c, Other_Ship_To_SAP_Contact__c,Other_Ship_To_Address__r.Name, Other_Ship_To_SAP_Contact__r.Name,
                                          Project_Start_Date__c, Project_End_Date__c, Billing_Schedule_Error_Msg__c, Revenue_Schedule_Error_Msg__c, Surcharge_Text__c, Revised_Revenue_Schedule__c, Opportunity.CEQActiveRelease__c, Delivery_Date__c FROM OpportunityLineItem];
        Test.startTest();
        Map<String, Object> returnMap = new Map<String, Object>();
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(bnf.Id);
        Approval.ProcessResult result = Approval.process(req1);
        returnMap = CNT_CRM_Edit_Products_iBNF.fetchAllDetails(bnf.Id);
        
        BNF_Approval_Extension.CustomApprovalPage = true;
        
        ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: bnf.id];
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setAction('Approve');
        req2.setComments('Approving request');
        req2.setWorkitemId(pItem.Id);
        result = Approval.process(req2);
        returnMap = CNT_CRM_Edit_Products_iBNF.fetchAllDetails(bnf.Id);
        
        pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: bnf.Id];
        Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
        req3.setAction('Approve');
        req3.setComments('Approving request');
        req3.setWorkitemId(pItem.Id);
        result = Approval.process(req3);
        returnMap = CNT_CRM_Edit_Products_iBNF.fetchAllDetails(bnf.Id);
        Test.stopTest();
    }
    
    
    @isTest
    public static void testSave(){
        BNF_Settings__c bnfSettings = BNF_Test_Data.createBNFSetting();
        
        Test.startTest();
        BNF2__C bnf = [SELECT Id, Name, RecordTypeId, Addendum__c, Opportunity__c, Contract_Start_Date__c, Contract_End_Date__c, Sales_Org_Code__c, Opportunity__r.Account.Region_Territory__c, Opportunity_Number__c, BNF_Status__c FROM BNF2__c LIMIT 1];
        List<OpportunityLineItem> olis=  [SELECT Id, PricebookEntry.Name, TotalPrice, PricebookEntry.ProductCode, Delivery_Country__c, WBS_R_Element__c, Product_Start_Date__c, Product_End_Date__c, Delivery_Media__c, Proj_Rpt_Frequency__c,
                                          Billing_Frequency__c, Sales_Text__c, Product_Invoice_Text__c, List_Price__c, Discount_Percentage_Formula__c, Discount_Amount_Formula__c, Discount_Reason__c, PO_line_item_number__c, Nbr_of_Users__c, Other_Ship_To__c,
                                          Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Therapy_Area__c, Audit_Subscription_Status__c, ProfitCenter__c, Revised_Price__c, Cancel__c, CurrencyIsoCode, Budget_Therapy_Area__c, 
                                          PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Delivery_Media__c, PricebookEntry.Product2.Delivery_Frequency__c, PricebookEntry.Product2.Therapy_Class__c, Opportunity.Therapy_Area__c,
                                          PricebookEntry.Product2.Material_Group_1__c, PricebookEntry.Product2.Item_Category_Group__c, Other_Ship_To_Address__c, Other_Ship_To_SAP_Contact__c,Other_Ship_To_Address__r.Name, Other_Ship_To_SAP_Contact__r.Name,
                                          Project_Start_Date__c, Project_End_Date__c, Billing_Schedule_Error_Msg__c, Revenue_Schedule_Error_Msg__c, Surcharge_Text__c, Revised_Revenue_Schedule__c, Opportunity.CEQActiveRelease__c, Delivery_Date__c FROM OpportunityLineItem];
        Map<String, Object> returnMap = CNT_CRM_Edit_Products_iBNF.save(olis,'save', bnf);
        System.assertEquals(true, returnMap.containsKey('Success'));
        
        olis[0].Product_Start_Date__c = null;
        olis[0].Product_End_Date__c = null;
        olis[0].Delivery_Media__c = '';
        olis[0].Billing_Date__c = null;
        olis[0].Delivery_Date__c = null;
        olis[0].Sale_Type__c = '';
        olis[0].Revenue_Type__c = '';
        olis[0].Therapy_Area__c = '';
        olis[0].ProfitCenter__c = null;
        olis[0].List_Price__c = null;
        olis[0].Nbr_of_Users__c = null;
        olis[0].Billing_Frequency__c = 'Other';
        returnMap = CNT_CRM_Edit_Products_iBNF.save(olis,'saveOnly', bnf);
        
        olis[0].Billing_Frequency__c = 'Once';
        olis[0].Proj_Rpt_Frequency__c = 'Once [O]';
        olis[0].PO_line_item_number__c = '123';
        olis[0].List_Price__c = 1000000.00;
        olis[0].Product_Start_Date__c = bnf.Contract_End_Date__c.addDays(360);
        olis[0].Product_End_Date__c = bnf.Contract_End_Date__c.addDays(2);
        
        bnf.Addendum__c = true;
        returnMap = CNT_CRM_Edit_Products_iBNF.save(olis,'saveOnly', bnf);
        Test.stopTest();
    }
    
    @isTest
    public static void testValidateAndSave(){
        Test.startTest();
        BNF2__C bnf = [SELECT Id, Name, RecordTypeId, Addendum__c, Opportunity__c, Contract_Start_Date__c, Contract_End_Date__c, Sales_Org_Code__c, Opportunity__r.Account.Region_Territory__c, Opportunity_Number__c, BNF_Status__c FROM BNF2__c LIMIT 1];
        List<OpportunityLineItem> olis=  [SELECT Id, PricebookEntry.Name, TotalPrice, PricebookEntry.ProductCode, Delivery_Country__c, WBS_R_Element__c, Product_Start_Date__c, Product_End_Date__c, Delivery_Media__c, Proj_Rpt_Frequency__c,
                                          Billing_Frequency__c, Sales_Text__c, Product_Invoice_Text__c, List_Price__c, Discount_Percentage_Formula__c, Discount_Amount_Formula__c, Discount_Reason__c, PO_line_item_number__c, Nbr_of_Users__c, Other_Ship_To__c,
                                          Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Therapy_Area__c, Audit_Subscription_Status__c, ProfitCenter__c, Revised_Price__c, Cancel__c, CurrencyIsoCode, Budget_Therapy_Area__c, 
                                          PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Delivery_Media__c, PricebookEntry.Product2.Delivery_Frequency__c, PricebookEntry.Product2.Therapy_Class__c, Opportunity.Therapy_Area__c,
                                          PricebookEntry.Product2.Material_Group_1__c, PricebookEntry.Product2.Item_Category_Group__c, Other_Ship_To_Address__c, Other_Ship_To_SAP_Contact__c,Other_Ship_To_Address__r.Name, Other_Ship_To_SAP_Contact__r.Name,
                                          Project_Start_Date__c, Project_End_Date__c, Billing_Schedule_Error_Msg__c, Revenue_Schedule_Error_Msg__c, Surcharge_Text__c, Revised_Revenue_Schedule__c, Opportunity.CEQActiveRelease__c, Delivery_Date__c FROM OpportunityLineItem];
        olis[0].Product_Start_Date__c = null;
        olis[0].Product_End_Date__c = null;
        olis[0].Delivery_Media__c = '';
        olis[0].Billing_Date__c = null;
        olis[0].Delivery_Date__c = null;
        olis[0].Sale_Type__c = '';
        olis[0].Revenue_Type__c = '';
        olis[0].Therapy_Area__c = '';
        olis[0].ProfitCenter__c = null;
        olis[0].List_Price__c = null;
        olis[0].Nbr_of_Users__c = null;
        olis[0].Billing_Frequency__c = 'Other';
        Map<String, Object> returnMap = CNT_CRM_Edit_Products_iBNF.save(olis,'validateAndSave', bnf);
        
        olis[0].Billing_Frequency__c = 'Once';
        olis[0].Proj_Rpt_Frequency__c = 'Once [O]';
        olis[0].PO_line_item_number__c = '123';
        olis[0].List_Price__c = 1000000.00;
        olis[0].Product_Start_Date__c = bnf.Contract_End_Date__c.addDays(360);
        olis[0].Product_End_Date__c = bnf.Contract_End_Date__c.addDays(2);
        
        bnf.Addendum__c = true;
        returnMap = CNT_CRM_Edit_Products_iBNF.save(olis,'validateAndSave', bnf);
        System.assertEquals(true, returnMap.containsKey('errorCNT'));
        
        BNF_Settings__c bnfSettings = BNF_Test_Data.createBNFSetting();//isNewBNF
        returnMap = CNT_CRM_Edit_Products_iBNF.save(olis,'validateAndSave', bnf);
        Test.stopTest();
    }
    
}