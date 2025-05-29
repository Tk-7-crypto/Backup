/*
 * Version       : 1.0
 * Description   : Apex Controller for PortalCaseHistory component.
 */

 public with sharing class CNT_CSM_PortalCaseHistory {
    public class CSM_CaseHistory {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String objName {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public DateTime lastModifiedDate {get; set;}
        @AuraEnabled
        public String createdByName {get; set;}
        @AuraEnabled
        public String fileExtension {get; set;}
    }

    @AuraEnabled
    public static List<CSM_CaseHistory> getCSM_CaseHistory(String recordId, String email_show, String status_show ){
        CSM_CaseHistory csm_ch;
        List<CSM_CaseHistory> csm_chl = new List<CSM_CaseHistory>();


        List<CaseComment> ccl = getCaseComments(recordId);
        //List<String> ccList = null;
        for(Integer i=0; i< ccl.size(); i++) {
            csm_ch =new CSM_CaseHistory();
            csm_ch.id = ccl[i].Id;
            csm_ch.objName = 'CaseComment';
            if(ccl[i].CommentBody != null && ccl[i].CommentBody.startsWith('ServiceNow Comment')){
                csm_ch.value = ccl[i].CommentBody.substringAfter('--');
                /*for(String snc : ccList){
                    if(!snc.startsWith('ServiceNow Comment')){
                        csm_ch.value = snc;
                    }
                }*/
            }else{
                csm_ch.value = ccl[i].CommentBody;
            }
            csm_ch.lastModifiedDate = ccl[i].LastModifiedDate;
            csm_ch.createdByName = ccl[i].CreatedBy.Name;
            csm_chl.add(csm_ch);
        }

        List<ContentDocumentLink> cdl = getAttachments(recordId);
        for(Integer i=0; i< cdl.size(); i++) {
            csm_ch =new CSM_CaseHistory();
            csm_ch.id = cdl[i].ContentDocumentId;
            csm_ch.objName = 'ContentDocumentLink';
            csm_ch.value = cdl[i].ContentDocument.Title+'.'+cdl[i].ContentDocument.FileExtension;
            csm_ch.lastModifiedDate = cdl[i].ContentDocument.LastModifiedDate;
            csm_ch.createdByName = cdl[i].ContentDocument.CreatedBy.Name;
            csm_chl.add(csm_ch);
        }

        Set<String> fields = new set<String> ();
        if(status_show.equals('true')){     
            fields.add('Status');
        }
        fields.add('Priority');
        fields.add('Impact');
        fields.add('Urgency');
        List<CaseHistory> chl = getCaseHistory(recordId, fields);
        for(Integer i=0; i< chl.size(); i++) {
            csm_ch =new CSM_CaseHistory();
            csm_ch.id = chl[i].Id;
            csm_ch.objName = 'CaseHistory';
            csm_ch.value = chl[i].Field + ' ' + Label.is_updated_from + ' <b>' + chl[i].OldValue + '</b> ' + Label.to + ' <b>' + chl[i].NewValue+'</b>';
            csm_ch.lastModifiedDate = chl[i].CreatedDate;
            csm_ch.createdByName = chl[i].CreatedBy.Name;
            csm_chl.add(csm_ch);
        }

    if(email_show.equals('true')){        
        List<EmailMessage> eml = getEmailMessages(recordId);
        for(Integer i=0; i< eml.size(); i++) {
            csm_ch =new CSM_CaseHistory();
            csm_ch.id = eml[i].Id;
            csm_ch.objName = 'EmailMessage';
            String htmlBody = null;
            if(eml[i].HtmlBody != null){
                htmlBody = eml[i].HtmlBody;
                if (htmlBody.indexOf('--------------- Original Message ---------------') > -1) {
                    htmlBody = eml[i].HtmlBody.split('--------------- Original Message ---------------')[0];
                    if (htmlBody.indexOf('From:') > -1) {
                        htmlBody = htmlBody.split('From:')[0];
                    }
                } else if(htmlBody.indexOf('From:') > -1) {
                    htmlBody = eml[i].HtmlBody.split('From:')[0];
                }

                if (htmlBody.lastIndexOf('@mailinator.com') > -1) {
                    htmlBody = htmlBody.split('@mailinator.com')[0];
                    if(htmlBody.lastIndexOf('<p') > -1) {
                        htmlBody = htmlBody.substring(0, htmlBody.lastIndexOf('<p')-2);
                    }
                } else if (htmlBody.lastIndexOf('replytocsm@iqvia.com') > -1) {
                    htmlBody = htmlBody.split('replytocsm@iqvia.com')[0];
                    if(htmlBody.lastIndexOf('<p') > -1) {
                        htmlBody = htmlBody.substring(0, htmlBody.lastIndexOf('<p')-2);
                    }
                } else if (htmlBody.lastIndexOf('email2casecsm@iqvia.com') > -1) {
                    htmlBody = htmlBody.split('email2casecsm@iqvia.com')[0];
                    if(htmlBody.lastIndexOf('<p') > -1) {
                        htmlBody = htmlBody.substring(0, htmlBody.lastIndexOf('<p')-2);
                    }
                }
            }else if(eml[i].TextBody != null){
                htmlBody = eml[i].TextBody;
            }
            if(htmlBody == null){
                htmlBody = '';
            }
            csm_ch.value = '<b>Subject:</b> ' + eml[i].Subject + '</a><br>'+'<b>From:</b> '+ eml[i].FromAddress + '<br>' +'<b>To:</b> '+ eml[i].ToAddress + '<br>' + htmlBody +'<br><a href="/support/s/detail/'+eml[i].id+'">' + eml[i].Subject + '</a>';
            csm_ch.lastModifiedDate = eml[i].CreatedDate;
            csm_ch.createdByName = eml[i].CreatedBy.Name;
            csm_chl.add(csm_ch);
        }
    }

        List<Task> cll = getLogCalls(recordId);
        for(Integer i=0; i< cll.size(); i++) {
            csm_ch =new CSM_CaseHistory();
            csm_ch.id = cll[i].Id;
            csm_ch.objName = 'CallLog';
            csm_ch.value = cll[i].Subject + '<br>' + cll[i].Description;
            csm_ch.lastModifiedDate = cll[i].CreatedDate;
            csm_ch.createdByName = cll[i].CreatedBy.Name;
            csm_chl.add(csm_ch);
        }
        
        List<CSM_Chat_History__c> lct = getCSMChatHistory(recordId);
        for(CSM_Chat_History__c ch : lct) {
            csm_ch = new CSM_CaseHistory();
            csm_ch.id = ch.Id;
            csm_ch.objName = 'CSMChatHistory';
            csm_ch.value = ch.Body__c;
            csm_ch.lastModifiedDate = ch.CreatedDate;
            csm_ch.createdByName = ch.CreatedBy.Name;
            csm_chl.add(csm_ch);
        }
        return csm_chl;
    }

    /**
    * This method used to return List<CaseComment> for parentId
    * @params  String parentId
    * @return  List<CaseComment>
    */
    @AuraEnabled
    public static List<CaseComment> getCaseComments(String recordId){
        List<CaseComment> caseComments = new List<CaseComment>();
        caseComments  = new SLT_CaseComment().selectByParentId(new Set<ID> {recordId});
        return CaseComments;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getAttachments(String recordId ){
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        cdl = [SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility, LinkedEntity.Name, LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =:recordId];
        return cdl;
    }

    public static List<CaseHistory> getCaseHistory(String recordId, Set<String> fields){
        List<CaseHistory> ch = new List<CaseHistory>();
        ch = [select Id, IsDeleted, CaseId, CreatedById,CreatedBy.Name, CreatedDate, Field, OldValue, NewValue from CaseHistory where Field in :fields and CaseId =:recordId];
        return ch;
    }

    @AuraEnabled
    public static List<EmailMessage> getEmailMessages (String recordId ){
        List<EmailMessage> em = new List<EmailMessage>();
        em = [select Id, ParentId, Subject, HtmlBody, TextBody, LastModifiedDate, CreatedDate, CreatedBy.Name, FromName, FromAddress, ToAddress from EmailMessage where ParentId != null AND ParentId =:recordId];
        return em;
    }

    @AuraEnabled
    public static List<Task> getLogCalls (String recordId ){
        List<Task> lc = new List<Task>();
        lc = [select Id, Subject, Description, type, CreatedDate, CreatedBy.Name from Task where TaskSubtype = 'Call' and WhatId =:recordId];
        return lc;
    }
    
    @AuraEnabled
    public static List<CSM_Chat_History__c> getCSMChatHistory(String recordId ){
        List<CSM_Chat_History__c> lc = new List<CSM_Chat_History__c>();
        lc = Database.query('select Id, Name, Case_Id__c,Body__c,CreatedDate,CreatedBy.Name from CSM_Chat_History__c where Case_Id__c != null and Case_Id__c =: recordId');
        return lc;
    }

    /**
    * This method used to insert a CaseComment
    * @params  CaseComment caseComment
    */
    @AuraEnabled
    public static void insertCaseComment(CaseComment caseComment){
        insert caseComment;
    }
    
    @AuraEnabled
    public static void sendAttachmentEmailToCaseOriginator(String caseId) {
        CNT_CSM_PortalCreateCase.sendAttachmentEmailToCaseOriginator(caseId);
    }
}