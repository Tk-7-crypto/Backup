@IsTest
public class TST_CNT_CRM_TimeTracker {
	@IsTest
    public static void testLogCreateTime(){
        CNT_CRM_TimeTracker.logCreateTime('Opportunity');
        Time_Tracker__c tt = [SELECT Id, Start_Time__c from Time_Tracker__c LIMIT 1];
        System.assertEquals(tt.Start_Time__c != null, true);
    }
    
    @IsTest
    public static void testLogSaveTime(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        CNT_CRM_TimeTracker.logCreateTime('Opportunity');
        CNT_CRM_TimeTracker.logSaveTime('Opportunity', opp.Id);
        List<Time_Tracker__c> ttList = [SELECT Id, Start_Timestamp__c from Time_Tracker__c];
        System.assertEquals(ttList.size() == 1, true);
    }
    
    @IsTest
    public static void testLogEditTime(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        CNT_CRM_TimeTracker.logEditTime('Opportunity', opp.Id, Datetime.now().getTime());
        Time_Tracker__c tt = [SELECT Id, End_Time__c from Time_Tracker__c LIMIT 1];
        System.assertEquals(tt.End_Time__c != null, true);
    }
    
    @IsTest
    public static void testGetCurrentTime(){
        Decimal currentTime = CNT_CRM_TimeTracker.getCurrentTimestamp();
        System.assertEquals(currentTime > 0, true);
    }
}