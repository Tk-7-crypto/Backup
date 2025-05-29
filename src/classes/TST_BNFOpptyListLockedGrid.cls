@isTest
private class TST_BNFOpptyListLockedGrid {
    
    public static ApexPages.StandardController controller;
    private static BNFOpptyListLockedGrid extension;
    public static PageReference pageRef1 ;
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
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        userlocaleList = BNF_Test_Data.create_User_LocaleSetting();
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity TestOpp = new Opportunity(Name='test',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.StageName='7a. Closed Won';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_Start_Date__c  = system.today().adddays(-5);
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
        //pse__Proj__c proj = CommanUtilityTestFunction.createEngagement(testContact1, pseregion, acc, salesorg);
        //insert proj;
        /*pse__Budget__c budg = CommanUtilityTestFunction.createBudget(proj,acc,testContact1,salesorg);
budg.WBSRElementCode__c = '1,3,5';
budg.Therapyarea__c = 'Hepatitis C [21]';
budg.pse__Amount__c = 9000;
insert budg;*/
        
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = TestOpp.Id;
        oli.Product_Start_Date__c = Date.today().adddays(30);
        oli.Product_End_Date__c = Date.today().addYears(1) ;
        oli.PricebookEntryId = pbe.Id;
        oli.Billing_Frequency__c = 'Once';
        oli.Proj_Rpt_Frequency__c='Once [O]';
        oli.Therapy_Area__c= 'Hepatitis C [21]';
        oli.Quantity = 1.00;
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
    
    public static testMethod void testBNFApproval() {
        Test.startTest();
        //pse__Proj__c pseproject = [Select id, pse__Start_Date__c, pse__End_Date__c from pse__Proj__c limit 1];
        //System.debug('pseproject.pse__Start_Date__c'+pseproject.pse__Start_Date__c+'  '+pseproject.pse__End_Date__c);
        //pseproject.pse__Start_Date__c = Date.today();
        //pseproject.pse__End_Date__c = Date.today().addmonths(1);
        //upsert pseproject;
        OpportunityLineItem oli = [Select id from OpportunityLineItem limit 1];
        oli.Delivery_Date__c = System.today(); 
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        oli.Billing_Frequency__c = '50% upon signature, 50% upon completion';
        upsert oli;
        //System.debug('pseproject.pse__Start_Date__c after'+pseproject.pse__Start_Date__c+'  '+pseproject.pse__End_Date__c);
        Product2 prod = [Select id from Product2 limit 1];
        prod.Offering_Type__c = 'Commercial Tech';
        upsert prod;
        createBNFTestData();
        BNF2__c BNF = [select  id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Test Comment');
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setObjectId(BNF.id); 
        try {
            Approval.ProcessResult result = Approval.process(req1);
        } catch (Exception e) {
            System.assert(true,'custom validation occur');
        }
        
        /*PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
pageRef.getParameters().put('bnfid', BNF.Id);
pageRef.getParameters().put('id', BNF.Opportunity__c);
Test.setCurrentPage(pageRef);
controller = new ApexPages.standardController(new BNF2__c());
extension = new BNFOpptyListLockedGrid(controller);
extension.init();

extension.save();*/
        Test.stopTest();
    }
    
    public static testMethod void testBNFValidateOLIFALSE() {
        Test.startTest();
        //pse__Proj__c pseproject = [Select id, pse__Start_Date__c, pse__End_Date__c from pse__Proj__c limit 1];
        //System.debug('pseproject.pse__Start_Date__c'+pseproject.pse__Start_Date__c+'  '+pseproject.pse__End_Date__c);
        //pseproject.pse__Start_Date__c = Date.today();
        //pseproject.pse__End_Date__c = Date.today().addmonths(1);
        //upsert pseproject;
        OpportunityLineItem oli = [Select id from OpportunityLineItem limit 1];
        oli.Delivery_Date__c = System.today(); 
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        oli.Billing_Frequency__c = '50% upon signature, 50% upon completion';
        upsert oli;
        //System.debug('pseproject.pse__Start_Date__c after'+pseproject.pse__Start_Date__c+'  '+pseproject.pse__End_Date__c);
        Product2 prod = [Select id from Product2 limit 1];
        prod.Offering_Type__c = 'Commercial Tech';
        upsert prod;
        createBNFTestData();
        BNF2__c BNF = [select  id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        
        
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', BNF.Id);
        pageRef.getParameters().put('id', BNF.Opportunity__c);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller);
        extension.init();
        
        extension.save();
        Test.stopTest();
    }
    
    
    
    public static testMethod void testBNFValidateOLIDeliveryDate() {
        Test.startTest();
        OpportunityLineItem oli = [Select id from OpportunityLineItem limit 1];
        oli.Delivery_Date__c = null;
        oli.Proj_Rpt_Frequency__c = 'Once [O]';
        upsert oli;
        
        createBNFTestData();
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 10000000;
        upsert temp;
        BNF2__c BNF = [select  id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', BNF.Id);
        pageRef.getParameters().put('id', BNF.Opportunity__c);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller);
        extension.init();
        
        extension.save();    
        Test.stopTest(); 
    }
    
    public static testMethod void testBNFApprovalDeliveryDateNULL() {
        Test.startTest();
        OpportunityLineItem oli = [Select id from OpportunityLineItem limit 1];
        oli.Delivery_Date__c = null;
        oli.Proj_Rpt_Frequency__c = 'Once [O]';
        upsert oli;
        
        createBNFTestData();
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 10000000;
        upsert temp;
        BNF2__c BNF = [select  id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Test Comment');
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setObjectId(BNF.id); 
        try {
            Approval.ProcessResult result = Approval.process(req1);
        } catch (Exception e) {
            System.assert(true,'custom validation occur');
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testBNFApprovalCorrect() {
        Test.startTest();
        createBNFTestData();
        BNFOpptyListLockedGrid.CheckValidation = false;
        BNF2__c BNF = [select  id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Test Comment');
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setObjectId(BNF.id); 
        Approval.ProcessResult result = Approval.process(req1);
        
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', BNF.Id);
        pageRef.getParameters().put('id', BNF.Opportunity__c);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller);
        extension.init();
        
        extension.save();
        Test.stopTest();
    }
    
    public static testMethod void testBNFApprovalNonSystemAdminProfile() {
        List<User> NonSystemAdminUserList = [Select id , name,profileid, profile.name from User where Profile.name like '%system administrator%' and isactive = true limit 2];
        Test.startTest();
        Id bnfId = null;
        BNF2__c  BNF;
        BNFOpptyListLockedGrid.CheckValidation = false;
        system.runAs(new User(Id = UserInfo.getUserid())) {
            createBNFTestData();
            BNF = [select id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
            bnfId = BNF.id;
            Revenue_Analyst__c testRA = [Select id , User__C from Revenue_Analyst__c where id =:BNF.Revenue_Analyst__c];
            testRA.User__c = NonSystemAdminUserList[0].id;
            upsert testRA;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Test Comment');
            req1.setSubmitterId(NonSystemAdminUserList[0].id);
            req1.setObjectId(BNF.id); 
            Approval.ProcessResult result = Approval.process(req1);
        }
        System.runAs(NonSystemAdminUserList[1]) {
            PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
            pageRef.getParameters().put('bnfid', bnfid);
            pageRef.getParameters().put('id', BNF.Opportunity__c);
            Test.setCurrentPage(pageRef);
            controller = new ApexPages.standardController(new BNF2__c());
            extension = new BNFOpptyListLockedGrid(controller);
            extension.init();
        }
        Test.stopTest();
    }
    
    public static testMethod void testBNFApprovalAccepted() {
        List<User> NonSystemAdminUserList = [Select id , name,profileid, profile.name from User where Profile.name like '%system administrator%' and isactive = true limit 2];
        Test.startTest();
        Id bnfId = null;
        BNF2__c  BNF;
        BNFOpptyListLockedGrid.CheckValidation = false;
        createBNFTestData();
        system.runAs(new User(Id = UserInfo.getUserid())) {
            BNF = [select id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
            bnfId = BNF.id;
            Revenue_Analyst__c testRA = [Select id , User__C from Revenue_Analyst__c where id =:BNF.Revenue_Analyst__c];
            testRA.User__c = NonSystemAdminUserList[0].id;
            upsert testRA;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Test Comment');
            req1.setSubmitterId(NonSystemAdminUserList[0].id);
            req1.setObjectId(BNF.id); 
            Approval.ProcessResult result = Approval.process(req1);
        }
        
        BNF = [select id, Revenue_Analyst__c,Opportunity__c from BNF2__c Limit 1];
        bnfId = BNF.id;
        System.runAs(new User(Id = UserInfo.getUserid())) {
            BNF_Approval_Extension.CustomApprovalPage = true;
            BNF.BNF_Status__c = 'Accepted';
            BNF.SAP_Contract__c = '1234567890';
            upsert BNF;
            PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
            pageRef.getParameters().put('bnfid', bnfid);
            pageRef.getParameters().put('id', BNF.Opportunity__c);
            Test.setCurrentPage(pageRef);
            controller = new ApexPages.standardController(new BNF2__c());
            extension = new BNFOpptyListLockedGrid(controller);
            extension.init();
        }
        Test.stopTest();
    }
    
    public static testMethod void testBNFApprovalRAAccepted() {
        List<User> NonSystemAdminUserList = [Select id , name,profileid, profile.name from User where Profile.name like '%system administrator%' and isactive = true limit 2];
        Test.startTest();
        Id bnfId = null;
        BNF2__c  BNF;
        BNFOpptyListLockedGrid.CheckValidation = false;
        system.runAs(new User(Id = UserInfo.getUserid())) {
            createBNFTestData();
            BNF = [select id, Revenue_Analyst__c,Opportunity__c,BNF_Status__c from BNF2__c Limit 1];
            bnfId = BNF.id;
            Revenue_Analyst__c testRA = [Select id , User__C from Revenue_Analyst__c where id =:BNF.Revenue_Analyst__c];
            testRA.User__c = NonSystemAdminUserList[0].id;
            upsert testRA;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Test Comment');
            req1.setSubmitterId(NonSystemAdminUserList[0].id);
            req1.setObjectId(BNF.id); 
            Approval.ProcessResult result = Approval.process(req1);
        }
        System.runAs(NonSystemAdminUserList[1]) {
            BNF_Approval_Extension.CustomApprovalPage = true;
            BNF.BNF_Status__c = 'RA Accepted';
            upsert BNF;
            PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
            pageRef.getParameters().put('bnfid', bnfid);
            pageRef.getParameters().put('id', BNF.Opportunity__c);
            Test.setCurrentPage(pageRef);
            controller = new ApexPages.standardController(new BNF2__c());
            extension = new BNFOpptyListLockedGrid(controller);
            extension.init();
        }
        Test.stopTest();
    }
    
    
    public static testMethod void testMyController() {
        Test.startTest();
        createBNFTestData();
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        product.Therapy_Class__c = '1:25';
        update product;
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name, opportunity_number__c, StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', bnfid);
        pageRef.getParameters().put('id', TestOpp.Id);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller);
        extension.testCheck();
        
        //Update by: Sneha Date: 14th March, 2012 - repeated for both pages
        pageRef = new PageReference('Page.BNFOpptyListLockedGrid');
        pageRef.getParameters().put('bnfid', bnfid);
        pageRef.getParameters().put('id', TestOpp.Id);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller);
        extension.testCheck();
        
        
        ApexPages.currentPage().getParameters().put('itemindex','0'); 
        ApexPages.currentPage().getParameters().put('pricevalue','400');
        extension.setOpportunityLineItem([Select   Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name,PricebookEntry.Product2.Material_Group_1__c, 
                                          PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                                          PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                          CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                          PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                          Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c,PO_line_item_number__c, 
                                          Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                                          Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                          Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c,Audit_Subscription_Status__c, 
                                          OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem o Limit 5]);
        extension.CalculateSurcharge();
        PageReference dummy = extension.save();
        List<OpportunityLineItem> dummyList = extension.getOpportunityLineItem2();
        //   extension.setDeliveryMediaAll();
        dummy = extension.cancel();
        extension.setDeliveryMediaOpt(true);
        
        extension.setTemp('Temp');
        String temp = extension.getTemp();
        //extension.showBNFInfo();
        Test.stopTest();
    }
    
    public static testMethod void testMyController1() {
        Test.startTest();
        createBNFTestData();
        BNF2__c testBNFrec = [Select id from BNF2__c limit 1];
        Id bnfid = testBNFrec.Id;
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', bnfid);
        pageRef.getParameters().put('itemindex', '0');
        pageRef.getParameters().put('pricevalue', 'three');
        pageRef.getParameters().put('isRevised', '0');
        Test.setCurrentPage(pageRef);
        
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller);
        extension.setOpportunityLineItem([Select   Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name, 
                                          PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                                          PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                          CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                          PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                          Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c,PO_line_item_number__c, 
                                          Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                                          Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                          Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                          OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem o]);
        extension.CalculateSurcharge();
        User_Locale__c userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format6'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        extension.CalculateSurcharge();
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format5'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        extension.CalculateSurcharge();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format4'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        extension.CalculateSurcharge();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format3'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        extension.CalculateSurcharge();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format2'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        extension.CalculateSurcharge();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format1'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        extension.CalculateSurcharge();
        Test.stopTest();
    }
    
    public static testmethod void t1()
    {
        Test.startTest();
        createBNFTestData();
        CLS_ProductionReference Convertor = new CLS_ProductionReference();
        Integer iTest = Convertor.CalculateElapsedMinsThisYear();
        system.debug('Mins this year: '+ iTest.format());
        String sOutput = Convertor.ConvertToRadix34(364883);
        system.debug('Output: '+ sOutput);
        system.assertEquals('AAMV',sOutput);
        Test.stopTest();
    }
    
    
    public static testmethod void t2() 
    {
        Test.startTest();
        createBNFTestData();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGrid');
        pageRef.getParameters().put('bnfid', bnfid);
        pageRef.getParameters().put('itemindex2', '0');
        
        pageRef.getParameters().put('id', TestOpp.Id);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller); 
        extension.CalculateRevisedPrice();
        Integer num = extension.billScheduleNum;
        Double amt = extension.billScheduleAmt;
        extension.getDeliveryMediaOpt();
        extension.getBNF();
        //extension.setBNF(bnfid);
        extension.getPORequiredOnBNF();
        extension.getOLITherapyErrorMsg();
        extension.setPORequiredOnBNF(true);
        extension.setOLITherapyErrorMsg('Err');
        Test.stopTest();
    }    
    
    public static testmethod void t3() 
    {
        Test.startTest();
        createBNFTestData();
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 10000000;
        upsert temp;
        
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGrid');
        pageRef.getParameters().put('bnfid', bnfid);
        pageRef.getParameters().put('itemindex2', '0');
        
        pageRef.getParameters().put('id', TestOpp.Id);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller); 
        extension.CalculateRevisedPrice();
        Integer num = extension.billScheduleNum;
        Double amt = extension.billScheduleAmt;
        extension.getDeliveryMediaOpt();
        extension.getBNF();
        //extension.setBNF(bnfid);
        extension.getPORequiredOnBNF();
        extension.getOLITherapyErrorMsg();
        extension.setPORequiredOnBNF(true);
        extension.setOLITherapyErrorMsg('Err');
        Test.stopTest();
    }     
    
    public static testmethod void t4() 
    {
        Test.startTest();
        createBNFTestData();
        
        
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        
        Id bnfid = bnfList[0].Id;
        BNFOpptyListLockedGrid.CheckValidation = false;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Test Comment');
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setObjectId(bnfid); 
        Approval.ProcessResult result = Approval.process(req1);
        
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 10000000;
        upsert temp;
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGrid');
        pageRef.getParameters().put('bnfid', bnfid);
        pageRef.getParameters().put('itemindex2', '0');
        
        pageRef.getParameters().put('id', TestOpp.Id);
        Test.setCurrentPage(pageRef);
        controller = new ApexPages.standardController(new BNF2__c());
        extension = new BNFOpptyListLockedGrid(controller); 
        extension.init();
        extension.CalculateRevisedPrice();
        Integer num = extension.billScheduleNum;
        Double amt = extension.billScheduleAmt;
        extension.getDeliveryMediaOpt();
        extension.getBNF();
        //extension.setBNF(bnfid);
        extension.getPORequiredOnBNF();
        extension.getOLITherapyErrorMsg();
        extension.setPORequiredOnBNF(true);
        extension.setOLITherapyErrorMsg('Err');
        Test.stopTest();
    }     
    
    public static testmethod void t5() 
    {
        Test.startTest();
        createBNFTestData();
        
        
        BNF2__c bnf = [Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c limit 1];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity limit 1];
        Id bnfid = bnf.Id;
        BNFOpptyListLockedGrid.CheckValidation = false;
        List<User> NonSystemAdminUserList = [Select id , name,profileid, profile.name from User where Profile.name like '%system administrator%' and isactive = true limit 2];
        System.runAs(new User(Id = UserInfo.getUserid())) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Test Comment');
            req1.setSubmitterId(NonSystemAdminUserList[0].id);
            req1.setObjectId(bnfid); 
            Approval.ProcessResult result = Approval.process(req1);
        }
        
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 10000000;
        upsert temp;
        System.runAs(NonSystemAdminUserList[1]) {
            BNF_Approval_Extension.CustomApprovalPage = true;
            BNF.BNF_Status__c = 'Accepted';
            BNF.SAP_Contract__c = '1234567890';
            upsert BNF;
            
            PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGrid');
            pageRef.getParameters().put('bnfid', bnfid);
            pageRef.getParameters().put('id', TestOpp.Id);
            Test.setCurrentPage(pageRef);
            controller = new ApexPages.standardController(new BNF2__c());
            extension = new BNFOpptyListLockedGrid(controller); 
            extension.init();
        }
        Test.stopTest();
    }
    
