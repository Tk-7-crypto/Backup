/**
* This batch class is used for the purpose of sending documents for E Signature process via docusign 
*/ 
public class BCH_CLM_BulkDocusignSendForESignatures implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    public String query;
    public List<String> lstException;
    public String emailTemplateName;
    public String sendAsUserEmail;
    
    public BCH_CLM_BulkDocusignSendForESignatures(String query, String emailTemplateName, String sendAsUserEmail) {
        this.query = query;
        lstException = new List<String>();
        this.emailTemplateName = emailTemplateName;
        this.sendAsUserEmail = sendAsUserEmail;
    } 

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Apttus__APTS_Agreement__c> lstAgreement) {
        try { 
            List<CNT_APTMS_DocuSignESignature.AttachmentWrapper> lstAttachment = CNT_APTMS_DocuSignESignature.getAllDocuments(lstAgreement[0].Id);
            List<Agreement_Contacts__c> lstContacts = CNT_APTMS_DocuSignESignature.getAgreementContacts(lstAgreement[0].Id);
            CNT_APTMS_DocuSignESignature.ReminderAndExpWrapper reminderAndExpRec = CNT_APTMS_DocuSignESignature.getReminderAndExpiration(lstAgreement[0].Docusign_Account_Id__c);
            List<CNT_APTMS_DocuSignESignature.EmailTemplateWrapper> lstEmailTemplate = CNT_APTMS_DocuSignESignature.getEmailTemplateNames(lstAgreement[0].Id);
            CNT_APTMS_DocuSignESignature.EmailDataWrapper emailWrapper = CNT_APTMS_DocuSignESignature.getEmailTemplateExecutedBody(lstAgreement[0].Id, emailTemplateName);
            String emailSubject = emailWrapper.subject;
            String emailBlurb = emailWrapper.body;
            Set<Id> selectedAttIds = new Set<Id>{lstAttachment[0].attId};
            List<ContentVersion> selectedAttList = new SLT_ContentVersion().selectById(selectedAttIds);  
            CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
            List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper> selectedSignersList = new List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper>();
            CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper(null, '', '1', 'Signer',
                (lstContacts[0].Contact__r.FirstName + ' ' + lstContacts[0].Contact__r.LastName), lstContacts[0].Email__c, '');
            docusignWrapper.disabled = 'false';
            docusignWrapper.emailBody = emailBlurb; 
            docusignWrapper.emailSubject = emailSubject; 
            docusignWrapper.userType = lstContacts[0].Type__c;
            docusignWrapper.emailTemplate = emailTemplateName; 
            selectedSignersList.add(docusignWrapper);
            if(configuration != null && configuration.Contracts_Distribution_Email__c != null) {
                CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapperCC = new CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper(null, '', '2', CON_CLM.RECIPIENT_TYPE_CC,
                    ('Contracts' + ' ' + 'Distribution'), configuration.Contracts_Distribution_Email__c, '');
                docusignWrapperCC.disabled = 'false';
                docusignWrapperCC.emailBody = emailBlurb; 
                docusignWrapperCC.emailSubject = emailSubject; 
                docusignWrapperCC.userType = 'Contact';
                docusignWrapperCC.emailTemplate = emailTemplateName; 
                selectedSignersList.add(docusignWrapperCC);
            }
            CNT_APTMS_DocuSignESignature.ESignatureResponseWrapper erw = CNT_APTMS_DocuSignESignature.doDocuSignCallout(true, CON_CLM.ENVELOPE_STATUS_SENT, emailSubject, 
                emailBlurb, selectedAttList, selectedSignersList, lstAgreement[0], reminderAndExpRec, sendAsUserEmail, null);
        }
        catch(Exception e) {
            lstException.add(UTL_CLM.concatenateException(e)); 
        }
    }  
    
    public void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        List<String> toAddress = new List<String>{job.CreatedBy.Email};    
        String subject = 'The apex job status for BCH_CLM_BulkDocusignSendForESignatures is '+job.Status;        
        String body = (lstException.isEmpty()) ? 'Successful' : 'Failed';      
        if(lstException != null && lstException.size() > 0) {
            body += '<br/>=====Exception=====<br/>';
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