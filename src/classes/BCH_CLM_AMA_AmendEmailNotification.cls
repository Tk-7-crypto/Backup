/**
* This is a batch class for sending email notifications to AMA users regarding annual renewals  
*/ 
global class BCH_CLM_AMA_AmendEmailNotification implements Database.Batchable<sObject>, Database.Stateful {
    global String query;
    global List<String> lstException;
    global BCH_CLM_AMA_AmendEmailNotification(String query) {
        lstException = new List<String>();
        this.query = query;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Apttus__APTS_Agreement__c> lstAgreement) {
        String htmlBody = 'htmlBody';
        String emailSubject = '';          
        List<Messaging.SendEmailResult> emailResultList = new List<Messaging.SendEmailResult>(); 
        Map<Messaging.SingleEmailMessage, Apttus__APTS_Agreement__c> emailToAgreementMap = new Map<Messaging.SingleEmailMessage, Apttus__APTS_Agreement__c>();
        CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
        List<EmailTemplate> lstEmailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(configuration.AMA_Email_Template__c,
            new Set<String>{'Id', 'HtmlValue', 'Subject'});
        List<OrgWideEmailAddress> lstOrgWideEmail = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress(CON_CLM.INTEGRATION_EMAIL, 
            new Set<String>{'Id', 'Address'});
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        if(!lstEmailTemplate.isEmpty()) {
            htmlBody = lstEmailTemplate[0].HtmlValue;
            emailSubject = lstEmailTemplate[0].Subject;
        } 
        try { 
            for(Apttus__APTS_Agreement__c agreement : lstAgreement) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();   
                String htmlBodyTable = createHTMLTableForAMABulkAmendEmailNotification(agreement, htmlBody);
                if(!lstEmailTemplate.isEmpty()) {
                    email.setTemplateId(lstEmailTemplate[0].Id);
                    email.setSubject(lstEmailTemplate[0].Subject); 
                }
                email.setHtmlBody(htmlBodyTable);
                email.setReplyTo(configuration.AMA_Contract_Renewal_Email_Address__c);
                if(configuration.AMA_USBU_Email_Address__c != null) {
                    email.setCcAddresses(new List<String>{configuration.AMA_USBU_Email_Address__c});
                }
                email.setSaveAsActivity(true);
                email.setToAddresses(new List<String>{agreement.Apttus__Primary_Contact__r.Email});
                email.setTreatBodiesAsTemplate(true);
                if(!lstOrgWideEmail.isEmpty()) {
                    email.setOrgWideEmailAddressId(lstOrgWideEmail[0].Id);                    
                }
                email.setTargetObjectId(agreement.Apttus__Primary_Contact__c); //contactId
                email.setWhatId(agreement.Id); //agreementId
                emailsToSend.add(email);
                emailToAgreementMap.put(email, agreement);
            }
            if(!emailsToSend.isEmpty() && !configuration.AMA_Send_Amend_Email__c) {
                Savepoint sp = Database.setSavepoint();
                emailResultList = Messaging.sendEmail(emailsToSend);
                Database.rollback(sp);
                taskCreationForAMAAmendEmailNotification(emailToAgreementMap, emailsToSend);
            }
            else if(!emailsToSend.isEmpty() && configuration.AMA_Send_Amend_Email__c) {
                emailResultList = Messaging.sendEmail(emailsToSend, false);
            }
        }
        catch(Exception e) {
            lstException.add(UTL_CLM.concatenateException(e)); 
        }
    }  
        
    /*
    * This method is used to construct HTML table for AMA Bulk Amend Email Batch class
    * @param Apttus__APTS_Agreement__c agreement
    * @return String
    */ 
    @testVisible
    private String createHTMLTableForAMABulkAmendEmailNotification(Apttus__APTS_Agreement__c agreement, String htmlBody) {
        AMA_Sales_Rep_Rate__mdt repTier = UTL_CLM.getSalesRepRateByRepCount(Integer.valueOf(agreement.Agreement_Year_Plus_One__c), 
            (Integer)agreement.Sales_Rep_Count__c); 
        Double nextYearRecordCost = UTL_CLM.calcRecordBasedCost(agreement, Integer.valueOf(agreement.Agreement_Year_Plus_One__c));
        String htmlTable = 'Table';
        if(repTier.Sales_Rep_Cost__c != null && repTier.Sales_Rep_Tier__c != null) {
            htmlTable = '<table id="outerTable"><tr><td><b>' + agreement.Agreement_Year__c + ' Fees/Details</b></td><td><b>'
                + agreement.Agreement_Year_Plus_One__c + ' Fees/Details</b></td></tr><tr><td>'
                + 'Agreement Type: ' + agreement.Apttus__Subtype__c + '</td><td>Agreement Type: ' + agreement.Apttus__Subtype__c + '</td></tr><tr><td>' 
                + '<table id="innerTable1"><tr><td>' + agreement.Record_Based_Cost__c + '</td><td>for ' + (Integer)agreement.Number_Of_Records__c + ' records</td><tr><td>'
                + (Integer)agreement.Sales_Rep_Cost__c + '</td><td>for ' + (Integer)agreement.Sales_Rep_Count__c + '(' + repTier.Sales_Rep_Tier__c + ' Reps tier)</td><tr><td>'    
                + agreement.Apttus__Total_Contract_Value__c + '</td><td>Total Royalties for ' + agreement.Agreement_Year__c + ' ' + agreement.Proration_Type__c
                + '</td></tr></table>' + '<td><table id="innerTable2"><tr><td>' + nextYearRecordCost + '</td><td>for ' + (Integer)agreement.Number_Of_Records__c + ' records</td></tr><tr><td>'   
                + repTier.Sales_Rep_Cost__c + '</td><td>for ' + (Integer)agreement.Sales_Rep_Count__c + '(' + repTier.Sales_Rep_Tier__c + ' Reps tier)</td></tr><tr><td>'    
                + '<b>' + (repTier.Sales_Rep_Cost__c + nextYearRecordCost) + '</b></td><td><b>Total Royalties for ' + agreement.Agreement_Year_Plus_One__c
                + '</b></td></tr></table></td></tr></table>'; 
            htmlBody = htmlBody.replace('<<REPLACETABLE>>', htmlTable);
        }
        else if(agreement.Sales_Rep_Count__c == null && repTier.Sales_Rep_Cost__c == null) {
            htmlTable = '<table id="outerTable"><tr><td><b>' + agreement.Agreement_Year__c + ' Fees/Details</b></td><td><b>'
                + agreement.Agreement_Year_Plus_One__c + ' Fees/Details</b></td></tr><tr><td>'
                + 'Agreement Type: ' + agreement.Apttus__Subtype__c + '</td><td>Agreement Type: ' + agreement.Apttus__Subtype__c + '</td></tr><tr><td>' 
                + '<table id="innerTable1"><tr><td>' + agreement.Record_Based_Cost__c + '</td><td>for ' + (Integer)agreement.Number_Of_Records__c + ' records</td><tr><td>'   
                + agreement.Apttus__Total_Contract_Value__c + '</td><td>Total Royalties for ' + agreement.Agreement_Year__c + ' ' + agreement.Proration_Type__c
                + '</td></tr></table>' + '<td><table id="innerTable2"><tr><td>' + nextYearRecordCost + '</td><td>for ' + (Integer)agreement.Number_Of_Records__c + ' records</td></tr>'   
                + '<tr><td><b>' + nextYearRecordCost + '</b></td><td><b>Total Royalties for ' + agreement.Agreement_Year_Plus_One__c
                + '</b></td></tr></table></td></tr></table>'; 
            htmlBody = htmlBody.replace('<<REPLACETABLE>>', htmlTable);
        }
        htmlBody = htmlBody.replace('<<Primary_Contact_Email>>', agreement.Apttus__Primary_Contact__r.Email);
        return htmlBody;
    }
    
    /**
    * This method is used to create tasks for AMA Bulk Amend Email Batch class
    * @param Map<Messaging.SingleEmailMessage, Apttus__APTS_Agreement__c> emailToAgreementMap
    * @param List<Messaging.SingleEmailMessage> emailsList
    */
    @testVisible
    private void taskCreationForAMAAmendEmailNotification(Map<Messaging.SingleEmailMessage, Apttus__APTS_Agreement__c> emailToAgreementMap, 
        List<Messaging.SingleEmailMessage> emailsList) {
        List<Task> lstTask = new List<Task>();
        for(Messaging.SingleEmailMessage email : emailsList) {
            if(emailToAgreementMap.containsKey(email)) {
                Task task = new Task();
                task.Subject = email.getSubject();
                task.WhatId = emailToAgreementMap.get(email).Id;  
                task.WhoId = emailToAgreementMap.get(email).Apttus__Primary_Contact__c;
                task.Description = email.getHtmlBody().stripHtmlTags();
                task.TaskSubtype = 'Email';
                task.ActivityDate = System.today();
                lstTask.add(task);               
            }
        }
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> {Task.SObjectType});
        if(!lstTask.isEmpty()) {
            uow.registerNew(lstTask);
            uow.commitWork();
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        List<String> toAddress = new List<String>{job.CreatedBy.Email};    
        String subject = 'The apex job status for BCH_CLM_AMA_AmendEmailNotification is '+job.Status;        
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