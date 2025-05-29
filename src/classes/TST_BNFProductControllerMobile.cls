@isTest
public class TST_BNFProductControllerMobile {
    
    @testSetup
    static void setUpTestData() {
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        
        Profit_Centre__c pseregion = CommanUtilityTestFunction.setUpRegion();
        pseregion.Profit_Center_Code_Chain__c = 'test(TOTGEO)test';
        insert pseregion;
        
        Datetime strDate = System.now();  
        Account acct1 = new Account(Name='SPO BT Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct1;
        List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
        Map<String,Double> Revenue_Map = new Map<String,Double>();
        //  Setup test parameters
        Integer NumTestOpps = 10;
        Integer iNumSchedules = 18;
        //  Create a test opportunity
        Opportunity oppty1 = new Opportunity(Name = 'SPO BT Test Oppty');
        oppty1.StageName = '1 - Identify Opportunity';
        oppty1.CloseDate = System.today();
        oppty1.AccountId = acct1.Id;
        //oppty1.Budget_Available__c = 'Yes';
        oppty1.CurrencyIsoCode = 'USD';
        insert oppty1;
        
        //****Jeganmohan N 09-25-11, to resolve 'Too many SOQL queries: 101' error while PROD migration
        Set<Id> Opp_Id_Set = new Set<Id>();
        Product2 objProduct1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZSET',CanUseRevenueSchedule= true,Delivery_Media__c='Ex',Delivery_Frequency__c='MM');
        Product2 objProduct2 = new Product2(Name='test2', ProductCode='2', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZSET',CanUseRevenueSchedule= true,Therapy_Class__c = '24');
        List<Product2> productList = new List<Product2>{objProduct1,objProduct2};
        insert productList;
        PricebookEntry PE1 = new PricebookEntry(UseStandardPrice = false,Pricebook2Id= Test.getStandardPricebookId(),IsActive=true,Product2Id = productList[0].Id,currencyisocode='USD',UnitPrice=100.0);
        PricebookEntry PE2 = new PricebookEntry(UseStandardPrice = false,Pricebook2Id= Test.getStandardPricebookId(),IsActive=true,Product2Id = productList[1].Id,currencyisocode='USD',UnitPrice=100.0);
        List<PricebookEntry> peList = new List<PricebookEntry>{PE1,PE2};
        insert peList;
        
        Id opptyId = oppty1.Id;
        Opp_Id_Set.add(opptyId);
        //  Add a line item to the opportunity
        OpportunityLineItem OLI1 = new OpportunityLineItem(OpportunityId = opptyId,PricebookEntryId = peList[0].Id,Quantity = 1.00,UnitPrice = 10000,Sale_Type__c = 'New',Revenue_Type__c = 'Ad Hoc',Billing_Date__c = Date.today(),Delivery_Country__c = 'USA');
        OpportunityLineItem OLI2 = new OpportunityLineItem(OpportunityId = opptyId,PricebookEntryId = peList[1].Id,Quantity = 1.00,UnitPrice = 10000,Sale_Type__c = 'New',Revenue_Type__c = 'Ad Hoc',Billing_Date__c = Date.today(),Delivery_Country__c = 'USA');
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> {OLI1,OLI2};
        insert oliList;
        
        //  Create 18 schedules to cover 18 months from the first month of the current year
        Revenue_Map.put(oliList[0].Id,1000.00);
        Revenue_Map.put(oliList[1].Id,1000.00);
        Date strScheduleDate = Date.valueOf(String.valueOf(strDate.year())+'-01-15 00:00:00');    
        for (Integer i = 0; i < iNumSchedules; i++) {
            OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
            OliSched.OpportunityLineItemId = oliList[0].Id;
            OliSched.Type = 'Revenue';
            OliSched.Revenue = 1000.00;
            OliSched.ScheduleDate = strScheduleDate;
            strScheduleDate = strScheduleDate.addMonths(1);
            InsertOLISList.add(OliSched); 
        }
        insert InsertOLISList;
        Test.startTest();
        //****Jeganmohan N 09-25-11, to resolve 'Too many SOQL queries: 101' error while PROD migration
        List<Opportunity> Opp_Array_All = new List<Opportunity>([select Id, Amount from Opportunity where Id in : Opp_Id_Set]);
        Address__c TestAddress = New Address__c (
            Name='Test Address',
            Account__c=acct1.Id,
            Street__c = 'Street',
            City__c = 'City',
            Country__c = 'Country',
            Marked_For_Deletion__c = false,
            SAP_Reference__c = '495001',
        	MDM_Validation_Status__c = 'Validated',
        	RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId());
        insert TestAddress;
        BNF2__c TestBnf = new BNF2__c(Opportunity__c=oppty1.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.Bill_To__c=TestAddress.id;
        TestBnf.X2nd_Copy__c=TestAddress.id;
        TestBnf.Carbon_Copy__c=TestAddress.id;
        TestBnf.Ship_To__c=TestAddress.id;
        TestBnf.Cover_Sheet__c=TestAddress.id;
        TestBnf.RecordTypeId = MDM_Defines.Manual_Setup_In_SAP_Record_Type_Id;
        //TestBnf.RecordTypeId  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
        insert TestBnf;
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 800000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        insert bnfsetting;
    }
    
    @isTest
    static void testFetchAllDetailsOnLoad1() {
        BNF2__c bnf = [SELECT Id FROM BNF2__c LIMIT 1];
        Test.startTest();
            Map<String, Object> returnMap = BNFProductControllerMobile.fetchAllDetailsOnLoad(bnf.Id);
        Test.stopTest();
        System.assertEquals(returnMap.get('bnfRecord') != null,true);
    }
    
    @isTest
    static void testSaveOLISuccess() {
        BNF2__c bnf = [SELECT Id,RecordTypeId FROM BNF2__c LIMIT 1];
        OpportunityLineItem oli = [SELECT Id,Revenue_Type__c,Billing_Date__c,Billing_Frequency__c,Proj_Rpt_Frequency__c,Delivery_Date__c, List_Price__c, 
                                   Opportunity.CEQActiveRelease__c, TotalPrice,PricebookEntry.Product2.Material_Group_1__c FROM OpportunityLineItem LIMIT 1];
        Test.startTest();
        Map<String, Object> returnMap = BNFProductControllerMobile.saveOLI(bnf, oli);
        Test.stopTest();
        System.debug(returnMap.get('success'));
        System.debug(returnMap.get('error'));
        System.assertEquals(returnMap.get('success') != null,true);
    }

    @isTest
    static void testSaveOLIError() {
        BNF2__c bnf = [SELECT Id,RecordTypeId FROM BNF2__c LIMIT 1];
        OpportunityLineItem oli = [SELECT Id,Revenue_Type__c,Billing_Date__c,Billing_Frequency__c,Proj_Rpt_Frequency__c,Delivery_Date__c, List_Price__c, 
                                   Opportunity.CEQActiveRelease__c, TotalPrice,PricebookEntry.Product2.Material_Group_1__c FROM OpportunityLineItem LIMIT 1];
        oli.Billing_Date__c = null;
        oli.Billing_Frequency__c = 'Once';
        oli.Proj_Rpt_Frequency__c = 'Once [O]';
        oli.Delivery_Date__c = null;
        
        Test.startTest();
        Map<String, Object> returnMap = BNFProductControllerMobile.saveOLI(bnf, oli);
        Test.stopTest();
        System.assertEquals(returnMap.get('error') != null,true);
    }
    
}