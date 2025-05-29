/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TST_ExtractBNF {
    
    @testSetup static void setupTestData(){
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        Current_Release_Version__c currentReleaseVersion = BNF_Test_Data.createCurrentReleaseVersionSetting();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        BNF_Test_Data.create_User_LocaleSetting();
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity TestOpp = new Opportunity(Name='test',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.StageName='7a. Closed Won';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_End_Date__c = system.today().addyears(12);
        TestOpp.Contract_Start_Date__c = system.today();
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        //TestOpp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        TestOpp.CurrencyIsoCode = 'USD';
        //TestOpp.Exclude_From_Pricing_Calculator__c = true;
        //TestOpp.Compelling_Event__c = 'Unknown';
        TestOpp.Budget_Available__c = 'Unknown';
        TestOpp.Potential_Regions__c = 'Asia Pacific';
        TestOpp.QI_Invited_to_Present__c = 'No';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Therapy_Area__c= 'Hepatitis C [21]';
        TestOpp.Potential_Competitor_1__c = comp.Id;
        insert TestOpp;
        
        Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
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
	  	insert pseregion; 
	  	SalesOrg__c salesorg = CommanUtilityTestFunction.setUpSalesOrg();
	  	insert salesorg;
	  	Account acc = CommanUtilityTestFunction.createAccount();
	  	insert acc;
	  	pse__Work_Calendar__c workcal = CommanUtilityTestFunction.setUpWorkCalender();
	  	insert workcal;
	  	User testUser1 = [Select id , name from User where Profile.Name like '%system administrator%' and isActive = true limit 1];
	  	Contact testContact1 = CommanUtilityTestFunction.createContact(acc, salesorg, testUser1,workcal,pseregion);
	  	//testContact1.Employee_Id__c = '22232';
	  	insert testContact1;
	  	pse__Proj__c proj = CommanUtilityTestFunction.createEngagement(testContact1, pseregion, acc, salesorg);
	  	//insert proj;
	  	/*pse__Budget__c budg = CommanUtilityTestFunction.createBudget(proj,acc,testContact1,salesorg);
	  	budg.WBSRElementCode__c = '1,3,5';
	  	budg.Therapyarea__c = 'Hepatitis C [21]';
	  	budg.pse__Amount__c = 9000;
	  	insert budg;*/
        
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = TestOpp.Id;
        oli.Product_Start_Date__c = Date.today();
        oli.Product_End_Date__c = Date.today().addYears(1) ;
        oli.PricebookEntryId = pbe.Id;
        oli.Billing_Frequency__c = 'Once';
        oli.Proj_Rpt_Frequency__c='Once [O]';
        oli.Therapy_Area__c= 'Allergy [25]';
        oli.Quantity = 1.00;
        oli.UnitPrice = 9000;  
        //oli.Budget__c = budg.id;
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
	   	TestBnf.RA_End_Date__c = Date.today();
	   	insert TestBnf;
    }

    public static testMethod void testMyController() {
    	Test.startTest();
        createBNFTestData();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c,RA_End_Date__c from BNF2__c]);
        
        Id bnfid = bnfList[0].Id;
        
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);        
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        BNF_BillingScheduleController classObj = new BNF_BillingScheduleController(stdController);  
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '50/50';
        classObj.calculateSchedules();           
                
        PageReference pageRef1 = new PageReference('Page.BNFPDF_MDM');
        pageRef1.getParameters().put('id', bnfid);
        Test.setCurrentPage(pageRef1);
        ExtractBNF controller = new ExtractBNF();
        controller.getBNF();
        List<OpportunityLineItem> tempOLIlst = controller.getOpportunityLineItem();
        controller.GetBilling_Schedule_Items();        
        controller.GetRevenue_Schedule_Items();
        
        //Ghanshyam
        if(tempOLIlst.size() > 0){
            List<OpportunityLineItemSchedule> olisLst = [Select id from OpportunityLineItemSchedule where OpportunityLineItemId =: tempOLIlst[0].Id];
            // Stop PA trigger
       		Global_Variables.PCFlag = false;
            delete olisLst;
        }
        
        if(tempOLIlst.size() > 1){
            tempOLIlst[0].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
            upsert tempOLIlst;
        }
        controller.getOpportunityLineItem();
        controller.GetBilling_Schedule_Items();
        controller.GetRevenue_Schedule_Items();
        
        Test.stopTest(); 
         /*     
        
        Id bnfid = [select id from BNF2__c limit 1].Id;
        
        ExtractBNF controller = new ExtractBNF();
        
        ApexPages.currentPage().getParameters().put('id',bnfid);
    
        controller.opptyLineItem=[Select o.WBS__c, o.UnitPrice, o.TotalPrice, o.Delivery_Country__c, o.SystemModstamp, o.SubPractice_Area__c, o.SortOrder, o.Service_Line__c, o.ServiceDate, o.Revenue_Comments__c, o.Quantity, o.Proj_Rpt_Frequency__c, o.Product_Invoice_Text__c, o.PricebookEntryId, o.Practice_Area__c, o.Other_Ship_To__c, o.OpportunityId, o.Net_Price__c, o.Nbr_of_Users__c, o.List_Price__c, o.ListPrice, o.Legacy_Opportunity_LineItemId__c, o.LastModifiedDate, o.LastModifiedById, o.IsDeleted, o.Invoice_Date__c, o.Id, o.HasSchedule, o.HasRevenueSchedule, o.HasQuantitySchedule, o.Gross_Q4_Value__c, o.Gross_Q3_Value__c, o.Gross_Q2_Value__c, o.Gross_Q2_NY_Value__c, o.Gross_Q1_Value__c, o.Gross_Q1_NY_Value__c, o.Discount_Reason__c, o.Discount_Percentage_Formula__c, o.Discount_Amount_Formula__c, o.Description, o.Delivery_Media__c, o.Product_Start_Date__c, o.Product_End_Date__c, o.CurrencyIsoCode, o.CreatedDate, o.CreatedById, o.Business_Type__c, o.PricebookEntry.Product2.Material_Type__c, o.Business_Line__c, o.Book_No__c, o.Billing_Frequency__c,
        Sale_Type__c,Revenue_Type__c,WinBack__c, Invoice_Lag_to_Data_Period__c,Billing_Date__c 
         From OpportunityLineItem o Limit 20];
        
        BNF2__c dummyBNF = controller.getBNF();

        List<OpportunityLineItem> dummyList = controller.getOpportunityLineItem();*/
     }
     // updated by dheeraj kumar 21 dec 2016 ER 3208
     static testmethod void testExtractRevisedBNF() {
		Test.startTest();  
		createBNFTestData();   	
     	Opportunity TestOpp = [Select Id from Opportunity Limit 1];
        BNF2__c TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
     	TestBnf.Addendum__c = true;
     	TestBnf.Addendum_Reasons__c = 'Additional Fees';
     	TestBNF.Revised_BNF_Date__c = System.today();
     	TestBNF.Revised_BNF_Comment__c = 'Test';
     	TestBNF.BNF_Status__c = 'SAP Contract Confirmed';
     	TestBNF.RA_End_Date__c =Date.today();
     	upsert TestBnf;
     	List<BNF2__c> bnfList = new List<BNF2__c>([Select id from BNF2__c where Addendum__c = false ]);
     	
     	PageReference pageRef1 = new PageReference('Page.MI_BNF_Comp_PDF');
     	pageRef1.getParameters().put('id', bnfList[0].id);
     	Test.stopTest();
     	Test.setCurrentPage(pageRef1);
        ExtractBNF controller = new ExtractBNF();
     }
     
     static testmethod void testExtractRevisedBNF1() {
		Test.startTest();  
		createBNFTestData();   	
		String query = 'select Id ';
        for(Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.FieldsToTraceForBNF.getFields()) {
		        query += ', ' + f.getFieldPath();
		}
		query += ' , BSI_Json_Data_LAB__c, OLIS_Json_Data_LAB__c, Other_Ship_To_SAP_Contact__r.Name, PricebookEntry.Name,  Other_Ship_To_Address__r.Name, Other_Ship_To_Address__r.SAP_Reference__c FROM OpportunityLineItem ';
		List<OpportunityLineItem> oli =  Database.query(query);
     	Opportunity TestOpp = [Select Id from Opportunity Limit 1];
        BNF2__c TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
     	TestBnf.Addendum__c = true;
     	TestBnf.Addendum_Reasons__c = 'Additional Fees';
     	TestBNF.Revised_BNF_Date__c = System.today();
     	TestBNF.Revised_BNF_Comment__c = 'Test';
     	TestBNF.BNF_Status__c = 'SAP Contract Confirmed';
     	TestBNf.OLI_Json_Data_1__c = JSON.serialize(oli);  
     	TestBNf.RA_End_Date__c = Date.today();
     	upsert TestBnf;
     	List<BNF2__c> bnfList = new List<BNF2__c>([Select id from BNF2__c where Addendum__c = false ]);
     	
     	PageReference pageRef1 = new PageReference('Page.MI_BNF_Comp_PDF');
     	pageRef1.getParameters().put('id', bnfList[0].id);
     	Test.stopTest();
     	Test.setCurrentPage(pageRef1);
        ExtractBNF controller = new ExtractBNF();
     }
     
     static testmethod void testExtractRevisedBNFUpdate() {
        Test.startTest();
        createBNFTestData();
        List<OpportunityLineItem> oli = [Select id, Revised_Revenue_Schedule__c from OpportunityLineItem ];
	  	oli[0].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert oli;
        Revenue_Analyst__c testLocalRAUser = [Select id from Revenue_Analyst__c  ];
		BNF2__c testBnf = [Select id ,BNF_Status__c,Revenue_Analyst__c from BNF2__c];
        System.debug('testBNF.Revenue_Analyst__c' + testBNF.Revenue_Analyst__c);
        testBNF.Revenue_Analyst__c = testLocalRAUser.id;
        upsert testBnf;  
        testBnf.BNF_Status__c = 'SAP Contract Confirmed';
        upsert testBnf;  
        Test.stopTest();
 
        
     }
    static testmethod void testExtractBNFSetting() {
    	Test.startTest();
    	createBNFTestData();
    	List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);        
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        BNF_BillingScheduleController classObj = new BNF_BillingScheduleController(stdController);  
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '50/50';
        classObj.calculateSchedules();           
        BNF_Settings__c bnfSetting = [Select BNF_Opportunity_Threshold__c from BNF_Settings__c ];
        bnfSetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfSetting;
        PageReference pageRef1 = new PageReference('Page.BNFPDF_MDM');
        pageRef1.getParameters().put('id', bnfid);
        Test.setCurrentPage(pageRef1);
        ExtractBNF controller = new ExtractBNF();
        controller.getBNF();
        
        bnfSetting.BNF_Opportunity_Threshold__c = 1223358;
        upsert bnfSetting;
        pageRef1 = new PageReference('Page.BNFPDF_MDM');
        pageRef1.getParameters().put('id', bnfid);
        Test.setCurrentPage(pageRef1);
        controller = new ExtractBNF();
        controller.getBNF();
        Test.stopTest();
    }
	  	
 	 static testmethod void testExtractRevisedRevenue() {
        Test.startTest();
        createBNFTestData();
        List<OpportunityLineItem> oli = [Select id, Revised_Revenue_Schedule__c from OpportunityLineItem ];
	  	oli[0].Revised_Revenue_Schedule__c = 'x|20160222:100|20160628:100';
        upsert oli;
        BNF2__c bnf = [Select id from BNF2__c limit 1];
        PageReference pageRef1 = new PageReference('Page.BNFPDF_MDM');
        pageRef1.getParameters().put('id', bnf.id);
        Test.setCurrentPage(pageRef1);
        ExtractBNF controller = new ExtractBNF();
        controller.opptyLineItem = oli;
        controller.GetRevenue_Schedule_Items();
        Test.stopTest();
 	 }
 	static testmethod void testExtractRevisedRevenue1() {
        Test.startTest();
        createBNFTestData();
        List<OpportunityLineItem> oli = [Select id, Revised_Revenue_Schedule__c from OpportunityLineItem ];
	  	oli[0].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert oli;
        BNF2__c bnf = [Select id from BNF2__c limit 1];
        PageReference pageRef1 = new PageReference('Page.BNFPDF_MDM');
        pageRef1.getParameters().put('id', bnf.id);
        Test.setCurrentPage(pageRef1);
        ExtractBNF controller = new ExtractBNF();
        controller.opptyLineItem = oli;
        controller.GetRevenue_Schedule_Items();
        Test.stopTest();
 	 }
 	 static testmethod void testExtractBNFDisplay() {
        /*Test.startTest();
        createBNFTestData();
        String query = 'select Id ';
        for(Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.FieldsToTraceForBNF.getFields()) {
		        query += ', ' + f.getFieldPath();
		}
		query += ' , BSI_Json_Data_LAB__c, OLIS_Json_Data_LAB__c, Other_Ship_To_SAP_Contact__r.Name, PricebookEntry.Name,  Other_Ship_To_Address__r.Name, Other_Ship_To_Address__r.SAP_Reference__c FROM OpportunityLineItem ';
		List<OpportunityLineItem> oli =  Database.query(query);
		oli[0].OLI_Json_Data_1__c = JSON.serialize(oli[0]); 
        upsert oli;
        BNF2__c bnf = [Select id from BNF2__c limit 1];
        PageReference pageRef1 = new PageReference('Page.BNFPDF_MDM');
        pageRef1.getParameters().put('id', bnf.id);
        Test.setCurrentPage(pageRef1);
        ExtractBNF controller = new ExtractBNF();
        Test.stopTest();*/
 	 }
        
    

     
 
}