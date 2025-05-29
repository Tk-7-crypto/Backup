@isTest
public class TST_SCH_BCH_CRM_sendEmailToOppOwner {

    @IsTest
    static void schedulerTest(){
        Test.startTest();
        SCH_BCH_CRM_sendEmailToOppOwner sch = new SCH_BCH_CRM_sendEmailToOppOwner();
        sch.scheduleBatch('Select id from User Where Id =  \''+Userinfo.getUserId()+'\''); 
        Test.stopTest(); 
    }
}