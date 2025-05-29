public with sharing class UTL_TPA_Flow_ActionHandler { 
    
    @InvocableMethod(label='Invoke Apex Flow Action')
    public static List<FlowOutputs> apexFlowAction(List<FlowInputs> requests) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        for(FlowInputs request: requests){
            if(request.action == 'TPA Certification Email Preview') {
                results.add(sendCertificateEmailPreview(request));
            }
            if(request.action == 'TPA Certification Send Email') {
                results.add(sendCertificateEmail(request));
            }
        }
        return results;
		
    }


    public static FlowOutputs sendCertificateEmailPreview(FlowInputs flowReq) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        FlowOutputs resp = new FlowOutputs();

        String templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA Certification emailEnglish').Translated_Template_Id__c;

        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, flowReq.recordID);
		
        email.setSubject(emailNotToSend.getSubject());

        resp.emailBody = emailNotToSend.getHtmlBody() == NULL ? emailNotToSend.getPlainTextBody() : emailNotToSend.getHtmlBody();
        resp.emailSubject = emailNotToSend.getSubject();
        resp.HasRichText = emailNotToSend.getHtmlBody() != NULL;
        return resp; 
    }
    
    
    public static FlowOutputs sendCertificateEmail(FlowInputs flowReq) {
        // Prepare the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        FlowOutputs resp = new FlowOutputs();
        List<String> toAddresses = new List<String>();
        if (!String.isEmpty(flowReq.ClientEmail)) {
            if(flowReq.ClientEmail.contains(',')){
                toAddresses.addall(flowReq.ClientEmail.split(','));
            }else{
                toAddresses.addall(flowReq.ClientEmail.split(';'));
            }   
        }

        String templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA Certification emailEnglish').Translated_Template_Id__c;

        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, flowReq.recordID);
        
        email.setToAddresses(toAddresses);
        email.setSubject(emailNotToSend.getSubject());
        email.setSaveAsActivity(true);
        email.setWhatId(flowReq.recordID);
        email.setTargetObjectId(UTL_TPA.emailTargetContactId);
        email.setTreatTargetObjectAsRecipient(false);
        email.setHtmlBody(emailNotToSend.getHtmlBody() == NULL ? emailNotToSend.getPlainTextBody() : emailNotToSend.getHtmlBody());//.replace('[Client Name]', flowReq.ClientName));
        email.setHtmlBody(email.getHtmlBody().replace('[Cerification_Content]', flowReq.emailBody));
        email.setOrgWideEmailAddressId(UTL_TPA.orgWideEmailAddress);
        

       
        
        list<string> ccList = new list<string>();
        // Set CC addresses
        if (!String.isEmpty(flowReq.ccEmails)) {
            if(flowReq.ccEmails.contains(',')){
                ccList.addall(flowReq.ccEmails.split(','));
            }else{
                ccList.addall(flowReq.ccEmails.split(';'));
            }           
        }

        List<TPA_Assigned_TP_Processor__c> assignTP = [select Id,TP_Processor__r.TP_Processor_Email__c from TPA_Assigned_TP_Processor__c where Email__c =: UserInfo.getUserEmail() Limit 1];
        if(assignTP != null && assignTP.size() > 0 && assignTP[0].TP_Processor__c != null && assignTP[0].TP_Processor__r.TP_Processor_Email__c != null){
            ccList.add(assignTP[0].TP_Processor__r.TP_Processor_Email__c);
            email.setReplyTo(assignTP[0].TP_Processor__r.TP_Processor_Email__c);
        }
        if(UTL_TPA.sharedEmailAddress != null && UTL_TPA.sharedEmailAddress != '') {
            ccList.add(UTL_TPA.sharedEmailAddress);
        }
        email.setCcAddresses(ccList);
        resp.emailBody = email.getHtmlBody() == NULL ? email.getPlainTextBody() : email.getHtmlBody();
        resp.emailSubject = email.getSubject();
        resp.HasRichText = email.getHtmlBody() != NULL;
        
        
        // Attach files
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        list<id> cvList = new list<id>();
        if(flowReq.attachmentIds!= null && flowReq.attachmentIds.size() > 0) {
            for (String docId : flowReq.attachmentIds) {
            ContentVersion cv = [SELECT VersionData, Title FROM ContentVersion WHERE ContentDocumentId = :docId LIMIT 1];
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(cv.Title);
            attachment.setBody(cv.VersionData);
            attachments.add(attachment);
            cvList.add(cv.id);
        }
        email.setEntityAttachments(cvList);
        }
        
        if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        return resp; 
    }
    
    
    
    public class FlowInputs {
        @InvocableVariable(label='Input Action')
        public String action;
        
        @InvocableVariable
        public String contactId;
        
        @InvocableVariable
        public String ccEmails;
        
        @InvocableVariable
        public List<String> attachmentIds;
        
        @InvocableVariable
        public String recordID;
        
        @InvocableVariable
        public String ClientEmail;
        
        @InvocableVariable
        public String ClientName;
        
        @InvocableVariable(label='Email Subject' description='The subject of the email.')
        public string emailSubject;
        
        @InvocableVariable(label='Email Body' description='The HTML/test email body.')
        public string emailBody;
    }
    
    public class FlowOutputs {
        @InvocableVariable(label='Email Subject' description='The subject of the email.')
        public string emailSubject;
        
        @InvocableVariable(label='Email Body' description='The HTML/test email body.')
        public string emailBody;
        
        @InvocableVariable(label='Has HTML Body?' description='This is true, if the email has HTML body.')
        public boolean HasRichText;
    }
    
}