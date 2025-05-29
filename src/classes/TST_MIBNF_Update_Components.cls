@isTest
private class TST_MIBNF_Update_Components {
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
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
    } 
    
    static testmethod void testmibnfupdate() {
        MIBNF2__c mibnf = [SELECT Id FROM MIBNF2__c LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF =UTL_TestData.createMIBNF_Comp(mibnf, TestAddress_Array);
        insert TestMIBNF;
        
        MI_BNF_LineItem__c MI_BNFLineItem= UTL_TestData.createMIBNFLineItem(TestMIBNF.Id, oli[0]);
        insert MI_BNFLineItem;
        
        mibnf.Renewal__c = true;
        upsert mibnf;
        
        Test.stopTest();
    }
}