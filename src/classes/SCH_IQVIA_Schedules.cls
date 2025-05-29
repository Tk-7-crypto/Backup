global class SCH_IQVIA_Schedules implements Schedulable{   
    
    global void execute(SchedulableContext SC) {
        Map<String, String> userIdToErrorMessageMap;
        Map<String,String> ScheduleFailureNotificationMailMap =new Map<String,String>();
        for(Schedule_Failure_Notification_Mail__c ScheduleFailureNotificationMail:[Select Id, User_Ids__c, Module_Name__c from Schedule_Failure_Notification_Mail__c]){
            ScheduleFailureNotificationMailMap.put(ScheduleFailureNotificationMail.Module_Name__c,ScheduleFailureNotificationMail.User_Ids__c);
        }
        
        try{
            String userId= userinfo.getUserId();
            DateTime batchExecutionTime;
            if(Test.isRunningTest()){
                batchExecutionTime = datetime.newInstance(Date.today().year(), 2, 1, 1, 0, 0);
            }
            else{
            	AsyncApexJob asyncJob = [Select CronTrigger.PreviousFireTime,CronTrigger.NextFireTime,Status from AsyncApexJob where ApexClass.Name ='SCH_IQVIA_Schedules' and createdBy.Id =: userId and Status ='Queued' order by CronTrigger.NextFireTime Limit 1];
            	batchExecutionTime = asyncJob.CronTrigger.NextFireTime.addMinutes(CON_GLOBAL.userToScheduleIntervalMap.get(userinfo.getName()));            
            }
            Integer batchExecutionHour = batchExecutionTime.hour();
            Integer batchExecutionYear = batchExecutionTime.year();
            Integer batchExecutionMonth = batchExecutionTime.month();
            Integer batchExecutionDay = batchExecutionTime.day();
            Integer batchExecutionMinute = batchExecutionTime.minute();
            String day_of_week= DateTime.now().format('E');
            
            List<IQVIA_Schedule_Setting__c> scheduleSettingsToBeUpdated = new List<IQVIA_Schedule_Setting__c>();
            List<IQVIA_Schedule_Setting__c> scheduleSettings = [Select  Id, Name, Abort_Current_Batch__c, Abort_Previous_Batch__c, Year_Upto__c, Batch_Name__c, Year__c, Batch_Size__c, Day_of_Month__c, Running_User__c, Month__c, Day_of_Week__c, Every_Minutes_Interval__c, Module_Name__c, Frequency__c, Mode__c, Hour__c, Is_Active__c, Minutes__c, Last_Error_Date__c, Last_Error_Message__c, Last_Processing_Datetime__c from IQVIA_Schedule_Setting__c where Running_User__c =:userId] ;
            
            Set<String> batchesInProgress = new Set<String>();
            Set<String> batchesToBeAborted = new Set<String>();
            Set<String> jobsInProgress = new Set<String>();
            
            for(IQVIA_Schedule_Setting__c scheduleSetting :scheduleSettings){
                if(scheduleSetting.Abort_Current_Batch__c){
                    batchesInProgress.add(scheduleSetting.Batch_Name__c);
                }
                if(scheduleSetting.Abort_Previous_Batch__c){
                    batchesToBeAborted.add(scheduleSetting.Batch_Name__c);
                }
            }
            
            for(AsyncApexJob asyncApexJob:[Select id ,Status, ApexClass.Name, CreatedDate from AsyncApexJob where ApexClass.Name in:batchesInProgress and JobType='BatchApex' and  status in ('Processing', 'Holding', 'Queued', 'Preparing')]){
                jobsInProgress.add(asyncApexJob.ApexClass.Name);
            }
            
            for(AsyncApexJob asyncApexJob:[SELECT Id,CronTrigger.id FROM AsyncapexJob WHERE ApexClass.Name in: batchesToBeAborted AND Status = 'Processing' And JobType = 'BatchApex']){
                System.AbortJob(asyncApexJob.CronTrigger.id);
            }
            
            if(scheduleSettings.size()>0){
                for(IQVIA_Schedule_Setting__c scheduleSetting : scheduleSettings){ 
                    try{
                        if((((scheduleSetting.Minutes__c!=NULL && scheduleSetting.Minutes__c  == batchExecutionMinute && scheduleSetting.Hour__c !=NULL && scheduleSetting.Hour__c == batchExecutionHour)
                             &&(((scheduleSetting.Frequency__c == 'DAILY' || scheduleSetting.Frequency__c == 'WEEKLY') && (scheduleSetting.Day_of_Week__c != NULL && scheduleSetting.Day_of_Week__c.contains(day_of_week.toUpperCase()))) ||
                                (scheduleSetting.Frequency__c == 'YEARLY' && scheduleSetting.Day_of_Month__c != NULL && scheduleSetting.Month__c != NULL && scheduleSetting.Year_Upto__c != NULL && scheduleSetting.Year_Upto__c >= batchExecutionYear && scheduleSetting.Day_of_Month__c == batchExecutionDay && scheduleSetting.Month__c == batchExecutionMonth) ||
                                (scheduleSetting.Frequency__c == 'MONTHLY' && scheduleSetting.Day_of_Month__c != NULL && scheduleSetting.Day_of_Month__c == batchExecutionDay) )) ||
                            (scheduleSetting.Frequency__c.toUpperCase() == 'MINUTES' && scheduleSetting.Every_Minutes_Interval__c != NULL && (scheduleSetting.Last_Processing_Datetime__c == NULL || ((batchExecutionTime.getTime()-scheduleSetting.Last_Processing_Datetime__c.getTime())/60000) >= scheduleSetting.Every_Minutes_Interval__c)
                            ))  
                           && scheduleSetting.Is_Active__c  && (!scheduleSetting.Abort_Current_Batch__c || (scheduleSetting.Abort_Current_Batch__c && (jobsInProgress.isEmpty() || (!jobsInProgress.isEmpty() && jobsInProgress.size()>0 && !jobsInProgress.contains(scheduleSetting.Batch_Name__c))))))
                            
                        {
                            
                            Type BatchName = Type.forName(scheduleSetting.Batch_Name__c); 
                            Database.Batchable<sObject> classInstance = (Database.Batchable<sObject>) BatchName.newInstance();
                            if(scheduleSetting.Mode__c != null){
                                ((BatchMode)classInstance).ExecuteMode(scheduleSetting.Mode__c.split(','));
                            }
                            database.executeBatch(classInstance, Integer.valueOf(scheduleSetting.Batch_Size__c));
                            scheduleSetting.Last_Processing_Datetime__c = batchExecutionTime;
                            scheduleSettingsToBeUpdated.add(scheduleSetting);
                        }
                    }
                    catch(Exception e){
                        if(!ScheduleFailureNotificationMailMap.isEmpty()){
                            scheduleSetting.Last_Error_Date__c = batchExecutionTime;
                            scheduleSettingsToBeUpdated.add(scheduleSetting);
                            scheduleSetting.Last_Error_Message__c = e.getMessage();
                            userIdToErrorMessageMap = new Map<String, String>();
                            userIdToErrorMessageMap.put(ScheduleFailureNotificationMailMap.get(scheduleSetting.Module_Name__c),'Error in Schedule/Batch: '+e.getMessage()); 
                            sendMailOnException(scheduleSetting.Batch_Name__c, userIdToErrorMessageMap, scheduleSetting.Batch_Name__c+': Failed');
                        }
                    }
                    
                }
            }
            if(!scheduleSettingsToBeUpdated.isEmpty()){
                update scheduleSettingsToBeUpdated;
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
            if(!ScheduleFailureNotificationMailMap.isEmpty()){
                userIdToErrorMessageMap = new Map<String, String>();
                userIdToErrorMessageMap.put(ScheduleFailureNotificationMailMap.get(CON_GLOBAL.DEVOPS),'Error in Schedule/Batch: '+e.getMessage()); 
                sendMailOnException('SCH_IQVIA_Schedules', userIdToErrorMessageMap, 'SCH_IQVIA_Schedules : Failed');
            }
        }
    }
    
    public static void sendMailOnException(String batchName, Map<String, String> sObjectIdToErrorMessageMap, String emailSubject) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String errorList = '';
        Integer counter = 0;
        List<String> userIdList = new List<String>();
        for (String k : sObjectIdToErrorMessageMap.keySet() ) {
            userIdList = k.split(',');
            errorList += ++counter+'. '+k+'----> ';
            errorList += sObjectIdToErrorMessageMap.get(k)+'\n\n  ';
        }
        Messaging.SingleEmailMessage mail;
        for (Id userId : userIdList){
            mail = new Messaging.SingleEmailMessage();
            mail.setSubject(emailSubject); 
            mail.setPlainTextBody('Following errors occured during batch process : \n\n'+ errorList);  
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(Id.valueOf(userId));
            emailList.add(mail);
        }
        Messaging.sendEmail(emailList);
    }
    
}