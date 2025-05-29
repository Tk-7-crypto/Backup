/*********************************************************
@Name : BCH_APTMS_DocuSignESignatureBatch
@Author : Conga AMS
@Description : Batch used to callout the Docusign api 
***********************************************************/
public class BCH_APTMS_DocuSignESignatureBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Database.AllowsCallouts {
    public String envelopeStatus;
    public String emailSubject;
    public String emailBlurb;
    public List<ContentVersion> selectedAttList;
    public List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper> selectedSignersList;
    public Apttus__APTS_Agreement__c agreement; 
    public CNT_APTMS_DocuSignESignature.ReminderAndExpWrapper reminderAndExpRec;
    public Id agreementId;
    public String sendAsUserEmail;
    public String docusignUserId;

    public BCH_APTMS_DocuSignESignatureBatch(String envelopeStatus, String emailSubject, String emailBlurb, 
        List<ContentVersion> selectedAttList, List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper> selectedSignersList,
        Apttus__APTS_Agreement__c agreement, CNT_APTMS_DocuSignESignature.ReminderAndExpWrapper reminderAndExpRec, 
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
        String query = 'SELECT Id, Name, Apttus__FF_Agreement_Number__c, Docusign_Account_Id__c, Apttus__Status__c,' 
            + 'Apttus__Status_Category__c, Execution_Order__c FROM Apttus__APTS_Agreement__c WHERE Id =: agreementId';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {   		
        CNT_APTMS_DocuSignESignature.ESignatureResponseWrapper erw = CNT_APTMS_DocuSignESignature.doDocuSignCallout(true, 
            envelopeStatus, emailSubject, emailBlurb, selectedAttList, selectedSignersList, agreement, reminderAndExpRec, sendAsUserEmail,docusignUserId);
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}