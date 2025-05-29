@isTest
private class TST_MI_BNF_Delete {
    
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
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        List<Address__c> TestAddress_Array = UTL_TestData.createAddresses(TestAccount);
        for(Integer index = 0; index < TestAddress_Array.size(); index++) {
            TestAddress_Array[index].MDM_Validation_Status__c = 'Validated';
            TestAddress_Array[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        insert TestAddress_Array;
        List<SAP_Contact__c> TestSapContact_Array = UTL_TestData.createSAPContacts(TestAddress_Array);
        
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        User u = BNF_Test_Data.createUser();
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
    } 
    
    static testmethod void  testMIBNFCompPDF() {
        
        Test.startTest();
        List<Address__c> TestAddress_Array = [SELECT Id FROM Address__c];
        
        List<OpportunityLineItem> oliList = [select id, TotalPrice FROM OpportunityLineItem];
        MIBNF2__c TestMIBNF = [SELECT id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c FROM MIBNF2__c LIMIT 1];
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        mibnfComp.BNF_Status__c='RA_ACCEPTED';
        insert mibnfComp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(mibnfComp.Id, oliList[0]);
        insert TestMI_BNFLineItem;
        
        MIBNF2__c mibnfRec = [Select id from MIBNF2__c limit 1];
        try {
            delete mibnfRec; 
            System.assert(false,'code never reached here');
        }
        catch(DmlException e) {
            System.assert(true, 'custom validation error occured');
        }
        Test.stopTest();
    }
}