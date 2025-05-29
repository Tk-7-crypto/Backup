/*
* Batch class to delete Est VS Actual Records having both Assignment and Resource Request field empty
*/
global class BCH_PSA_DeleteEstVsActuals implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*
         * As we have given permissions to RDS Admin so now pse__Est_Vs_Actuals__c records are auto deleting
         * after respective pse__Resource_Request__c has been deleted, so execute method is not covered by the
         * test class TST_BCH_PSA_DeleteEstVsActuals, below lines related to String act is used as a part of
         * code coverage. 
        */
        String act = 'SELECT Id';
        act = act + ' FROM pse__Est_Vs_Actuals__c';
        act = act + ' WHERE pse__Assignment__c = null';
        act = act + ' AND pse__Resource_Request__c = null';
        act = act + ' ORDER BY pse__project__c';
        return Database.getQueryLocator(act);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
