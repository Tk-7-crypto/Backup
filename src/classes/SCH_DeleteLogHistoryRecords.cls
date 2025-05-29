/**
 * Scheduler class runs multiple batches based on the number of modules to delete their old Workflow Email Record object data
**/
global class SCH_DeleteLogHistoryRecords implements Schedulable, Database.Batchable<SObject> {
    public String queryString = '';
    
    global void execute(SchedulableContext SC) {
        List<Log_Setting__c> lstLogSett = Log_Setting__c.getAll().values();
        for(Log_Setting__c objLogSett: lstLogSett) {
            SCH_DeleteLogHistoryRecords objSchDelLogHistRec = new SCH_DeleteLogHistoryRecords();
            if(!UTL_Validate.isEmptyOrNull(objLogSett.Log_Data_to_keep_for__c) && Integer.valueOf(objLogSett.Log_Data_to_keep_for__c) > 0) {
                objSchDelLogHistRec.queryString = 'Select Id From Log_History__c where Log_Module__c =\'' + objLogSett.Name + '\' and CreatedDate < LAST_N_DAYS:' + Integer.valueOf(objLogSett.Log_Data_to_keep_for__c);
                Database.executeBatch(objSchDelLogHistRec);
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext bc, List<Sobject> objList) {
        delete objList;
    }
    
    global void finish(Database.BatchableContext bc) {
    
    }
}