public with sharing class CNT_CRM_TimeTracker {
    
    @AuraEnabled
    public static void logEditTime(String sObjectName, String recordId, Decimal startTimeStamp){
        UTL_TimeTracker.logEditTime(sObjectName, recordId, startTimeStamp);
    }
    
    @AuraEnabled
    public static void logCreateTime(String sObjectName){
        UTL_TimeTracker.logCreateTime(sObjectName);
    }
    
    @AuraEnabled
    public static void logSaveTime(String sObjectName, String recordId){
        UTL_TimeTracker.logSaveTime(sObjectName, recordId);
    }
    
    @AuraEnabled
    public static Decimal getCurrentTimestamp(){
        return Datetime.now().getTime();
    }
}