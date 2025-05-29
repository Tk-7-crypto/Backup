@IsTest
public class TST_UTL_TimeTracker {
	@IsTest
    public static void testLogCreateTime(){
        UTL_TimeTracker.logCreateTime('Opportunity');
        Time_Tracker__c tt = [SELECT Id, Start_Time__c from Time_Tracker__c LIMIT 1];
        System.assertEquals(tt.Start_Time__c != null, true);
    }
    
    @IsTest
    public static void testLogSaveTime(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        UTL_TimeTracker.logCreateTime('Opportunity');
        UTL_TimeTracker.logSaveTime('Opportunity', opp.Id);
        List<Time_Tracker__c> ttList = [SELECT Id from Time_Tracker__c];
        System.assertEquals(ttList.size() == 1, true);
    }
    
    @IsTest
    public static void testLogEditTime(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        UTL_TimeTracker.logEditTime('Opportunity', opp.Id, Datetime.now().getTime());
        Time_Tracker__c tt = [SELECT Id, End_Time__c from Time_Tracker__c LIMIT 1];
        System.assertEquals(tt.End_Time__c != null, true);
    }
    
    @IsTest
    public static void testLogEditStartTime(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        UTL_TimeTracker.logEditStartTime('Opportunity', opp.Id);
        Time_Tracker__c tt = [SELECT Id, Start_Time__c from Time_Tracker__c LIMIT 1];
        System.assertEquals(tt.Start_Time__c != null, true);
    }
    
    @IsTest
    public static void testLogEditEndTime(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        UTL_TimeTracker.logEditStartTime('Opportunity', opp.Id);
        UTL_TimeTracker.logEditEndTime('Opportunity', opp.Id);
        Time_Tracker__c tt = [SELECT Id, End_Time__c from Time_Tracker__c LIMIT 1];
        System.assertEquals(tt.End_Time__c != null, true);
    }
    
    @IsTest
    public static void testLogMassEditTime(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        List<Opportunity> opps = new List<Opportunity>();
        List<String> recordIds = new List<String>();
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opps.add(opp);
        recordIds.add(opp.Id);
        opp = UTL_TestData.createOpportunity(acc.Id);
        opps.add(opp);
        recordIds.add(opp.Id);
        insert opps;
        
        UTL_TimeTracker.logMassEditTime('Opportunity', recordIds, Datetime.now());
        List<Time_Tracker__c> tts = [SELECT Id from Time_Tracker__c];
        System.assertEquals(tts.size() == 2, true);
    }
}