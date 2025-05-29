/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-15872 / ESPSFDCQI-15936
* Purpose      : Scheduler Class of BCH_CRM_sendEmailToOppOwner.
*/
public class SCH_BCH_CRM_sendEmailToOppOwner implements Schedulable{
    public String query = '';
    
    public SCH_BCH_CRM_sendEmailToOppOwner(String customQuery){
        this.query = customQuery;
    }
    
    public SCH_BCH_CRM_sendEmailToOppOwner(){
    }
    
    /*
     * @param Query String to Run Batch.
     * Purpose : use only for Test Class
    */
    public void scheduleBatch(String testQuery){
        String CRON_EXP = '00 00 09 ? * FRI *';
        if(Test.isRunningTest()){
            String jobId = System.schedule('SCH_BCH_CRM_sendEmailToOppOwnerTestV1',CRON_EXP, new SCH_BCH_CRM_sendEmailToOppOwner(testQuery));
        }
    }
    
    public void execute(SchedulableContext sc){
        if(query != ''){
            BCH_CRM_sendEmailToOppOwner csb = new BCH_CRM_sendEmailToOppOwner(query);
            Database.executeBatch(csb, 10); 
        }
        else{
            BCH_CRM_sendEmailToOppOwner csb = new BCH_CRM_sendEmailToOppOwner();
            Database.executeBatch(csb, 10); 
        }
            
    }
}