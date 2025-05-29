/**
* This batch class is used for the purpose of checking E Signature status 
*/ 
public class BCH_APTMS_BulkCheckESignatureStatus implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents {   
    public static String authCode;
    public static Integer numOfDocuments;
    public String query;
    public List<String> lstException;
    
    public BCH_APTMS_BulkCheckESignatureStatus(String query) {
        this.query = query;
        lstException = new List<String>();
    } 
    
    public Database.QueryLocator start(Database.BatchableContext bc) {       
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Apttus__APTS_Agreement__c> scope) {
        List<IQ_DocuSignEnvelope__c> envelopeList = new List<IQ_DocuSignEnvelope__c>();
        DocuSign_Auth_Data__c docuSignData;
        String consentURL;        
        Set<Id> envIds = new Set<Id>();     
        try {
            CNT_APTMS_AddDocusignRecipient.cancelDraftEnvelopes(scope);
            for(Apttus__APTS_Agreement__c obj : scope) {
                envIds.add(obj.DocuSign_Envelope_Id__c);
            }       
            envelopeList = new SLT_IQDocuSignEnvelope().getDocuSignEnvelopeByIdAndStatus(CON_CLM.SENT_STATUS, envIds, new Set<String>{'Id','Name',
                'Status__c','APTS_Agreement__c','NumberOfDocuments__c' ,
                'Send_As_User_Email__c','Docusign_AccountId__c','DocumentName__c','APTS_Agreement__r.OwnerId', 'Docusign_App_Name__c'});               
            if(!envelopeList.isEmpty() && envelopeList[0].Status__c == CON_CLM.SENT_STATUS && envelopeList[0].Docusign_AccountId__c != null ) {
                List<DocuSign_Auth_Data__c> docuSignDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id','Base_URL__c',
                    'Client_Id__c','Account_Id__c', 'Name'}, envelopeList[0].Docusign_App_Name__c, 1);
                docuSignData = docuSignDataList.size() > 0 ? docuSignDataList[0] : new DocuSign_Auth_Data__c();           
                String baseUrl = docuSignData.Base_URL__c + '/restapi/v2/accounts/' + docuSignData.Account_Id__c;
                String endPoint = '/envelopes/' + envelopeList[0].name; 
                String method = CON_CLM.GET;
                authCode = CNT_APTMS_AddDocusignRecipient.getJWTAccessToken(envelopeList[0].Docusign_App_Name__c, envelopeList[0].Send_As_User_Email__c);
                if(authCode != '' && authCode != null) {
                    HttpResponse response = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, endPoint, method, authCode, null, envelopeList[0].Send_As_User_Email__c);               
                    if(response.getStatusCode() == 401) {
                        authCode = CNT_APTMS_AddDocusignRecipient.getJWTAccessToken(envelopeList[0].Docusign_App_Name__c, envelopeList[0].Send_As_User_Email__c);                   
                        response = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, endPoint, method, authCode, null, envelopeList[0].Send_As_User_Email__c);                   
                    } 
                    if(response.getStatusCode() == 200) {                   
                        CNT_APTMS_AddDocusignRecipient.EnvelopeWrapper envelopeWrapperObj = (CNT_APTMS_AddDocusignRecipient.EnvelopeWrapper)JSON.deserialize(response.getBody(), 
                            CNT_APTMS_AddDocusignRecipient.EnvelopeWrapper.class); 
                        if(envelopeWrapperObj.status == CON_CLM.COMPLETED_STATUS) {                       
                            CNT_APTMS_AddDocusignRecipient.completeSentEnvelope(envelopeList[0].APTS_Agreement__c, envelopeList[0].name, baseUrl, 
                                envelopeList[0].Id, envelopeList[0].Docusign_App_Name__c, envelopeList[0].Send_As_User_Email__c,false);                                               
                            String endPointdoc = '/envelopes/'+envelopeList[0].name+'/documents';     
                            if(!Test.isRunningTest()) {
                                System.enqueueJob(new QUE_CLM_DocusignSendForESignatures(baseURL, envelopeList[0], authCode));
                            }
                        }
                        else if(envelopeWrapperObj.status == CON_CLM.DECLINED_STATUS) {
                            CNT_APTMS_AddDocusignRecipient.declineSentEnvelope(envelopeList[0].APTS_Agreement__c, 
                                envelopeList[0].name, baseUrl, envelopeList[0].Id, envelopeList[0].Docusign_App_Name__c,
                                envelopeList[0].Send_As_User_Email__c);
                        } else if(EnvelopeWrapperObj.status == CON_CLM.SENT_STATUS){
                            CNT_APTMS_AddDocusignRecipient.completeSentEnvelope(envelopeList[0].APTS_Agreement__c, 
                                envelopeList[0].name, baseUrl, envelopeList[0].Id, envelopeList[0].Docusign_App_Name__c,
                                envelopeList[0].Send_As_User_Email__c,true);
                        }
                    } 
                }                     
            }
        }
        catch(Exception e) {
            lstException.add('Agreement : ' + scope + ' Envelope : ' + envIds + UTL_CLM.concatenateException(e));
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        if(Test.isRunningTest() || job.ExtendedStatus != null) {
            List<String> toAddress = new List<String>{job.CreatedBy.Email};    
            String subject = 'BCH_APTMS_BulkCheckESignatureStatus '+ job.Status;       
            String body = String.join(lstException, ', ');
            Messaging.SingleEmailMessage mail = UTL_CLM.createSingleEmailMessage(toAddress, subject, body + 'The first error is -' + job.ExtendedStatus, null, null, null); 
            mails.add(mail);
            if(mails.size() > 0) {
                UTL_CLM.sendEmail(mails);
            } 
        }       
    }    
}