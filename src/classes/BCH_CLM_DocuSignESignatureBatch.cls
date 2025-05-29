public class BCH_CLM_DocuSignESignatureBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Database.AllowsCallouts {
    public String envelopeStatus;
    public String emailSubject;
    public String emailBlurb;
    public List<ContentVersion> selectedAttList;
    public List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper> selectedSignersList;
    public IQVIA_Agreement__c agreement; 
    public CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderAndExpRec;
    public Id agreementId;
    public String sendAsUserEmail;
    public String docusignUserId;

    public BCH_CLM_DocuSignESignatureBatch(String envelopeStatus, String emailSubject, String emailBlurb, 
        List<ContentVersion> selectedAttList, List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper> selectedSignersList,
        IQVIA_Agreement__c agreement, CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderAndExpRec, 
        String sendAsUserEmail, String docusignUserId) {
        this.envelopeStatus = envelopeStatus;	
        this.emailSubject = emailSubject;
        this.emailBlurb = emailBlurb; 
        this.selectedAttList = selectedAttList;
        this.selectedSignersList = selectedSignersList;
        this.agreement = agreement; 
        this.reminderAndExpRec = reminderAndExpRec; 
        this.agreementId = agreement.Id;
        this.sendAsUserEmail = sendAsUserEmail;
        this.docusignUserId = docusignUserId;
   }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, FF_Agreement_Number__c, Docusign_Account_Id__c, Status__c,' 
            + 'Status_Category__c FROM IQVIA_Agreement__c WHERE Id =: agreementId';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {   		
        CNT_CLM_DocuSignESignature.ESignatureResponseWrapper erw = CNT_CLM_DocuSignESignature.doDocuSignCallout(true, 
            envelopeStatus, emailSubject, emailBlurb, selectedAttList, selectedSignersList, agreement, reminderAndExpRec, sendAsUserEmail,docusignUserId);
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}