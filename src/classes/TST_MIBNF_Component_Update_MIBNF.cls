@isTest
private class TST_MIBNF_Component_Update_MIBNF { 
    public static MIBNF2__c MIBNF;
    public static MIBNF_Component__c MIBNF_Comp;
    public static Opportunity opp;
    public static OpportunityLineItem OLI1;
    public static Account TestAccount;
    public static List<Address__c> TestAddress_Array; 
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
        
        Revenue_Analyst__c TestRA=UTL_TestData.createRevenueAnalyst();
        insert TestRA;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        opp =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
                             Contract_Term__c='Single-Period',Contract_Type__c='Individual');
        opp.LeadSource = 'Account Planning';
        opp.Budget_Available__c = 'Yes';
        opp.Contract_Start_Date__c=system.today();
        opp.Contract_End_Date__c=system.today();
        opp.Potential_Competitor_1__c = comp.Id;
        insert opp;
        
        Product2 Product1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH08', Business_Type__c = 'I&A', Material_Type__c = 'ZSET', Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
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
        Opportunity opp1 =new Opportunity(id=opp.Id);
        opp1.StageName='7a. Closed Won';
        opp1.Primary_Win_Reason__c ='Project Performance';
        opp1.Win_Type__c = 'Non-competitive bid';
		opp1.CurrencyIsoCode = 'USD';
        update opp1;
        UTL_ExecutionControl.stopTriggerExecution = false;        
        
        TestAddress_Array = UTL_TestData.createAddresses(TestAccount);
        insert TestAddress_Array;
        
        MIBNF = UTL_TestData.createMIBNF(opp, TestRA);
        insert MIBNF;
    }
    
    @isTest 
    static void reassignRAMIBNFCompChanged() {
        Revenue_Analyst__c TestLocalRA = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
        MIBNF2__c MIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        System.debug('TestR: '+ limits.getQueries());
        MIBNF_Component__c TestMIBNF = UTL_TestData.createMIBNF_Comp(MIBNF, TestAddress_Array);
        TestMIBNF.Comp_Revenue_Analyst__c = null;
        TestMibnf.SAP_Master_Contract__c = null;
        insert TestMIBNF;
        Test.startTest();
        
        MI_BNF_LineItem__c miLI = UTL_TestData.createMIBNFLineItem(TestMIBNF.id, oli[0]);
        insert miLi;
        
        System.debug('TestR: '+ limits.getQueries());
        
        MIBNF2__c TestMIBNF1  = [Select id, Revenue_Analyst__c, SAP_Master_Contract__c from MIBNF2__c Limit 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestMIBNF.Id);
        Approval.ProcessResult result = Approval.process(req1);
        
        System.debug('TestR: '+ limits.getQueries());
        TestMIBNF.Comp_Revenue_Analyst__c = TestLocalRA.id;
        TestMIBNF.SAP_Master_Contract__c = '1032009760';
        upsert TestMIBNF;
        
        System.debug('TestR: '+ limits.getQueries());
        Test.stopTest();
    }
}