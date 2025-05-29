/*
* Version       : 1.0
* Description   : This test class is used for NewURLRedirection Class
*/
@isTest
private class TST_NewURLRedirection {
    
    /**
     * This method used to test complete class functionality
     */  
    static testMethod void myUnitTest() {
        Account acc = new Account(Name = 'TestAccount',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        
        Contact c = new Contact();
        c.firstname = 'test';
        c.lastname = 'test';
        c.Email = 'test@test.com';
        c.Phone = '';
        c.AccountId = acc.id;
        insert c;
        
        Test.startTest();
            NewURLRedirection newurlredirection = new NewURLRedirection(new ApexPages.StandardController(c));
            newurlredirection.initContact();
            NewURLRedirection newurlredirection1 = new NewURLRedirection(new ApexPages.StandardController(acc));
            newurlredirection1.initAccount();
        Test.stopTest();
    } 
}