@isTest
public class TST_CNT_CRM_Edit_products {
    
    @testSetup
    static void setUpTestData() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = True;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        List<User_Locale__c> userlocaleList = BNF_Test_Data.create_User_LocaleSetting();
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity TestOpp = new Opportunity(Name='test',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.StageName='7a. Closed Won';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_Start_Date__c  = system.today();
        TestOpp.Contract_End_Date__c = system.today().addyears(12);
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Potential_Competitor_1__c = comp.Id;
        insert TestOpp;
        
        Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly', Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        insert prod1;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id=prod1.id;
        pbe.IsActive=true;
        pbe.UnitPrice=100.0;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
        
        Profit_Centre__c pseregion = CommanUtilityTestFunction.setUpRegion();
        pseregion.Profit_Center_Code_Chain__c = 'test(TOTGEO)test';
        insert pseregion;
        
        SalesOrg__c salesorg = CommanUtilityTestFunction.setUpSalesOrg();
        insert salesorg;
        Account acc = CommanUtilityTestFunction.createAccount();
        insert acc;
        pse__Work_Calendar__c workcal = CommanUtilityTestFunction.setUpWorkCalender();
        insert workcal;
        User testUser1 = [SELECT Id, name FROM User where Profile.Name like '%system administrator%' and isActive = true limit 1];
        Contact testContact1 = CommanUtilityTestFunction.createContact(acc, salesorg, testUser1,workcal,pseregion);
        insert testContact1;        
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = TestOpp.Id;
        oli.Product_Start_Date__c = Date.today();
        oli.Product_End_Date__c = Date.today().addYears(1) ;
        oli.PricebookEntryId = pbe.Id;
        oli.Billing_Frequency__c = 'Once';
        oli.Proj_Rpt_Frequency__c='Once [O]';
        oli.Therapy_Area__c= 'Hepatitis C [21]';
        oli.Quantity = 1.00;
        oli.UnitPrice = 9000;
        oli.List_Price__c = 9000;
        oli.Wbsrelementcode__c = 'asd';  
        oli.Delivery_Date__c = System.today().addYears(1);
        oli.Revenue_Type__c = 'Ad Hoc';
        oli.Sale_Type__c = 'New';
        oli.Delivery_Country__c = 'USA';
        insert oli;
        List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
        Integer RevFactor = 1;
        
        Date strScheduleDate = Date.valueOf(String.valueOf(System.now().year())+'-01-15 00:00:00');    
        for (Integer i = 0; i < 3; i++) {
            Double dRevenueAmount = RevFactor*1000.00;
            RevFactor = RevFactor + 2;
            OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
            OliSched.OpportunityLineItemId = OLI.Id;
            OliSched.Type = 'Revenue';
            OliSched.Revenue = dRevenueAmount;
            OliSched.ScheduleDate = strScheduleDate;
            strScheduleDate = strScheduleDate.addMonths(1);
            InsertOLISList.add(OliSched); 
        }
        insert InsertOLISList;
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oli.id);
        insert sche;
        