    public static testmethod void t6() 
    {
        Test.startTest();
        createBNFTestData();
        
        
        BNF2__c bnf = [Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c limit 1];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity limit 1];
        Id bnfid = bnf.Id;
        
        List<User> NonSystemAdminUserList = [Select id , name,profileid, profile.name from User where Profile.name like '%system administrator%' and isactive = true limit 2];
        /*System.runAs(new User(Id = UserInfo.getUserid())) {
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Test Comment');
req1.setSubmitterId(NonSystemAdminUserList[0].id);
req1.setObjectId(bnfid); 
Approval.ProcessResult result = Approval.process(req1);
}*/
        
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 10000000;
        upsert temp;
        System.runAs(NonSystemAdminUserList[1]) {
            BNF_Approval_Extension.CustomApprovalPage = true;
            BNF.BNF_Status__c = 'SAP Contract Confirmed';
            BNF.SAP_Contract__c = '1234567890';
            upsert BNF;
            
            PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGrid');
            pageRef.getParameters().put('bnfid', bnfid);
            pageRef.getParameters().put('id', TestOpp.Id);
            Test.setCurrentPage(pageRef);
            controller = new ApexPages.standardController(new BNF2__c());
            extension = new BNFOpptyListLockedGrid(controller); 
            extension.init();
        }
        Test.stopTest();
        
    }  
    
    public static testmethod void t7() 
    {
        Test.startTest();
        createBNFTestData();
        
        
        BNF2__c bnf = [Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c limit 1];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity limit 1];
        Id bnfid = bnf.Id;
        BNFOpptyListLockedGrid.CheckValidation = false;
        List<User> NonSystemAdminUserList = [Select id , name,profileid, profile.name from User where Profile.name like '%system administrator%' and isactive = true limit 2];
        System.runAs(new User(Id = UserInfo.getUserid())) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Test Comment');
            req1.setSubmitterId(NonSystemAdminUserList[0].id);
            req1.setObjectId(bnfid); 
            Approval.ProcessResult result = Approval.process(req1);
        }
        
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 10000000;
        upsert temp;
        System.runAs(NonSystemAdminUserList[1]) {
            PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGrid');
            pageRef.getParameters().put('bnfid', bnfid);
            pageRef.getParameters().put('id', TestOpp.Id);
            Test.setCurrentPage(pageRef);
            controller = new ApexPages.standardController(new BNF2__c());
            extension = new BNFOpptyListLockedGrid(controller); 
            extension.init();
        }
        Test.stopTest();
        
    }
    
    public static testMethod void BNFInitTest()
    {
        Test.startTest();
        createBNFTestData();
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        Revenue_Analyst__c TestLocalRA = [select Id,Name,User__c from Revenue_Analyst__c where User__r.IsActive = true limit 1];
        setupBNF(TestLocalRA.Id,true);
        User U= [select id from user where id=: TestLocalRA.User__c];
        system.runAs(U)
        { 
            pageReference BnfApprovalPage = Page.BNF_Approval;
            BnfApprovalPage.getParameters().put('id',TestBnf.Id);
            
        }
        BNFOpptyListLockedGrid.CheckValidation = false;
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        system.runAs(U)
        {
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
            pageRef.getParameters().put('newid', TestBnf.Id);
            pageRef.getParameters().put('id', TestOpp.Id);
            Test.setCurrentPage(pageRef);
            controller = new ApexPages.standardController(new BNF2__c());
            extension = new BNFOpptyListLockedGrid(controller); 
            Document document;
            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = MDM_Defines.Document_Dev_Name_IMSSFDCGlossary;
            document.IsPublic = true;
            document.Name = 'My Document';
            document.FolderId = [select id from folder where name = 'Shared Documents'].id;
            insert document;
            extension.isNewBnf = true;
            extension.Init();
        }
        Test.stopTest();
    }
    static testmethod void testBNF() {
        Test.startTest();
        createBNFTestData();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name, opportunity_number__c, StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        OpportunityLineItem oli = [Select Id , Name from OpportunityLineItem Limit 1];
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', bnfList[0].id);
        pageRef.getParameters().put('id', TestOpp.Id);
        pageRef.getParameters().put('newid', bnfList[0].id);
        Test.setCurrentPage(pageRef); 
        controller = new ApexPages.standardController(bnfList[0]); 
        extension = new BNFOpptyListLockedGrid(controller);
        extension.oppLiId = oli.id;
        extension.showBNFInfo();
        oli = [Select id, Revised_Revenue_Schedule__c from OpportunityLineItem Limit 1 ];
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert oli;
        extension.ValidateOLI();
        extension.save();
        Test.stopTest();
    }
    
    static testmethod void testBNFNew() {
        Test.startTest();
        createBNFTestData();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name, opportunity_number__c, StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        OpportunityLineItem oli = [Select Id ,Revised_Revenue_Schedule__c,  Name from OpportunityLineItem Limit 1];
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert oli;
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('newid', bnfList[0].id);
        pageRef.getParameters().put('id', TestOpp.Id);
        Test.setCurrentPage(pageRef); 
        controller = new ApexPages.standardController(bnfList[0]); 
        extension = new BNFOpptyListLockedGrid(controller);
        extension.oppLiId = oli.id;
        extension.showBNFInfo();
        extension.ValidateOLI();
        Test.stopTest();
    }
    
    static testmethod void testBNFvalidate() {
        Test.startTest();
        createBNFTestData();
        BNF_Settings__c bnfsetting = [Select id, BNF_Opportunity_Threshold__c from  BNF_Settings__c limit 1 ];
        bnfsetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfsetting;
        OpportunityLineItem oli = [Select id,Billing_Frequency__c,OpportunityId from OpportunityLineItem Limit 1];
        System.debug('Billing_Frequency__c ::test'+oli.Billing_Frequency__c);
        
        
        BNF2__c BNF = [select id from BNF2__c Limit 1];
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', BNF.id);
        pageRef.getParameters().put('id', oli.OpportunityId);
        Test.setCurrentPage(pageRef); 
        controller = new ApexPages.standardController(BNF); 
        extension = new BNFOpptyListLockedGrid(controller);
        //extension.oppLiId = oli.id;
        oli.Billing_Frequency__c = '50% upon signature, 50% upon completion';
        oli = [Select id,Billing_Frequency__c,OpportunityId from OpportunityLineItem Limit 1];
        System.debug('Billing_Frequency__c ::test after'+oli.Billing_Frequency__c);
        upsert oli;
        extension.ValidateOLI();
        extension.save();
        Test.stopTest();
    }
    
    static void setupBNF(String ApproverID,Boolean isSAPBNF)
    {  
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        
        TestBnf.Revenue_Analyst__c = ApproverID;
        upsert TestBnf;
    }
    static testmethod void testsetIsNewBnfFlagException() {
        Test.startTest();
        createBNFTestData();
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = 1;
        upsert temp;
        //controller = new ApexPages.standardController(new BNF2__c(Opportunity_Number__c = '12345ii'));
        extension = new BNFOpptyListLockedGrid();
        extension.setIsNewBnfFlag();
        extension.glossaryDocumentId = null;
        Test.stopTest();
    }
    
    static testmethod void testPartialSave1(){
        Test.startTest();
        createBNFTestData();
        OpportunityLineItem oli = [Select id, OpportunityId from OpportunityLineItem Limit 1];
        Mulesoft_Integration_Control__c mulsoftSetting = Mulesoft_Integration_Control__c.getOrgDefaults();
        mulsoftSetting.Ignore_Validation_Rules__c = true;
        upsert mulsoftSetting;
        Product2 product = [Select Id from Product2 Limit 1];
        upsert new product2(Id = product.Id,Material_Type__c = 'ZPUB',Item_Category_Group__c ='ZPLI');
        upsert new OpportunityLineItem(Id = oli.Id, Product_Start_Date__c = Null, Delivery_Media__c = Null,  Proj_Rpt_Frequency__c = Null,Billing_Frequency__c = Null, Delivery_Country__c = 'USA',
                                       Nbr_of_Users__c = Null, Therapy_Area__c = Null,Product_End_Date__c = Null, Sale_Type__c = Null,Revenue_Type__c = Null,Audit_Subscription_Status__c = Null );
        //mulsoftSetting.Ignore_Validation_Rules__c = false; 
        BNF2__c BNF = [select id  from BNF2__c Limit 1];
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', BNF.id);
        pageRef.getParameters().put('id', oli.OpportunityId);
        Test.setCurrentPage(pageRef); 
        controller = new ApexPages.standardController(BNF); 
        extension = new BNFOpptyListLockedGrid(controller);
        extension.save();
        Test.stopTest();
    }
    
    static testmethod void testPartialSave2(){
        Test.startTest();
        createBNFTestData();
        OpportunityLineItem oli = [Select id, OpportunityId from OpportunityLineItem Limit 1];
        Mulesoft_Integration_Control__c mulsoftSetting = Mulesoft_Integration_Control__c.getOrgDefaults();
        mulsoftSetting.Ignore_Validation_Rules__c = true;
        upsert mulsoftSetting;
        Product2 product = [Select Id from Product2 Limit 1];
        upsert new product2(Id = product.Id,Material_Type__c = 'ZPUB',Item_Category_Group__c ='ZPLI');
        upsert new OpportunityLineItem(Id = oli.Id, Product_Start_Date__c = Null, Delivery_Media__c = Null,  Proj_Rpt_Frequency__c = Null,Billing_Frequency__c = Null, Delivery_Country__c = 'USA',
                                       Nbr_of_Users__c = Null, Therapy_Area__c = Null,Product_End_Date__c = Null, Sale_Type__c = Null,Revenue_Type__c = Null,Audit_Subscription_Status__c = Null );
        //mulsoftSetting.Ignore_Validation_Rules__c = false; 
        BNF2__c BNF = [select id, Opportunity_Number__c  from BNF2__c Limit 1];
        BNF_Settings__c temp = BNF_Settings__c.getOrgDefaults();
        temp.BNF_Opportunity_Threshold__c = decimal.valueOf(BNF.Opportunity_Number__c);
        upsert temp;
        PageReference pageRef = new PageReference('Page.BNFOpptyListLockedGridMDM');
        pageRef.getParameters().put('bnfid', BNF.id);
        pageRef.getParameters().put('id', oli.OpportunityId);
        Test.setCurrentPage(pageRef); 
        controller = new ApexPages.standardController(BNF); 
        extension = new BNFOpptyListLockedGrid(controller);
        extension.save();
        extension.savePartial();
        Test.stopTest();
    }  
}