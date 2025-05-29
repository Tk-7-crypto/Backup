@isTest
public class TST_SCH_CSM_SendEmailRnDKBAccountMgmt {
    
    static testmethod void testSchedule(){
        SCH_CSM_SendEmailRnDKBAccountMgmt te = new SCH_CSM_SendEmailRnDKBAccountMgmt();
        String sch = '0 0 * * * ?';
        String jobID = system.schedule('Run SCH_CSM_SendEmailRnDKBAccountMgmt', sch, te);
        
    }    
    
}