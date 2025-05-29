/** 
* Batch Class for the folder count logging during migration of folders and files of Box from Contract to Agreement object 
*/  
global class BCH_CLM_BoxCount implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global String query;
    global List<String> lstExceptionForLogs;
    
    global BCH_CLM_BoxCount(String query) {
        lstExceptionForLogs = new List<String>();
        this.query = query;        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contract> lstContract) {
        Set<Id> currentContractIdSet = new Set<Id>(); 
        Set<Id> existingLogIdSet = new Set<Id>();
        Set<String> existingFolderIdSet = new Set<String>();
        List<Log_History__c> lstLogCount = new List<Log_History__c>();    
        List<Log_History__c> lstLogForError = new List<Log_History__c>();  
        try {   
            for(Contract contract : lstContract) {
                currentContractIdSet.add(contract.Id);
            }
            List<Log_History__c> lstLogHistory = [SELECT Log_Detail__c, Log_Level__c, Log_Module__c, Record_Id__c FROM Log_History__c
                WHERE Log_Module__c = 'CLM' AND Log_Level__c = 'WARN' AND Record_Id__c IN: currentContractIdSet];    
            if(!lstLogHistory.isEmpty()) {
                for(Log_History__c log : lstLogHistory) {
                    if(log.Record_Id__c != null) {
                        existingLogIdSet.add(log.Record_Id__c);
                    }
                }
            }
            String conditionForFRUP = 'box__Record_ID__c IN: boxRecordIds';
            List<box__FRUP__c> frupList = new SLT_FRUP().getFRUPRecordsByBoxRecordId(currentContractIdSet, new Set<String>
                {'box__Folder_ID__c', 'box__Record_ID__c'}, conditionForFRUP);
            for(box__FRUP__c frupRecord : frupList) {
                if(!existingFolderIdSet.contains(frupRecord.box__Folder_ID__c) && !existingLogIdSet.contains(frupRecord.box__Record_ID__c)) {
                    lstLogCount.add(UTL_LogFactory.generateAndCommitLog(false, false, null, String.valueOf(UTL_CLM_Box.getTotalFolderCount(frupRecord.box__Folder_ID__c)), 'CLM',
                        'Custom', 'WARN', frupRecord.box__Folder_ID__c, frupRecord.box__Record_ID__c)); 
                    existingFolderIdSet.add(frupRecord.box__Folder_ID__c);
                }
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<SObjectType> {Log_History__c.SObjectType});
            if(!UTL_CLM_Box.lstBoxException.isEmpty()) {
                for(String excp : UTL_CLM_Box.lstBoxException) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, excp, 'CLM', 'Custom', 
                        'ERROR', excp.substring(0, excp.indexOf('=')), null));
                }
                uow.registerNew(lstLogForError);    
            }
            if(!lstLogCount.isEmpty()) {
                uow.registerNew(lstLogCount);
            }
            uow.commitWork();
        }
        catch(Exception e) {
            lstExceptionForLogs.add(UTL_CLM.concatenateException(e));  
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        List<String> toAddress = new List<String>{job.CreatedBy.Email};    
        String subject = 'The apex job status for BCH_CLM_BoxCount is '+job.Status;
        String body = (lstExceptionForLogs.isEmpty()) ? 'Box Count Successful' : 'Box Count Failed'; 
        if(!lstExceptionForLogs.isEmpty()) {
            body += '<br/>=====LogException=====<br/>';
            for(String str : lstExceptionForLogs) {
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