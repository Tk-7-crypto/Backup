/*
* Version       : 1.0
* Name          : SCH_OWF_CommonSchedule
* Description   : This is a Common scheduler class for executing all OWF and DSSR Batch jobs
*/
global class SCH_OWF_CommonSchedule implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        DateTime batchExecutionTime = datetime.now();
        Integer batchExecutionHour = batchExecutionTime.hour();
        Integer batchExecutionDay = batchExecutionTime.day();
        Integer batchExecutionMinute = batchExecutionTime.minute();
        String day_of_week= DateTime.now().format('E');
        //System.debug(batchExecutionHour + '::' + batchExecutionMinute + '::' + day_of_week);
        String userName= userinfo.getName();
        System.debug(userName);
        if((batchExecutionHour == 1 || Test.isRunningTest())&& userName=='OWF Notification User'){
            OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_Generate_Triage_Users_Report);
            Integer batchSize;
            if(batchConfig != null && batchConfig.Batch_Size__c != null)
                batchSize = (Integer)batchConfig.Batch_Size__c;
            else
                batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
            BCH_OWF_Generate_Triage_Users_Report batch = new BCH_OWF_Generate_Triage_Users_Report();
            batch.batchMod = 'PSASET';
            CON_OWF.runFutureJob = false;
            database.executeBatch(batch, batchSize);
        }
        
        
        if((batchExecutionHour == 13 || Test.isRunningTest()) && userName=='OWF Notification User'){
            OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_Generate_Triage_Users_Report);
            Integer batchSize;
            if(batchConfig != null && batchConfig.Batch_Size__c != null)
                batchSize = (Integer)batchConfig.Batch_Size__c;
            else
                batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
            BCH_OWF_Generate_Triage_Users_Report batch = new BCH_OWF_Generate_Triage_Users_Report();
            batch.batchMod = 'PSARESET';
            CON_OWF.runFutureJob = false;
            database.executeBatch(batch, batchSize);
        }
        
        if((batchExecutionHour == 21 || Test.isRunningTest()) && userName=='OWF Notification User' ){
            OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_Generate_Triage_Users_Report);
            Integer batchSize;
            if(batchConfig != null && batchConfig.Batch_Size__c != null)
                batchSize = (Integer)batchConfig.Batch_Size__c;
            else
                batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
            BCH_OWF_Generate_Triage_Users_Report batch = new BCH_OWF_Generate_Triage_Users_Report();
            batch.batchMod = 'LICENCERESET';
            CON_OWF.runFutureJob = false;
            database.executeBatch(batch, batchSize);
        }
        
        if((batchExecutionHour == 9 || Test.isRunningTest()) && userName=='OWF Notification User' ){
            OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_Generate_Triage_Users_Report);
            Integer batchSize;
            if(batchConfig != null && batchConfig.Batch_Size__c != null)
                batchSize = (Integer)batchConfig.Batch_Size__c;
            else
                batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
            BCH_OWF_Generate_Triage_Users_Report batch = new BCH_OWF_Generate_Triage_Users_Report();
            batch.batchMod = 'LICENCESET';
            CON_OWF.runFutureJob = false;
            database.executeBatch(batch, batchSize);
        }
        
        if(batchExecutionHour == 14 && (day_of_week.toUpperCase()=='MON' || day_of_week.toUpperCase()=='TUE' || day_of_week.toUpperCase()=='WED'|| day_of_week.toUpperCase()=='THU' || day_of_week.toUpperCase()=='FRI') &&  userName=='OWF Notification User')
        {
            OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_ACCEPTUNASSIGNEDASSIGNMENTS);
            Integer batchSize;
            if(batchConfig != null && batchConfig.Batch_Size__c != null)
                batchSize = (Integer)batchConfig.Batch_Size__c;
            else
                batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
            BCH_OWF_AcceptUnassignedAssignments batch = new BCH_OWF_AcceptUnassignedAssignments();
            database.executeBatch(batch, batchSize);
            
        }
        
        if((batchExecutionHour == 3 || Test.isRunningTest()) && userName=='OWF Notification User' )
        {
            OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_UPDATERESOURCEREQUESTSTATUS);
            Integer batchSize;
            if(batchConfig != null && batchConfig.Batch_Size__c != null)
                batchSize = (Integer)batchConfig.Batch_Size__c;
            else
                batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
            BCH_OWF_UpdateResourceRequestStatus batch = new BCH_OWF_UpdateResourceRequestStatus();
            database.executeBatch(batch, batchSize);
            
        }
        if((batchExecutionHour == 5 || Test.isRunningTest()) && userName=='PSA Notification User'){
            BCH_PSA_SendEmailsForLR sendEmailForLrBatchable = new BCH_PSA_SendEmailsForLR();
            Database.executebatch(sendEmailForLrBatchable,100);
        }
        if(((batchExecutionDay == 1 && batchExecutionHour == 1)|| Test.isRunningTest()) && userName=='PSA Notification User'){
            BCH_PSA_Send_Monthly_LR_Metric_Mails metricMailsBatchable = new BCH_PSA_Send_Monthly_LR_Metric_Mails();
            Database.executebatch(metricMailsBatchable,100);
        }
        
        if((batchExecutionHour == 3 || Test.isRunningTest()) && userName=='PSA Notification User'){
            BCH_PSA_Send_Mails_Annual_Srch_Strategy sendMailsAnnualSSBatchable = new BCH_PSA_Send_Mails_Annual_Srch_Strategy();
            Database.executebatch(sendMailsAnnualSSBatchable,100);
        }
        
        if(( batchExecutionHour == 7 || Test.isRunningTest()) && userName=='PSA Notification User'){
            BCH_PSA_UPDT_ACCNT_ON_LR updateAccountLRsBatchable = new BCH_PSA_UPDT_ACCNT_ON_LR();
            Database.executebatch(updateAccountLRsBatchable,100);
        }
		
        if(Test.isRunningTest() && userName=='PSA Notification User'){
            BCH_PSA_Send_Mail_Updtd_LR_Metrics sendMailsUpdtdLRBatchable = new BCH_PSA_Send_Mail_Updtd_LR_Metrics();
            Database.executebatch(sendMailsUpdtdLRBatchable,100);
        }
        
    }
}
