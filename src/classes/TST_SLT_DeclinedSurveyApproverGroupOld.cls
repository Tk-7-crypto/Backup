@isTest
public class TST_SLT_DeclinedSurveyApproverGroupOld {
    static testMethod void test1(){
        SLT_DeclinedSurveyApproverGroupOld ss = new SLT_DeclinedSurveyApproverGroupOld();
    }
    /*
	@Istest
    private static void testGetDeclinedSurveyApproverGroupOrderByPriority() {
        DeclinedSurveyApproverGroup__c declinedApproverGroup = UTL_TestData.createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Client Sat Approver Canada', 1);
        insert declinedApproverGroup; 
        
        Test.startTest();
            List<DeclinedSurveyApproverGroup__c> declinedApproverList = 
                new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApproverGroupOrderByPriority();
        Test.stopTest();
        
        System.assertEquals(1, declinedApproverList.size(), 'Got Declined Approver');
    }
	*/
}