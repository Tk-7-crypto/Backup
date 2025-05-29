@isTest
public class TST_SCH_CRM_sendEmailForOnHoldOpp {
    
    @IsTest
    static void schedulerTest(){
        Test.startTest();
        SCH_CRM_sendEmailForOnHoldOpp sch = new SCH_CRM_sendEmailForOnHoldOpp();
        sch.scheduleBatch('Select id from User Where Id =  \''+Userinfo.getUserId()+'\''); 
        Test.stopTest(); 
    }

}