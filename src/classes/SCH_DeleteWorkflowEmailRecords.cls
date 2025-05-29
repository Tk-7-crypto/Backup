/**
 * Scheduler class runs multiple batches based on the number of modules to delete their old Workflow Email Record object data
**/
global class SCH_DeleteWorkflowEmailRecords implements Schedulable, Database.Batchable<SObject>
{
    public String queryString = '';
    
    global void execute(SchedulableContext SC) {
        List<Log_Setting__c> lstLogSett = Log_Setting__c.getAll().values();
        for(Log_Setting__c objLogSett: lstLogSett) {
            SCH_DeleteWorkflowEmailRecords objSchDelEmaiWorkfRec = new SCH_DeleteWorkflowEmailRecords();
            if(!UTL_Validate.isEmptyOrNull(objLogSett.Workflow_Email_Record_keep_for__c) && Integer.valueOf(objLogSett.Workflow_Email_Record_keep_for__c) > 0) {
                objSchDelEmaiWorkfRec.queryString = 'Select Id From Workflow_Email_Record__c where Module_Name__c =\'' + objLogSett.Name + '\' and CreatedDate < LAST_N_DAYS:' + Integer.valueOf(objLogSett.Workflow_Email_Record_keep_for__c);
                Database.executeBatch(objSchDelEmaiWorkfRec);
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