        List<Billing_Schedule_Item__c> billingScheduleItem = new List<Billing_Schedule_Item__c>();
        Billing_Schedule_Item__c sche1 = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 1000,Billing_Date__c = system.today(),Billing_Schedule__c = sche.id);
        Billing_Schedule_Item__c sche2 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp1', Billing_Amount__c = 3000, Billing_Date__c = system.today().addMonths(1),Billing_Schedule__c = sche.id );
        Billing_Schedule_Item__c sche3 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp2', Billing_Amount__c = 5000, Billing_Date__c = system.today().addMonths(2),Billing_Schedule__c = sche.id );
        billingScheduleItem.add(sche1);
        billingScheduleItem.add(sche2); 
        billingScheduleItem.add(sche3); 
        insert billingScheduleItem;
        
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(name='TestRA',User__c = UserInfo.getUserId());
        insert TestLocalRA;
        
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 800000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        insert bnfsetting;
    }
    
    static void createBNFTestData(Id recordTypeId) {
        Revenue_Analyst__c TestLocalRA = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity limit 1];
        List<Address__c> TestAddress_Array = [SELECT id FROM Address__c LIMIT 5];
        BNF2__c TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today();
        TestBnf.Contract_End_Date__c = Date.today().addYears(1);
        TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.Bill_To__c=TestAddress_Array[0].id;
        TestBnf.X2nd_Copy__c=TestAddress_Array[1].id;
        TestBnf.Carbon_Copy__c=TestAddress_Array[2].id;
        TestBnf.Ship_To__c=TestAddress_Array[3].id;
        TestBnf.Cover_Sheet__c=TestAddress_Array[4].id;
        TestBnf.RecordTypeId = recordTypeId;
        TestBnf.Revenue_Analyst__c = TestLocalRA.id;  
        insert TestBnf;
    }
    
    static void createMIBNFTestData(){
        Opportunity opp =[SELECT Id,AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem OLI1 = [SELECT Id,TotalPrice FROM OpportunityLineItem LIMIT 1];

        ID RevenueAnalystID = [SELECT Id FROM Revenue_Analyst__c].Id;
        MIBNF2__c MIBNF = new MIBNF2__c();
        MIBNF.Client__c = opp.AccountId;
        MIBNF.Opportunity__c = opp.Id;
        MIBNF.Sales_Org_Code__c = 'CH08';
        MIBNF.Billing_Currency__c = 'USD';
        MIBNF.IMS_Sales_Org__c = 'Acceletra';
        MIBNF.Fair_Value_Type__c = 'Stand Alone';
        MIBNF.Invoice_Default_Day__c = '15';
        MIBNF.Contract_Start_Date__c = system.today();
        MIBNF.Contract_End_Date__c = system.today();
        MIBNF.Contract_Type__c = 'Individual';
        MIBNF.Contract_Term__c = 'Single-Period';
        MIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        MIBNF.Revenue_Analyst__c = RevenueAnalystID;
        
        insert MIBNF;
        MIBNF_Component__c MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=MIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        insert MIBNF_Comp;
        
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
        MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
        insert MI_BNFLineItem;
    }
    
    @isTest
    static void testFetchAllDetailsOnLoadSAPBNF() {
        Test.startTest();
            createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id);
            BNF2__c bnf = [SELECT Id FROM BNF2__c LIMIT 1];
            Map<String, Object> returnMap = CNT_CRM_Edit_products.fetchAllDetailsOnLoad(bnf.Id);
        Test.stopTest();
        System.assertEquals(returnMap.get('objectType'), 'BNF2__c');
    }
    
    @isTest
    static void testFetchAllDetailsOnLoadManualBNF() {
        Test.startTest();
            createBNFTestData(MDM_Defines.Manual_Setup_In_SAP_Record_Type_Id);
            BNF2__c bnf = [SELECT Id FROM BNF2__c LIMIT 1];
            Map<String, Object> returnMap = CNT_CRM_Edit_products.fetchAllDetailsOnLoad(bnf.Id);
        Test.stopTest();
        System.assertEquals(returnMap.get('objectType'), 'BNF2__c');
    }
    
    @isTest
    static void testFetchAllDetailsOnLoadMIBNF() {
        Test.startTest();
        	createMIBNFTestData();
        	System.debug(System.Limits.getQueries());
        	MIBNF_Component__c bnf = [SELECT Id FROM MIBNF_Component__c LIMIT 1];
        	Map<String, Object> returnMap = CNT_CRM_Edit_products.fetchAllDetailsOnLoad(bnf.Id);
        Test.stopTest();
        System.assertEquals(returnMap.get('objectType'), 'MIBNF_Component__c');
    }
    
    @isTest
    static void testGetIsAboveThreshold() {
        Test.startTest();
            createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id);
            BNF2__c bnf = [SELECT Id FROM BNF2__c LIMIT 1];
            Boolean isAboveThreshold = CNT_CRM_Edit_products.getIsAboveThreshold(bnf.Id);
        Test.stopTest();
        System.assertEquals(isAboveThreshold,true);
    }
    
    @isTest
    static void testGetIsAboveThresholdMIBNF() {
        Test.startTest();
        	createMIBNFTestData();
        	System.debug(System.Limits.getQueries());
        	MIBNF_Component__c bnf = [SELECT Id FROM MIBNF_Component__c LIMIT 1];
            Boolean isAboveThreshold = CNT_CRM_Edit_products.getIsAboveThreshold(bnf.Id);
        Test.stopTest();
        System.assertEquals(isAboveThreshold,true);
    }
    
    @isTest
    static void testGetRevisedPrice(){
        Test.startTest();
            createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id);
            OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        	Decimal revenueAmount = CNT_CRM_Edit_products.getRevisedPrice(oli.Id,false);
        Test.stopTest();
        System.assertEquals(revenueAmount,0.00);
    }
}