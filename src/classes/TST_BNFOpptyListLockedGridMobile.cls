@isTest
public class TST_BNFOpptyListLockedGridMobile {

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
        
        Product2 objProduct1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUB',CanUseRevenueSchedule= true,Delivery_Media__c='Ex',Delivery_Frequency__c='MM');
        //Product2 objProduct2 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly', Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        Product2 objProduct2 = new Product2(Name='test2', ProductCode='2', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true,Therapy_Class__c = '24',Item_Category_Group__c='ZPLI');
        List<Product2> productList = new List<Product2>{objProduct1,objProduct2};
        insert productList;
        
        PricebookEntry PE1 = new PricebookEntry(UseStandardPrice = false,Pricebook2Id= Test.getStandardPricebookId(),IsActive=true,Product2Id = productList[0].Id,currencyisocode='USD',UnitPrice=100.0);
        PricebookEntry PE2 = new PricebookEntry(UseStandardPrice = false,Pricebook2Id= Test.getStandardPricebookId(),IsActive=true,Product2Id = productList[1].Id,currencyisocode='USD',UnitPrice=100.0);
        List<PricebookEntry> peList = new List<PricebookEntry>{PE1,PE2};
        insert peList;
                
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
        
        OpportunityLineItem OLI1 = new OpportunityLineItem(OpportunityId = TestOpp.Id,PricebookEntryId = peList[0].Id,Product_Start_Date__c = Date.today(),Product_End_Date__c = Date.today().addYears(1),Billing_Frequency__c = 'Once',Proj_Rpt_Frequency__c='Once [O]',Therapy_Area__c= 'Hepatitis C [21]',Quantity = 1.00,UnitPrice = 9000,List_Price__c = 9000,Wbsrelementcode__c = 'asd',Delivery_Date__c = System.today().addYears(1),Revenue_Type__c = 'Ad Hoc',Sale_Type__c = 'New',Delivery_Country__c = 'USA',Revised_Revenue_Schedule__c = 'x');
        OpportunityLineItem OLI2 = new OpportunityLineItem(OpportunityId = TestOpp.Id,PricebookEntryId = peList[1].Id,Product_Start_Date__c = Date.today(),Product_End_Date__c = Date.today().addYears(1),Billing_Frequency__c = 'Once',Proj_Rpt_Frequency__c='Once [O]',Therapy_Area__c= 'Hepatitis C [21]',Quantity = 1.00,UnitPrice = 9000,List_Price__c = 9000,Wbsrelementcode__c = 'asd',Delivery_Date__c = System.today().addYears(1),Revenue_Type__c = 'Subscription',Sale_Type__c = 'New',Delivery_Country__c = 'USA',Revised_Revenue_Schedule__c = '20160222:100|20160628:100',surcharge_text__c='test',Nbr_of_Users__c = 0);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> {OLI1,OLI2};
        insert oliList;
        
        List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
        Integer RevFactor = 1;
        
        for (Integer i = 0; i < 3; i++) {
            Double dRevenueAmount = RevFactor*1000.00;
            RevFactor = RevFactor + 2;
            OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
            OliSched.OpportunityLineItemId = oliList[0].Id;
            OliSched.Type = 'Revenue';
            OliSched.Revenue = dRevenueAmount;
            OliSched.ScheduleDate = Date.today();
            InsertOLISList.add(OliSched); 
        }
        
        insert InsertOLISList;
        Billing_Schedule__c bs1 = new Billing_Schedule__c(name = 'textSchedule1', OLIId__c = oliList[0].id);
        Billing_Schedule__c bs2 = new Billing_Schedule__c(name = 'textSchedule2', OLIId__c = oliList[1].id);
        List<Billing_Schedule__c> listBS = new List<Billing_Schedule__c>{bs1,bs2};
        insert listBS;

