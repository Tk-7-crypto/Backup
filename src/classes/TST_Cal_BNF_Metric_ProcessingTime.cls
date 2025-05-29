@isTest
public class TST_Cal_BNF_Metric_ProcessingTime {
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
        Account newAccount = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert newAccount;
        
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        //Added by Prakhar
        UTL_ExecutionControl.stopTriggerExecution = true;
        User tstUser= BNF_Test_Data.createUser();
        tstUser.email='mdmhelpdesk@imshealth.com';
        update tstUser;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        UTL_ExecutionControl.stopTriggerExecution = false;
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
        opp.Actual_Close_Timestamp__c = Date.today();
        opp.Potential_Competitor_1__c = comp.Id;
        oppList.add(opp);
        insert oppList;
        
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'CH08',MDM_Validation_Status__c = 'Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert product;
        
        //Product2 product = new Product2(Name='test1', ProductCode='122', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUB',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
        //insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50);
        insert pbe;
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Quantity = 1, unitPrice_USD__c = 10, TotalPrice = 2000, Delivery_Country__c = 'USA');
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.Sale_Type__c = 'Repeat';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.List_Price__c = 20001;
        lineItem.Therapy_Area__c= 'Hepatitis C [21]';
        //Added by PRakhar
        lineItem.Other_Ship_To_Address__c=testAddress.id;
        //Ended by Prakhar
        insert lineItem;
        
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
}