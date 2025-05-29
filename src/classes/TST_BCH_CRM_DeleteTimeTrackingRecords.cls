@IsTest
public class TST_BCH_CRM_DeleteTimeTrackingRecords {
    @testSetup
    static void dataSetup() {
        Time_Tracker__c tt = new Time_Tracker__c();
        tt.Start_Time__c = DateTime.now().addHours(-2);
        insert tt;
    }
    
    @IsTest
    static void deleteTimeTrackingRecordsBatchTest(){
        Test.startTest();
        Database.executebatch(new BCH_CRM_DeleteTimeTrackingRecords());
        Test.stopTest();
        List<Time_Tracker__c> tts = [SELECT Id from Time_Tracker__c];
        System.assert(tts.size() == 0, true);
    }
}