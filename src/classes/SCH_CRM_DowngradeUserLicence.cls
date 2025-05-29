/*
 * Version       : 1.0
 * Description   : This Scheduler Class for DowngradeUserLicence
 */
public class SCH_CRM_DowngradeUserLicence implements Schedulable {

    /**
     * execute method 
     * @params  SchedulableContext context
     * @return  void
     */
    public void execute(SchedulableContext sc) {
        User_Downgrade_Setting__c userDownCs = User_Downgrade_Setting__c.getInstance();
        if (userDownCs != null && userDownCs.Batch_Size__c != null) {
            BCH_CRM_DowngradeUserLicence batchdowngradeUserLicence = new BCH_CRM_DowngradeUserLicence();
            Database.executeBatch(batchdowngradeUserLicence, Integer.valueOf(userDownCs.Batch_Size__c));   
        }
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_CRM_DowngradeUserLicence scheduler = new SCH_CRM_DowngradeUserLicence();
        System.schedule(jobName, cronExp, scheduler);
    }
}