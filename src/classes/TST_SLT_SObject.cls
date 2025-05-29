@isTest
private class TST_SLT_SObject {
    @isTest
    static void testUtilityMethods(){
        Test.startTest();
        SLT_SObject obj;
        obj = new SLT_SObject();
        obj = new SLT_SObject(false);
        obj = new SLT_SObject(false, false);
        List<Schema.SObjectField> fieldList = obj.getSObjectFieldList();
        Schema.SObjectType objectType = obj.getSObjectType();
        Test.stopTest();
    }

    @isTest
    static void testSelectSObjectByLookup(){
        setupTestData();
        Test.startTest();
        List<sObject> objects = new SLT_SObject().selectSObjectByLookup(Service__c.sObjectType, 'Service_Line__c', serviceLine.Id, new Set<String>{'Id','Name'});
        Test.stopTest();
        system.assertEquals(1,objects.size());
    }

    @isTest
    static void testSelectSObjectRowsByIds(){
        setupTestData();
        Test.startTest();
        Map<Id, SObject> recs = new SLT_SObject().selectSObjectRowsByIds(Service_Line__c.sObjectType, new Set<String>{serviceLine.Id}, new Set<String>{'Id', 'Name'});
        Test.stopTest();
        system.assertEquals(1,recs.size());
    }
    
    @isTest
    static void testSelectSObjectListByIds(){
        setupTestData();
        Test.startTest();
        List<SObject> recs = new SLT_SObject().selectSObjectListByIds(Service_Line__c.sObjectType, new Set<String>{serviceLine.Id}, new Set<String>{'Id', 'Name'});
        Test.stopTest();
        system.assertEquals(1,recs.size());
    }
    
    private static Service_Line__c serviceLine;
    private static Service__c service;

    static void setupTestData() {
        // service line
        serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'PVA',
            Name = 'PVA'
            );
        insert serviceLine;

        // service
        service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'PVA1'
            );
        insert service;
    }
}