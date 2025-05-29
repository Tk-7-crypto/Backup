public class QUE_CRM_LockAccount implements Queueable{
    Id accountId;
    public QUE_CRM_LockAccount(Id accountId)  {
        this.accountId = accountId;
    }
    public void execute(QueueableContext context) {
        Approval.lockResult result1 = Approval.lock(this.accountId);
        if (result1.isSuccess()) {
            System.debug('Successfully locked account with ID: ' + result1.getId());
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : result1.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
            }
        }
    }
    
}