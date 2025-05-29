@isTest
private class TST_MIBNF_LineBreak {
    
    static testmethod void testinsertmibnf() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
     Account acc = BNF_Test_Data.createAccount();
     Opportunity opp = BNF_Test_Data.createOpp();
     User user = BNF_Test_Data.createUser();
     Revenue_Analyst__c ratest = BNF_Test_Data.createRA();
     MIBNF2__c mibnf = BNF_Test_Data.createMIBNF();
     mibnf.Comments__c = 'Test Ra submit     ';
     upsert mibnf;
    }

}