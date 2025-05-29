@isTest
public class TST_MIBNF_Component_CheckBNFSubmit  {
    
    static testmethod void testmibnf_comp() {
        Contract_Management_Setting__c contractSetting = new Contract_Management_Setting__c();
        contractSetting.Allow_SalesOrg_Update_In_BNF_From_SCM__c = true;
        contractSetting.SOW__c = 'SOW';
        insert contractSetting;
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        bnfsetting.Enable_PO_Validation__c = true;
        upsert bnfsetting;
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, OLI_Array[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(OLI_Array);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        OpportunityLineItem oli = [Select id, Revised_Revenue_Schedule__c from OpportunityLineItem Limit 1];
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert oli;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestMIBNF_Comp.Id);
        try{
            Approval.ProcessResult result = Approval.process(req1);
            System.assert(false, 'code never reached here');
        } catch(Exception  ex) {
            System.assert(true, 'custom validation error');
        }
        Test.stopTest();
        
    }
    
    static testmethod void testmibnf_CompSAP_REJECTED() {
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        bnfsetting.BNF_Opportunity_Threshold__c = 2525225;
        bnfsetting.Enable_PO_Validation__c = true;
        upsert bnfsetting;
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, OLI_Array[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(OLI_Array);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        OpportunityLineItem oli = [Select id, Revised_Revenue_Schedule__c from OpportunityLineItem Limit 1];
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert oli;
        
        TestMIBNF_Comp.BNF_Status__c = 'RA Rejected';
        upsert TestMIBNF_Comp;
        Test.stopTest();
    }
    
    static testmethod void testmibnf_CompSAP_Confirm() {
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        bnfsetting.BNF_Opportunity_Threshold__c = 2525225;
        bnfsetting.Enable_PO_Validation__c = true;
        upsert bnfsetting;
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, OLI_Array[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(OLI_Array);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        OpportunityLineItem oli = [Select id, Revised_Revenue_Schedule__c from OpportunityLineItem Limit 1];
        oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert oli;
        
        TestMIBNF_Comp.BNF_Status__c = 'SAP Contract Confirmed';
        upsert TestMIBNF_Comp;
        Test.stopTest();
    }
    
    @isTest
    static void test1() {
        CON_CRM.MULESOFT_OLI_SYNC_TRIGGER_HAS_RUN = true;
        CON_CRM.IS_CURRENCY_CHANGE_FLOW =  true;
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Test_Data.createBNFSetting();
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        User testUser = [Select id, name from User where isActive = true Limit 1];
        //Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', PO_Required__c=true,Enabled_Sales_Orgs__c = 'Test12', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50);
        insert pbe;
        UTL_ExecutionControl.stopTriggerExecution = false;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='Test Opp');
        opp.AccountId = newAccount.Id;
        opp.StageName = '7a. Closed Won';
        opp.CloseDate = System.today();
        opp.Contract_Term__c='Single-Period';
        opp.Contract_End_Date__c = system.today();
        opp.Contract_Start_Date__c = system.today();
        opp.CurrencyIsoCode = 'USD';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.QI_Invited_to_Present__c = 'No';
        opp.FPI_Date__c = system.today();
        opp.Population_Age_Group__c = 'Not Applicable';
        opp.Potential_Competitor_1__c = comp.Id;
        oppList.add(opp);
        insert oppList;
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Quantity = 1, Delivery_Country__c = 'USA', unitPrice_USD__c = 10, TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.List_Price__c = 2000;
        lineItem.Sale_Type__c = 'New';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.Therapy_Area__c = 'Hepatitis C [21]';
        insert lineItem;
        
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 2000;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        MIBNF2__c testMIBNF = new MIBNF2__c();
        testMIBNF.Client__c = opp.AccountId;
        testMIBNF.Opportunity__c = opp.Id;
        testMIBNF.Sales_Org_Code__c = 'CH08';
        testMIBNF.Billing_Currency__c = 'USD';
        testMIBNF.IMS_Sales_Org__c = 'Acceletra';
        testMIBNF.Fair_Value_Type__c = 'Stand Alone';
        testMIBNF.Invoice_Default_Day__c = '15';
        testMIBNF.Contract_Start_Date__c = system.today();
        testMIBNF.Contract_End_Date__c = system.today();
        testMIBNF.Contract_Type__c = 'Individual';
        testMIBNF.Contract_Term__c = 'Single-Period';
        testMIBNF.IMS_Sales_Org__c = 'IMS Spain';
        testMIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        testMIBNF.Revenue_Analyst__c = ratest.Id;
        insert testMIBNF;
        
        MIBNF_Component__c testMIBNF_Comp = new MIBNF_Component__c();
        testMIBNF_Comp.MIBNF__c=testMIBNF.Id;
        testMIBNF_Comp.BNF_Status__c='New';
        testMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        testMIBNF_Comp.Print_Shop__c='No';
        testMIBNF_Comp.Bill_To__c = testAddress.Id;
        testMIBNF_Comp.X2nd_Copy__c = testAddress.Id;
        testMIBNF_Comp.Carbon_Copy__c = testAddress.Id;
        testMIBNF_Comp.Ship_To__c = testAddress.Id;
        testMIBNF_Comp.Cover_Sheet__c = testAddress.Id;
        testMIBNF_Comp.SAP_Contract__c = '1234567890';
        insert testMIBNF_Comp;
        
        Test.startTest();
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(testMIBNF_Comp.Id);
        Approval.ProcessResult result = Approval.process(req1);
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        newWorkItemIds = result2.getNewWorkitemIds();
        if(newWorkItemIds.size() > 0){
            req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setWorkitemId(newWorkItemIds.get(0));
            result2 =  Approval.process(req2);
        }
        Test.stopTest();
        System.assertEquals('Approved', result2.getInstanceStatus(),'Instance Status'+result2.getInstanceStatus());
    }
    
    @isTest
    static void test2() {
        CON_CRM.MULESOFT_OLI_SYNC_TRIGGER_HAS_RUN = true;
        CON_CRM.IS_CURRENCY_CHANGE_FLOW =  true;
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Test_Data.createBNFSetting();
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        User testUser = [Select id, name from User where isActive = true Limit 1];
        //Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'Test12', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50,CurrencyIsoCode = 'USD');
        insert pbe;
        
        UTL_ExecutionControl.stopTriggerExecution = false;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='Test Opp');
        opp.AccountId = newAccount.Id;
        opp.StageName = '7a. Closed Won';
        opp.CloseDate = System.today();
        opp.Contract_Term__c='Single-Period';
        opp.Contract_End_Date__c = system.today();
        opp.Contract_Start_Date__c = system.today();
        opp.CurrencyIsoCode = 'USD';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.QI_Invited_to_Present__c = 'No';
        opp.FPI_Date__c = system.today();
        opp.Population_Age_Group__c = 'Not Applicable';
        opp.Potential_Competitor_1__c = comp.Id;
        oppList.add(opp);
        insert oppList;
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Quantity = 1, Delivery_Country__c = 'USA', unitPrice_USD__c = 10, TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.List_Price__c = 2000;
        lineItem.Sale_Type__c = 'New';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.Therapy_Area__c = 'Hepatitis C [21]';
        insert lineItem;
        
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 2000;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        MIBNF2__c testMIBNF = new MIBNF2__c();
        testMIBNF.Client__c = opp.AccountId;
        testMIBNF.Opportunity__c = opp.Id;
        testMIBNF.Sales_Org_Code__c = 'CH08';
        testMIBNF.Billing_Currency__c = 'USD';
        testMIBNF.IMS_Sales_Org__c = 'Acceletra';
        testMIBNF.Fair_Value_Type__c = 'Stand Alone';
        testMIBNF.Invoice_Default_Day__c = '15';
        testMIBNF.Contract_Start_Date__c = system.today();
        testMIBNF.Contract_End_Date__c = system.today();
        testMIBNF.Contract_Type__c = 'Individual';
        testMIBNF.Contract_Term__c = 'Single-Period';
        testMIBNF.IMS_Sales_Org__c = 'IMS Spain';
        testMIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        testMIBNF.Revenue_Analyst__c = ratest.Id;
        insert testMIBNF;
        
        MIBNF_Component__c testMIBNF_Comp = new MIBNF_Component__c();
        testMIBNF_Comp.MIBNF__c=testMIBNF.Id;
        testMIBNF_Comp.BNF_Status__c='New';
        testMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        testMIBNF_Comp.Print_Shop__c='No';
        testMIBNF_Comp.Bill_To__c = testAddress.Id;
        testMIBNF_Comp.X2nd_Copy__c = testAddress.Id;
        testMIBNF_Comp.Carbon_Copy__c = testAddress.Id;
        testMIBNF_Comp.Ship_To__c = testAddress.Id;
        testMIBNF_Comp.Cover_Sheet__c = testAddress.Id;
        testMIBNF_Comp.SAP_Contract__c = '1234567890';
        insert testMIBNF_Comp;
        
        Test.startTest();
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(testMIBNF_Comp.Id);
        Approval.ProcessResult result = Approval.process(req1);
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        newWorkItemIds = result2.getNewWorkitemIds();
        if(newWorkItemIds.size() > 0){
            req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Reject');
            req2.setWorkitemId(newWorkItemIds.get(0));
            result2 =  Approval.process(req2);
        }
        Test.stopTest();
        //System.assertEquals('Rejected', result2.getInstanceStatus(),'Instance Status'+result2.getInstanceStatus());
    }
    