        Billing_Schedule_Item__c sche1 = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 1000,Billing_Date__c = system.today().addMonths(1),Billing_Schedule__c = listBS[0].id);
        Billing_Schedule_Item__c sche2 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp1', Billing_Amount__c = 3000, Billing_Date__c = system.today().addMonths(2),Billing_Schedule__c = listBS[0].id );
        Billing_Schedule_Item__c sche3 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp2', Billing_Amount__c = 5000, Billing_Date__c = system.today().addMonths(3),Billing_Schedule__c = listBS[0].id );
        Billing_Schedule_Item__c sche4 = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 1000,Billing_Date__c = system.today().addMonths(1),Billing_Schedule__c = listBS[1].id);
        Billing_Schedule_Item__c sche5 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp1', Billing_Amount__c = 3000, Billing_Date__c = system.today().addMonths(2),Billing_Schedule__c = listBS[1].id );
        Billing_Schedule_Item__c sche6 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp2', Billing_Amount__c = 5000, Billing_Date__c = system.today().addMonths(3),Billing_Schedule__c = listBS[1].id );
        List<Billing_Schedule_Item__c> billingScheduleItem = new List<Billing_Schedule_Item__c>{sche1,sche2,sche3,sche4,sche5,sche6};
        insert billingScheduleItem;
        
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(name='TestRA',User__c = UserInfo.getUserId());
        insert TestLocalRA;
    }
    
    static void createBNFTestData(Id recordTypeId,boolean isnew) {
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
        if(isNew){
            TestBnf.Addendum__c = true;
        }
        insert TestBnf;
    }
    @isTest
    static void testFetchAllDetailsOnLoad() {
        Test.startTest();
            BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 800000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
            bnfsetting.Excluded_Products__c = 'ZQUI|Test';
            insert bnfsetting;
            createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id,false);
            BNF2__c bnf = [SELECT Id FROM BNF2__c LIMIT 1];
            Map<String, Object> returnMap = BNFOpptyListLockedGridMobile.fetchAllDetailsOnLoad(bnf.Id);
        Test.stopTest();
        System.debug(returnMap.get('bnfRecord'));
        System.assertEquals(returnMap.get('bnfRecord') != null,true);
        System.assertEquals(returnMap.get('opptyLineItem2') != null,true);
    }
    
    @isTest
    static void testFetchAllDetailsOnLoad2() {
        Test.startTest();
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 80000000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        insert bnfsetting;
        createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id,true);
        BNF2__c bnf = [SELECT Id FROM BNF2__c LIMIT 1];

        Map<String, Object> returnMap = BNFOpptyListLockedGridMobile.fetchAllDetailsOnLoad(bnf.Id);
        Test.stopTest();
        System.debug(returnMap.get('bnfRecord'));
        System.assertEquals(returnMap.get('bnfRecord') != null,true);
        System.assertEquals(returnMap.get('opptyLineItem2') != null,true);
    }
    /*
    @isTest
    static void testFetchAllDetailsOnLoad3() {
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        insert bnfsetting;
        createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id,true);
        BNF2__c bnf = [SELECT Id FROM BNF2__c LIMIT 1];

        Test.startTest();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Test Comment');
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setObjectId(bnf.id); 
        Approval.ProcessResult result = Approval.process(req1);
        Map<String, Object> returnMap = BNFOpptyListLockedGridMobile.fetchAllDetailsOnLoad(bnf.Id);
        Test.stopTest();
        System.assertEquals(returnMap.get('bnfRecord') != null,true);
        System.assertEquals(returnMap.get('opptyLineItem2') != null,true);
    }*/
    
    @isTest
    static void testSaveOLI() {
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 800000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        insert bnfsetting;
        Test.startTest();
	        createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id,false);
	        BNF2__c bnf = [SELECT Id,Sales_Org_Code__c,recordTypeId,Opportunity__c,Addendum__c,Contract_End_Date__c,Contract_Start_Date__c FROM BNF2__c LIMIT 1];
	        OpportunityLineItem oli = [Select Id ,Product_Start_Date__c,Project_End_Date__c,Revised_Revenue_Schedule__c,PricebookEntry.Product2.Material_Type__c,Billing_Frequency__c,PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.Offering_Type__c,
	                                       List_Price__c,PricebookEntry.ProductCode,Delivery_Date__c,Product_End_Date__c,Revenue_Type__c,Billing_Date__c,Proj_Rpt_Frequency__c,Revised_Price__c,TotalPrice,Surcharge_Text__c, Discount_Reason__c,
	                                       Opportunity.CEQActiveRelease__c,Sale_Type__c,Billing_Schedule__r.Total_Billing_Amount__c,Nbr_of_Users__c,PricebookEntry.Product2.Material_Group_1__c,ProfitCenter__c from OpportunityLineItem WHERE OpportunityId =:bnf.Opportunity__c Limit 1];
	        oli.Billing_Date__c = Date.today();
	        update oli;
        	Map<String,Object> returnMap = BNFOpptyListLockedGridMobile.saveOLI(bnf, oli);
        Test.stopTest();
        System.debug(returnMap.get('success'));
        System.debug(returnMap.get(''));
        System.debug(returnMap.get('error'));
        //System.assertEquals(true,returnMap.get('success') != null);
    }
    
    @isTest
    static void testSaveOLI2() {
        Test.startTest();
	        createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id,true);
	        BNF2__c bnf = [SELECT Id,Opportunity_Number__c,Sales_Org_Code__c,recordTypeId,Opportunity__c,Addendum__c,Contract_End_Date__c,Contract_Start_Date__c FROM BNF2__c LIMIT 1];
        	BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = Integer.valueOf(bnf.Opportunity_Number__c)-10, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        	bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        	insert bnfsetting;
        	OpportunityLineItem oli = [Select Id ,Product_Start_Date__c,Project_End_Date__c,Revised_Revenue_Schedule__c,PricebookEntry.Product2.Material_Type__c,Billing_Frequency__c,PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.Offering_Type__c,
            	List_Price__c,PricebookEntry.ProductCode,Delivery_Date__c,Product_End_Date__c,Revenue_Type__c,Billing_Date__c,Proj_Rpt_Frequency__c,Revised_Price__c,TotalPrice,Surcharge_Text__c, Discount_Reason__c,
                Opportunity.CEQActiveRelease__c,Sale_Type__c,Billing_Schedule__r.Total_Billing_Amount__c,Nbr_of_Users__c,PricebookEntry.Product2.Material_Group_1__c,ProfitCenter__c from OpportunityLineItem WHERE OpportunityId =:bnf.Opportunity__c AND PricebookEntry.Product2.Material_Type__c= 'ZPUB' Limit 1];
        	oli.Billing_Date__c = null;
        oli.Billing_Frequency__c ='50% upon signature, 50% upon completion';
        oli.Delivery_Date__c= null;
        oli.Sale_Type__c= null;
        oli.Revenue_Type__c= null;
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        oli.Product_End_Date__c = bnf.Contract_Start_Date__c - 7;
       		Map<String,Object> returnMap = BNFOpptyListLockedGridMobile.saveOLI(bnf, oli);
        Test.stopTest();
        System.debug(returnMap.get('success'));
        System.debug(returnMap.get('error'));
        System.assertEquals(true,returnMap.get('error') != null);
    }
    
    @isTest
    static void testSaveOLI3() {
        Test.startTest();
	        createBNFTestData(MDM_Defines.SAP_SD_Integrated_Record_Type_Id,true);
	        BNF2__c bnf = [SELECT Id,Opportunity_Number__c,Sales_Org_Code__c,recordTypeId,Opportunity__c,Addendum__c,Contract_End_Date__c,Contract_Start_Date__c FROM BNF2__c LIMIT 1];
        	BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = Integer.valueOf(bnf.Opportunity_Number__c)-10, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
        	bnfsetting.Excluded_Products__c = 'ZQUI|Test';
        	insert bnfsetting;
        	OpportunityLineItem oli = [Select Id ,Product_Start_Date__c,Project_End_Date__c,Revised_Revenue_Schedule__c,PricebookEntry.Product2.Material_Type__c,Billing_Frequency__c,PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.Offering_Type__c,
            	List_Price__c,PricebookEntry.ProductCode,Delivery_Date__c,Product_End_Date__c,Revenue_Type__c,Billing_Date__c,Proj_Rpt_Frequency__c,Revised_Price__c,TotalPrice,Surcharge_Text__c, Discount_Reason__c,
                Opportunity.CEQActiveRelease__c,Sale_Type__c,Billing_Schedule__r.Total_Billing_Amount__c,Nbr_of_Users__c,PricebookEntry.Product2.Material_Group_1__c,ProfitCenter__c from OpportunityLineItem WHERE OpportunityId =:bnf.Opportunity__c AND surcharge_text__c != null Limit 1];
        	oli.Billing_Date__c = null;
        	oli.Delivery_Date__c= null;
        	oli.Sale_Type__c= null;
        	oli.Revenue_Type__c= null;
        	oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        	oli.Product_End_Date__c = bnf.Contract_Start_Date__c - 7;
       		Map<String,Object> returnMap = BNFOpptyListLockedGridMobile.saveOLI(bnf, oli);
        Test.stopTest();
        System.debug(returnMap.get('success'));
        System.debug(returnMap.get('error'));
        System.assertEquals(true,returnMap.get('error') != null);
    }
}