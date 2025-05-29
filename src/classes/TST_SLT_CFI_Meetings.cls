@istest
public with sharing class TST_SLT_CFI_Meetings {
    @testSetup
    static void dataSetup() {
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        insert lrRec;
        CFI_Meetings__c cfiMeetings = UTL_PSA_TestData.createCfiMeetings();
        insert cfiMeetings;
    }
	@isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_CFI_Meetings(true,true).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }
    @isTest
    static void testCfiMeetings() {
        Set<String> fieldSet = new Set<String>{'Id','Products__c','Project__c'};
        Test.startTest();
        
        LR_Project_Overview__c lrRec = [SELECT Id FROM LR_Project_Overview__c LIMIT 1];
        List<CFI_Meetings__c> cfiMeetings = new SLT_CFI_Meetings().getCFIMeetingsBylRProjectOverViewIds( new Set<String>{ lrRec.Id}, fieldSet );
        List<CFI_Meetings__c> cfiMeetings1 = new SLT_CFI_Meetings().getCFI_Meetings( fieldSet );
        Test.stopTest();

        System.assertNotEquals(0,cfiMeetings1.size());
    }
}
