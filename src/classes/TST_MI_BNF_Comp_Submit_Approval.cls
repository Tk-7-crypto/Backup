/**
* Test Class for MI_BNF_Comp_Submit_Approval  
*/
@isTest
private class TST_MI_BNF_Comp_Submit_Approval {
    
    static ApexPages.StandardController sc;
    static MIBNF2__c MIBNF;
    static MIBNF_Component__c MIBNF_Comp;
    static MI_BNF_LineItem__c MIBNFLineItem;
    static Opportunity opp;
    static OpportunityLineItem OLI1;
    static User TestUser1;
    static Account TestAccount;
    static List<Address__c> TestAddress_Array; 
    static BNF_Settings__c bnfsetting;
    
    @Testsetup
    static void testDataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = true;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        //OpportunityTriggerUtil.RunBeforeTrigger = false;
        //OpportunityTriggerUtil.RunAfterTrigger = false;
        Global_Variables.isupdatableOppPlan = false;
        Global_Variables.isclonningOpportunity = true;
        UTL_ExecutionControl.stopTriggerExecution = true;
        bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=false,Enable_Customer_Validation__c=false,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=false);
        upsert bnfsetting;
        
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        TestAddress_Array = UTL_TestData.createAddresses(TestAccount);
        insert TestAddress_Array;
        
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        insert userList;
        
        Contact cnt = UTL_TestData.createContact(TestAccount.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        insert cnt;
        
        insert new Profit_Centre__c(name='xz',ProfitCenterCode__c='USD' );
        Contact MainDecisionMakerContact1 = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = TestAccount.Id, Email = 'abc@metacube.com', CurrencyIsoCode = 'USD');
        MainDecisionMakerContact1.pse__Is_Resource__c=true;
        MainDecisionMakerContact1.pse__Is_Resource_Active__c=true;
        insert MainDecisionMakerContact1;
        
        Revenue_Analyst__c TestRA=UTL_TestData.createRevenueAnalyst();
        insert TestRA;
        
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        opp =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
                             Contract_Term__c='Single-Period',Contract_Type__c='Individual',CurrencyIsoCode = 'USD');
        opp.LeadSource = 'Account Planning';
        opp.Budget_Available__c = 'Yes';
        opp.Contract_Start_Date__c = Date.today();
        opp.Contract_End_Date__c = Date.today();
        opp.Potential_Competitor_1__c = comp.Id;
        insert opp;
        
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        
        Product2 Product1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH08', Business_Type__c = 'I&A', Material_Type__c = 'ZSET', isactive=true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        Product1.Pillar__c = 'Technology Solutions; Information Offering';
        insert product1;
        
        List<PricebookEntry> pbeList = [Select id from PricebookEntry where IsActive = true and CurrencyIsoCode ='USD' and Pricebook2Id = :Test.getStandardPricebookId()  Limit 1];
        PricebookEntry pbe;
        if(pbeList.size() == 0) {
            pbe = new PricebookEntry();
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            pbe.Product2Id=Product1.id;
            pbe.IsActive=true;
            pbe.UnitPrice=100.0;
            pbe.CurrencyIsoCode = 'USD';
            insert pbe;
        }
        else {
            pbe = pbeList[0];
        }
        OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = opp.Id;
        OLI1.PricebookEntryId = Pbe.Id;
        OLI1.Quantity = 1.00;
        OLI1.TotalPrice=10000;
        OLI1.List_Price__c = 100;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        UTL_ExecutionControl.stopTriggerExecution = true;
        insert OLI1;
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        Opportunity opp1 =new Opportunity(id=opp.Id);
        opp1.StageName='7a. Closed Won';
        opp1.Primary_Win_Reason__c ='Project Performance';
        opp1.Win_Type__c = 'Non-competitive bid';
        update opp1;
        
        MIBNF=new MIBNF2__c();
        MIBNF.Client__c=opp.AccountId;
        MIBNF.Opportunity__c=opp.Id;
        MIBNF.Sales_Org_Code__c='CH08';
        MIBNF.Billing_Currency__c='USD';
        MIBNF.IMS_Sales_Org__c='Acceletra';
        MIBNF.Fair_Value_Type__c='Stand Alone';
        MIBNF.Invoice_Default_Day__c='15';
        MIBNF.Contract_Start_Date__c=system.today();
        MIBNF.Contract_End_Date__c=system.today();
        MIBNF.Contract_Type__c='Individual';
        MIBNF.Contract_Term__c='Single-Period';
        MIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        MIBNF.Revenue_Analyst__c=TestRA.id;
        insert MIBNF;
    }
    
    
    static testMethod void CancelTest() {
        MIBNF2__c MIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        OpportunityLineItem OLI1 =[SELECT Id, TotalPrice FROM OpportunityLineItem LIMIT 1];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        Test.startTest();
        MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=MIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        MIBNF_Comp.Bill_To__c=TestAddress_Array[0].Id;
        MIBNF_Comp.Ship_To__c=TestAddress_Array[0].id;
        insert MIBNF_Comp;
        
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
        MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
        insert MI_BNFLineItem;
        
        MIBNF_Component__c MIBNF_Comp1 = [Select id from MIBNF_Component__c limit 1];
        ApexPages.CurrentPage().getParameters().put('id' ,MIBNF_Comp.id);
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        MI_BNF_Comp_Submit_Approval controller = new MI_BNF_Comp_Submit_Approval();
        PageReference pg=controller.cancel();
        Test.stopTest();
    }
    
    static testMethod void SubmitAvailableProductTest() {
        MIBNF2__c MIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        OpportunityLineItem OLI1 =[SELECT Id, TotalPrice FROM OpportunityLineItem LIMIT 1];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        Test.startTest();
        MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=MIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        MIBNF_Comp.Bill_To__c=TestAddress_Array[0].Id;
        MIBNF_Comp.Ship_To__c=TestAddress_Array[0].id;
        insert MIBNF_Comp;
        
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
        MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
        insert MI_BNFLineItem;
        
        ApexPages.CurrentPage().getParameters().put('id' ,MIBNF_Comp.id);
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        MI_BNF_Comp_Submit_Approval controller = new MI_BNF_Comp_Submit_Approval();
        PageReference pg=controller.SubmitRequest();
        Test.stopTest();
    }
    
}