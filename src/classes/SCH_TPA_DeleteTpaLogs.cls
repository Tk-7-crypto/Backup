/**
 * Scheduler class runs on the monthly basis and deletes all TPA Logs prior to six months
**/
global class SCH_TPA_DeleteTpaLogs implements Schedulable {
    global void execute(SchedulableContext SC) {
        massDeleteLogs();
    }
    
    public void massDeleteLogs() {
        List<TPA_Logs__c> tpaLogsToDelete = [Select Id From TPA_Logs__c where CreatedDate < LAST_N_DAYS:180];
        delete tpaLogsToDelete;
    }
}