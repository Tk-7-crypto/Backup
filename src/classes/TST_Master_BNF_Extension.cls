@isTest
private class TST_Master_BNF_Extension 
{

    private static Opportunity TestOpp;
    private static Opportunity TestOpp2;
    private static Opportunity TestOpp3;
    private static List<Opportunity> Opportunity_Array;
    private static BNF2__c TestBnf;
    private static Master_BNF__c MBNF;
    private static Master_BNF_Extension controller;
    
    static void SetupExistingOpps() {
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        Account NewAccount = new Account();
        NewAccount.Name = 'Test Account';
        NewAccount.CustomerSegment__c = 'GOVERNMENT';
        NewAccount.Sub_Industry__c = 'STATE';
        insert NewAccount;
        
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        userList[0].PIC_Eligible__c = true;
        insert userList;
        Contact cnt = UTL_TestData.createContact(NewAccount.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        insert cnt;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        Opportunity_Array = new List<Opportunity>();
        TestOpp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Budget_Available__c = 'Yes';
        TestOpp.StageName='5. Finalizing Deal';
        TestOpp.FPI_Date__c=system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        TestOpp.AccountId = NewAccount.Id;
        TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Principle_inCharge__c = cnt.Id;
        TestOpp.Potential_Competitor_1__c = comp.Id;
        Opportunity_Array.add(TestOpp);
        
        TestOpp2 = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp2.LeadSource = 'Account Planning';
        TestOpp2.CurrencyIsoCode = 'USD';
        TestOpp2.Budget_Available__c = 'Yes';
        TestOpp2.StageName='5. Finalizing Deal';
        TestOpp2.FPI_Date__c=system.today();
        TestOpp2.Population_Age_Group__c = 'Not Applicable';
        TestOpp2.AccountId = NewAccount.Id;
        TestOpp2.Contract_Term__c='Single-Period';
        TestOpp2.Contract_End_Date__c = system.today();
        TestOpp2.Contract_Start_Date__c = system.today();
        TestOpp2.Contract_Type__c='Individual';
        TestOpp2.LeadSource = 'Account Planning';
        TestOpp2.Principle_inCharge__c = cnt.Id;
        TestOpp2.Potential_Competitor_1__c = comp.Id;
        Opportunity_Array.add(TestOpp2);
        
        TestOpp3 = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp3.LeadSource = 'Account Planning';
        TestOpp3.CurrencyIsoCode = 'USD';
        TestOpp3.Budget_Available__c = 'Yes';
        TestOpp3.StageName='5. Finalizing Deal';
        TestOpp3.FPI_Date__c=system.today();
        TestOpp3.Population_Age_Group__c = 'Not Applicable';
        TestOpp3.AccountId = NewAccount.Id;
        TestOpp3.Contract_Term__c='Single-Period';
        TestOpp3.Contract_End_Date__c = system.today();
        TestOpp3.Contract_Start_Date__c = system.today();
        TestOpp3.Contract_Type__c='Individual';
        TestOpp3.LeadSource = 'Account Planning';
        TestOpp3.Principle_inCharge__c = cnt.Id;
        TestOpp3.Potential_Competitor_1__c = comp.Id;
        Opportunity_Array.add(TestOpp3);

        insert Opportunity_Array;
        
        OpportunityContactRole contactRole1 = UTL_TestData.createOpportunityContactRole(cnt.Id, TestOpp.Id);
        OpportunityContactRole contactRole2 = UTL_TestData.createOpportunityContactRole(cnt.Id, TestOpp2.Id);
        OpportunityContactRole contactRole3 = UTL_TestData.createOpportunityContactRole(cnt.Id, TestOpp3.Id);
        insert new List<OpportunityContactRole>{contactRole1,contactRole2,contactRole3};
        TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        insert TestBnf;
    }
    
    static void AddLineItems() {
        //  Add a line item to the opportunity
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        
        Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly' , isActive =true );
        prod1.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI ;
        prod1.Pillar__c = 'Technology Solutions; Information Offering';
        insert prod1;
       
        PricebookEntry pbe;
        pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id=prod1.id;
        pbe.IsActive=true;
        pbe.UnitPrice=100.0;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
        
        for (Opportunity O:Opportunity_Array) {
            OpportunityLineItem OLI1 = new OpportunityLineItem();
            OLI1.OpportunityId = O.Id;
            PricebookEntry PE1 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZREP' limit 1][0];
            OLI1.PricebookEntryId = PE1.Id;
            OLI1.Quantity = 1.00;
            OLI1.UnitPrice = 10000;
            OLI1.Sale_Type__c = 'New';
            OLI1.Revenue_Type__c = 'Ad Hoc';
            OLI1.Therapy_Area__c= 'Hepatitis C [21]';
            OLI1.Wbsrelementcode__c = 'Test';
			OLI1.Delivery_Country__c = 'USA';
            OLI_Array.add(OLI1);
            //insert OLI1;
            
            OpportunityLineItem OLI2 = new OpportunityLineItem();
            OLI2.OpportunityId = O.Id;
            PricebookEntry PE2 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZREP' limit 1][0];
            OLI2.PricebookEntryId = PE2.Id;
            OLI2.Quantity = 1.00;
            OLI2.UnitPrice = 10000;
            OLI2.Sale_Type__c = 'New';
            OLI2.Revenue_Type__c = 'Ad Hoc';
            OLI2.Therapy_Area__c= 'Hepatitis C [21]';
            OLI2.Wbsrelementcode__c = 'Test';
			OLI2.Delivery_Country__c = 'USA';
            OLI_Array.add(OLI2);
        }
        UTL_ExecutionControl.stopTriggerExecution = true;
        insert OLI_Array;
        UTL_ExecutionControl.stopTriggerExecution = false;
       // insert OLI2;
    }
    
    static void CreateStdController() {
        ApexPages.currentPage().getParameters().put('OpportunityId',TestOpp.Id);
        ApexPages.currentPage().getParameters().put('bnftype','invoice');
        ApexPages.currentPage().getParameters().put('bnfid',TestBnf.Id);
        //  Create an instance of the standard controller
        MBNF = new Master_BNF__c(IMS_Sales_Org__c = 'Acceletra'); 
        ApexPages.StandardController stc = new ApexPages.StandardController(MBNF);
        //  Create an instance of the controller extension       
        controller = new Master_BNF_Extension(stc);
    }
    
    static void SetupMBNF() {
        SetupExistingOpps();
        AddLineItems();
        TestOpp.StageName = '7a. Closed Won';
        TestOpp.FPI_Date__c=system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        TestOpp.Primary_Win_Reason__c = 'Project Performance';
        TestOpp2.Primary_Win_Reason__c = 'Project Performance';
        TestOpp2.StageName = '7a. Closed Won';
        TestOpp2.FPI_Date__c=system.today();
        TestOpp2.Population_Age_Group__c = 'Not Applicable';
        update Opportunity_Array;
        CreateStdController();
        Revenue_Analyst__c RA = new Revenue_Analyst__c(Name ='Test RA', User__c = UserInfo.getUserId());
        insert RA;
        
        MBNF.Revenue_Analyst__c = RA.Id;
        controller.ProxyOcr.OpportunityId = TestOpp2.Id;
        controller.AddOpportunityRow();
    }
    
    static void runMethods1() {
        controller.getsetCon();
        controller.getContactLookupQueryModifier();
        controller.getChooseRender();
        controller.getRenderForPdf();
        controller.getInitiatingBnf();
        controller.getChooseContentType();
        controller.GeneratePdf();
        controller.getBillingContacts();
        controller.getAccountOpportunities();
        controller.getTest();
        controller.getEditOppsRendered();
        controller.getEditHeaderRendered();
        controller.getAddMoreOppsRendered();
        controller.getOppListRendered();
        controller.getNewBnfWizardStep1Rendered();
        controller.getNewBnfWizardStep2Rendered();
        controller.getNewBnfWizardStep2BRendered();
        controller.getNewBnfWizardStep3Rendered();
        controller.getNewBnfWizardStep4Rendered();
        controller.Init_View();
        controller.getOpportunityContainer_Array();
        controller.SaveOppList();
        controller.DisplayMessage('Test Message','INFO');
        
    }
    
    static void runMethods3() {
        controller.DoNothing();
        controller.ShowEditOpps();
        controller.HideEditOpps();
        controller.CancelEditOpps();
        controller.ShowEditHeader();
        controller.HideEditHeader();
        controller.ShowOppList();
        controller.ProxyOcr.OpportunityId = TestOpp3.Id;
        controller.AddOpportunityRow();
        controller.SaveAddedOpp();
        controller.ToggleEditOpps();
        ApexPages.currentPage().getParameters().put('DelOppId',TestOpp.Id);
        controller.DeleteOpportunityRow();
        
    }
    
    static void runMethods2() {
        controller.Next2();
        controller.Next3();
        controller.Back2();
        controller.Back3();
        controller.InvoiceNext2();
        controller.InvoiceNext3();
        controller.InvoiceBack3();
        controller.getRenderedForInvoice();
        controller.ShowAddMoreOpps();
        controller.HideAddMoreOpps();
        controller.SaveHeader();
        controller.CancelWizard();
        controller.getBnfLocked();
        controller.getStatusImage();
        Controlling_Field_Option__c fieldOption = new Controlling_Field_Option__c();
        fieldOption.Name = 'Acceletra';
        fieldOption.Controlling_Field_Name__c = 'IMS_Sales_Org__c';
        fieldOption.Controlling_Field_Value__c = 'Acceletra';
        fieldOption.object_name__c = 'Master_BNF__c';
        insert fieldOption;
        controller.getSalesOrgs();
        Dependent_Field_Option__c depfieldOption = new Dependent_Field_Option__c();
        depfieldOption.Controlling_Field_Option__c = fieldOption.id;
        depfieldOption.Dependent_Field_Name__c = 'IMS_Sales_Org__c';
        depfieldOption.Dependent_Field_Value__c = 'Acceletra';
        insert depfieldOption;
        controller.getSalesOrgCodes();
    }
    
    static testMethod void t1() {
        //PseSecurity.settingDisableSecurityTriggers = true;
        User TestUser = [select Id from User where IsActive = true and Profile.Name = 'System Administrator' and Id =:UserInfo.getUserid() limit 1];
        System.runAs(TestUser) {
            SetupMBNF();
            Test.startTest();
            controller.CreateMasterBnf();
            //Need to be refactor below code, commented out to make deployment successful 
            runMethods1();
            Test.stopTest();
        }  
    }
    
    static testMethod void t2() {
        //PseSecurity.settingDisableSecurityTriggers = true;
        User TestUser = [select Id from User where IsActive = true and Profile.Name = 'System Administrator' and Id =:UserInfo.getUserid() limit 1];
        System.runAs(TestUser) {
            SetupMBNF();
            //Need to be refactor below code, commented out to make deployment successful 
            Test.startTest();
            controller.CreateMasterBnf();
            runMethods2();
            Test.stopTest(); 
        }
        
    }
    
    static testMethod void t3() {
        //PseSecurity.settingDisableSecurityTriggers = true;
        User TestUser = [select Id from User where IsActive = true and Profile.Name = 'System Administrator' and Id =:UserInfo.getUserid() limit 1];
        System.runAs(TestUser) {
            SetupMBNF();
            Test.startTest();
            controller.CreateMasterBnf();
            runMethods3();
            Test.stopTest();
        }
    }
    
    static testMethod void t4() {
        Test.startTest();
        SetupExistingOpps();
        AddLineItems();
        TestOpp.StageName = '7a. Closed Won';
        TestOpp.FPI_Date__c=system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        TestOpp2.StageName = '7a. Closed Won';
        TestOpp2.FPI_Date__c=system.today();
        TestOpp2.Population_Age_Group__c = 'Not Applicable';
        TestOpp.Primary_Win_Reason__c = 'Project Performance';
        TestOpp2.Primary_Win_Reason__c = 'Project Performance';
        update Opportunity_Array;
        MBNF = new Master_BNF__c(IMS_Sales_Org__c = 'Acceletra'); 
        ApexPages.StandardController stc = new ApexPages.StandardController(MBNF);
        //  Create an instance of the controller extension       
        controller = new Master_BNF_Extension(stc);
        controller.ProxyOcr.OpportunityId = TestOpp.id;
        controller.AddOpportunityRow();
        controller.Init_View();    
        Test.stopTest();
    }
}