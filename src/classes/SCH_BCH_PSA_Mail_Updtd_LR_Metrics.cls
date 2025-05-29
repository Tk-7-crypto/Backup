public class SCH_BCH_PSA_Mail_Updtd_LR_Metrics implements Schedulable{
    
    /**
     * execute method 
     * @params SchedulableContext context
     * @return void
     */
    public void execute(SchedulableContext sc) {
        BCH_PSA_Send_Mail_Updtd_LR_Metrics batchToRun = new BCH_PSA_Send_Mail_Updtd_LR_Metrics();
        Database.executeBatch(batchToRun);
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_BCH_PSA_Mail_Updtd_LR_Metrics scheduler = new SCH_BCH_PSA_Mail_Updtd_LR_Metrics();
        System.schedule(jobName, cronExp, scheduler);
    }
} 
