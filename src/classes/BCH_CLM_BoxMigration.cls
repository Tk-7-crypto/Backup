/** 
* Batch Class for the migration of folders and files of Box from Contract to Agreement object 
*/  
global class BCH_CLM_BoxMigration implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global String query;
    global List<String> lstException;
    global List<String> lstExceptionForLogs;
    
    global BCH_CLM_BoxMigration(String query) {
        lstException = new List<String>();
        lstExceptionForLogs = new List<String>();
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contract> lstContract) {
        String folderCreatedId = null;
        Set<Id> currentContractIdSet = new Set<Id>(); 
        Set<String> existingFolderId = new Set<String>();
        Map<Id, Apttus__APTS_Agreement__c> mapContractIdWithAgreement = new Map<Id, Apttus__APTS_Agreement__c>();  
        List<box__FRUP__c> frupListForAgreement = new List<box__FRUP__c>(); 
        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        box__Folder_Details__c boxFolderDetails = box__Folder_Details__c.getValues(CON_CLM.AGREEMENTS);
        List<Log_History__c> lstLogForInfo = new List<Log_History__c>();
        List<Log_History__c> lstLogForError = new List<Log_History__c>();
        List<String> lstExceptionForBatchFailure = new List<String>();
        try {
            for(Contract contract : lstContract) {
                currentContractIdSet.add(contract.Id);
            }
            if(currentContractIdSet != null && currentContractIdSet.size() > 0 ) {
                String condition = 'Is_This_A_Migrated_Contract_Record__c = true AND Special_Terms_Included__c !=\''+CON_CLM.MIGRATION_COMPLETED +
                    +'\' AND SFDC_ID_Of_Migrated_Contract__c IN: agreementIds';
                List<Apttus__APTS_Agreement__c> lstAgreementByContractId = new SLT_Agreement().getAgreementListByCondition(new Set<String>
                    {'Id', 'Name', 'Apttus__FF_Agreement_Number__c', 'SFDC_ID_Of_Migrated_Contract__c', 'Special_Terms_Included__c'}, condition, currentContractIdSet);   
                if(!lstAgreementByContractId.isEmpty()) {
                    for(Apttus__APTS_Agreement__c agreement : lstAgreementByContractId) {
                        if(agreement.SFDC_ID_Of_Migrated_Contract__c != null) {
                            mapContractIdWithAgreement.put(agreement.SFDC_ID_Of_Migrated_Contract__c, agreement);
                        }
                    }
                }     
                String conditionForFRUP = 'box__Record_ID__c IN: boxRecordIds';
                List<box__FRUP__c> frupList = new SLT_FRUP().getFRUPRecordsByBoxRecordId(currentContractIdSet, new Set<String>
                    {'box__Folder_ID__c', 'box__Record_ID__c'}, conditionForFRUP);
                for(box__FRUP__c frupRecord : frupList) {
                    if(!existingFolderId.contains(frupRecord.box__Folder_ID__c) 
                        && mapContractIdWithAgreement.containsKey(frupRecord.box__Record_ID__c)) {
                        Apttus__APTS_Agreement__c agreement = mapContractIdWithAgreement.get(frupRecord.box__Record_ID__c);     
                        String folderName = agreement.Name + '-' + agreement.Apttus__FF_Agreement_Number__c; 
                        folderCreatedId = UTL_CLM_Box.copyAllFoldersAndFilesFromContractToAgreement(frupRecord.box__Folder_ID__c, 
                            boxFolderDetails.box__FolderId__c, folderName);
                        if(String.isNotBlank(folderCreatedId)) {  
                            box__FRUP__c newFrupRecord = new box__FRUP__c();
                            newFrupRecord.box__Object_Name__c = 'Apttus__APTS_Agreement__c';
                            newFrupRecord.box__Folder_ID__c = folderCreatedId;
                            newFrupRecord.box__Record_ID__c =  agreement.Id;
                            frupListForAgreement.add(newFrupRecord);
                            agreement.Special_Terms_Included__c = CON_CLM.MIGRATION_COMPLETED;    
                            agreement.Box_Migration_Status__c = CON_CLM.COMPLETED;
                            lstAgreement.add(agreement);
                            lstLogForInfo.add(UTL_LogFactory.generateAndCommitLog(false, false, null, frupRecord.box__Folder_ID__c, 'CLM',
                                'Custom', 'INFO', folderCreatedId, agreement.Id));
                        }
                        existingFolderId.add(frupRecord.box__Folder_ID__c);
                    }
                }
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {box__FRUP__c.SObjectType, Apttus__APTS_Agreement__c.SObjectType, Log_History__c.SObjectType}
                );
                if(!lstAgreement.isEmpty() && !frupListForAgreement.isEmpty() && !lstLogForInfo.isEmpty()) {
                    uow.registerDirty(lstAgreement);
                    uow.registerNew(frupListForAgreement);
                    uow.registerNew(lstLogForInfo);
                    uow.commitWork();
                }
            }
        }
        catch(Exception e) {
            lstException.add(UTL_CLM.concatenateException(e));
            lstExceptionForBatchFailure.add(UTL_CLM.concatenateException(e)); 
            if(!frupListForAgreement.isEmpty()) {
                System.enqueueJob(new QUE_CLM_BoxMigration(frupListForAgreement));
            }
        }
        finally {         
            if(!UTL_CLM_Box.lstBoxException.isEmpty()) {
                for(String excp : UTL_CLM_Box.lstBoxException) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, excp, 'CLM', 'Custom', 
                        'ERROR', excp.substring(0, excp.indexOf('=')), null));
                }
            }
            if(!lstExceptionForBatchFailure.isEmpty()) {
                for(Apttus__APTS_Agreement__c agreement : lstAgreement) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, agreement.Id, 'CLM', 'Custom', 
                        'ERROR', 'Entire Batch Failure', null));  
                }
            }
            try {
                UTL_LogFactory.saveLogs(lstLogForError, false);
            }
            catch(Exception e) {
                lstExceptionForLogs.add(UTL_CLM.concatenateException(e));
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        List<String> toAddress = new List<String>{job.CreatedBy.Email};    
        String subject = 'The apex job status for BCH_CLM_BoxMigration is '+job.Status;
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