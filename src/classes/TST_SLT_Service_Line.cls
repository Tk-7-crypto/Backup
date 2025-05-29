/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Service_Line
 */
@isTest
public class TST_SLT_Service_Line {
    
    /**
     * This method used to get Service Line by Id.
     */    
    @IsTest
    static void testSelectById() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Service_Line_Code__c'};
        List<Service_Line__c> serviceLines = new SLT_Service_Line().selectById(new Set<Id> {serviceLine.id}, fieldSet );
        Service_Line__c line = serviceLines.get(0);
        Test.stopTest();
        System.assertNotEquals(line, null);
        System.assertEquals(serviceLine.Name, line.Name);
        System.assertEquals(serviceLine.Service_Line_Code__c, line.Service_Line_Code__c);
    }

    /**
     * This method used to get Service Line by Name.
     */    
    @IsTest
    static void testSelectByName() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Service_Line_Code__c'};
        List<Service_Line__c> serviceLines = new SLT_Service_Line().selectByName(new Set<String> {serviceLine.Name}, fieldSet );
        Service_Line__c line = serviceLines.get(0);
        Test.stopTest();
        System.assertNotEquals(line, null);
        System.assertEquals(serviceLine.Name, line.Name);
        System.assertEquals(serviceLine.Service_Line_Code__c, line.Service_Line_Code__c);
    }

    /**
     * This method used to get sObjectFieldset
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        setupTestData();
        Test.startTest();
        List<Schema.SObjectField> fieldNames = new SLT_Service_Line().getSObjectFieldList();
        Test.stopTest();
    }

    /**
     * This method used to get sObject Type
     */    
    @IsTest
    static void testGetSObjectType() {
        setupTestData();
        Test.startTest();
        Schema.SObjectType sObjectType = new SLT_Service_Line().getSObjectType();
        Test.stopTest();
        System.assertEquals(Service_Line__c.sObjectType,sObjectType);
    }



    static Service_Line__c serviceLine;

    static void setupTestData () {

        // service line
        serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'unique',
            Name = 'Service Line'
		);
        insert serviceLine;

    }

}