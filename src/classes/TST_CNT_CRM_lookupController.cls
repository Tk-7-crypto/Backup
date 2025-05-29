/**
 * Version : 1.0
 * An test class for exposes the lookup Component.
 */
@isTest
private class TST_CNT_CRM_lookupController{

    @isTest static void test_getRecentRecords() {
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';

        Test.startTest();
            String responseString = CNT_CRM_lookupController.getRecentRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');

        System.assertEquals(true, response.get('isSuccess'));
    }

    @isTest static void test_getRecordLabel() {
        Account a = new Account(Name='Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert a;

        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';

        Test.startTest();
            String responseString = CNT_CRM_lookupController.getRecordLabel(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        String objectLabel = String.valueOf(results.get('objectLabel'));

        System.assertEquals('Account', objectLabel);
    }

    @isTest static void test_getData() {
        Account a = new Account(Name='Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert a;

        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'", "order": "Name", "limit": "5", "searchTerm": "Test"}';

        Test.startTest();
            String responseString = CNT_CRM_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_subtitleField() {
        Account a = new Account(Name='Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert a;

        String jsonString = '{"searchField":"Name", "subtitleField": "Name", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test"}';

        Test.startTest();
            String responseString = CNT_CRM_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_addressField() {
        Account a = new Account(
            Name='Test Account',
            BillingStreet='Test Street',
            BillingCity='Test City',
            BillingState='Test State',
            BillingCountry='Test Country',
            BillingPostalCode='Test Postal Code',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert a;

        String jsonString = '{"searchField":"Name", "subtitleField": "BillingAddress", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test"}';

        Test.startTest();
            String responseString = CNT_CRM_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_reference() {
        Account a = new Account(Name='Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert a;

        Contact c = new Contact(
            LastName='Contact',
            FirstName='Test',
            AccountId = a.Id);
        insert c;

        String jsonString = '{"searchField":"FirstName", "subtitleField": "Account.Name", "object": "Contact", "filter": "Name = \'Test Contact\'", "searchTerm": "Test"}';

        Test.startTest();
            String responseString = CNT_CRM_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);
        
        Lookup_ResponseData responseData = new Lookup_ResponseData ();
        
        responseData.addError('test');
        
        System.assertEquals(c.Id, record.get('value'));
    }
}