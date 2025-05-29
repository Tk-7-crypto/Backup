/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-16229
* Purpose      : Scheduler Class of BCH_CRM_sendEmailForOnHoldOpp.
*/
public class SCH_CRM_sendEmailForOnHoldOpp implements Schedulable {
    
    public String query = '';
    
    public SCH_CRM_sendEmailForOnHoldOpp(String customQuery){
        this.query = customQuery;
    }
    
    public SCH_CRM_sendEmailForOnHoldOpp(){
    }
    
    /*
     * @param Query String to Run Batch.
     * Purpose : use only for Test Class
    */
    public void scheduleBatch(String testQuery){
        String CRON_EXP = '00 00 9 ? * *';
        if(Test.isRunningTest()){
            String jobId = System.schedule('SCH_CRM_sendEmailForOnHoldOppV1',CRON_EXP, new SCH_CRM_sendEmailForOnHoldOpp(testQuery));
        }
    }
    
    public void execute(SchedulableContext sc){
        if(query != ''){
            BCH_CRM_sendEmailForOnHoldOpp csb = new BCH_CRM_sendEmailForOnHoldOpp(query);
            Database.executeBatch(csb, 10); 
        }
        else{
            BCH_CRM_sendEmailForOnHoldOpp csb = new BCH_CRM_sendEmailForOnHoldOpp();
            Database.executeBatch(csb, 10); 
        }
            
    }
}