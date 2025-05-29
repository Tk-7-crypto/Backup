public class SCH_BCH_PSA_ANNUAL_SS_EMAILS implements Schedulable{

    /**
     * execute method 
     * @params SchedulableContext context
     * @return void
     */
    public void execute(SchedulableContext sc) {
        BCH_PSA_Send_Mails_Annual_Srch_Strategy batchToRun = new BCH_PSA_Send_Mails_Annual_Srch_Strategy();
        Database.executeBatch(batchToRun);
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_BCH_PSA_ANNUAL_SS_EMAILS scheduler = new SCH_BCH_PSA_ANNUAL_SS_EMAILS();
        System.schedule(jobName, cronExp, scheduler);
    }
}