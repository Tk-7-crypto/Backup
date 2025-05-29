/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-17052
* Purpose      : Scheduler Class of BCH_CRM_SendEmailToClosedLostOpportunity.
*/
public class SCH_CRM_SendEmailToClosedOpp implements Schedulable {
    
    public String query = '';
    
    public SCH_CRM_SendEmailToClosedOpp(String customQuery){
        this.query = customQuery;
    }
    
    public SCH_CRM_SendEmailToClosedOpp(){
    }
    
    /*
     * @param Query String to Run Batch.
     * Purpose : use only for Test Class
    */
    public void scheduleBatch(String testQuery){
        String CRON_EXP = '00 00 9 ? * *';
        if(Test.isRunningTest()){
            String jobId = System.schedule('SCH_CRM_SendEmailToClosedOppV1',CRON_EXP, new SCH_CRM_SendEmailToClosedOpp(testQuery));
        }
    }
    
    public void execute(SchedulableContext sc){
        if(query != ''){
            BCH_CRM_SendEmailToClosedOpp csb = new BCH_CRM_SendEmailToClosedOpp(query);
            Database.executeBatch(csb, 10); 
        }
        else{
            BCH_CRM_SendEmailToClosedOpp csb = new BCH_CRM_SendEmailToClosedOpp();
            Database.executeBatch(csb, 10); 
        }
            
    }

}