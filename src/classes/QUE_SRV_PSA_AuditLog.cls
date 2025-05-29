public class QUE_SRV_PSA_AuditLog implements Queueable {
    private final SRV_PSA_AuditLog.AuditLogWrapper[] auditLogWrappers;
    private Integer cursor;
    public static final Integer SIZE_LIMIT = 5000;
    public static final Integer QUEUE_LIMIT = 20000;
    @TestVisible Boolean allOrNone = true; // audit log insert dml option
    
    public QUE_SRV_PSA_AuditLog(List<SRV_PSA_AuditLog.AuditLogWrapper> wrapperList) {
        this(wrapperList,0);
    }

    public QUE_SRV_PSA_AuditLog(List<SRV_PSA_AuditLog.AuditLogWrapper> wrapperList, Integer startAt) {
        if( wrapperList.size() > QUEUE_LIMIT){
            LimitException e  = new LimitException();
            e.setMessage('Hit Audit Queue Limit of '+QUEUE_LIMIT+' with an input of '+wrapperList.size()+'. Please break this up and create multiple queues.');
            throw e;
        }
        this.cursor = startAt; 
        this.auditLogWrappers = wrapperList;
        System.debug('@@ QUE_SRV_PSA_AuditLog constructor starting cursor position ' + this.cursor+' ('+startAt+')');
        System.debug('@@ QUE_SRV_PSA_AuditLog constructor (wrapperList.size())' + wrapperList.size());
    }
    
    public void execute(QueueableContext context) {
        this.insertAuditLogs(auditLogWrappers);
    }
        /*
* save to custom audit log object
*/
    public void insertAuditLogs (SRV_PSA_AuditLog.AuditLogWrapper[] auditLogWrappers) {
        System.debug('@@ QUE_SRV_PSA_AuditLog.insertAuditLogs starting processing with index '+this.cursor);
        // build sobjects from wrapper!
        Audit_Log__c[] auditLogsToSave = new Audit_Log__c[]{};
        SRV_PSA_AuditLog.AuditLogWrapper logWrapper;
        Integer wrapperSize;
        Integer counter;
        for( counter = 0, wrapperSize = auditLogWrappers.size(); this.cursor < wrapperSize && counter < SIZE_LIMIT; counter++) {
            logWrapper = auditLogWrappers[this.cursor];
            DateTime rightNow = System.now();
            Audit_Log__c auditlog = new Audit_Log__c(
                Record_ID__c = logWrapper.recordId.left(18),
                Operation__c = logWrapper.operation,
                Field__c = logWrapper.field,
                Time__c = logWrapper.logTime,
                Object__c  = logWrapper.logObject,
                Transaction_Key__c = logWrapper.transactionKey,
                Replay_ID__c = logWrapper.replayId,
                User__c = logWrapper.userId
            );
            // if (logWrapper.priorValue != null) {
            //   auditlog.Prior_Value__c = JSON.serialize(logWrapper.priorValue);
            // }
            if (logWrapper.newValue != null) {
                // auditlog.New_Value__c = JSON.serialize(logWrapper.newValue);
                auditlog.New_Value__c = logWrapper.newValue;
            }
            if(logWrapper.operation == 'DELETE' && !SRV_PSA_AuditLog.ignoreObjs.contains(logWrapper.logObject)) {
                auditlog.Reason_for_Deletion__c = logWrapper.reasonForDeletion;
            } else if(logWrapper.operation == 'DELETE' && SRV_PSA_AuditLog.ignoreObjs.contains(logWrapper.logObject)){
                auditlog.Reason_for_Deletion__c = '';
            }
            
            auditLogsToSave.add(auditlog);
            this.cursor++;
        }
        
        System.debug('@@ QUE_SRV_PSA_AuditLog.insertAuditLogs (auditLogsToSave.size())' + auditLogsToSave.size());
        
        if (auditLogsToSave != null && auditLogsToSave.size() > 0) {
            // now save it!
            saveAuditLogSObjects(auditLogsToSave);
        }
        
        //If we have leftovers that didn't fit, we chain another queue and pass the current position
        if (this.cursor + 1 < wrapperSize){
        System.debug('@@ QUE_SRV_PSA_AuditLog.insertAuditLogs found more wrappers to process after index '+this.cursor+', starting new queue');
            System.enqueueJob(new QUE_SRV_PSA_AuditLog(auditLogWrappers,this.cursor));
        }
        // // RAISE A LIMIT EXCEPTION TO TEST BATCH APEX ERROR EVENT!
        // LimitException e  = new LimitException();
        // e.setMessage('TESTING. This is a constructed LimitException! Catch It If You Can!');
        // throw e;
        
    }
    
    @TestVisible
    private void saveAuditLogSObjects(Audit_Log__c[] auditLogsToSave) {
        if (auditLogsToSave != null  && auditLogsToSave.size() > 0) {
            Database.SaveResult[] srList = Database.insert(auditLogsToSave, allOrNone);
            // check for errors and log messages
            appirio_core__App_Log__c[] errorLogs = new appirio_core__App_Log__c[]{};
                for (Integer i=0; i< srList.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    if (!sr.isSuccess()) {
                        String[] errors = new String[]{};
                            for(Database.Error err : sr.getErrors()) {
                                errors.add(err.getMessage());
                            }
                        String errMsg =  String.join(errors, ',');
                        String errData = JSON.serialize(auditLogsToSave[i]);
                        String origin = SRV_PSA_AuditLog.APP_LOG_ORIGIN;
                        appirio_core__App_Log__c appLog = UTL_PSA_AppLog.writeLog(origin, UTL_PSA_AppLog.APP_LOG_ERROR_LEVEL, errMsg, errData, false);
                        
                        errorLogs.add(appLog);
                    }
                }
            if (errorLogs.size() > 0) {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { appirio_core__App_Log__c.SObjectType });
                uow.registerNew(errorLogs);
                uow.commitWork();
            }
        }
    }
    
}