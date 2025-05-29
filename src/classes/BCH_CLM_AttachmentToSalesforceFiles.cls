/** 
* Batch Class for the conversion of existing Agreement's attachment into Salesforce Files 
*/  
public class BCH_CLM_AttachmentToSalesforceFiles implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> lstException;
	
	public BCH_CLM_AttachmentToSalesforceFiles(String query) {
        lstException = new List<String>();
        this.query = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Attachment> records) {
        List<Attachment> attachmentsToProcess = [SELECT Id, Name, Body, Description, ParentId, 
            IsPrivate, OwnerId, CreatedDate, LastModifiedById, LastModifiedDate 
            FROM Attachment WHERE ID IN: records];
            
        List<Log_History__c> lstLogForError = new List<Log_History__c>();
        SavePoint sp = Database.setSavePoint();
        try {
            UTL_CLM.convertAttachmentsIntoFiles(attachmentsToProcess,false);
        }
        catch(Exception e) {
            lstException.add(UTL_CLM.concatenateException(e));
            database.rollback(sp);
        }
        finally {
            for(String excp: lstException) {
                lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, excp, 'CLM', 'Custom',
                    'ERROR', 'Entire Batch Failure for ' + null, null));
            }
            UTL_LogFactory.saveLogs(lstLogForError, false);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        List<String> toAddress = new List<String>{job.CreatedBy.Email};    
        String subject = 'The apex job status for BCH_CLM_AttachmentToSalesforceFiles is '+job.Status;
        String body = (lstException.isEmpty()) ? 'Attachment Conversion Successful' : 'Attachment Conversion Failed'; 
        if(lstException != null && lstException.size() > 0) {
            body += '=====Exception=====<br/>';
            for(String str : lstException) {
                body += str+'<br/>';
            }
        }
        Messaging.SingleEmailMessage mail = UTL_CLM.createSingleEmailMessage(toAddress, subject, body, null, null, null); 
        mails.add(mail);
        if(mails.size() > 0) {
            UTL_CLM.sendEmail(mails);
        }
    }
}