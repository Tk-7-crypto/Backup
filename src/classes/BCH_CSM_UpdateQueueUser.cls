global class BCH_CSM_UpdateQueueUser implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name FROM Queue_User_Relationship__c WHERE Name LIKE \'RnD%\' AND AFU_Queue_Email__c = null AND Type__c = \'User\'';
        if(Test.isRunningTest()){
            query += ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Queue_User_Relationship__c> queueUserList){
        if(!queueUserList.isEmpty()){
            Map<String, String> queueNameEmailMap = new Map<String, String>();
            List<Queue_User_Relationship__c> queueList = new SLT_QueueUserRelationshipC().getUserQueueRecords();
            for(Queue_User_Relationship__c queueRecord : queueList){
                queueNameEmailMap.put(queueRecord.Name, queueRecord.AFU_Queue_Email__c);
            }

            for(Queue_User_Relationship__c userRecord : queueUserList){
                userRecord.AFU_Queue_Email__c = queueNameEmailMap.get(userRecord.Name);
            }
            
            try{
                update queueUserList;
            }
            catch(Exception ex){
                ex.getMessage();
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}