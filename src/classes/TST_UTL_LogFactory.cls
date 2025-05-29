@isTest
public class TST_UTL_LogFactory { 
    @testSetup
    static void setupTestData() {
        insert new Log_Setting__c(Name = 'TPA', Log_Data_to_keep_for__c = 6, Severity_Level__c = 'DEBUG');
    }
    
    public static testMethod void testMethod1() {
        Log_History__c tstLog = new Log_History__c(Log_Module__c = 'TPA', Log_Level__c = 'DEBUG', GUID__c = UTL_LogFactory.Guid, Log_Detail__c = 'Test');
        
        UTL_LogFactory.instance.getLogInstance();
        UTL_LogFactory.getLogLst();
        UTL_LogFactory.resetLogList();
        UTL_LogFactory.saveLogs(tstLog, false);
        tstLog.Id = null;
        UTL_LogFactory.saveLogs(new List<Log_History__c>{tstLog}, false);
        UTL_LogFactory.generateAndCommitLog(true, false, UTL_LogFactory.Guid, 'Test', 'TPA', null, 'DEBUG', 'otherDetails', null);
        tstLog.Id = null;
        UTL_LogFactory.commitLogsAsync(JSON.serialize(New List<Log_History__c>{tstLog}), true);
        tstLog.Id = null;
        UTL_LogFactory.commitLogsAsync(JSON.serialize(tstLog), false);
        tstLog.GUID__c = null;
        UTL_LogFactory.saveLogs(tstLog, false);
        tstLog.GUID__c = UTL_LogFactory.Guid;
        tstLog.Log_Detail__c = null;
        UTL_LogFactory.saveLogs(tstLog, false);
        tstLog.Log_Detail__c = 'Test';
        tstLog.Log_Module__c = null;
        UTL_LogFactory.isValidLog(tstLog);
        tstLog.Log_Module__c = 'TPA';
        tstLog.Log_Level__c = null;
        UTL_LogFactory.saveLogs(tstLog, false);
        UTL_LogFactory.saveLogs(new List<Log_History__c>{tstLog}, false);
    }
}