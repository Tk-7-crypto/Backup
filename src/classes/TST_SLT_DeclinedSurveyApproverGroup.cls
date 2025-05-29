@Istest
private class TST_SLT_DeclinedSurveyApproverGroup {
    @Istest
    private static void testGetDeclinedSurveyApproverGroupOrderByPriority() {
        DeclinedSurveyApproverGroup__c declinedApproverGroup = UTL_TestData.createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Client Sat Approver Canada', 1);
        insert declinedApproverGroup; 
        Set<String> testdata = new Set<String>{CON_Qualtrics.ALL};
        Test.startTest();
            List<DeclinedSurveyApproverGroup__c> declinedApproverListNonRDS = 
                new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApproverNonRDSOrderByPriority(testdata, testdata, testdata, testdata, testdata, testdata, testdata);
        List<DeclinedSurveyApproverGroup__c> declinedApproverListRDS = 
                new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApproverRDSOrderByPriority(testdata, testdata);
        Test.stopTest();
        
    }
    
    @Istest
    private static void testgetDeclinedSurveyApprovernonRDSWithLOBset() {
        DeclinedSurveyApproverGroup__c declinedApproverGroup = UTL_TestData.createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Client Sat Approver Canada', 1);
        insert declinedApproverGroup; 
        Set<String> oppBUtest = new Set<String>{CON_Qualtrics.ALL};
		Set<String> LOBtest = new Set<String>{'Medical Affairs'};
                
        Test.startTest();
            List<DeclinedSurveyApproverGroup__c> declinedApproverListNonRDS = 
                new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApprovernonRDSWithLOBset(oppBUtest,LOBtest);
        Test.stopTest();
        
    }
}