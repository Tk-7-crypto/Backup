/*
* Version : 1.0
* Description: Exception Class for Code coverage of TGRH_CRM_BatchApexErrorEvent.It nevers runs or Scheduled.
*/
global class BatchExceptionThrow implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {
    
    // Query to fetch all Account records
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT Id, Name FROM Account LIMIT 1]);
    }

    // Process each batch of records
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
       integer i = 1/0;
    }

    // Called once when the entire batch job is finished
    global void finish(Database.BatchableContext BC) {

    }
}