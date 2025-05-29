/** 
* Batch Class for the creation of document version for bulk agreements.
*/  
global class BCH_CLM_AgreementDocumentCreation implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global String query;
    global List<String> lstException;
    global Id templateId;
    global BCH_CLM_AgreementDocumentCreation(String query, Id templateId) {
        lstException = new List<String>();
        this.query = query;
        this.templateId = templateId;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);    
    }
    
    global void execute(Database.BatchableContext bc, List<Apttus__APTS_Agreement__c> lstAgreement) {
        UTL_CLM.createContractVersionForBulkAgreement(lstAgreement,templateId);
    }
    
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        List<String> toAddress = new List<String>{job.CreatedBy.Email};    
        String subject = 'The apex job status for BCH_CLM_AgreementDocumentCreation is '+job.Status;
        String body = (lstException.isEmpty()) ? 'Document version creation Successful' : 'Document version creation Failed'; 
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