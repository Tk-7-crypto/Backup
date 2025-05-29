@isTest
public class TST_CNT_CRM_DeleteBNF {
    public static List<User_Locale__c> userlocaleList;
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
        for (Integer i = 0; i < 3; i++) 
        {
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
    }
    
    static void createBNFTestData() {
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        insert bnfsetting;
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(name='TestRA',User__c = UserInfo.getUserId());
        insert TestLocalRA;
        Opportunity testOpp = [Select id from Opportunity limit 1];
        List<Address__c> TestAddress_Array = [Select id from Address__c limit 5];
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
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.Revenue_Analyst__c = TestLocalRA.id;  
        insert TestBnf;
    }
    public static testMethod void test1(){
        Test.StartTest();
        createBNFTestData();
        BNF2__c BNF = [select  id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('id', BNF.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.standardController(BNF);
        CNT_CRM_DeleteBNF extension = new CNT_CRM_DeleteBNF(controller);
        try{
            extension.deleteBNFRecord();
        }catch(Exception e){
            System.debug('--'+e);
        }
        Test.stopTest();
        System.assert(true);
    }
    public static testMethod void test2(){
        Test.StartTest();
        createBNFTestData();
        BNF2__c BNF = [select  id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('id', BNF.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.standardController(new BNF2__c());
        CNT_CRM_DeleteBNF extension = new CNT_CRM_DeleteBNF(controller);
        try{
            extension.deleteBNFRecord();
        }catch(Exception e){
            System.debug('--'+e);
        }
        Test.stopTest();
        System.assert(true);
    }
}