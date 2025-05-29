public class SCH_BCH_PSA_EmailForLR_DLP_LBI implements Schedulable{

    /**
     * execute method 
     * @params SchedulableContext context
     * @return void
     */
    public void execute(SchedulableContext sc) {
        BCH_PSA_SendEmailsForLR batchToRun = new BCH_PSA_SendEmailsForLR();
        Database.executeBatch(batchToRun);
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_BCH_PSA_EmailForLR_DLP_LBI scheduler = new SCH_BCH_PSA_EmailForLR_DLP_LBI();
        System.schedule(jobName, cronExp, scheduler);
    }
}
