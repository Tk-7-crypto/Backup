global without sharing class UTL_LogFactory implements GBL_LogBase.ILogBase { 

    public static Log_History__c logToInsertPrvt{get;set;}
    public static List<Log_History__c> lstLogsPrvt{get;set;}
    public enum LogResult {SUCCESS, INCORRECTOREMPTYGUID, MISSINGLOGDETAIL, MISSINGLOGLEVEL, MISSINGMODULEINFO}
    public static Map<String, Log_Setting__c> mapLogSetting {
        get {
            if(mapLogSetting == null) {
                mapLogSetting = new Map<String, Log_Setting__c>();
                for(Log_Setting__c objLogSett: Log_Setting__c.getAll().values()) {
                    mapLogSetting.put(objLogSett.Name, objLogSett);
                }
            }
            return mapLogSetting;
        }
        private set;
    }
    
    public static Map<String, Integer> mapDebugLogs {
        get {
            if(mapDebugLogs == null) {
                mapDebugLogs = new Map<String, Integer>();
                mapDebugLogs.put('NONE', 1);
                mapDebugLogs.put('ERROR', 2);
                mapDebugLogs.put('WARN', 3);
                mapDebugLogs.put('INFO', 4);
                mapDebugLogs.put('DEBUG', 5);
                mapDebugLogs.put('FINE', 6);
                mapDebugLogs.put('FINER', 7);
                mapDebugLogs.put('FINEST', 8);
            }
            return mapDebugLogs;
        }
        private set;
    }
    
    public static LogResult logResultMessage { get; set; }

    public static UTL_LogFactory instance {
        get {
            if(instance == null) {
                instance = (UTL_LogFactory)((new GBL_LogBase.LogFactoryCreator()).instance('UTL_LogFactory'));
            }
            return instance;
        }
        private set;
    }
    
    public static String Guid {
        get {
            if(Guid == null) {
                Guid = UTL_Guid.Guid;
            }
            return Guid;
        }
        set;
    }
    
    /**
     * Function to create new Log.
     * @param isLogCommit: if log needs to be created or not
     * @return
     */
    public Log_History__c getLogInstance() {
        logToInsertPrvt = new Log_History__c(GUID__c = UTL_LogFactory.Guid);
        return logToInsertPrvt;
    }
    
    //Function get list of logs
    public static List<Log_History__c> getLogLst() {
        if(UTL_Validate.isEmptyOrNull(lstLogsPrvt)) {
            resetLogList();
        }
        return lstLogsPrvt;
    }
    
    //Function to reset log history list
    public static void resetLogList() {
        lstLogsPrvt = new List<Log_History__c>();
    }
    
    /**
     * Function to save log history record
     * @param logHistory: Pass log history record (Mandatory field)
     * @param isAsyncCommit: set True if wants to commit asynchronously else False (This is a mandatory field)
     * @return
     */
    public static void saveLogs(Log_History__c logHistory, Boolean isAsyncCommit) {
        if(!UTL_Validate.isEmptyOrNull(logHistory)) {
            if(!isSavable(logHistory.Log_Module__c, logHistory.Log_Level__c)) {
                return;
            }
            
            if(!isValidLog(logHistory)) {
                return;
            }
            if(!UTL_Validate.isEmptyOrNull(isAsyncCommit) && isAsyncCommit && UTL_Validate.isFutureCallAllowed()) {
                commitLogsAsync(JSON.serialize(logHistory), False);
            }
            else {
                insert logHistory;
            }            
            logResultMessage = LogResult.SUCCESS;
            system.debug('logResultMessage:::' + logResultMessage);
        }
    }
    
    /**
     * Overloaded "saveLogs" function to save list of log history records
     * @param lstLogHistory: Pass list of log history records (Mandatory field)
     * @param isAsyncCommit: set True if wants to commit asynchronously else False (This is a mandatory field)
     * @return
     */
    public static void saveLogs(List<Log_History__c> lstLogHistory, Boolean isAsyncCommit) {
        lstLogHistory = cleanLogList(lstLogHistory);
        if(!UTL_Validate.isEmptyOrNull(lstLogHistory)) {
            if(!isValidLog(lstLogHistory)) {
                return;
            }
            if(!UTL_Validate.isEmptyOrNull(isAsyncCommit) && isAsyncCommit && UTL_Validate.isFutureCallAllowed()) {
                commitLogsAsync(JSON.serialize(lstLogHistory), True);
            }
            else {
                insert lstLogHistory;
            }
            resetLogList();
            logResultMessage = LogResult.SUCCESS;
            system.debug('logResultMessage:::' + logResultMessage);
        }
    }
    
    /**
     * Function to create new Log.
     * @param isLogCommit: set True if wants to commit log history in history object else False (This is a mandatory field)
     * @param isAsyncCommit: set True if wants to commit asynchronously else False (This is a mandatory field)
     * @param GUID: Pass GUID value (Optional)
     * @param logDetail: Details of log (This is a mandatory field)
     * @param logModule: Module type for log (This is a mandatory field)
     * @param logType: supported logType value (Optional)
     * @param logLevel: Log level to check if log can be saved or not (This is a mandatory field and pass value from LoggingLevel like LoggingLevel.DEBUG, LoggingLevel.INFO, etc.)
     * @param otherDetails: Pass additional details\comments (Optional)
     * @param recordId: Pass id of the record under whose transaction you are creating log (Optional)
     * @return: returns Log_History__c object
     */
    public static Log_History__c generateAndCommitLog(Boolean isLogCommit, Boolean isAsyncCommit, String GUID, String logDetail, String logModule, String logType, String logLevel, String otherDetails, String recordId) {        
        if(!isSavable(logModule, logLevel)) {
            return null;
        }
        system.debug('increation::');
        logToInsertPrvt = new Log_History__c();
        system.debug('GUID::'+GUID);
        if(!UTL_Validate.isEmptyOrNull(GUID)) {
            logToInsertPrvt.GUID__c = GUID;
        }
        else {
            logToInsertPrvt.GUID__c = UTL_LogFactory.Guid;
        }
        system.debug('logDetail::'+logDetail+':::'+logModule);
        logToInsertPrvt.Log_Detail__c = logDetail;
        logToInsertPrvt.Log_Module__c = logModule;
        system.debug('logType::'+logType);
        if(!UTL_Validate.isEmptyOrNull(logType)) {
            logToInsertPrvt.Log_Type__c = logType;
        }
        system.debug('logLevel::'+logLevel);
        logToInsertPrvt.Log_Level__c = logLevel;
        system.debug('otherDetails::'+otherDetails);
        if(!UTL_Validate.isEmptyOrNull(otherDetails)) {
            logToInsertPrvt.Other_Details__c = otherDetails;
        }        
        system.debug('recordId::'+recordId);
        if(!UTL_Validate.isEmptyOrNull(recordId)) {
            logToInsertPrvt.Record_Id__c = recordId;
        }
        system.debug('logToInsertPrvt::'+logToInsertPrvt);
        if(!isValidLog(logToInsertPrvt)) {
            return null;
        }
        system.debug('isLogCommit::'+isLogCommit+':::'+isAsyncCommit);
        if(!UTL_Validate.isEmptyOrNull(isLogCommit) && isLogCommit) {            
            if(!UTL_Validate.isEmptyOrNull(isAsyncCommit) && isAsyncCommit && UTL_Validate.isFutureCallAllowed()) {
                commitLogsAsync(JSON.serialize(logToInsertPrvt), False);
            }
            else {
                insert logToInsertPrvt;
            }
            logResultMessage = LogResult.SUCCESS;
            system.debug('logResultMessage:::' + logResultMessage);
        }
        
        return logToInsertPrvt;
    }
    
    /**
     * Asynchronous function to create new Log.
     * @param logsToInsert: Pass serialized List of Log History records (This is a mandatory field)
     * @param isListType: set True if wants to commit list of records else False for a single record (This is a mandatory field)
     * @return
     */
    @Future
    public static void commitLogsAsync(String logsToInsert, Boolean isListType) {
        if(!UTL_Validate.isEmptyOrNull(isListType)) {
            if(isListType) {
                List<Log_History__c> lstLogToInsert = (List<Log_History__c>)JSON.deserialize(logsToInsert, List<Log_History__c>.class);
                lstLogToInsert = cleanLogList(lstLogToInsert);
                if(UTL_Validate.isEmptyOrNull(lstLogToInsert) || !isValidLog(lstLogToInsert)) {
                    return;
                }
                insert lstLogToInsert;        
            }
            else {
                Log_History__c logToInsert = (Log_History__c)JSON.deserialize(logsToInsert, Log_History__c.class);
                if(!isValidLog(logToInsert)) {
                    return;
                }
                insert logToInsert;
            }
        }
        logResultMessage = LogResult.SUCCESS;
        system.debug('logResultMessage:::' + logResultMessage);
    }
    
    public static List<Log_History__c> cleanLogList(List<Log_History__c> lstLogHist) {system.debug('lstLogHist.size()00:::'+lstLogHist);
        for(integer i = lstLogHist.size() - 1; i >= 0; i--) {system.debug('lstLogHist.size():::'+lstLogHist.size()+':::'+i+'::::'+lstLogHist[i]);
            if(lstLogHist[i] == null || !isSavable(lstLogHist[i].Log_Module__c, lstLogHist[i].Log_Level__c)) {
                lstLogHist.remove(i);
            }
        }
        return lstLogHist;
    }
    
    public static boolean isValidLog(List<Log_History__c> lstLogHistory) {
        for(Log_History__c objLstHist: lstLogHistory) {
            if(!isValidLog(objLstHist)) {
                return false;
            }
        }
        return true;
    }
    
    public static boolean isValidLog(Log_History__c objLogHistory) {
        if (UTL_Validate.isEmptyOrNull(GUID) || !UTL_Validate.isValidGuid(objLogHistory.GUID__c)) {
            system.debug('Incorrect GUID format');
            logResultMessage = LogResult.INCORRECTOREMPTYGUID;
            system.debug('logResultMessage:::' + logResultMessage);
            return false;
        }
        
        if(UTL_Validate.isEmptyOrNull(objLogHistory.Log_Detail__c)) {
            logResultMessage = LogResult.MISSINGLOGDETAIL;
            system.debug('logResultMessage:::' + logResultMessage);
            return false;
        }
        if(UTL_Validate.isEmptyOrNull(objLogHistory.Log_Module__c)) {
            logResultMessage = LogResult.MISSINGMODULEINFO;
            system.debug('logResultMessage:::' + logResultMessage);
            return false;
        }
        
        if(UTL_Validate.isEmptyOrNull(objLogHistory.Log_Level__c)) {
            logResultMessage = LogResult.MISSINGLOGLEVEL;
            system.debug('logResultMessage:::' + logResultMessage);
            return false;
        }
        
        return true;
    }
    
    public static boolean isSavable(String logModule, string recDebuLevel) {
        Log_Setting__c logSett = mapLogSetting.get(logModule);
        if(UTL_Validate.isEmptyOrNull(logSett) || UTL_Validate.isEmptyOrNull(recDebuLevel) || UTL_Validate.isEmptyOrNull(mapDebugLogs.get(logSett.Severity_Level__c)) || UTL_Validate.isEmptyOrNull(mapDebugLogs.get(recDebuLevel)) || (mapDebugLogs.get(logSett.Severity_Level__c) < mapDebugLogs.get(recDebuLevel))) {
            return false;
        }
        return true;
    }
}