@isTest
public class TST_BCH_CRM_UpdateOLIJSONData {
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
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        //TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        TestOpp.CurrencyIsoCode = 'USD';
        //TestOpp.Exclude_From_Pricing_Calculator__c = true;
        //TestOpp.Compelling_Event__c = 'Unknown';
        //TestOpp.Budget_Available__c = 'Unknown';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Therapy_Area__c= 'Hepatitis C [21]';
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
        User testUser1 = [Select id , name from User where Profile.Name like '%system administrator%' and isActive = true limit 1];
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
    }
    static testMethod void test1(){
        Test.startTest();
        Database.executeBatch(new BCH_CRM_UpdateOLIJSONData());
        Test.stopTest();
    }
}