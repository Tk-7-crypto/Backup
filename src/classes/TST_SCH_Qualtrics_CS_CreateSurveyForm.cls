@isTest
private class TST_SCH_Qualtrics_CS_CreateSurveyForm {

    @IsTest
    static void schedulerTest(){
        Test.startTest();
        SCH_Qualtrics_CS_CreateSurveyForm.scheduleBatch(); 
        Test.stopTest(); 
    }
}