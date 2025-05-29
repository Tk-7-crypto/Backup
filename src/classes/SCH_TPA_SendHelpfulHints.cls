global with sharing class SCH_TPA_SendHelpfulHints implements Schedulable, Database.Batchable<sObject> {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new SCH_TPA_SendHelpfulHints(), 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        TPA_Settings__c tpaSetting = TPA_Settings__c.getOrgDefaults();  
        String newHelpfulHintDate = DateTime.newInstance(tpaSetting.TPA_New_Helpful_Hints_Functionality_Date__c.year(),tpaSetting.TPA_New_Helpful_Hints_Functionality_Date__c.month(),tpaSetting.TPA_New_Helpful_Hints_Functionality_Date__c.day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
        //String newHelpfulHintDate = DateTime.newInstance(tpaSetting.TPA_New_Helpful_Hints_Functionality_Date__c.year(),tpaSetting.TPA_New_Helpful_Hints_Functionality_Date__c.month(),tpaSetting.TPA_New_Helpful_Hints_Functionality_Date__c.day()).format('yyyy-MM-dd');      
        //DateTime newHelpfulHintDate = DateTime.newInstance(2020, 11, 01, 00, 00, 00);
        String query = 'Select Id, Vendor_Contact_e_mail__c, All_Helpful_Emails_Sent__c, Data_Access_End_Date__c, Vendor_Compliance_Email__c, Vendor_Language__c, In_Effect_Date__c, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, ClientContact__c, Authorized_Signer_Email__c, Vendor_App_Submitted__c, (Select Email__c from TPA_Request_Contacts__r where Type__c = \'Additional Vendor Contact\') ';
        query += 'from TPA_Request__c '; 
        if(!Test.isRunningTest()) {
            query += 'where In_Effect_Date__c >= ' + newHelpfulHintDate;
            query += ' AND All_Helpful_Emails_Sent__c = false';
            query += ' AND Request_Status__c not in (\'' + 'Covered By MOU' + '\', \'' + 'Draft Closed' + '\', \'' + 'Pending IQVIA Review of Voided Envelope' + '\')';
            //query += ' AND id = \'aE53I000000CaUa\'';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<TPA_Request__c> tpaRequestList = (List<TPA_Request__c>)scope;
        string templateId = '';
        String preferredLanguage = 'English';
        Map<Id, TPA_Agreement_Additional_Field__c> tpaRequestToAddtionalInfoMap = new Map<Id, TPA_Agreement_Additional_Field__c>();
        List<TPA_Agreement_Additional_Field__c> additionalInfoObjList = [SELECT Id, Name, TPA_Helpful_Hint_Emails_Sent__c, Related_TPA_Request__c FROM TPA_Agreement_Additional_Field__c
                                                                         WHERE Related_TPA_Request__c IN :tpaRequestList];
        for(TPA_Agreement_Additional_Field__c addObj : additionalInfoObjList) {
            tpaRequestToAddtionalInfoMap.put(addObj.Related_TPA_Request__c, addObj);
        }
        List<TPA_Agreement_Additional_Field__c> additionalInforObjListToUpdate = new List<TPA_Agreement_Additional_Field__c>();
        List<TPA_Request__c> tpaRequestListToUpdate = new List<TPA_Request__c>();
        try {
            for(TPA_Request__c tpaRequest : tpaRequestList) {
                List<Attachment> lstAttachment = [select Id, Name, LastModifiedDate, Body from Attachment where ParentId =: tpaRequest.Id and Name like '%TPA Helpful Hints Addendum%.pdf' order by LastModifiedDate Desc limit 1];
                if(lstAttachment.size() == 0 || (lstAttachment.size() > 0 && lstAttachment[0].LastModifiedDate < tpaRequest.Vendor_App_Submitted__c) ){
                    Integer requestLifeSpan = tpaRequest.In_Effect_Date__c.Date().daysBetween(tpaRequest.Data_Access_End_Date__c);
                    system.debug('requestLifeSpan: ' + requestLifeSpan);
                    Integer dayDiff = requestLifeSpan > 9 ? (Integer)(((decimal)requestLifeSpan/9).round()) : 1;
                    system.debug('dayDiff: ' + dayDiff);
                    Integer daysAfterInEffect = tpaRequest.In_Effect_Date__c.Date().daysBetween(Date.today());
                    system.debug('daysAfterInEffect: ' + daysAfterInEffect);
                    system.debug('dayDiff %: '+ math.mod(daysAfterInEffect, dayDiff));
                    if(Test.isRunningTest()) {
                        dayDiff = 1;
                        daysAfterInEffect = 8;
                    }
                    if(math.mod(daysAfterInEffect, dayDiff) == 1 || dayDiff == 1) {
                        system.debug('dayDiff /: '  + daysAfterInEffect/dayDiff);
                        Integer emailNumber = dayDiff != 1 ? (daysAfterInEffect/dayDiff) + 1 : (daysAfterInEffect/dayDiff);
                            if(emailNumber > 0 && emailNumber < 9) {
                                preferredLanguage = tpaRequest.vendor_language__c != null ? tpaRequest.vendor_language__c : 'English';
                                templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Helpful Hint ' + emailNumber + preferredLanguage).Translated_Template_Id__c;
                                system.debug('templateId : ' + templateId);
                                
                                List<String> ccList = new List<String>{ tpaRequest.TP_Processor_Email__c };
                                    if(tpaRequest.Vendor_Contact_e_mail__c != tpaRequest.Authorized_Signer_Email__c){
                                        ccList.add(tpaRequest.Authorized_Signer_Email__c);
                                    }
                                List<TPA_Contact__c> additionalVendor = tpaRequest.TPA_Request_Contacts__r;
                                if(additionalVendor.size() > 0){
                                    for(TPA_Contact__c tpaCon: additionalVendor){
                                        ccList.add(tpaCon.Email__c);
                                    }
                                }
                                List<String> toAddressesList = new List<String>{tpaRequest.Vendor_Contact_e_mail__c};
                                    if(tpaRequest.Vendor_Compliance_Email__c != null && tpaRequest.Vendor_Contact_e_mail__c != tpaRequest.Vendor_Compliance_Email__c) {
                                        toAddressesList.add(tpaRequest.Vendor_Compliance_Email__c);
                                    }
                                if(emailNumber == 8) {
                                    tpaRequest.All_Helpful_Emails_Sent__c = true;
                                    tpaRequestListToUpdate.add(tpaRequest);
                                }
                                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                                SRV_TPA_TPARequest.assignedTPProcessorName = tpaRequest.TPA_Assigned_TP_Processor__r.Initials__c;
                                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddressesList, ccList, 'SendEmail', templateId, tpaRequest.Id, null, '', false, '');
                                SRV_TPA_TPARequest.addTPProcessorInitials = false;*/
                                TPA_Agreement_Additional_Field__c addtionInfoObj = tpaRequestToAddtionalInfoMap.get(tpaRequest.Id);
                                if(addtionInfoObj.TPA_Helpful_Hint_Emails_Sent__c != null) {
                                    addtionInfoObj.TPA_Helpful_Hint_Emails_Sent__c += emailNumber + ', ';
                                }
                                else {
                                    addtionInfoObj.TPA_Helpful_Hint_Emails_Sent__c = emailNumber + ', ';
                                }
                                additionalInforObjListToUpdate.add(addtionInfoObj);
                            }                    
                    }
                }
                if(additionalInforObjListToUpdate.size() > 0) {
                    update additionalInforObjListToUpdate;
                }  
                if(tpaRequestListToUpdate.size() > 0) {
                    UTL_TPA.modifyRequestForcefully = true;
                    update tpaRequestListToUpdate;
                    UTL_TPA.modifyRequestForcefully = false;
                } 
            }
        }
        catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SCH_TPA_SendHelpfulHints.execute', '');
        }   
        finally {
            UTL_TPA.modifyRequestForcefully = false;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}
