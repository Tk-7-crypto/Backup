public class QBL_UserContactSyncError implements Queueable{
    
    public List<User> userList;
    
    public QBL_UserContactSyncError (List<User> userList) {
        this.userList = userList;
    }
    
    public void execute(QueueableContext context) {
        List<Log_History__c> logHistoryList = new List<Log_History__c>();
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        
        List<Database.SaveResult> updateUserList = Database.update(userList,false);
        for(Integer i=0; i<updateUserList.size(); i++) {
            if (!updateUserList.get(i).isSuccess()) {
                Database.Error error = updateUserList.get(i).getErrors().get(0);
                String failedDML = error.getStatusCode()+' '+error.getMessage();
                Log_History__c logObj = new Log_History__c();
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                String guid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
                logObj.GUID__c = guid;
                logObj.Record_Id__c = userList.get(i).Id;
                logObj.Log_Module__c = 'CRM';
                logObj.Log_Detail__c = failedDML;
                logHistoryList.add(logObj);
            }
        }
        insert logHistoryList;
        
        UTL_ExecutionControl.stopTriggerExecution = false;
    }
    
}