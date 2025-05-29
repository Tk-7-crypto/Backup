/** 
* Batch Class for the migration of folders and files of Box from Contract to Quote object 
*/  
global class BCH_CLM_BoxMigrationToQuote implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global String query;
    global List<String> lstException;
    global List<String> lstExceptionForLogs;
    
    global BCH_CLM_BoxMigrationToQuote(String query) {
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
        Map<Id, Quote> mapContractIdWithQuote = new Map<Id, Quote>();  
        List<box__FRUP__c> frupListForQuote = new List<box__FRUP__c>(); 
        List<Quote> lstQuote = new List<Quote>();
        box__Folder_Details__c boxFolderDetails = box__Folder_Details__c.getValues(CON_CLM.QUOTES);
        List<Log_History__c> lstLogForInfo = new List<Log_History__c>();
        List<Log_History__c> lstLogForError = new List<Log_History__c>();
        List<String> lstExceptionForBatchFailure = new List<String>();
        try {
            for(Contract contract : lstContract) {
                currentContractIdSet.add(contract.Id);
            }
            if(currentContractIdSet != null && currentContractIdSet.size() > 0 ) {
                String condition = 'Is_This_A_Migrated_Contract_Record__c = true AND Box_Migration_Status__c !=\''+CON_CLM.MIGRATION_COMPLETED +
                    +'\' AND ContractId IN: IdSet';
                List<Quote> lstQuoteByContractId = new SLT_Quote().getQuotesByCondition(new Set<String>
                    {'Id', 'Name', 'ContractId', 'Box_Migration_Status__c', 'Account.Name', 'Project_Number__c', 'QuoteNumber'},
                    condition, currentContractIdSet);   
                if(!lstQuoteByContractId.isEmpty()) {
                    for(Quote quote : lstQuoteByContractId) {
                        if(quote.ContractId != null) {
                            mapContractIdWithQuote.put(quote.ContractId, quote);
                        }
                    }
                }     
                String conditionForFRUP = 'box__Record_ID__c IN: boxRecordIds';
                List<box__FRUP__c> frupList = new SLT_FRUP().getFRUPRecordsByBoxRecordId(currentContractIdSet, new Set<String>
                    {'box__Folder_ID__c', 'box__Record_ID__c'}, conditionForFRUP);
                for(box__FRUP__c frupRecord : frupList) {
                    if(!existingFolderId.contains(frupRecord.box__Folder_ID__c) 
                        && mapContractIdWithQuote.containsKey(frupRecord.box__Record_ID__c)) {
                        Quote quote = mapContractIdWithQuote.get(frupRecord.box__Record_ID__c);     
                        String folderName = quote.Account.Name + (quote.Project_Number__c != null ? ' '+ quote.Project_Number__c:'') + ' '+quote.QuoteNumber;
                        folderCreatedId = UTL_CLM_Box.copyAllFoldersAndFilesFromContractToAgreement(frupRecord.box__Folder_ID__c, 
                            boxFolderDetails.box__FolderId__c, folderName);
                        if(String.isNotBlank(folderCreatedId)) {  
                            box__FRUP__c newFrupRecord = new box__FRUP__c();
                            newFrupRecord.box__Object_Name__c = 'Quote';
                            newFrupRecord.box__Folder_ID__c = folderCreatedId;
                            newFrupRecord.box__Record_ID__c =  quote.Id;
                            frupListForQuote.add(newFrupRecord);  
                            quote.Box_Migration_Status__c = CON_CLM.MIGRATION_COMPLETED;
                            lstQuote.add(quote);
                            lstLogForInfo.add(UTL_LogFactory.generateAndCommitLog(false, false, null, frupRecord.box__Folder_ID__c, 'CLM',
                                'Custom', 'INFO', folderCreatedId, quote.Id));
                        }
                        existingFolderId.add(frupRecord.box__Folder_ID__c);
                    }
                }
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {box__FRUP__c.SObjectType, Quote.SObjectType, Log_History__c.SObjectType}
                );
                if(!lstQuote.isEmpty() && !frupListForQuote.isEmpty() && !lstLogForInfo.isEmpty()) {
                    uow.registerDirty(lstQuote);
                    uow.registerNew(frupListForQuote);
                    uow.registerNew(lstLogForInfo);
                    uow.commitWork();
                }
            }
        }
        catch(Exception e) {
            lstException.add(UTL_CLM.concatenateException(e));
            lstExceptionForBatchFailure.add(UTL_CLM.concatenateException(e)); 
            if(!frupListForQuote.isEmpty()) {
                System.enqueueJob(new QUE_CLM_BoxMigration(frupListForQuote));
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
                for(Quote quote : lstQuote) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, quote.Id, 'CLM', 'Custom', 
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
        String subject = 'The apex job status for BCH_CLM_BoxMigrationToQuote is '+job.Status;
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