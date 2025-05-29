/**
 * @File Name          : EmailBodyComposer.cls
 * @Description        : This class is used to fetch the Email templates and receipients
 * @Author             : Anup Kage  
 * @Group              : 
 * @Last Modified By   : Anup Kage  
 * @Last Modified On   : 4/10/2020, 10:18:39 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/10/2020   Anup Kage       Initial Version
**/
public with sharing class CNT_AEA_EmailBodyComposer {
    public static integer i = 0;
    public static Map<String,String> accountParentIdById = new Map<String,String>();
    public static List<Id> oppAccountHierarchyIdList = new List<Id>();
    private static Boolean checkNotFirst = false;
    private static String strFormValue;
    // public static Id userId = UserInfo.getUserId();

    /**
    * @description : This Method will preview the selected Email Template
    * @author Anup Kage   | 4/10/2020 
    * @param templateId 
    * @param recId 
    * @return EmailTemplate 
    **/

    @AuraEnabled
    public static EmailTemplate generatePreview(String templateId, String recId ) {
        EmailTemplate emailTemplate = new SLT_EmailTemplate().selectEmailTemplatesById(templateId);
        Contact contactRec = new SLT_Contact().getContact();
        if(emailTemplate != null && emailTemplate.Id != null) {
           
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage tempEmail = new Messaging.SingleEmailMessage();
            tempEmail.setUseSignature(false);
            tempEmail.setSaveAsActivity(false);
            tempEmail.setSenderDisplayName('No Replay');
            tempEmail.setTemplateId(emailTemplate.Id);
            tempEmail.setWhatId(recId);
            tempEmail.setTargetObjectId(contactRec.Id);
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {tempEmail});
           
            Database.rollback(sp);
            emailTemplate.HtmlValue = tempEmail.getHtmlBody();
            emailTemplate.Subject = tempEmail.getSubject();
        }
        return emailTemplate;
    }   
    /**
    * @description : this method is used to fetch the email templates
    * @author Anup Kage   | 4/10/2020 
    * @return List<sObject> 
    **/
    @AuraEnabled(cacheable=true)
    public static List < sObject > getEmailTemplates() {
        List < sObject > emailTemplateList = new List < sObject > ();
        String templateName = 'BHR%';
        emailTemplateList = new SLT_EmailTemplate().selectEmailTemplatesByFolderId('Triage Folder', templateName);
        return emailTemplateList;
    }
    /**
    * @description : This method is used to send the email
    * @author Anup Kage   | 4/10/2020 
    * @param templateId 
    * @param recId 
    * @param receipeints 
    * @return boolean 
    **/
    @AuraEnabled
    public static boolean sendMail(String templateId, Id recId, List<String> toRecepients, List<String> bccRecepients, List<String> ccRecepients){
        EmailTemplate emailTemplate = new SLT_EmailTemplate().selectEmailTemplatesById(templateId);
        if(emailTemplate != null && emailTemplate.Id != null) {
            Contact contactRec = new SLT_Contact().getContact();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'request.proposal.global@quintiles.com'];
            Messaging.SingleEmailMessage tempEmail = new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) {
                tempEmail.setOrgWideEmailAddressId(owea.get(0).Id);
            } else{
                tempEmail.setReplyTo('request.proposal.global@quintiles.com');
                tempEmail.setSenderDisplayName('No Replay');
            }
            Messaging.reserveSingleEmailCapacity(1);
            // String[] toAddresses = new String[]{'anupk@rockitdata.com'};
            //
            tempEmail.setToAddresses(toRecepients);
            tempEmail.setBccAddresses(bccRecepients);
            tempEmail.setCcAddresses(ccRecepients);
            tempEmail.setUseSignature(false);
            tempEmail.setSaveAsActivity(false);
            tempEmail.setTemplateId(emailTemplate.Id);
            tempEmail.setWhatId(recId);
            tempEmail.setTargetObjectId(contactRec.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {tempEmail});
            
        }
    return false;
    }
    /**
    * @description : This method is used to fetch receipients
    * @author Anup Kage   | 4/10/2020 
    * @param searchKey 
    * @param recId 
    * @return List<sObject> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecepients(String recId) {
        List<sObject> sObjectRecordsList = new List<sObject>();
        // User currentUser = getTriageUser(); 
        schema.sObjectType sObjType = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c');
        String prefix =  sObjType.getDescribe().getKeyPrefix();
        
        Bid_History__c agRecord = new SLT_Bid_History().getRecordById(recId);
        if(agRecord.Bid_History_Related_Opportunity__r.AccountId != null){
            getAccounts(new Set<Id>{agRecord.Bid_History_Related_Opportunity__r.AccountId});
        } 
        
        Opportunity oppRecord = new SLT_Opportunity().getRecordByIdForCallOut(agRecord.Bid_History_Related_Opportunity__c);
        String region =  '\''+'\'';
        String country = '\''+'\'';
        String service = '\''+'\'';
        String ageGroup ='\''+'\'';
        if(agRecord.Bid_History_Related_Opportunity__r.Potential_Regions__c != null)
            region = separateStringWithComma(agRecord.Bid_History_Related_Opportunity__r.Potential_Regions__c.split(';'));
        if(agRecord.Targeted_Countries__c != null)
            country = separateStringWithComma(agRecord.Targeted_Countries__c.split(';'));
        if(agRecord.Requested_Services__c != null)           
            service = separateStringWithComma(agRecord.Requested_Services__c.split(';'));
        if(oppRecord.Population_Age_Group__c != null)
            ageGroup = separateStringWithComma(oppRecord.Population_Age_Group__c.split(';'));
        
        List<Agreement_Email_Alert__c> agrementEmailAlertList = new SLT_AgreementEmailAlert().getEmailReceipieantsByMatchingFilter(agRecord, oppRecord,region, country, service, ageGroup);

        if(agrementEmailAlertList.size() > 0)
           sObjectRecordsList =   filterRecordsByAgreement(agrementEmailAlertList, agRecord);
        return sObjectRecordsList;
    }
    
    /**
    * @description : Method to used to convert multipicklist value to String
    * @author Devang Gandhi | 08/18/2020 
    * @param  multiPickListValues
    * @return String 
    **/
    Private static String separateStringWithComma(List<String> multiPickListValues){
        checkNotFirst = false;
        strFormValue = '';
        for(String value : multiPickListValues){
            if(checkNotFirst)
                strFormValue += ',';
            strFormValue += '\''+value+'\'' ;
            checkNotFirst = true;
        }
        return strFormValue;
    }
    
    /**
    * @description : This method is used to fetch the records for displaying name of Branches
    * @author Anup Kage   | 4/10/2020 
    * @param recordId 
    * @return List<sObject> 
    **/
    @AuraEnabled(cacheable=true)
    public static sObject getRecord(String recordId){
        return new SLT_Bid_History().getRecordById(recordId);
    }
    
    public static void getAccounts(Set<Id> recordIds){
        //IQVIACBEX-1044
        oppAccountHierarchyIdList.addAll(recordIds);
        getAccountChildHierachyList(recordIds);
        getAccountParentHierachyList(recordIds); 
    }
    
    /**
     * This Method is used to get child Account hierarchy list
     * @param recordIds 
     */ 
    private static void getAccountChildHierachyList(Set<Id> recordIds){ 
        Map<Id, Account> childAccMap = new SLT_Account().getAccountsByParentAccount(recordIds);
        if(childAccMap.size() > 0){ 
            oppAccountHierarchyIdList.addAll(childAccMap.keySet());
            getAccountChildHierachyList(childAccMap.keySet());
        }
    }
    
    /**
     * This Method is used to get Parent Account hierarchy list
     * @param recordId
     */ 
    private static void getAccountParentHierachyList(Set<Id> recordIds){
       List<Account> accounts = new SLT_Account().selectById(recordIds);
       Set<Id> accountId = new Set<Id>();
        for(Account acc : accounts){
            if(acc.ParentId != Null){
                accountId.add(acc.ParentId);
            } 
        }
        if(accountId.size() > 0){
            oppAccountHierarchyIdList.addAll(accountId);
            getAccountParentHierachyList(accountId);
        }
    }
    
    /**
    * @description : The records will be filtered based on the matching fields on Agreement
    * @author Anup Kage   | 4/23/2020 
    * @param agreementEmailAlertList 
    * @param agRecord 
    * @return List<sObject> 
    **/
    public static List<sObject> filterRecordsByAgreement(List<Agreement_Email_Alert__c> agreementEmailAlertList, Bid_History__c agRecord){
        List<sObject> sObjectRecordsList = new List<sObject>();
        Opportunity oppRecord = new SLT_Opportunity().getRecordByIdForCallOut(agRecord.Bid_History_Related_Opportunity__c);
        for(Agreement_Email_Alert__c agEmailRecord : agreementEmailAlertList){
            //remove some condition and  move to query filter ---IQVIACBEX-843
            if((oppAccountHierarchyIdList.contains(agEmailRecord.Account__c) || agEmailRecord.Account__c == null ) &&
               (agEmailRecord.Incl_on_re_bids__c == null || (agRecord.Bid_Number__c > 1 && agEmailRecord.Incl_on_re_bids__c == 'Yes') || ((agRecord.Bid_Number__c == 0 || agRecord.Bid_Number__c == 1) && agEmailRecord.Incl_on_re_bids__c == 'No')) &&
               (agEmailRecord.Rare_Disease__c == null || ((agEmailRecord.Rare_Disease__c == 'Yes' && agRecord.Bid_History_Related_Opportunity__r.Rare_Disease__c == true) ||(agEmailRecord.Rare_Disease__c == 'No' && agRecord.Bid_History_Related_Opportunity__r.Rare_Disease__c == false ))) ){
                   sObjectRecordsList.add(agEmailRecord);
               }
        }
        
        return sObjectRecordsList;
    }

    /**
    * @description : To Fetch the Opportunity related to Agreement
    * @author Anup Kage   | 5/15/2020 
    * @param getOppRecord 
    * @return Opportunity
    **/
    @AuraEnabled(cacheable=true)
    public static Opportunity getOppRecord(String recordId){
        Bid_History__c agRecord = new SLT_Bid_History().getRecordById(recordId); 
        return  new SLT_Opportunity().getRecordByIdForCallOut(agRecord.Bid_History_Related_Opportunity__c);
    }
    @AuraEnabled(cacheable=true)
    public static List<Id> getParentAccountIds(String recordId){
        Bid_History__c agRecord = new SLT_Bid_History().getRecordById(recordId);
        if(agRecord.Bid_History_Related_Opportunity__r.AccountId != null){
            getAccounts(new Set<Id>{agRecord.Bid_History_Related_Opportunity__r.AccountId});
        }
        
        return oppAccountHierarchyIdList;
    } 
} 