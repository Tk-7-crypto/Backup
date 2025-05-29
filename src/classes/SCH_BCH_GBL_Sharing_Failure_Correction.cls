/*
 * Version       : 1.0
 * Description   : This Scheduler Class for BCH_GBL_Sharing_Failure_Correction
 */
public class SCH_BCH_GBL_Sharing_Failure_Correction implements Schedulable {

    /**
     * execute method 
     * @params SchedulableContext context
     * @return void
     */
    public void execute(SchedulableContext sc) {
        BCH_GBL_Sharing_Failure_Correction batchSharingFailure = new BCH_GBL_Sharing_Failure_Correction();
        Database.executeBatch(batchSharingFailure);
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_BCH_GBL_Sharing_Failure_Correction scheduler = new SCH_BCH_GBL_Sharing_Failure_Correction();
        System.schedule(jobName, cronExp, scheduler);
    }
}