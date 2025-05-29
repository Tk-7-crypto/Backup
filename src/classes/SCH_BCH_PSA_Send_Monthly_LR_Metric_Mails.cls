public class SCH_BCH_PSA_Send_Monthly_LR_Metric_Mails implements Schedulable{

    
    /**
     * execute method 
     * @params SchedulableContext context
     * @return void
     */
    public void execute(SchedulableContext sc) {
        BCH_PSA_Send_Monthly_LR_Metric_Mails batchToRun = new BCH_PSA_Send_Monthly_LR_Metric_Mails();
        Database.executeBatch(batchToRun);
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_BCH_PSA_Send_Monthly_LR_Metric_Mails scheduler = new SCH_BCH_PSA_Send_Monthly_LR_Metric_Mails();
        System.schedule(jobName, cronExp, scheduler);
    }
}
