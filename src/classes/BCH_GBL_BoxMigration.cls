/****
 * Batch Class for the migration of folders and files of Box from Source to Destination object
 * @Param String query : query for destination records for which the Box folders and files should be cloned from Source object records
 * @Param String destFolderNameInCustomSetting : The name for destination object from which the box__Folder_Details__c Custom setting contain the record
 * @Param String destinationObjectName : API Name for destination object
 * @Param String logModule : Module name  
 * @Param List<String> destinationfolderNameKeyFields : Field API names which are used to create folder name for detination
 * @Param Map<String, String> destiationFieldToValueMapToUpdate : Contains Field API Name as Key and field value as Value of Map for the destination object record which should be updated 
 * @Param String sourceIdInDestinationFieldName : The Field API name in destination object which contains the ID of corresponding source object record
****/
global class BCH_GBL_BoxMigration implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global String query;
    global String destFolderNameInCustomSetting;
    global String destinationObjectName;
    global List<String> lstException;
    global List<String> lstExceptionForLogs;
    global String logModule;
    global List<String> destinationfolderNameKeyFields;
    global Map<String, String> destiationFieldToValueMapToUpdate;
    global Map<String, Boolean> destiationFieldToValueMapToUpdateBool;
    global String sourceIdInDestinationFieldName;
    global List<String> successFailureEmailRecieverList;
    global Set<Id> recordIdSet;
    
    global BCH_GBL_BoxMigration(String query, String destFolderNameInCustomSetting, String destinationObjectName, String logModule, 
                                List<String> destinationfolderNameKeyFields, Map<String, String> destiationFieldToValueMapToUpdate,
                               Map<String, Boolean> destiationFieldToValueMapToUpdateBool, String sourceIdInDestinationFieldName,
                                List<String> successFailureEmailRecieverList, Set<Id> recordIdSet){
        this.query = query;
        this.destinationObjectName = destinationObjectName;
        this.destFolderNameInCustomSetting = destFolderNameInCustomSetting;
        this.logModule = logModule;
        this.destinationfolderNameKeyFields = destinationfolderNameKeyFields;
        this.destiationFieldToValueMapToUpdate = destiationFieldToValueMapToUpdate;
        this.destiationFieldToValueMapToUpdateBool = destiationFieldToValueMapToUpdateBool;
        this.sourceIdInDestinationFieldName = sourceIdInDestinationFieldName;
        this.successFailureEmailRecieverList = successFailureEmailRecieverList;
        this.recordIdSet = recordIdSet;
        lstException = new List<String>();
        lstExceptionForLogs = new List<String>();                          
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> lstDestinationRecords){
        String folderCreatedId = null;
        Set<String> existingFolderId = new Set<String>();
        Map<Id, SObject> mapSourceIdWithDestination = new Map<Id, SObject>();
        List<box__FRUP__c> frupListForDestination = new List<box__FRUP__c>(); 
        List<SObject> lstDestinationToUpdate = new List<SObject>();
        String destinationFolderId = '';
        if(box__Folder_Details__c.getValues(destFolderNameInCustomSetting) != null){
            destinationFolderId = box__Folder_Details__c.getValues(destFolderNameInCustomSetting).box__FolderId__c;
        }
        System.debug('destinationFolderId:'+destinationFolderId);
        List<Log_History__c> lstLogForInfo = new List<Log_History__c>();
        List<Log_History__c> lstLogForError = new List<Log_History__c>();
        
        try{
            for(SObject destinationRecord : lstDestinationRecords){
                Id sourceRecordId = (Id)destinationRecord.get(sourceIdInDestinationFieldName);
                System.debug('sourceRecordId:'+sourceRecordId);
                if(sourceRecordId != null){
                    mapSourceIdWithDestination.put(sourceRecordId, destinationRecord);
                }
            }
            if(mapSourceIdWithDestination.size() > 0){
                String conditionForFRUP = 'box__Record_ID__c IN: boxRecordIds';
                List<box__FRUP__c> frupList = new SLT_FRUP().getFRUPRecordsByBoxRecordId(mapSourceIdWithDestination.keySet(), new Set<String>
                            {'box__Folder_ID__c', 'box__Record_ID__c'}, conditionForFRUP);
                for(box__FRUP__c frupRecord : frupList) {
                    if(!existingFolderId.contains(frupRecord.box__Folder_ID__c) 
                       && mapSourceIdWithDestination.containsKey(frupRecord.box__Record_ID__c)) {
                           SObject destinationRecord = mapSourceIdWithDestination.get(frupRecord.box__Record_ID__c);     
                           String folderName;
                           if(destinationfolderNameKeyFields != null){
                               folderName = '';
                               for(String fieldName : destinationfolderNameKeyFields){
                                   folderName = folderName + destinationRecord.get(fieldName) + '-';
                               }
                               folderName = folderName.removeEnd('-');
                           }
                           folderCreatedId = UTL_Box.copyAllFoldersAndFilesFromSourceToDestination(frupRecord.box__Folder_ID__c, 
                                    destinationFolderId, folderName);
                           if(String.isNotBlank(folderCreatedId)) {
                               box__FRUP__c newFrupRecord = new box__FRUP__c();
                               newFrupRecord.box__Object_Name__c = destinationObjectName;
                               newFrupRecord.box__Folder_ID__c = folderCreatedId;
                               newFrupRecord.box__Record_ID__c =  destinationRecord.Id;
                               frupListForDestination.add(newFrupRecord);
                               if(destiationFieldToValueMapToUpdate != null){
                                   for(String fieldName : destiationFieldToValueMapToUpdate.keySet()){
                                       destinationRecord.put(fieldName, destiationFieldToValueMapToUpdate.get(fieldName));
                                   }
                               }
                               if(destiationFieldToValueMapToUpdateBool != null){
                                   for(String fieldName : destiationFieldToValueMapToUpdateBool.keySet()){
                                       destinationRecord.put(fieldName, destiationFieldToValueMapToUpdateBool.get(fieldName));
                                   }
                               }
                               if(destiationFieldToValueMapToUpdate != null || destiationFieldToValueMapToUpdateBool != null){
                                   lstDestinationToUpdate.add(destinationRecord);
                               }
                               lstLogForInfo.add(UTL_LogFactory.generateAndCommitLog(false, false, null, 'Source Folder Id '+frupRecord.box__Folder_ID__c,
                                                                                     logModule,'Custom', 'INFO', 'Folder Created '+folderCreatedId,
                                                                                     destinationRecord.Id));
                               System.debug('Log : '+lstLogForInfo);
                           }
                           existingFolderId.add(frupRecord.box__Folder_ID__c);
                       }
                  }
                if(destiationFieldToValueMapToUpdate != null || destiationFieldToValueMapToUpdateBool != null){
                  fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                  new List<SObjectType> {box__FRUP__c.SObjectType,  Schema.getGlobalDescribe().get(destinationObjectName), Log_History__c.SObjectType}
                  );
                  if(!lstDestinationToUpdate.isEmpty() && !frupListForDestination.isEmpty() && !lstLogForInfo.isEmpty()) {
               		  uow.registerDirty(lstDestinationToUpdate);
                      uow.registerNew(frupListForDestination);
                      uow.registerNew(lstLogForInfo);
                      uow.commitWork();
                 }
                } else {
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                  new List<SObjectType> {box__FRUP__c.SObjectType, Log_History__c.SObjectType}
                  );
                  if(!frupListForDestination.isEmpty() && !lstLogForInfo.isEmpty()) {
               		  uow.registerNew(frupListForDestination);
                      System.debug('Log in update : '+lstLogForInfo);
                      uow.registerNew(lstLogForInfo);
                      uow.commitWork();
                }
                }
             }
         }
         Catch(Exception e){
             System.debug('Exception');
            lstException.add(UTL_GLOBAL.concatenateException(e));
            if(!frupListForDestination.isEmpty()) {
                System.enqueueJob(new QUE_GBL_BoxMigration(frupListForDestination));
            }
        }
        finally{
            if(!UTL_Box.lstBoxException.isEmpty()) {
                for(String excp : UTL_Box.lstBoxException) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, excp, logModule, 'Custom', 
                        'ERROR', excp.substring(0, excp.indexOf(':')), null));
                }
            }
            if(!lstException.isEmpty()) {
                for(SObject destinationRecord : lstDestinationToUpdate) {
                    lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, lstException[0], logModule, 'Custom', 
                        'ERROR', 'Entire Batch Failure', destinationRecord.Id));  
                }
            }
            if(!lstException.isEmpty() || !UTL_Box.lstBoxException.isEmpty()){
                lstException.addAll(UTL_Box.lstBoxException);
            }
            try {
                UTL_LogFactory.saveLogs(lstLogForError, false);
            }
            catch(Exception e) {
                lstExceptionForLogs.add(UTL_GLOBAL.concatenateException(e));
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        String subject = 'The apex job status for BCH_BoxMigration is '+job.Status;
        String body = (lstException.isEmpty()) ? 'Box Migration Successful' : 'Box Migration Failed with Below errors :'; 
        if(lstException != null && lstException.size() > 0) {
            body += '\n\n';
            for(String str : lstException) {
                body += str+'\n\n';
            }
        }
        if(!lstExceptionForLogs.isEmpty()) {
            body += '\n\n LogException \n\n';
            for(String str : lstExceptionForLogs) {
                body += str+'\n\n';
            }
        }
        UTL_GLOBAL.sendEmail(successFailureEmailRecieverList, subject, body);
    }
}