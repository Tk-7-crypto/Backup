public class QUE_CRM_UnlockAccount implements Queueable {
    Id accountId;
    public QUE_CRM_UnlockAccount(Id accountId)  {
        this.accountId = accountId;
    }
    public void execute(QueueableContext context) {
        System.debug('isLocked---' + Approval.isLocked(this.accountId));
        Approval.UnlockResult result = Approval.unlock(this.accountId);
        if (result.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully unlocked account with ID: ' + result.getId());
            descartesdps.DescartesDPSTriggerManager.triggerOnDemandSearchDPS(this.accountId);  
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : result.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
            }
        }
        
    }
}