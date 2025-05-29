/**
* This class is used to test BCH_CRM_BNF_MIBNF_Data_Update Batch class
*/ 

@isTest
public class TST_BCH_CRM_BNF_MIBNF_Data_Update {
    public static List<User_Locale__c> userlocaleList;
    @testSetup
    static void dataSetup() {
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        userlocaleList = BNF_Test_Data.create_User_LocaleSetting();
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
        TestOpp.Potential_Regions__c = 'Asia Pacific';
        TestOpp.QI_Invited_to_Present__c = 'Yes';
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        TestOpp.Potential_Regions__c = 'Japan';
        TestOpp.QI_Invited_to_Present__c = 'No';
        TestOpp.FPI_Date__c = system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Is_this_IQVIA_Biotech__c = 'No';
        TestOpp.Potential_Regions__c = 'Asia Pacific';
        TestOpp.QI_Invited_to_Present__c = 'No';
        TestOpp.FPI_Date__c = system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
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
        
        Account acc = CommanUtilityTestFunction.createAccount();
        insert acc;
        pse__Work_Calendar__c workcal = CommanUtilityTestFunction.setUpWorkCalender();
        insert workcal;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = TestOpp.Id;
        oli.Product_Start_Date__c = Date.today();
        oli.Product_End_Date__c = Date.today().addYears(1) ;
        oli.PricebookEntryId = pbe.Id;
        oli.Billing_Frequency__c = 'Once';
        oli.Proj_Rpt_Frequency__c='Once [O]';
        oli.Therapy_Area__c= 'Hepatitis C [21]';
        oli.Quantity = 1.00;
        oli.JSON_Correction__c = true;
        oli.UnitPrice = 9000;
        oli.List_Price__c = 9000;
        oli.Wbsrelementcode__c = 'asd';  
        //oli.Budget__c = budg.id;
        oli.Delivery_Date__c = System.today().addYears(1);
        oli.Revenue_Type__c = 'Ad Hoc';
        oli.Sale_Type__c = 'New';
        oli.Delivery_Country__c = 'USA';
        insert oli;
        List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
        Integer RevFactor = 1;
        Date strScheduleDate = Date.valueOf(String.valueOf(System.now().year())+'-01-15 00:00:00');    
        for (Integer i = 0; i < 3; i++){
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
        oli.BSI_Json_Data_LAB__c = JSON.serialize(billingScheduleItem);
        update oli;
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c=13342,Enable_Billing_Schedule_Validation__c=true,Enable_RSchedule_Validation__c=true,Excluded_Products__c='ZQUI');
        upsert bnfsetting;
        
    }
    
    static void createMIBNFTestData() {
        Opportunity testOpp = [Select id, AccountId from Opportunity limit 1];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        
        
        MIBNF2__c TestMIBNF = new MIBNF2__c();
        TestMIBNF.Client__c=TestOpp.AccountId;
        TestMIBNF.Opportunity__c=testOpp.Id;
        TestMIBNF.Sales_Org_Code__c='CH03';
        TestMIBNF.Billing_Currency__c='USD';
        TestMIBNF.IMS_Sales_Org__c='IHA, IMS Health Rotkreuz';
        TestMIBNF.Fair_Value_Type__c='Stand Alone';
        TestMIBNF.Invoice_Default_Day__c='15';
        TestMIBNF.Contract_Start_Date__c=system.today();
        TestMIBNF.Contract_End_Date__c=system.today().addYears(1);
        TestMIBNF.Contract_Type__c='Individual';
        TestMIBNF.Contract_Term__c='Single-Period';
        TestMIBNF.IMS_Sales_Org__c = 'IMS Spain';
        TestMIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        TestMIBNF.Revenue_Analyst__c = TestLocalRA.id;
        insert TestMIBNF;
        
        
    }
    
    static void createMIBNFComp(Id MIBNFId, OpportunityLineItem oli) { 
        List<Address__c> TestAddress_Array = [Select id from Address__c limit 5];
        List<MIBNF_Component__c> MIBNFCompList = new List<MIBNF_Component__c>();
        List<MI_BNF_LineItem__c> MIBNFLIList = new List<MI_BNF_LineItem__c>();
        MIBNF_Component__c TestMIBNF_Comp = new MIBNF_Component__c();
        TestMIBNF_Comp.MIBNF__c=MIBNFId;
        TestMIBNF_Comp.BNF_Status__c='New';
        TestMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        TestMIBNF_Comp.Print_Shop__c='No';
        TestMIBNF_Comp.Bill_To__c=TestAddress_Array[0].id;
        TestMIBNF_Comp.X2nd_Copy__c=TestAddress_Array[1].id;
        TestMIBNF_Comp.Carbon_Copy__c=TestAddress_Array[2].id;
        TestMIBNF_Comp.Ship_To__c=TestAddress_Array[3].id;
        TestMIBNF_Comp.Cover_Sheet__c=TestAddress_Array[4].id;
        MIBNFCompList.add(TestMIBNF_Comp);
        MIBNF_Component__c TestMIBNF_Comp1 = new MIBNF_Component__c();
        TestMIBNF_Comp1.MIBNF__c=MIBNFId;
        TestMIBNF_Comp1.BNF_Status__c='New';
        TestMIBNF_Comp1.Is_this_a_retainer_downpayment__c='No';
        TestMIBNF_Comp1.Print_Shop__c='No';
        TestMIBNF_Comp1.Bill_To__c=TestAddress_Array[0].id;
        TestMIBNF_Comp1.X2nd_Copy__c=TestAddress_Array[1].id;
        TestMIBNF_Comp1.Carbon_Copy__c=TestAddress_Array[2].id;
        TestMIBNF_Comp1.Ship_To__c=TestAddress_Array[3].id;
        TestMIBNF_Comp1.Cover_Sheet__c=TestAddress_Array[4].id;
        MIBNFCompList.add(TestMIBNF_Comp1);
        insert MIBNFCompList;
        MI_BNF_LineItem__c TestMI_BNFLineItem = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem.MIBNF_Component__c = TestMIBNF_Comp.id;
        TestMI_BNFLineItem.Opportunity_Line_Itemid__c = oli.id;
        TestMI_BNFLineItem.Total_Price__c = oli.TotalPrice;       
        MIBNFLIList.add(TestMI_BNFLineItem);
        MI_BNF_LineItem__c TestMI_BNFLineItem1 = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem1.MIBNF_Component__c = TestMIBNF_Comp1.id;
        TestMI_BNFLineItem1.Opportunity_Line_Itemid__c = oli.id;
        TestMI_BNFLineItem1.Total_Price__c = oli.TotalPrice;       
        MIBNFLIList.add(TestMI_BNFLineItem1);
        insert MIBNFLIList;
    }
    
    static testMethod void test_BNF_MIBNF_Test() {
        Test.startTest();
        createMIBNFTestData();   
        MIBNF2__c testMIBNF = [Select id from MIBNF2__c limit 1];
        List<OpportunityLineItem> oliList = [Select id, TotalPrice from OpportunityLineItem limit 2];
        createMIBNFComp(testMIBNF.id, oliList[0]);
        BCH_CRM_BNF_MIBNF_Data_Update bc =  new BCH_CRM_BNF_MIBNF_Data_Update('Select Id, Opportunity__c from MIBNF_Component__c where CreatedDate = TODAY','MIBNF_Component__c');
        Database.executeBatch(bc);
        BCH_CRM_BNF_MIBNF_Data_Update.sendErrorMailNotification('Test','Test');
        Test.stopTest();
    }
}