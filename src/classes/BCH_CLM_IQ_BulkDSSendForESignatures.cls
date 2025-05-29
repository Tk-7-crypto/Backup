/**
* This batch class is used for the purpose of sending documents for E Signature process via docusign 
*/ 
public class BCH_CLM_IQ_BulkDSSendForESignatures implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    public String query;
    public List<String> lstException;
    public String emailTemplateName;
    public String sendAsUserEmail;
    
    public BCH_CLM_IQ_BulkDSSendForESignatures(String query, String emailTemplateName, String sendAsUserEmail) {
        this.query = query;
        lstException = new List<String>();
        this.emailTemplateName = emailTemplateName;
        this.sendAsUserEmail = sendAsUserEmail;
    } 

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<IQVIA_Agreement__c> lstAgreement) {
        
        List<CNT_CLM_DocuSignESignature.AttachmentWrapper> lstAttachment = CNT_CLM_DocuSignESignature.getAllDocuments(lstAgreement[0].Id);
        List<IQVIA_Agreement_Team__c> lstContacts = CNT_CLM_DocuSignESignature.getAgreementTeams(lstAgreement[0].Id);
        CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderAndExpRec = CNT_CLM_DocuSignESignature.getReminderAndExpiration(lstAgreement[0].Docusign_Account_Id__c);
        List<CNT_CLM_DocuSignESignature.EmailTemplateWrapper> lstEmailTemplate = CNT_CLM_DocuSignESignature.getEmailTemplateNames(lstAgreement[0].Id);
        CNT_CLM_DocuSignESignature.EmailDataWrapper emailWrapper = CNT_CLM_DocuSignESignature.getEmailTemplateExecutedBody(lstAgreement[0].Id, emailTemplateName);
        String emailSubject = emailWrapper.subject;
        String emailBlurb = emailWrapper.body;
        Set<Id> selectedAttIds = new Set<Id>{lstAttachment[0].attId};
        List<ContentVersion> selectedAttList = new SLT_ContentVersion().selectById(selectedAttIds);  
        CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
        List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper> selectedSignersList = new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>();
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(null, '', '1', 'Signer',
            (lstContacts[0].Contact__r.FirstName + ' ' + lstContacts[0].Contact__r.LastName), lstContacts[0].Email__c, '');
        docusignWrapper.disabled = 'false';
        docusignWrapper.emailBody = emailBlurb; 
        docusignWrapper.emailSubject = emailSubject; 
        docusignWrapper.userType = lstContacts[0].Type__c;
        docusignWrapper.emailTemplate = emailTemplateName; 
        selectedSignersList.add(docusignWrapper);
        if(configuration != null && configuration.Contracts_Distribution_Email__c != null) {
            CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapperCC = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(null, '', '2', CON_CLM.RECIPIENT_TYPE_CC,
                ('Contracts' + ' ' + 'Distribution'), configuration.Contracts_Distribution_Email__c, '');
            docusignWrapperCC.disabled = 'false';
            docusignWrapperCC.emailBody = emailBlurb; 
            docusignWrapperCC.emailSubject = emailSubject; 
            docusignWrapperCC.userType = 'Contact';
            docusignWrapperCC.emailTemplate = emailTemplateName; 
            selectedSignersList.add(docusignWrapperCC);
        }
        CNT_CLM_DocuSignESignature.ESignatureResponseWrapper erw = CNT_CLM_DocuSignESignature.doDocuSignCallout(true, CON_CLM.ENVELOPE_STATUS_SENT, emailSubject, 
            emailBlurb, selectedAttList, selectedSignersList, lstAgreement[0], reminderAndExpRec, sendAsUserEmail, null);
        
    }  
    
    public void finish(Database.BatchableContext bc) {
        
    }        
}