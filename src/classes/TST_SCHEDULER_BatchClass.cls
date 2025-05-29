@IsTest
public class TST_SCHEDULER_BatchClass {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        Sch_BCH_BatchQueue s = new Sch_BCH_BatchQueue();
        String sch = '0 0 23 * * ?'; 
        system.schedule('TST_SCHEDULER_BatchClass', sch, s); 
        Test.stopTest();
    }


}