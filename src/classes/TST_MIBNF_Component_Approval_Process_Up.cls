@isTest
private class TST_MIBNF_Component_Approval_Process_Up  {
    
    static testmethod void test1() {
        UTL_ExecutionControl.stopTriggerExecution = true;
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        BNF_Test_Data.create_User_LocaleSetting();
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Test_Data.createBNFSetting();
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        User testUser = [Select id, name from User where isActive = true and profile.Name = 'System Administrator' Limit 1];
        system.runas(testUser){
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            
            GroupMember gm1 = new GroupMember(GroupId= g1.id, UserOrGroupId = UserInfo.getUserId());
            insert gm1;
            
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Revenue_Analyst__c');
            insert q1;
        }
        Group grp = [select id from Group where name ='group name'];
        
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        ratest.ownerId = grp.Id;
        ratest.Revenue_Analyst_Email__c ='test@test.com';
        insert ratest;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='Test Opp');
        opp.AccountId = newAccount.Id;
        opp.Opportunity_Number__c = '123';
        opp.StageName = '7a. Closed Won';
        opp.CloseDate = System.today();
        opp.Contract_Term__c='Single-Period';
        opp.Contract_End_Date__c = system.today();
        opp.Contract_Start_Date__c = system.today();
        opp.CurrencyIsoCode = 'USD';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.QI_Invited_to_Present__c = 'No';
        opp.Potential_Competitor_1__c = comp.Id;	
        oppList.add(opp);
        insert oppList;
        
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'CH08', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50,CurrencyIsoCode = 'USD');
        insert pbe;
        UTL_ExecutionControl.stopTriggerExecution = true;
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Quantity = 1, unitPrice_USD__c = 10, Delivery_Country__c = 'USA', TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.List_Price__c = 20001;
        lineItem.Sale_Type__c = 'New';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.Therapy_Area__c= 'Hepatitis C [21]';
        insert lineItem;
        
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 200;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        MIBNF2__c testMIBNF = new MIBNF2__c();
        testMIBNF.Client__c = opp.AccountId;
        testMIBNF.Opportunity__c = opp.Id;
        testMIBNF.Sales_Org_Code__c = 'CH08';
        testMIBNF.Billing_Currency__c = 'USD';
        testMIBNF.IMS_Sales_Org__c = '[AE01] Dimensions Healthcare';
        testMIBNF.Fair_Value_Type__c = 'Stand Alone';
        testMIBNF.Invoice_Default_Day__c = '15';
        testMIBNF.Contract_Start_Date__c = system.today();
        testMIBNF.Contract_End_Date__c = system.today();
        testMIBNF.Contract_Type__c = 'Individual';
        testMIBNF.Contract_Term__c = 'Single-Period';
        testMIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        testMIBNF.Revenue_Analyst__c = ratest.Id;
        insert testMIBNF;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
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
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
        System.debug('TestR: '+ Limits.getQueries());
        Test.startTest();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(testMIBNF_Comp.Id);
        Approval.ProcessResult result = Approval.process(req1);
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        System.debug('TestR: '+ Limits.getQueries());
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        testMIBNF_Comp.BNF_Status__c='SAP Rejected';
        update testMIBNF_Comp;
        Test.stopTest();
    }
    
    static testmethod void test2() {
        UTL_ExecutionControl.stopTriggerExecution = true;
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        BNF_Test_Data.create_User_LocaleSetting();
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Test_Data.createBNFSetting();
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        User testUser = [Select id, name from User where isActive = true Limit 1];
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
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
        opp.Opportunity_Number__c = '123';
        opp.Potential_Competitor_1__c = comp.Id;	
        oppList.add(opp);
        insert oppList;
        
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'CH08', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50,CurrencyIsoCode = 'USD');
        insert pbe;
        UTL_ExecutionControl.stopTriggerExecution = true;
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Quantity = 1, Delivery_Country__c = 'USA', unitPrice_USD__c = 10, TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.List_Price__c = 20001;
        lineItem.Sale_Type__c = 'New';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.Therapy_Area__c= 'Hepatitis C [21]';
        insert lineItem;
        
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 200;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        MIBNF2__c testMIBNF = new MIBNF2__c();
        testMIBNF.Client__c = opp.AccountId;
        testMIBNF.Opportunity__c = opp.Id;
        testMIBNF.Sales_Org_Code__c = 'CH08';
        testMIBNF.Billing_Currency__c = 'USD';
        testMIBNF.IMS_Sales_Org__c = '[AE01] Dimensions Healthcare';
        testMIBNF.Fair_Value_Type__c = 'Stand Alone';
        testMIBNF.Invoice_Default_Day__c = '15';
        testMIBNF.Contract_Start_Date__c = system.today();
        testMIBNF.Contract_End_Date__c = system.today();
        testMIBNF.Contract_Type__c = 'Individual';
        testMIBNF.Contract_Term__c = 'Single-Period';
        testMIBNF.Payment_Terms__c = '0000-Default Payment Terms of Customer Master Data';
        testMIBNF.Revenue_Analyst__c = ratest.Id;
        insert testMIBNF;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
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
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        
        
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
        System.debug('TestR: '+ Limits.getQueries());
        Test.startTest();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(testMIBNF_Comp.Id);
        Approval.ProcessResult result = Approval.process(req1);
        System.debug('TestR: '+ Limits.getQueries());
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        testMIBNF_Comp.BNF_Status__c='SAP Contract Confirmed';
        update testMIBNF_Comp;
        Test.stopTest();
    }
    
    static testmethod void test3() {
        UTL_ExecutionControl.stopTriggerExecution = true;
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        BNF_Test_Data.create_User_LocaleSetting();
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        BNF_Test_Data.createBNFSetting();
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert newAccount;
        
        User testUser = [Select id, name from User where isActive = true Limit 1];
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        
        User tstUser= BNF_Test_Data.createUser();
        tstUser.email = MDM_Defines.MdmApprovalEmailAddress;
        update tstUser;
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
        opp.Opportunity_Number__c = '123';
        opp.Potential_Competitor_1__c = comp.Id;	
        oppList.add(opp);
        insert oppList;
        
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'Test12', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50);
        insert pbe;
        UTL_ExecutionControl.stopTriggerExecution = true;
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Quantity = 1, Delivery_Country__c = 'USA', unitPrice_USD__c = 10, TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.Sale_Type__c = 'New';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.List_Price__c = 20001;
        lineItem.Therapy_Area__c = 'Hepatitis C [21]';
        lineItem.Other_Ship_To_Address__c=testAddress.id;
        insert lineItem;
        
        OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
        OliSched.OpportunityLineItemId = lineItem.Id;
        OliSched.Type = 'Revenue';
        OliSched.Revenue = 200;
        OliSched.ScheduleDate = Date.today();
        insert OliSched;
        
        UTL_ExecutionControl.stopTriggerExecution = false;
        
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
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
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
        testMIBNF_Comp.Rejection_Reasons_Multi__c = 'MIBNF Rejected Check|Test1|Test2';
        insert testMIBNF_Comp;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
        System.debug('TestR: '+ Limits.getQueries());
        Test.startTest();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(testMIBNF_Comp.Id);
        Approval.ProcessResult result = Approval.process(req1);
        
        System.debug('TestR: '+ Limits.getQueries());
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        try{
            MDM_Defines.StopBNFTriggerExecution = false;
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Reject');
            req2.setWorkitemId(newWorkItemIds.get(0));
            Approval.ProcessResult result2 =  Approval.process(req2);
            System.assertEquals('Rejected', result2.getInstanceStatus(),'Instance Status'+result2.getInstanceStatus());
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}