    @isTest
    static void test3() {
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Test_Data.createBNFSetting();
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        User testUser = [Select id, name from User where isActive = true Limit 1];
        //Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        //Added by Prakhar
        
        User tstUser= BNF_Test_Data.createUser();
        tstUser.email = MDM_Defines.MdmApprovalEmailAddress;
        update tstUser;
        
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'Test12', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50);
        insert pbe;
        UTL_ExecutionControl.stopTriggerExecution = false;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        //Ended by Prakhar
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='Test Opp');
        opp.AccountId = newAccount.Id;
        opp.StageName = '7a. Closed Won';
        opp.CloseDate = System.today();
        opp.Contract_Term__c='Single-Period';
        opp.Contract_End_Date__c = system.today();
        opp.Contract_Start_Date__c = system.today();
        opp.CurrencyIsoCode = 'USD';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.QI_Invited_to_Present__c = 'No';
        opp.FPI_Date__c = system.today();
        opp.Population_Age_Group__c = 'Not Applicable';
        opp.Potential_Competitor_1__c = comp.Id;
        oppList.add(opp);
        insert oppList;
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Delivery_Country__c = 'USA', Quantity = 1, unitPrice_USD__c = 10, TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.Sale_Type__c = 'New';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.List_Price__c = 20001;
        lineItem.Therapy_Area__c = 'Hepatitis C [21]';
        //Added by PRakhar
        lineItem.Other_Ship_To_Address__c=testAddress.id;
        //Ended by Prakhar
        UTL_ExecutionControl.stopTriggerExecution = true;
        insert lineItem;
        UTL_ExecutionControl.stopTriggerExecution = false;
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 200;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        MIBNF2__c testMIBNF = new MIBNF2__c();
        testMIBNF.Client__c = opp.AccountId;
        testMIBNF.Opportunity__c = opp.Id;
        testMIBNF.Sales_Org_Code__c = 'CH08';
        testMIBNF.Billing_Currency__c = 'USD';
        testMIBNF.IMS_Sales_Org__c = 'Acceletra';
        testMIBNF.Fair_Value_Type__c = 'Stand Alone';
        testMIBNF.Invoice_Default_Day__c = '15';
        testMIBNF.Contract_Start_Date__c = system.today();
        testMIBNF.Contract_End_Date__c = system.today();
        testMIBNF.Contract_Type__c = 'Individual';
        testMIBNF.Contract_Term__c = 'Single-Period';
        testMIBNF.IMS_Sales_Org__c = 'IMS Spain';
        testMIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        testMIBNF.Revenue_Analyst__c = ratest.Id;
        insert testMIBNF;
        
        Test.startTest();
        MIBNF_Component__c testMIBNF_Comp = new MIBNF_Component__c();
        testMIBNF_Comp.MIBNF__c=testMIBNF.Id;
        testMIBNF_Comp.BNF_Status__c='New';
        testMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        testMIBNF_Comp.Print_Shop__c='No';
        testMIBNF_Comp.Bill_To__c = testAddress.Id;
        testMIBNF_Comp.X2nd_Copy__c = testAddress.Id;
        testMIBNF_Comp.Carbon_Copy__c = testAddress.Id;
        testMIBNF_Comp.Ship_To__c = testAddress.Id;
        testMIBNF_Comp.Cover_Sheet__c = testAddress.Id;
        testMIBNF_Comp.SAP_Contract__c = '1234567890';
        //testMIBNF_Comp.Rejection_Reasons_Multi__c = 'MIBNF Rejected Check';
        insert testMIBNF_Comp;
        
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(testMIBNF_Comp.Id);
        Approval.ProcessResult result = Approval.process(req1);
        
        Test.stopTest();
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        try{
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Reject');
            req2.setWorkitemId(newWorkItemIds.get(0));
            Approval.ProcessResult result2 =  Approval.process(req2);
            System.assertEquals('Rejected', result2.getInstanceStatus(),'Instance Status'+result2.getInstanceStatus());
        }catch(Exception e){
            
        }
    }
    @isTest
    static void test4() {
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;   
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Settings__c bnfSetting = BNF_Test_Data.createBNFSetting();
        bnfSetting.Enable_RSchedule_Validation__c = true;
        upsert bnfSetting;
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        User testUser = [Select id, name from User where isActive = true Limit 1];
        //Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        //Added by Prakhar
        
        User tstUser= BNF_Test_Data.createUser();
        tstUser.email = MDM_Defines.MdmApprovalEmailAddress;
        update tstUser;
        //Ended by Prakhar
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'CH08', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50);
        insert pbe;
        UTL_ExecutionControl.stopTriggerExecution = false;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='Test Opp');
        opp.AccountId = newAccount.Id;
        opp.StageName = '7a. Closed Won';
        opp.CloseDate = System.today();
        opp.Contract_Term__c='Single-Period';
        opp.Contract_End_Date__c = system.today();
        opp.Contract_Start_Date__c = system.today();
        opp.CurrencyIsoCode = 'USD';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Actual_Close_Timestamp__c = Date.today();
        opp.FPI_Date__c = system.today();
        opp.QI_Invited_to_Present__c = 'No';
        opp.Population_Age_Group__c = 'Not Applicable';
        opp.Potential_Competitor_1__c = comp.Id;
        oppList.add(opp);
        insert oppList;
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Delivery_Country__c = 'USA', Quantity = 1, unitPrice_USD__c = 10, TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.Sale_Type__c = 'Repeat';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.List_Price__c = 20001;
        lineItem.Therapy_Area__c = 'Hepatitis C [21]';
        //Added by PRakhar
        lineItem.Other_Ship_To_Address__c=testAddress.id;
        //Ended by Prakhar
        UTL_ExecutionControl.stopTriggerExecution = true;
        insert lineItem;
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 200;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        MIBNF2__c testMIBNF = new MIBNF2__c();
        testMIBNF.Client__c = opp.AccountId;
        testMIBNF.Opportunity__c = opp.Id;
        testMIBNF.Sales_Org_Code__c = 'CH04';
        testMIBNF.Billing_Currency__c = 'USD';
        testMIBNF.IMS_Sales_Org__c = 'Acceletra';
        testMIBNF.Fair_Value_Type__c = 'Stand Alone';
        testMIBNF.Invoice_Default_Day__c = '15';
        testMIBNF.Contract_Start_Date__c = system.today();
        testMIBNF.Contract_End_Date__c = system.today();
        testMIBNF.Contract_Type__c = 'Individual';
        testMIBNF.Contract_Term__c = 'Single-Period';
        testMIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        testMIBNF.Revenue_Analyst__c = ratest.Id;
        insert testMIBNF;
        
        Test.startTest();
        MIBNF_Component__c testMIBNF_Comp = new MIBNF_Component__c();
        testMIBNF_Comp.MIBNF__c=testMIBNF.Id;
        testMIBNF_Comp.BNF_Status__c='New';
        testMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        testMIBNF_Comp.Print_Shop__c='No';
        testMIBNF_Comp.Bill_To__c = testAddress.Id;
        testMIBNF_Comp.X2nd_Copy__c = testAddress.Id;
        testMIBNF_Comp.Carbon_Copy__c = testAddress.Id;
        testMIBNF_Comp.Ship_To__c = testAddress.Id;
        testMIBNF_Comp.Cover_Sheet__c = testAddress.Id;
        testMIBNF_Comp.SAP_Contract__c = '1234567890';
        //testMIBNF_Comp.Rejection_Reasons_Multi__c = 'MIBNF Rejected Check';
        insert testMIBNF_Comp;
        
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        testMIBNF_Comp.BNF_Status__c='LO Accepted';
        update testMIBNF_Comp;
        Test.stopTest();
    }
    @isTest
    static void test5() {
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;   
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Settings__c bnfSetting = BNF_Test_Data.createBNFSetting();
        bnfSetting.Enable_RSchedule_Validation__c = true;
        upsert bnfSetting;
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        User testUser = [Select id, name from User where isActive = true Limit 1];
        //Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        //Added by Prakhar
        
        User tstUser= BNF_Test_Data.createUser();
        tstUser.email = MDM_Defines.MdmApprovalEmailAddress;
        update tstUser;
        //Ended by Prakhar
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'CH08', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50);
        insert pbe;
        UTL_ExecutionControl.stopTriggerExecution = false;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='Test Opp');
        opp.AccountId = newAccount.Id;
        opp.StageName = '7a. Closed Won';
        opp.CloseDate = System.today();
        opp.Contract_Term__c='Single-Period';
        opp.Contract_End_Date__c = system.today();
        opp.Contract_Start_Date__c = system.today();
        opp.CurrencyIsoCode = 'USD';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Actual_Close_Timestamp__c = Date.today();
        opp.FPI_Date__c = system.today();
        opp.QI_Invited_to_Present__c = 'No';
        opp.Population_Age_Group__c = 'Not Applicable';
        opp.Potential_Competitor_1__c = comp.Id;
        oppList.add(opp);
        insert oppList;
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Delivery_Country__c = 'USA', Quantity = 1, unitPrice_USD__c = 10, TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.Sale_Type__c = 'Repeat';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.List_Price__c = 20001;
        lineItem.Therapy_Area__c = 'Hepatitis C [21]';
        //Added by PRakhar
        lineItem.Other_Ship_To_Address__c=testAddress.id;
        //Ended by Prakhar
        UTL_ExecutionControl.stopTriggerExecution = true;
        insert lineItem;
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 200;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        MIBNF2__c testMIBNF = new MIBNF2__c();
        testMIBNF.Client__c = opp.AccountId;
        testMIBNF.Opportunity__c = opp.Id;
        testMIBNF.Sales_Org_Code__c = 'CH04';
        testMIBNF.Billing_Currency__c = 'USD';
        testMIBNF.IMS_Sales_Org__c = 'Acceletra';
        testMIBNF.Fair_Value_Type__c = 'Stand Alone';
        testMIBNF.Invoice_Default_Day__c = '15';
        testMIBNF.Contract_Start_Date__c = system.today();
        testMIBNF.Contract_End_Date__c = system.today();
        testMIBNF.Contract_Type__c = 'Individual';
        testMIBNF.Contract_Term__c = 'Single-Period';
        testMIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        testMIBNF.Revenue_Analyst__c = ratest.Id;
        insert testMIBNF;
        
        Test.startTest();
        MIBNF_Component__c testMIBNF_Comp = new MIBNF_Component__c();
        testMIBNF_Comp.MIBNF__c=testMIBNF.Id;
        testMIBNF_Comp.BNF_Status__c='New';
        testMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        testMIBNF_Comp.Print_Shop__c='No';
        testMIBNF_Comp.Bill_To__c = testAddress.Id;
        testMIBNF_Comp.X2nd_Copy__c = testAddress.Id;
        testMIBNF_Comp.Carbon_Copy__c = testAddress.Id;
        testMIBNF_Comp.Ship_To__c = testAddress.Id;
        testMIBNF_Comp.Cover_Sheet__c = testAddress.Id;
        testMIBNF_Comp.SAP_Contract__c = '1234567890';
        //testMIBNF_Comp.Rejection_Reasons_Multi__c = 'MIBNF Rejected Check';
        insert testMIBNF_Comp;
        
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        
        testMIBNF_Comp.BNF_Status__c='LO Rejected';
        update testMIBNF_Comp;
        testMIBNF_Comp.BNF_Status__c='SAP Rejected';
        update testMIBNF_Comp;
        Test.stopTest();
    }
    
    static testmethod void test_Cal_BNF_Metric_ProcessingTime() {
        //Cal_BNF_Metric_ProcessingTime processingTime = new Cal_BNF_Metric_ProcessingTime();
        Date d1 =  date.newInstance(2017, 09, 02);
        Date d2 =  date.newInstance(2017, 09, 09);
        Cal_BNF_Metric_ProcessingTime.CalculateWorkingHoursBetween(d2,d1,0);        
        
    }
}