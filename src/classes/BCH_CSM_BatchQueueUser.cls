global class BCH_CSM_BatchQueueUser implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        DAOH_User.manageQueuesRelations();
        
        String query = 'SELECT Id, Name FROM Group WHERE type=\'Queue\'';
        if(Test.isRunningTest()){
            query += ' limit 1';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Group> aGroups){

       DAOH_User.manageUserQueuesRelations(aGroups);
    }

    global void finish(Database.BatchableContext BC){

        BCH_CSM_UpdateQueueUser updateBatchObject = new BCH_CSM_UpdateQueueUser();
        Database.executeBatch(updateBatchObject);
    }
}