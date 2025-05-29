/*
 * Version       : 1.0
 * Description   : This batch is used to monitor the cdc process in PSA.
                   It will run every hour to check if the audit logs have been created for the transaction
                   on the 4 objects for which CDC is enabled:
                   Project Task, Aggregate Report, Target, Project Log.*/
 
global class BCH_PSA_CDCHealthCheckup implements Database.Batchable<String> , Database.Stateful{
  
    @TestVisible boolean isCDCHealthFine;    
    /**
     * Constructor
     */
    public BCH_PSA_CDCHealthCheckup() {
        isCDCHealthFine = true;
    }
    
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public Iterable<String> start(Database.BatchableContext context) {    
        return new List<String> { 'pse__Project_Task__c', 'Aggregate_Report__c', 'Target__c','Project_Log__c'}; 
    }
    
    global void execute(Database.BatchableContext context, List<String> sObjectNameList) {
    
        List<AsyncApexJob> cdcMonitorJobList = [SELECT id, CreatedDate, CompletedDate 
                                      FROM AsyncApexJob 
                                      WHERE ApexClass.name = 'BCH_PSA_CDCHealthCheckup' and CompletedDate != NULL
                                      ORDER BY CompletedDate desc limit 1]; 
        DateTime lastBatchCompletionDate;
        if(cdcMonitorJobList != null && cdcMonitorJobList.size() > 0) {
            lastBatchCompletionDate = cdcMonitorJobList[0].CompletedDate;
        }                             
        else {
            lastBatchCompletionDate = DateTime.now().addHours(-1);
        }                                                          
        PSA_RDS_Settings__c rdsSetting = PSA_RDS_Settings__c.getInstance();
        Decimal noOfARFields =0, noOfPTFields=0, noOfPLFields=0, noOfTargetFields=0;
        if(rdsSetting != null) {
            noOfARFields = rdsSetting.Total_Fields_of_Aggregate_Report__c;
            noOfPTFields = rdsSetting.Total_Fields_of_Project_Task__c;
            noOfPLFields = rdsSetting.Total_Fields_of_Project_Log__c;
            noOfTargetFields = rdsSetting.Total_Fields_of_Target__c;            
        }                              
        Integer totalProjectTasksModified = [SELECT count()
                                             FROM pse__Project_Task__c
                                             WHERE lastmodifieddate >: lastBatchCompletionDate];
                                                      
        Integer totalProjectTasksCreated = [SELECT count()
                                             FROM pse__Project_Task__c
                                             WHERE createddate >: lastBatchCompletionDate];  
                                                                                        
        Integer actualPTModified = ((totalProjectTasksModified - totalProjectTasksCreated) > 0) ? (totalProjectTasksModified - totalProjectTasksCreated): 0;
                                                     
        Integer totalAggregateReportsModified = [SELECT count()
                                                 FROM Aggregate_Report__c
                                                 WHERE lastmodifieddate >: lastBatchCompletionDate];
                                                     
        Integer totalAggregateReportsCreated = [SELECT count()
                                                 FROM Aggregate_Report__c
                                                 WHERE createddate >: lastBatchCompletionDate];   
                                                                                           
        Integer actualARModified = ((totalAggregateReportsModified - totalAggregateReportsCreated) > 0) ? (totalAggregateReportsModified - totalAggregateReportsCreated): 0;
                                                     
        Integer totalProjectLogsModified = [SELECT count()
                                        FROM Project_Log__c
                                        WHERE lastmodifieddate >: lastBatchCompletionDate];
                                               
        Integer totalProjectLogsCreated = [SELECT count()
                                        FROM Project_Log__c
                                        WHERE createddate >: lastBatchCompletionDate];          
                                        
        Integer actualPLModified = ((totalProjectLogsModified - totalProjectLogsCreated) > 0) ? (totalProjectLogsModified - totalProjectLogsCreated): 0;                                                             
                                               
        Integer totalTargetsModified = [SELECT count()
                                        FROM Target__c
                                        WHERE lastmodifieddate >: lastBatchCompletionDate];
                                               
        Integer totalTargetsCreated = [SELECT count()
                                        FROM Target__c
                                        WHERE createddate >: lastBatchCompletionDate];       
                                        
        Integer actualTModified = ((totalTargetsModified - totalTargetsCreated) > 0) ? (totalTargetsModified - totalTargetsCreated): 0;                                                                
                                             
        Integer totalAuditLogsCreatedForUpdateCase = [SELECT count()
                                         FROM Audit_Log__c
                                         WHERE createddate >: lastBatchCompletionDate
                                         AND Object__c in ('pse__Project_Task__c','Aggregate_Report__c','Project_Log__c','Target__c')
                                         AND Operation__c = 'UPDATE'];

        Integer totalAuditLogsCreatedForCreationCase = [SELECT count()
                                         FROM Audit_Log__c
                                         WHERE createddate >: lastBatchCompletionDate
                                         AND Object__c in ('pse__Project_Task__c','Aggregate_Report__c','Project_Log__c','Target__c')
                                         AND Operation__c = 'INSERT'];
        
        Decimal totalAuditLogsExpectedForCreationCase;
        if(rdsSetting != null) {                                 
            totalAuditLogsExpectedForCreationCase = ( (noOfPTFields*totalProjectTasksCreated) + (noOfARFields*totalAggregateReportsCreated) 
                                         + (noOfPLFields*totalProjectLogsCreated) + (noOfTargetFields*totalTargetsCreated) );
        }                                 
                                         
        Integer minimumAuditLogsExpectedForUpdateCase = 2* (actualPTModified + 
                                                            actualARModified + 
                                                            actualPLModified + 
                                                            actualTModified);  
        
        system.debug('actualPTModified: '+actualPTModified+
                     '\n actualARModified: '+actualARModified+
                     '\n actualPLModified: '+actualPLModified+
                     '\n actualTModified: '+actualTModified); 
        system.debug('totalProjectTasksCreated: '+totalProjectTasksCreated+
                     '\n totalAggregateReportsCreated: '+totalAggregateReportsCreated+
                     '\n totalProjectLogsCreated: '+totalProjectLogsCreated+
                     '\n totalTargetsCreated: '+totalTargetsCreated);
        system.debug('totalAuditLogsCreatedForUpdateCase: '+totalAuditLogsCreatedForUpdateCase+'\n minimumAuditLogsExpectedForUpdateCase: '+minimumAuditLogsExpectedForUpdateCase
                      +'\n totalAuditLogsCreatedForCreationCase: '+totalAuditLogsCreatedForCreationCase
                      +'\n totalAuditLogsExpectedForCreationCase: '+totalAuditLogsExpectedForCreationCase);                                                                                            
                                     
        if(totalAuditLogsCreatedForUpdateCase < minimumAuditLogsExpectedForUpdateCase 
        || totalAuditLogsCreatedForCreationCase < totalAuditLogsExpectedForCreationCase) {
            isCDCHealthFine = false;
        }   
        
    }
    
    /**
     * finish method 
     * @params  Database.BatchableContext context
     */
    public void finish(Database.BatchableContext context) {
        if (!isCDCHealthFine){
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            PSA_RDS_Settings__c rdsSetting = PSA_RDS_Settings__c.getInstance();
            List<String> userIdList = new List<String>();
            if(rdsSetting != null && rdsSetting.User_Ids__c != null && rdsSetting.User_Ids__c != '')
                userIdList = rdsSetting.User_Ids__c.split(',');
            else
                userIdList.add(userInfo.getUserId());
            
            Messaging.SingleEmailMessage mail;
            for (Id userId : userIdList){
                mail = new Messaging.SingleEmailMessage();
                mail.setSubject('**IQVIA-PSA: Need to review CDC process**'); 
                mail.setPlainTextBody('Hi,\n\n The number of audit logs created in the last hour are less than the expected number.\n\n Please review.\n\nThanks.');  
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(userId);
                emailList.add(mail);
            }
            Messaging.sendEmail(emailList);
        }
    }
}