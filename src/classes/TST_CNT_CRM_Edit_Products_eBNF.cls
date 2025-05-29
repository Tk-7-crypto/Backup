@isTest
public class TST_CNT_CRM_Edit_Products_eBNF {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        
        insert new Profit_Centre__c(name='xyz' ,ProfitCenterCode__c='USD', Profit_Center_Code_Chain__c = '(2W)->(ANDES)->(TOTGEO)->(OPRTN-R)');
        
        Product2 prod = UTL_TestData.createProduct();
        prod.Material_Type__c = 'ZPUB';
        prod.Therapy_Class__c = '24';
        insert prod;
        
        PricebookEntry PE = UTL_TestData.createPricebookEntry(prod.Id);
        insert PE;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        OpportunityLineItem oli =UTL_TestData.createOpportunityLineItem(opp.Id, PE.Id);
        insert oli;
        
        Revenue_Analyst__c ra = UTL_TestData.createRevenueAnalyst();
        insert ra;
        
        BNF_Settings__c bnfSetting = BNF_Settings__c.getOrgDefaults();
        bnfSetting.Excluded_Products__c = 'ZQUI';
        upsert bnfSetting;
        
        BNF2__c TestBnf = UTL_TestData.createBNFRecord(opp, oli, addressList, ra.Id);
        new BNF2__c(Opportunity__c=opp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        TestBnf.IMS_Sales_Org__c = '[CH03] IQVIA AG, Branch Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.RecordTypeId  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('Manual Setup in SAP').getRecordTypeId();
        insert TestBnf;
    }
    
    @isTest
    public static void testFetchAllDetails(){
        Test.startTest();
        Id recId = [SELECT Id FROM BNF2__c LIMIT 1].Id;
        Map<String, Object> returnMap = CNT_CRM_Edit_Products_eBNF.fetchAllDetails(recId);
        List<OpportunityLineItem> olis = (List<OpportunityLineItem>) returnMap.get('opptyLineItem2');
        System.assertEquals(true, returnMap.get('bnf') != null);
        System.assertEquals(1 , olis.size());
        Test.stopTest();
        
    }
    
    @isTest
    public static void testSave(){
        Test.startTest();
        List<OpportunityLineItem> olis=  [SELECT Id, PricebookEntry.Name, TotalPrice, PricebookEntry.ProductCode, Delivery_Country__c, WBS_R_Element__c, Product_Start_Date__c, Product_End_Date__c, Delivery_Media__c, Proj_Rpt_Frequency__c,
                                          Billing_Frequency__c, Product_Invoice_Text__c, List_Price__c, Discount_Percentage_Formula__c, Discount_Amount_Formula__c, Discount_Reason__c, PO_line_item_number__c, Nbr_of_Users__c, Other_Ship_To__c,
                                          Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Therapy_Area__c, Audit_Subscription_Status__c, ProfitCenter__c, Revised_Price__c, Cancel__c, CurrencyISOCode, 
                                          PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Delivery_Media__c, PricebookEntry.Product2.Delivery_Frequency__c, PricebookEntry.Product2.Therapy_Class__c, Opportunity.Therapy_Area__c,
                                          PricebookEntry.Product2.Material_Group_1__c FROM OpportunityLineItem];
        Map<String, Object> returnMap = CNT_CRM_Edit_Products_eBNF.save(olis,'save');
        System.assertEquals(true, returnMap.containsKey('Success'));
        Test.stopTest();
    }
    
    @isTest
    public static void testValidateAndSave(){
        Test.startTest();
        List<OpportunityLineItem> olis=  [SELECT Id, PricebookEntry.Name, TotalPrice, PricebookEntry.ProductCode, Delivery_Country__c, WBS_R_Element__c, Product_Start_Date__c, Product_End_Date__c, Delivery_Media__c, Proj_Rpt_Frequency__c,
                                          Billing_Frequency__c, Product_Invoice_Text__c, List_Price__c, Discount_Percentage_Formula__c, Discount_Amount_Formula__c, Discount_Reason__c, PO_line_item_number__c, Nbr_of_Users__c, Other_Ship_To__c,
                                          Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Therapy_Area__c, Audit_Subscription_Status__c, ProfitCenter__c, Revised_Price__c, Cancel__c, CurrencyISOCode, 
                                          PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Delivery_Media__c, PricebookEntry.Product2.Delivery_Frequency__c, PricebookEntry.Product2.Therapy_Class__c, Opportunity.Therapy_Area__c,
                                          PricebookEntry.Product2.Material_Group_1__c FROM OpportunityLineItem];
        olis[0].Product_Start_Date__c = null;
        olis[0].Product_End_Date__c = null;
        olis[0].Delivery_Media__c = '';
        olis[0].Proj_Rpt_Frequency__c = '';
        olis[0].Billing_Frequency__c = '';
        olis[0].Billing_Date__c = null;
        olis[0].Sale_Type__c = '';
        olis[0].Revenue_Type__c = '';
        olis[0].Therapy_Area__c = '';
        Map<String, Object> returnMap = CNT_CRM_Edit_Products_eBNF.save(olis,'validateAndSave');
        System.assertEquals(true, returnMap.containsKey('error'));
        Test.stopTest();
    }
    
}