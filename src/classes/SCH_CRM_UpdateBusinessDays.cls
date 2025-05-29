/*
 * Version       : 1.0
 * Description   : This Scheduler Class for BCH_CRM_UnsignedContractAlert
 */
global class SCH_CRM_UpdateBusinessDays implements Schedulable {
    
    /**
     * execute method 
     * @params  SchedulableContext context
     * @return  void
     */
    global void execute(SchedulableContext sc) {
        Database.executebatch(new BCH_CRM_UpdateBusinessDays());
    }
}