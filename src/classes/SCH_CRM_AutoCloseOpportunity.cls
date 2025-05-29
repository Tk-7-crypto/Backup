/*
 * Version       : 1.0
 * Description   : This Scheduler Class for BCH_CRM_AutoCloseOpportunity
 */
public class SCH_CRM_AutoCloseOpportunity implements Schedulable{

    /**
     * execute method 
     * @params  SchedulableContext context
     * @return  void
     */
    public void execute(SchedulableContext SC) {
        BCH_CRM_AutoCloseOpportunity batchAutoCloseOpportunity = new BCH_CRM_AutoCloseOpportunity();
        Database.executeBatch(batchAutoCloseOpportunity);
    }
    
    public static void scheduleJob(String jobName, String cron_exp){
        SCH_CRM_AutoCloseOpportunity scheduler = new SCH_CRM_AutoCloseOpportunity();
        System.schedule(jobName, cron_exp, scheduler);
    }
}