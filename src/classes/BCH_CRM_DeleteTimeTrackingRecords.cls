global class BCH_CRM_DeleteTimeTrackingRecords implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id from Time_Tracker__c where (Time_Spent__c = null OR End_Time__c = null) AND Start_Time__c < :DateTime.now().addHours(-1)]);
    }
    
    global void execute(Database.BatchableContext bc, List<Time_Tracker__c> ttList){
        delete ttList;
    }
    
    global void finish(Database.BatchableContext bc){
    }
}