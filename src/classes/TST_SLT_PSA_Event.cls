/**
 * This test class is used to test the PSA Event Selector
 */
@isTest
private class TST_SLT_PSA_Event 
{
    @testSetup
    static void dataSetup() 
    {
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.Event_Name__c = 'Test Event';
        psaEvent.RecordTypes__c = 'General_Report';
        psaEvent.Object__c = 'Aggregate_Report__c';
        psaEvent.Planned_Date_Field__c = 'Client_First_Draft_Due__c';
        psaEvent.Primary_Resource_Field__c = 'Primary_Author__c';
        psaEvent.Stakeholder_Fields__c = 'Primary_Author__c';
        psaEvent.Notification_Offset__c = -2;
        insert psaEvent;
    }
    
    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_PSA_Event().getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }

    @isTest
    static void testGetPSAEventsByPlannedDateField() {
        //setupTestData();
        Test.startTest();
        Set<String> dateFields = new Set<String>{'Client_First_Draft_Due__c'};
        Map<String, PSA_Event__c> eventsMap = new SLT_PSA_Event().getPSAEventsByPlannedDateField(dateFields); 
        Test.stopTest();
        System.assertNotEquals(0, eventsMap.values().size());
        System.assertEquals('Test Event', eventsMap.values().get(0).Event_Name__c);
    }

    @isTest
    static void testGetAllPSAEvents(){
        //setupTestData();
        Test.startTest();
        List<PSA_Event__c> allEvents = new SLT_PSA_Event(true).getAllPSAEvents();
        Test.stopTest();
        System.assertNotEquals(0, allEvents.size());
        PSA_Event__c testEvent = allEvents.get(0);
        System.assertEquals('Test Event', testEvent.Event_Name__c);
    }

    /*
    static void setupTestData () {
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.Event_Name__c = 'Test Event';
        psaEvent.RecordTypes__c = 'General_Report';
        psaEvent.Object__c = 'Aggregate_Report__c';
        psaEvent.Planned_Date_Field__c = 'Client_First_Draft_Due__c';
        psaEvent.Primary_Resource_Field__c = 'Primary_Author__c';
        psaEvent.Stakeholder_Fields__c = 'Primary_Author__c';
        psaEvent.Notification_Offset__c = -2;
        insert psaEvent;
    }
	*/
}