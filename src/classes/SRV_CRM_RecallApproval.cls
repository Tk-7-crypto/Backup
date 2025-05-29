/*
 * Version       : 1.0
 * Description   : Service Class for Recall Approval Requests
 */
global without sharing class SRV_CRM_RecallApproval
{
    /**
     * service method to UnLock Record
     * @params : Id recId
     */
    webservice static void unlockRecord(Id recId)   
    {       
        Approval.unlockResult ur = Approval.unlock(recId);
        if (ur.isSuccess()) {
        }
        else {	
            // Operation failed, so get all errors                
            for(Database.Error err : ur.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
            }
        }
    }
    
    /**
     * service method to Lock Record
     * @params : Id recId
     */
    webservice static void lockRecord(Id recId)   
    {       
        Approval.lockResult lr = Approval.lock(recId);
        if (lr.isSuccess()) {
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : lr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
            }
        }
    }
}