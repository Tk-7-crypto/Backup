/*
 * Version       : 1.0
 * Description   : Test Class for Record Triggered Flow - CRM_MIBNF_RecordTriggered_After_Insert_Update
*/

@IsTest
public class TST_CRM_MIBNF_RecordTriggered_Flow {
    
    static void setupMIBNF(){
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
        Account newAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'ACADEMIA & RESEARCH',Sub_Industry__c = 'ACADEMIA & RESEARCH');
        insert newAccount;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        User testUser = [Select id, name from User where isActive = true Limit 1];
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        
        User tstUser= BNF_Test_Data.createUser();
        tstUser.email = MDM_Defines.MdmApprovalEmailAddress;
        update tstUser;
        
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = newAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'CH08', MDM_Validation_Status__c='Validated');
        insert testAddress;
        
        Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        product.Pillar__c = 'Technology Solutions; Information Offering';
        insert product;
        
        String standardPricebookId =Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry (Product2ID = product.id, Pricebook2ID = standardPricebookId, IsActive = true, UnitPrice = 50 ,CurrencyIsoCode = 'USD');
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
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe.id, Quantity = 1, unitPrice_USD__c = 10, Delivery_Country__c = 'USA', TotalPrice = 2000);
        lineItem.Revised_Revenue_Schedule__c = ''+Date.today();
        lineItem.Sale_Type__c = 'Repeat';
        lineItem.Revenue_Type__c = 'Ad Hoc';
        lineItem.List_Price__c = 20001;
        lineItem.Therapy_Area__c = 'Hepatitis C [21]';
        lineItem.Other_Ship_To_Address__c=testAddress.id;
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
    }
    
     @isTest
    static void testRTFlowonMIBNF() {
        
        setupMIBNF();
       
        MIBNF2__c testMIBNF = [Select id from MIBNF2__c LIMIT 1];
        Address__c testAddress = [Select id from Address__c LIMIT 1]; 
        OpportunityLineItem lineItem = [Select id from OpportunityLineItem LIMIT 1];
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
        insert testMIBNF_Comp;
        
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = lineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = lineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
       
        testMIBNF_Comp.BNF_Status__c='SAP Rejected';
        update testMIBNF_Comp;
        Test.stopTest();
    }
}