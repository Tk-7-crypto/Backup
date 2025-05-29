/*
 * Version       : 1.0
 * Description   : This Scheduler Class for BCH_CRM_UserLicenseExpiry
 */
public class SCH_CRM_UserLicenseExpiry implements Schedulable {

    /**
     * execute method 
     * @params  SchedulableContext context
     * @return  void
     */
    public void execute(SchedulableContext sc) {
        Deactivate_User_Setting__c userDeactivationConfig = Deactivate_User_Setting__c.getValues('Rajeev Kumar');
        if (userDeactivationConfig != null && userDeactivationConfig.Batch_Size__c != null) {
            BCH_CRM_UserLicenseExpiry batchUserLicenseExpiry = new BCH_CRM_UserLicenseExpiry();
            Database.executeBatch(batchUserLicenseExpiry, Integer.valueOf(userDeactivationConfig.Batch_Size__c));   
        }
    }
    
    /**
     * Method to schedule the batch 
     * @params jobName String
     * @params cronExp String
     * @return  void
     */
    public static void scheduleJob(String jobName, String cronExp) {
        SCH_CRM_UserLicenseExpiry scheduler = new SCH_CRM_UserLicenseExpiry();
        System.schedule(jobName, cronExp, scheduler);
    }
}