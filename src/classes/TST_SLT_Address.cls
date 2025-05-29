@isTest
private class TST_SLT_Address {

    @testSetup
    private static void setupTestData(){
        Account account = UTL_TestData.createAccount();
        insert account;

        Address__c address = new Address__c(Account__c = account.Id,Name = 'Test Address');
        insert address;
        
        Address__c address2 = new Address__c(Account__c = account.Id,Name = 'Test Address 2');
        address2.MDM_Validation_Status__c = 'Validated';
        address2.SAP_Reference__c = '0123456789';
        insert address2;
    }

    @isTest
    private static void testSelectByIdShouldReturnListOfAddress(){
        
        Address__c address = [Select Id from Address__c where Name = 'Test Address'];

        Test.startTest();
            List<Address__c> lstAddress = new SLT_Address().selectById(new Set<Id>{address.Id});
        Test.stopTest();

        System.assertNotEquals(true,lstAddress.isEmpty(), 'Returned List is empty when not expected');
        System.assertEquals(1,lstAddress.size(), 'Returned List size is not 1');
    }
    
    @isTest
    private static void testSelectByAddressId(){
        
        Address__c address = [Select Id, Account__c from Address__c where Name = 'Test Address 2'];
        String accId = address.Account__c;
        Test.startTest();
            Map<Id,Address__c> addressMap = new SLT_Address().selectByAddressId(new Set<Id>{address.Id},new Set<String>{'id', 'MDM_Validation_Status__c', 'SAP_Reference__c'});
        Test.stopTest();
        System.assertEquals(1,addressMap.size());
    }
    
    @isTest
    private static void testGetSAPValidatedAddress(){
        
        Address__c address = [Select Id, Account__c from Address__c where Name = 'Test Address 2'];
        String accId = address.Account__c;
        Test.startTest();
            List<Address__c> lstAddress = new SLT_Address().getSAPValidatedAddress(accId,new Set<String>{'id', 'MDM_Validation_Status__c', 'SAP_Reference__c'});
        Test.stopTest();
        System.assertEquals(1,lstAddress.size());
    }
    
    @isTest
    private static void testGetAddressWithValidateSapContact(){
        Set<String> fieldSet = new Set<String>{'Id'};
            String  condition = ' Id != null';
        Test.startTest();
            List<Address__c> lstAddress = new SLT_Address().getAddressWithValidateSapContact(fieldSet, condition, fieldSet, condition);
        Test.stopTest();
        System.assertEquals(2, lstAddress.size());
    }
}