/*
 * Version       : 1.0
 * Description   : This Scheduler Class for BCH_CRM_UnsignedContractAlert
 */
global class SCH_CRM_UnsignedContractAlert implements Schedulable {
    
    /**
     * execute method 
     * @params  SchedulableContext context
     * @return  void
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BCH_CRM_Unsigned_Contract_Alert());
    }
}