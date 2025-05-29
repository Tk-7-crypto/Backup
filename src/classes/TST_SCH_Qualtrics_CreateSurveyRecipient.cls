@isTest
private class TST_SCH_Qualtrics_CreateSurveyRecipient {
    
    @IsTest
    static void schedulerTest() {
        Test.startTest();
        SCH_Qualtrics_CreateSurveyRecipient.scheduleBatch();
        Test.stopTest(); 
    }
}