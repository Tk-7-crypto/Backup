public class GBL_LogBase {
    // Base Interface template to create custom logs
    public interface ILogBase {
        Log_History__c getLogInstance();
    
        sobject generateAndCommitLog(Boolean isLogCommit, Boolean isAsyncCommit, String GUID, String logDetail, String logModule, String logType, String logSeverity, String otherDetails, String recordId);
        
        list<Log_History__c> getLogLst();
        
        void saveLogs(Log_History__c sObj, Boolean isAsyncCommit);
        
        void resetLogList();
    }
    
    public class LogFactoryCreator {
        public LogFactoryCreator(){}
        
        // Return the appropriate class instance based on className
        public GBL_LogBase.ILogBase Instance(String className) {
            Type t = Type.forName(className);
            return (GBL_LogBase.ILogBase) t.newInstance();
        }
    }
}