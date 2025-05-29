/*
* Test class for FLOW - BHR_FL02_OWF_SendScheduledEmailNotificationforLQ
  IQVIAPSA-7228
*/
@isTest
public class TST_BHR_FL02_OWF_LQScheduledEmail {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Scientific_Review__c = 'No';
        bidHistory.Scientific_Review_Received__c = 'Received, outstanding fees';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Bid_Due_Date__c =  system.today().addDays(5);
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        bidHistory.Reason_for_short_TAT__c = 'other';
        insert bidHistory;
    }
    @isTest
    static void testScheduledEmail(){
        Bid_History__c bidHistory = [SELECT Id, Name,Bid_Due_Date__c,Scientific_Review__c,Scientific_Review_Received__c,Scientific_Review_Completed__c,Science_Due_Date__c FROM Bid_History__c WHERE Name = 'TestBidHistory'];
        bidHistory.Scientific_Review__c = 'Yes';
        Test.startTest();
        update bidHistory;
        Test.stopTest();
    }
}