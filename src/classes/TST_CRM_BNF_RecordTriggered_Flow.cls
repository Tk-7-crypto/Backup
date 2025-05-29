/*
 * Version       : 1.0
 * Description   : Test Class for Record Triggered Flow - CRM_BNF_RecordTriggered_After_Insert_Update
*/

@IsTest
public class TST_CRM_BNF_RecordTriggered_Flow {
    private static BNF2__c TestBnf;
    private static Opportunity TestOpp;
    private static Account TestAccount;
    private static Contact testContact;
    private static BNF_Approval_Extension controller;
    private static User TestUser;
    private static Revenue_Analyst__c TestLocalRA;
    private static Revenue_Analyst__c TestSAPRA;
    
    /* 
      Test Method for Data Setup 
    */
     static void setupBNF() {
        UTL_ExecutionControl.stopTriggerExecution = true;
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];
        TestUser = new User(Alias = 'standt', Email='standarduser@iqvia.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser31044'+'@metacube1a.com', isActive = true, Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808');
        TestUser.PIC_Eligible__c = true;

        insert TestUser;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser.Id;
        TestAccount.CustomerSegment__c = 'ACADEMIA & RESEARCH';
        TestAccount.Sub_Industry__c = '	ACADEMIA & RESEARCH';
        insert TestAccount;
        
        testContact = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = TestAccount.Id, Email = 'abc@iqvia.com', CurrencyIsoCode = 'USD');
        testContact.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContact.Salesforce_User__c = TestUser.Id;
        insert testContact;
        
