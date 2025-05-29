@IsTest
private class TST_SLT_Agreement_Repository {
    @TestSetup
    private static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;

        Agreement_Repository__c ar = new Agreement_Repository__c();
        ar.Name = 'test';
        ar.Account__c = account.Id;
        ar.Agreement_Type__c = 'SOW';
        insert ar;
    }
    
    @isTest
    private static void testGetAgreementRepository(){
        Agreement_Repository__c ar = [Select Id, Name, AR_Number__c From Agreement_Repository__c Where Name = 'test' LIMIT 1];
        String condition = 'Id IN: docIds';
        
        Test.startTest();
            List<Agreement_Repository__c> agreementRepositories = new SLT_Agreement_Repository(false, false).getAgreementRepository(condition, new Set<Id>{ar.Id}) ;
        Test.stopTest();
        
        System.assertEquals(1, agreementRepositories.size(), 'Should return Agreement Repository');
    }

    @isTest
    private static void testGetAgreementRepositoryByARNumbers(){
        Agreement_Repository__c ar = [Select Id, Name, AR_Number__c From Agreement_Repository__c Where Name = 'test' LIMIT 1];
        String condition = 'Agreement_Type__c IN: arNumbers';

        Test.startTest();
            List<Agreement_Repository__c> agreementRepositories = new SLT_Agreement_Repository(false, false).getAgreementRepositoryByARNumbers(condition,new Set<String>{'SOW'}, new Set<String>{'Name'}) ;
        Test.stopTest();
        
        System.assertEquals('test', agreementRepositories[0].Name, 'Should return Test');
    }
}