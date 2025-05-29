@isTest 
public with sharing class TST_DAOH_PSA_CFI_Meetings {
    @testsetup
    static void dataSetup() {  
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        insert lrRec;
        CFI_Meetings__c cfiMeetings = UTL_PSA_TestData.createCfiMeetings();
        insert cfiMeetings; 
    }
    
    @istest
    static void testInsertAndUpdateAuditLog(){
        Test.startTest();
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        insert lrRec;
        CFI_Meetings__c cfiMeetings = UTL_PSA_TestData.createCfiMeetings();
        insert cfiMeetings;
        cfiMeetings.AR_Type__c = 'IND';
        update cfiMeetings;
        Test.stopTest();
    } 
    
    @istest
    static void testDeleteAuditLog(){
        Test.startTest();
        list<CFI_Meetings__c> cfiMeeting = [SELECT id, AR_Type__c from CFI_Meetings__c limit 1];
        delete cfiMeeting;
        Test.stopTest();
    }
}