        TestLocalRA =new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = false,name='SAPRAUser, Test');
        TestLocalRA.Revenue_Analyst_Email__c = 'test@iqvia.com';
        insert TestLocalRA;
        
        TestSAPRA=new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = true,name='SAPRAUser, Test');
        TestSAPRA.Revenue_Analyst_Email__c = 'test1@iqvia.com';
        insert TestSAPRA;
        
        AccountTeamMember ATM = new AccountTeamMember(AccountId=TestAccount.Id,UserId=TestLocalRA.User__c);
        insert ATM;
        
        AccountShare AccShare = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, RowCause, LastModifiedDate, LastModifiedById FROM AccountShare WHERE RowCause = 'Team' AND AccountId = :TestAccount.Id and UserOrGroupId=:TestLocalRA.User__c limit 1];
        AccShare.AccountAccessLevel = 'Edit';
        AccShare.OpportunityAccessLevel = 'Edit';
        update AccShare;
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        List<Opportunity> oppToInsert = new List<Opportunity>();
        System.runAs(TestUser) {
            TestOpp = new Opportunity();
            TestOpp.Name = 'test';
            TestOpp.CloseDate = System.today();
            TestOpp.LeadSource = 'Account Planning';
            TestOpp.Budget_Available__c = 'Yes';
            TestOpp.AccountId = TestAccount.Id;
            TestOpp.Contract_End_Date__c = system.today();
            TestOpp.Contract_Start_Date__c = system.today();
            TestOpp.LeadSource = 'Account Planning';
            TestOpp.CurrencyIsoCode = 'USD';       
            Testopp.Principle_inCharge__c = testContact.Id;
            TestOpp.StageName = '7a. Closed Won';
            TestOpp.Primary_Win_Reason__c ='Project Performance';
            TestOpp.Win_Type__c = 'Non-competitive bid';
            TestOpp.Potential_Regions__c = 'Asia Pacific';
            TestOpp.QI_Invited_to_Present__c = 'No';
            TestOpp.FPI_Date__c = system.today();
            TestOpp.Population_Age_Group__c = 'Not Applicable';
            TestOpp.OwnerId = TestUser.Id;
        	TestOpp.Potential_Competitor_1__c = comp.Id;
            oppToInsert.add(TestOpp);
        }
        
        Opportunity TestOpp1 = new Opportunity();
        TestOpp1.Name = 'test2';
        TestOpp1.StageName = '1. Identifying Opportunity';
        TestOpp1.CloseDate = System.today();
        TestOpp1.Budget_Available__c = 'Yes';
        TestOpp1.AccountId = TestAccount.Id;
        TestOpp1.Contract_End_Date__c = system.today();
        TestOpp1.Contract_Start_Date__c = system.today();
        TestOpp1.LeadSource = 'Account Planning';
        TestOpp1.CurrencyIsoCode = 'USD';
        TestOpp1.Potential_Regions__c = 'Asia Pacific';
        TestOpp1.QI_Invited_to_Present__c = 'No';
        TestOpp1.FPI_Date__c = system.today();
        TestOpp1.Population_Age_Group__c = 'Not Applicable';
        TestOpp1.Potential_Competitor_1__c = comp.Id;
        oppToInsert.add(TestOpp1);
        
        insert oppToInsert;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c=13342,Enable_Billing_Schedule_Validation__c=true,Enable_RSchedule_Validation__c=true,Excluded_Products__c = 'Test|ZQUI');
        upsert bnfsetting;
        
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(testContact.Id, TestOpp.Id);
        insert contactRole;
        List<Product2> productList = new List<Product2>();
        
        Product2 objProduct = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH04',CurrencyIsoCode = 'USD', Business_Type__c = 'I&A', Material_Type__c = 'ZPUB', isactive=true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI); 
        Product2 objProduct1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH04', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly', Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        productList.add(objProduct);
        productList.add(objProduct1);
        insert productList;
        
        List<PricebookEntry> PEList = new List<PricebookEntry>();
        PricebookEntry PE1 = new PricebookEntry();
        PE1.UseStandardPrice = false;
        PE1.Pricebook2Id = Test.getStandardPricebookId();
        PE1.Product2Id=objProduct.id;
        PE1.IsActive=true;
        PE1.UnitPrice=100.0;
        PE1.CurrencyIsoCode = 'USD';
        PEList.add(PE1);
        
        PricebookEntry PE2 = new PricebookEntry();
        PE2.UseStandardPrice = false;
        PE2.Pricebook2Id = Test.getStandardPricebookId();
        PE2.Product2Id=objProduct1.id;
        PE2.IsActive=true;
        PE2.UnitPrice=100.0;
        PE2.CurrencyIsoCode = 'USD';
        PEList.add(PE2);
        insert PEList;
        
        List<Address__c> Addresslst=new List<Address__c>();
        Address__c a1=new Address__c(name='testAddress',SAP_Reference__c='500',Enabled_Sales_Orgs__c='CA03') ;
        Addresslst.add(a1);
        Address__c a2=new Address__c(name='testAddress2',SAP_Reference__c='501',Enabled_Sales_Orgs__c='CA03')  ; 
        Addresslst.add(a2);
        Address__c a3=new Address__c(name='testAddress3',SAP_Reference__c='502',Enabled_Sales_Orgs__c='CA03')  ; 
        Addresslst.add(a3);
        Address__c a4=new Address__c(name='testAddress4',SAP_Reference__c='503',Enabled_Sales_Orgs__c='CA03')  ; 
        Addresslst.add(a4);
        Address__c a5=new Address__c(name='testAddress5',SAP_Reference__c='504',Enabled_Sales_Orgs__c='CA03')  ; 
        Addresslst.add(a5);
        for(Integer index = 0; index < Addresslst.size(); index++) {
            Addresslst[index].MDM_Validation_Status__c = 'Validated';
            Addresslst[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
        }
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert Addresslst;
        
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = TestOpp.Id;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        OLI1.Other_Ship_To_Address__c = Addresslst[0].Id;
        OLI1.Product_Start_Date__c = Date.today();
        OLI1.Product_End_Date__c = Date.today().addYears(1) ;
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Billing_Frequency__c = 'Once';
        OLI1.Proj_Rpt_Frequency__c='Once [O]';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Quantity = 1.00;  
        OLI1.List_Price__c = 100;
        OLI1.TotalPrice = 100;
        OLI1.Wbsrelementcode__c = 'test Code1';
        OLI1.Revised_Revenue_Schedule__c = '2012|2011';
        OLI1.Billing_Date__c = Date.today();
        OLI1.Delivery_Date__c = Date.today().addYears(2);
        OLI1.PO_line_item_number__c = '123456';
        OLI_Array.add(OLI1);
        
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = TestOpp.Id;
        OLI2.Sale_Type__c = 'New';
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Revenue_Type__c = 'Ad Hoc';
        OLI2.Other_Ship_To_Address__c = Addresslst[0].Id;
        OLI2.Revised_Revenue_Schedule__c = '201211:201211|201211:201211';
        OLI2.Product_Start_Date__c = Date.today();
        OLI2.Product_End_Date__c = Date.today().addYears(1) ;
        OLI2.PricebookEntryId = PE2.Id;
        OLI2.Billing_Frequency__c = 'Once';
        OLI2.Proj_Rpt_Frequency__c='Once [O]';
        OLI2.Quantity = 1.00;
        OLI2.TotalPrice = 100;  
        OLI2.List_Price__c = 100;
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Wbsrelementcode__c = 'test Code';
        OLI2.Billing_Date__c = Date.today();
        OLI2.Delivery_Date__c = Date.today().addYears(2);
        OLI2.PO_line_item_number__c = '543215';
        OLI_Array.add(OLI2);
        
        insert OLI_Array;
        
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule1', OLIId__c = OLI_Array[0].id);
        insert sche;
        
        Billing_Schedule_Item__c scheItem1 = new Billing_Schedule_Item__c(name = 'textScheduleItem1', Billing_Amount__c = 100, Billing_Date__c = system.today(), Billing_Schedule__c = sche.id);
        insert scheItem1;
        
        OLI_Array[0].Billing_Schedule__c = sche.Id;
        OLI_Array[1].Billing_Schedule__c = sche.Id;
        update OLI_Array;
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.IMS_Sales_Org__c = 'IMS Spain';
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.Bill_To__c = a1.Id;
        TestBnf.X2nd_Copy__c = a2.Id;
        TestBnf.Carbon_Copy__c = a3.Id;
        TestBnf.Ship_To__c = a4.Id;
        TestBnf.Cover_Sheet__c = a5.Id;
        TestBnf.Revenue_Analyst__c = TestLocalRA.Id;
        TestBnf.Sales_Org_Code__c = 'CH04';
        TestBnf.OLI_Json_Data_1__c = JSON.serialize(OLI1);
        TestBnf.OLI_Json_Data_2__c = JSON.serialize(OLI2);
        insert TestBnf;
    }
    
    /*
      Test method to test immediate action path
    */
    static testMethod void testRTFlow(){
        setupBNF();
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        system.runAs(TestUser) {
            BNF_Test_Data.create_User_LocaleSetting();
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            UTL_ExecutionControl.stopTriggerExecution = true;
            result = Approval.process(req1);
            UTL_ExecutionControl.stopTriggerExecution = true;
        }
        System.assert(result.isSuccess());
        Approval.ProcessWorkitemRequest req2;
        BNF_Approval_Extension.CustomApprovalPage = true;
        System.runAs(TestUser) {
            req2 = new Approval.ProcessWorkitemRequest();
            req2.setAction('Approve');
            req2.setComments('Approving request');
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: TestBnf.id];
            req2.setWorkitemId(pItem.Id);
            result = Approval.process(req2);
        }
        Test.startTest();
        
        Approval.ProcessWorkitemRequest req3;
        System.runAs(TestUser) {
            req3 = new Approval.ProcessWorkitemRequest();
            req3.setAction('Approve');
            req3.setComments('Approving request');
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: TestBnf.id];
            req3.setWorkitemId(pItem.Id);
            UTL_ExecutionControl.stopTriggerExecution = true;
            result = Approval.process(req3);
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
        
        Approval.ProcessWorkitemRequest req4;
        System.runAs(TestUser) {
            req4 = new Approval.ProcessWorkitemRequest();
            req4.setAction('Reject');
            req4.setComments('Rejecting request');
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: TestBnf.id];
            req4.setWorkitemId(pItem.Id);
            UTL_ExecutionControl.stopTriggerExecution = true;
            result = Approval.process(req4);
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
        
        Approval.ProcessWorkitemRequest req5;
        System.runAs(TestUser) {
            req5 = new Approval.ProcessWorkitemRequest();
            req5.setAction('Reject');
            req5.setComments('Rejecting request');
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: TestBnf.id];
            req5.setWorkitemId(pItem.Id);
            UTL_ExecutionControl.stopTriggerExecution = true;
            result = Approval.process(req5);
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
        TestBnf.BNF_Status__c = 'SAP Contract Rejected';
        update TestBnf;
        
        Map<String,BNF2__c> newmap = new Map<String,BNF2__c>();
        newmap.put(TestBnf.id,TestBnf);
        Flow.Interview myFlow = flow.Interview.createInterview('CRM_BNF_RecordTriggered_After_Insert_Update', newmap);
        myFlow.start();
        Test.stopTest();
    
    }
    
    
}