public class SCH_BCH_PSA_UPDT_ACCNT_ON_LR implements Schedulable{

        /**
     * execute method 
     * @params SchedulableContext context
     * @return void
     */
    public void execute(SchedulableContext sc) {
        BCH_PSA_UPDT_ACCNT_ON_LR batchToRun = new BCH_PSA_UPDT_ACCNT_ON_LR();
        Database.executeBatch(batchToRun);
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_BCH_PSA_UPDT_ACCNT_ON_LR scheduler = new SCH_BCH_PSA_UPDT_ACCNT_ON_LR();
        System.schedule(jobName, cronExp, scheduler);
    }
}