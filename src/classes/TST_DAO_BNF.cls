@isTest
private class TST_DAO_BNF {
    
    @testSetup static void setupTestData(){
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        User TestUser1  = new User(alias = 'jpusr', email='japnalocal@metacube.com', isActive = true,
                                   emailencodingkey='UTF-8',firstname='User',lastname='Testing', languagelocalekey='en_US', 
                                   localesidkey='en_US', profileid = p.Id, EmployeeNumber='676534',
                                   timezonesidkey='America/Los_Angeles', username='japnalocal@metacube1222.com',
                                   Change_Request_Description__c = 'test',
                                   Change_Request_Ticket_Number__c ='test description');
        insert TestUser1;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        UTL_ExecutionControl.stopTriggerExecution = false;
        System.runAs(TestUser1) {
            Current_Release_Version__c crv = new Current_Release_Version__c();
            crv.Current_Release__c = '3000.01';
            upsert crv;
            Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(ownerId = UserInfo.getUserId() , name='TestRA',User__c = TestUser1.id ,Revenue_Analyst_Email__c='test123192@metacube.com');
            insert TestLocalRA;
            BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true,Revenue_Analyst_Exception_Email__c = 'dheeraj.kumar1@metacube.com');
            bnfsetting.Excluded_Products__c = 'ZQUI|test';
            //bnfsetting.BNF_Submission_Template_ID__c = '00X700000019RwuEAE';
            //bnfsetting.MIBNF_Submission_Template_ID__c = '00X700000019RwxEAE';
            insert bnfsetting;
            Automated_User_Downgrade_Settings__c downgradeSettings = new Automated_User_Downgrade_Settings__c(FailureEmail__c = 'dheeraj.kumar1@metacube.com');
            insert downgradeSettings;
            
            Account TestAccount = BNF_Test_Data.createAccount();
            Contact con = UTL_TestData.createContact(TestAccount.Id);
            con.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
            con.Salesforce_User__c = TestUser1.Id;
            con.Survey_Opt_Out__c = false;
            insert con;
            List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
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
            TestOpp.Survey_Recipient__c = con.Id;
            //TestOpp.Unique_Business_Value__c = 'Unknown';
            //TestOpp.Therapy_Area__c= 'Hepatitis C [21]';
            TestOpp.Global_project_unit__c = 'AA/Japan';
            TestOpp.Potential_Competitor_1__c = comp.Id;
            insert TestOpp;
            
            Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
            prod1.Pillar__c = 'Information Offering; Technology Solutions';
            insert prod1;
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            pbe.Product2Id=prod1.id;
            pbe.IsActive=true;
            pbe.UnitPrice=100.0;
            pbe.CurrencyIsoCode = 'USD';
            insert pbe;
            
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            for(integer i = 0; i < 2; i++){
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = TestOpp.Id;
                oli.Product_Start_Date__c = Date.today();
                oli.Product_End_Date__c = Date.today().addYears(1) ;
                oli.PricebookEntryId = pbe.Id;
                oli.Billing_Frequency__c = 'Once';
                oli.Proj_Rpt_Frequency__c='Once [O]';
                oli.Therapy_Area__c= 'Hepatitis C [21]';
                oli.Delivery_Country__c = 'USA';
                oli.Quantity = 1.00;
                oli.UnitPrice = 9000;  
                oli.List_Price__c = 9000;
                //oli.Budget__c = budg.id;
                oli.Delivery_Date__c = System.today().addYears(1);
                oli.Revenue_Type__c = 'Ad Hoc';
                oli.Sale_Type__c = 'New';
                oli.Wbsrelementcode__c = 'asd';
                oliList.add(oli);
            }
            insert oliList;
            
            List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
            Integer RevFactor = 1;
            
            Date strScheduleDate = Date.valueOf(String.valueOf(System.now().year())+'-01-15 00:00:00');    
            for(OpportunityLineItem oli : oliList){
                RevFactor = 1;
                for (Integer i = 0; i < 3; i++) 
                {
                    Double dRevenueAmount = RevFactor*1000.00;
                    RevFactor = RevFactor + 2;
                    OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
                    OliSched.OpportunityLineItemId = oli.Id;
                    OliSched.Type = 'Revenue';
                    OliSched.Revenue = dRevenueAmount;
                    OliSched.ScheduleDate = strScheduleDate;
                    strScheduleDate = strScheduleDate.addMonths(1);
                    InsertOLISList.add(OliSched); 
                }
            }
            insert InsertOLISList;
            
            List<Billing_Schedule__c> schList = new List<Billing_Schedule__c>();
            Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oliList[0].Id);
            schList.add(sche);
            sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oliList[1].Id);
            schList.add(sche);
            insert schList;
            
            List<Billing_Schedule_Item__c> billingScheduleItem = new List<Billing_Schedule_Item__c>();
            
            for(Billing_Schedule__c schedule : schList){
                Billing_Schedule_Item__c sche1 = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 1000,Billing_Date__c = system.today(),Billing_Schedule__c = schedule.id);
                Billing_Schedule_Item__c sche2 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp1', Billing_Amount__c = 3000, Billing_Date__c = system.today().addMonths(1),Billing_Schedule__c = schedule.id );
                Billing_Schedule_Item__c sche3 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp2', Billing_Amount__c = 5000, Billing_Date__c = system.today().addMonths(2),Billing_Schedule__c = schedule.id );
                billingScheduleItem.add(sche1);
                billingScheduleItem.add(sche2); 
                billingScheduleItem.add(sche3);
            }
            insert billingScheduleItem;
        }
    }
    
    static void createBNFTestData() {
        
        User testUser = [Select id from User where email = 'japnalocal@metacube.com'];
        System.runAs(testUser) {
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
            Revenue_Analyst__c TestLocalRA = [Select id from Revenue_Analyst__c limit 1];
            TestBnf.Revenue_Analyst__c = TestLocalRA.id;  
            insert TestBnf;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Test Comment');
            req1.setSubmitterId(UserInfo.getUserId());
            req1.setObjectId(TestBnf.id); 
            Approval.ProcessResult result = Approval.process(req1);
        }
    }
    
    static void createMIBNFTestData() {
        Opportunity testOpp = [Select id, AccountId from Opportunity limit 1];
        
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
        Revenue_Analyst__c TestLocalRA = [Select id from Revenue_Analyst__c limit 1];
        TestMIBNF.Revenue_Analyst__c = TestLocalRA.id;
        insert TestMIBNF;
    }
    
    static void createMIBNFComp(Id MIBNFId, OpportunityLineItem oli) { 
        List<Address__c> TestAddress_Array = [Select id from Address__c limit 5];
        List<MIBNF_Component__c> mibnfList = new List<MIBNF_Component__c>();
        List<MI_BNF_LineItem__c> mibnfLI = new List<MI_BNF_LineItem__c>();
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
        mibnfList.add(TestMIBNF_Comp);
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
        mibnfList.add(TestMIBNF_Comp1);
        insert mibnfList;
        
        MI_BNF_LineItem__c TestMI_BNFLineItem = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem.MIBNF_Component__c = TestMIBNF_Comp.id;
        TestMI_BNFLineItem.Opportunity_Line_Itemid__c = oli.id;
        TestMI_BNFLineItem.Total_Price__c = oli.TotalPrice;       
        mibnfLI.add(TestMI_BNFLineItem);
        MI_BNF_LineItem__c TestMI_BNFLineItem1 = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem1.MIBNF_Component__c = TestMIBNF_Comp1.id;
        TestMI_BNFLineItem1.Opportunity_Line_Itemid__c = oli.id;
        TestMI_BNFLineItem1.Total_Price__c = oli.TotalPrice;       
        mibnfLI.add(TestMI_BNFLineItem1);
        insert mibnfLI;
    }
    
    @isTest
    public static void testdeleteInactiveUsersWorkItem(){
        Test.startTest();
        Profile p = [select id from profile where Name like '%system administrator%' limit 1];
        User TestUser1  = new User(alias = 'jpusr', email='japnalocal@metacube.com', isActive = false,
        emailencodingkey='UTF-8',firstname='User',EmployeeNumber='6764554',lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, 
        timezonesidkey='America/Los_Angeles', username='japnalocal@metacube1234aw.com');
        insert TestUser1;
        DAO_BNF.deleteInactiveUsersWorkItemFuture(new Set<Id>{TestUser1.Id});
        DAO_BNF.sendMailOnException(new Set<Id>{TestUser1.Id},'Exception occured');
        Test.stopTest();
    }
    
    @isTest
    public static void teststopDeletionOfBNF(){
        createMIBNFTestData();
        Test.startTest();
        MIBNF2__c testMIBNF = [Select id from MIBNF2__c limit 1];
        List<OpportunityLineItem> oliList = [Select id, TotalPrice from OpportunityLineItem limit 2];
        createMIBNFComp(testMIBNF.id, oliList[0]);
        Map<Id, MIBNF_Component__c> triggerOldMap = new Map<Id, MIBNF_Component__c>([select id,MIBNF__c from MIBNF_Component__c]);
        DAO_BNF.stopDeletionOfBNF(triggerOldMap);
        Test.stopTest();
    }
}