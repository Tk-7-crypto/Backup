@isTest
private class TST_CallSampleDataLoader {
 
    @isTest
    static void testCallSampleDataLoader(){
        //Id orgId = ;
        //Id sandboxId = UserInfo.getOrganizationId();
        Test.startTest();
          Test.testSandboxPostCopyScript(new CallSampleDataLoader(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), 'sandbox');
        Test.stopTest();
         List<Opportunity> opp = [Select Id From Opportunity Where Name like 'Test Opportunity%'];
        System.assertEquals(opp.size(), 20);
    }
}