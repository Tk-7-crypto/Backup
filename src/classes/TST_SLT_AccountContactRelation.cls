@isTest
private class TST_SLT_AccountContactRelation {
    @isTest
    static void testMethod1() {
    	test.startTest();
        List<Account> acc = new List<Account>();
    	Account acc1 = UTL_TestData.createAccount();
        Account acc2 = UTL_TestData.createAccount();
        acc.add(acc1);
        acc.add(acc2);
        insert acc;
        acc1.LI_Account_Id__c = acc2.Id;
        acc1.LQ_Account_Id__c = acc2.Id;
        update acc1;
        acc2.MDM_SFDC_Golden_Record_Id__c = acc1.Id;
        acc2.MDM_Validation_Status__c = 'Rejected';
        update acc2;
        test.stopTest();
    }
    
    @isTest
    static void testMethod2() {
        test.startTest();
        List<Account> acc = new List<Account>();
        Account acc1 = UTL_TestData.createAccount();
        acc.add(acc1);
        insert acc;
        new SLT_AccountContactRelation().getAccountContactRelations(new Set<String>{'Id'}, acc1.id, 'test', false);
        test.stopTest();
    }
    
    @isTest
    static void testMethod3() {
        test.startTest();
        List<Account> acc = new List<Account>();
        Account acc1 = UTL_TestData.createAccount();
        acc.add(acc1);
        insert acc;
        List<AccountContactRelation> acr=new SLT_AccountContactRelation().getAccountContactRelationsforOWFUsingSubGroupAndFunction(new Set<String>{'Id'}, acc1.id, 'test', false,new Set<String>{'COE Lead / Category Lead / SME'},new Set<String>{'TSL'});
        test.stopTest();
        System.assertEquals(0, acr.size());
    }
}