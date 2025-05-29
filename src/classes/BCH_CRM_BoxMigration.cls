/**
* Created by Ronak Mehta on 23-Nov-2023
* Description : Batch Class for the migration of folders and files of Box from LQ Opportunity to IQVIA Opportunity Record 
*/
global class BCH_CRM_BoxMigration implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global String query;
    global List<String> lstException;
    global List<String> lstExceptionForLogs;
    
    global BCH_CRM_BoxMigration(String query) {
        lstException = new List<String>();
        lstExceptionForLogs = new List<String>();
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        String folderCreatedId = null;
        Set<Id> oppIdSet = new Set<Id>(); 
        Set<String> existingFolderId = new Set<String>();
        Map<String,Opportunity> mapLQIdWithOpportunity = new Map<String, Opportunity>();
        List<box__FRUP__c> frupListForOpportunity = new List<box__FRUP__c>();
        List<Opportunity> lstopp = new List<Opportunity>();
        box__Folder_Details__c boxFolderDetails = box__Folder_Details__c.getValues('Opportunities');
        List<Log_History__c> lstLogForInfo = new List<Log_History__c>();
        List<Log_History__c> lstLogForError = new List<Log_History__c>();
        List<String> lstExceptionForBatchFailure = new List<String>();
        try {
            for(Opportunity opp : oppList) {
                oppIdSet.add(opp.Id);
            }
            if(oppIdSet != null && oppIdSet.size() > 0 ) {
                List<Opportunity> OpportunityList = [SELECT Id, Name, LQ_Box_Id_to_be_Migrated__c FROM Opportunity WHERE Id In: oppIdSet AND LQ_Box_Migration_Status__c != :CON_CLM.COMPLETED AND LQ_Box_Id_to_be_Migrated__c != null];
                System.debug('OpportunityList: '+ OpportunityList.size() + ' : ' + OpportunityList);
                for(Opportunity opp : OpportunityList) {
                    if(!existingFolderId.contains(opp.LQ_Box_Id_to_be_Migrated__c)) {
                        String folderName = opp.Name;
                        folderCreatedId = UTL_CLM_Box.copyAllFoldersAndFilesFromContractToAgreement(opp.LQ_Box_Id_to_be_Migrated__c,boxFolderDetails.box__FolderId__c, folderName);
                        if(String.isNotBlank(folderCreatedId)) {
                            box__FRUP__c newFrupRecord = new box__FRUP__c();
                            newFrupRecord.box__Object_Name__c = 'Opportunity';
                            newFrupRecord.box__Folder_ID__c = folderCreatedId;
                            newFrupRecord.box__Record_ID__c =  opp.Id;
                            frupListForOpportunity.add(newFrupRecord);
                            opp.LQ_Box_Migration_Status__c = CON_CLM.COMPLETED;
                            //opp.Box_Folder_Id__c = folderCreatedId;
                            lstopp.add(opp);
                            lstLogForInfo.add(UTL_LogFactory.generateAndCommitLog(false, false, null, opp.LQ_Box_Id_to_be_Migrated__c, 'CRM','Custom', 'INFO', folderCreatedId, opp.Id));
                        }
                        existingFolderId.add(opp.LQ_Box_Id_to_be_Migrated__c);
                    }
                }
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {box__FRUP__c.SObjectType, Opportunity.SObjectType, Log_History__c.SObjectType}
                );
                if(!lstopp.isEmpty() && !frupListForOpportunity.isEmpty() && !lstLogForInfo.isEmpty()) {
                    uow.registerDirty(lstopp);
                    uow.registerNew(frupListForOpportunity);
                    uow.registerNew(lstLogForInfo);
                    uow.commitWork();
                }
            }
        }
        catch(Exception e) {
            System.debug('catch E: '+e.getMessage());
            System.debug('catch E: '+e.getStackTraceString());

            lstException.add(UTL_CLM.concatenateException(e));
            lstExceptionForBatchFailure.add(UTL_CLM.concatenateException(e));
            if(!frupListForOpportunity.isEmpty()) {
                System.enqueueJob(new QUE_CLM_BoxMigration(frupListForOpportunity));
            }
        }
        finally {         
            if(!UTL_CLM_Box.lstBoxException.isEmpty()) {
                for(String excp : UTL_CLM_Box.lstBoxException) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, excp, 'CRM', 'Custom', 'ERROR', excp.substring(0, excp.indexOf('=')), null));
                }
            }
            if(!lstExceptionForBatchFailure.isEmpty()) {
                for(Opportunity opp : lstopp) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, opp.Id, 'CRM', 'Custom', 'ERROR', 'Entire Batch Failure', null));
                }
            }
            try {
                UTL_LogFactory.saveLogs(lstLogForError, false);
            }
            catch(Exception e) {
                System.debug('saveLogs catch E: '+e.getMessage());
                System.debug('saveLogs catch E: '+e.getStackTraceString());
                lstExceptionForLogs.add(UTL_CLM.concatenateException(e));
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        List<String> toAddress = new List<String>{job.CreatedBy.Email};    
            String subject = 'The apex job status for BCH_CRM_BoxMigration is '+job.Status;
        String body = (lstException.isEmpty()) ? 'Box Migration Successful' : 'Box Migration Failed'; 
        if(lstException != null && lstException.size() > 0) {
            body += '=====Exception=====<br/>';
            for(String str : lstException) {
                body += str+'<br/>';
            }
        }
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