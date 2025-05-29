/**
 * Email service handler are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class BulkAmendEmailServiceHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<Log_History__c> lstLogForError = new List<Log_History__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		try{
            String subjectString = System.label.CLM_CL_0004_AMA_Contract_Renewal_Response_2023;
            Contact senderContact = new SLT_Contact().selectByEmail(String.valueOf(email.fromAddress));
            Double agreementVersionNumber = 0;
            if(senderContact != null) {
                String taskFilterCondition = 'WhoId = \''+senderContact.Id+'\' AND Subject = \''+subjectString + '\'';
                List<Task> listOfAssociatedTask = new SLT_Task().getTasks(new Set<String>{'Id'}, taskFilterCondition, null, null);
                if(listOfAssociatedTask == null || listOfAssociatedTask.isEmpty()){
                    String agreementFilterCondition = 'RecordType.DeveloperName = \''+CON_CLM.AMA_RECORD_TYPE_NAME
                        +'\' AND Apttus__Auto_Renewal__c = '+true+' AND Apttus__Primary_Contact__c = \''+senderContact.id+'\'';
                    List<Apttus__APTS_Agreement__c> listOfAgremeents = new SLT_Agreement().getAgreementListByCondition
                        (new Set<String>{'Id', 'CLM_Event__c', 'Agreement_Year__c', 'Apttus__Status_Category__c', 
                        'Apttus__Status__c', 'Apttus__Version_Number__c'}, agreementFilterCondition, null);
                    if(listOfAgremeents != null && !listOfAgremeents.isEmpty()) {
                        List<Apttus__APTS_Template__c> templateList = null;
                        templateList = SRV_CLM_APTS_Template.getTemplates(new Set<String>{'Id', 'Name'}, 'Name = \''+CON_CLM.AMA_AMEND_TEMPLATE_NAME+'\' AND Apttus__IsActive__c = true', 1);
                        Apttus__APTS_Agreement__c agreementAMA = listOfAgremeents[0];
                        for(Apttus__APTS_Agreement__c agreement: listOfAgremeents){
                            if(agreementVersionNumber < agreement.Apttus__Version_Number__c){
                                agreementVersionNumber = agreement.Apttus__Version_Number__c;
                                agreementAMA = agreement;
                            }
                        }
                        String emailBody = email.plainTextBody.toUpperCase();
                        String taskDesc = email.plainTextBody.contains('\n') && email.plainTextBody.contains('IQVIA Global Contract Management')
                            ? email.plainTextBody.substring(email.plainTextBody.indexOf('\n'), email.plainTextBody.indexOf('IQVIA Global Contract Management')) : '';
                        if(taskDesc != '' && taskDesc.contains('\n')){
                            taskDesc = taskDesc.substring(0, taskDesc.lastIndexOf('\n'));
                        }
                        Set<String> emailTemplateDevNames = new Set<String>{
                            CON_CLM.AMA_AUTO_RENEWAL_PROCESS_INVOKE_TEMPLATE, 
                            CON_CLM.AMA_AUTO_RENEWAL_ALREADY_SETUP_TEMPLATE, 
                            CON_CLM.AMA_AUTO_RENEWAL_INVALID_RESPONSE_TEMPLATE};
                                List<EmailTemplate> lstEmailTemplate = new SLT_EmailTemplate().selectEmailTemplatesByCondition(emailTemplateDevNames, 
                                	new Set<String> {'Id','Subject','HtmlValue'}, 'DeveloperName =: developerNames');
                        if(emailBody.startsWith(CON_CLM.AMA_AMEND_ACTION_RENEW) && templateList != null && !templateList.isEmpty()){
                            if(agreementAMA.Agreement_Year__c == String.valueOf(System.Today().year()) 
                                && agreementAMA.Apttus__Status_Category__c == CON_CLM.IN_EFFECT 
                                && agreementAMA.Apttus__Status__c == CON_CLM.ACTIVATED){
                                AgreementWrapper.AmendAgreementWrapper agrWrapper = new AgreementWrapper.AmendAgreementWrapper();
                                agrWrapper.agreementId = agreementAMA.Id;
                                agrWrapper.contractId = senderContact.Id;
                                agrWrapper.action = CON_CLM.AMEND;
                                Id amendedAggId = UTL_CLM.amendContract(agrWrapper);
                                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                                if(!lstEmailTemplate.isEmpty()){
                                    mail.setTemplateId(lstEmailTemplate[0].Id);
                                }
                                mail.setTargetObjectId(senderContact.Id);
                                mail.setSubject(lstEmailTemplate[0].Subject);
                                mail.setHTMLBody(lstEmailTemplate[0].HtmlValue);
                                mail.setSaveAsActivity(true);
                                mail.toAddresses = new List<String>{email.fromAddress};
                                mail.setWhatId(agreementAMA.Id);
                            	mails.add(mail);
                                if(amendedAggId != null) {
                                    UTL_CLM.createContractDocument(amendedAggId, templateList[0].Id);
                                    UTL_CLM.setupActivity(amendedAggId, senderContact.Id, subjectString,taskDesc);
                                }
                            }
                            else if(agreementAMA.CLM_Event__c == CON_CLM.RENEWAL 
                                && agreementAMA.Agreement_Year__c == String.valueOf(System.Today().year() + 1)){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(!lstEmailTemplate.isEmpty()){
                                    mail.setTemplateId(lstEmailTemplate[1].Id);
                                }
                                mail.setTargetObjectId(senderContact.Id);
                                mail.setSubject(lstEmailTemplate[1].Subject);
                                mail.setHTMLBody(lstEmailTemplate[1].HtmlValue);
                                mail.setSaveAsActivity(true);
                                mail.toAddresses = new List<String>{email.fromAddress};
                                mail.setWhatId(agreementAMA.Id);
                                mails.add(mail);
                            }
                        }
                        else if(emailBody.startsWith(CON_CLM.AMA_AMEND_ACTION_CHANGES)){
                            UTL_CLM.setupActivity(agreementAMA.Id, senderContact.Id, subjectString,taskDesc);
                        }
                        else if(emailBody.startsWith(CON_CLM.AMA_AMEND_ACTION_CANCEL)){
                            UTL_CLM.setupActivity(agreementAMA.Id, senderContact.Id, subjectString,taskDesc);
                        }
                        else{
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(!lstEmailTemplate.isEmpty()){
                                mail.setTemplateId(lstEmailTemplate[2].Id);
                            }
                            String htmlBody = lstEmailTemplate[2].HtmlValue;
                            htmlBody = htmlBody.replace('{!EmailMessage.FromAddress}', email.fromAddress);
                            htmlBody = htmlBody.replace('{!EmailMessage.TextBody}', email.htmlBody);
                            mail.setTargetObjectId(senderContact.Id);
                            mail.setSubject(lstEmailTemplate[2].Subject);
                            mail.setHTMLBody(htmlBody);
                            mail.setSaveAsActivity(true);
                            mail.toAddresses = new List<String>{email.fromAddress};
                            mail.setWhatId(agreementAMA.Id);
                            mails.add(mail);
                            lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, 'Email reply format cannot validate', 'CLM', 'Custom',
                                'ERROR', 'AMA Bulk Renew \nEmail reply format cannot be validated, \nPlease check sender email and email response below - \n'+'Sender Email - '+email.fromAddress+'\n Email Response - '+email.plainTextBody, null));
                        }
                    }
                    else{
                        lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, 'Agreement not found', 'CLM', 'Custom',
                        'ERROR', 'AMA Bulk Renew \nAgreement not found, \nPlease check sender email and email response below - \n'+'Sender Email - '+email.fromAddress+'\n Email Response - '+email.plainTextBody, null)); 
                    }
                }
            }
            else {
                lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, 'No contact found', 'CLM', 'Custom',
                    'ERROR', 'AMA Bulk Renew \nNo Contact Found, \nPlease check sender email and email response below - \n'+'Sender Email - '+email.fromAddress+'\n Email Response - '+email.plainTextBody, null));
            }
            if(mails.size() > 0) {
                UTL_CLM.sendEmail(mails);
            }
        }
        catch(QueryException e){
            lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, e.getMessage(), 'CLM', 'Custom',
                'ERROR', 'AMA Bulk Renew \n'+e.getMessage()+', \nPlease check sender email and email response below - \n'+'Sender Email - '+email.fromAddress+'\n Email Response - '+email.plainTextBody, null));
        }
        finally{
            UTL_LogFactory.saveLogs(lstLogForError, false);
        }
        result.success = true;
        return result;
    }
}