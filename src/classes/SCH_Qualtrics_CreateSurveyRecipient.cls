global class SCH_Qualtrics_CreateSurveyRecipient implements Schedulable {
    global void execute(SchedulableContext sc) {
        BCH_Qualtrics_CreateSurveyRecipient surveyRecipient = new BCH_Qualtrics_CreateSurveyRecipient();
        Database.executebatch(surveyRecipient,9); 
    }    
    global static void scheduleBatch(){
        String CRON_EXP = '0 45 12 ? * *';
        if(!Test.isRunningTest()){
            String jobId = System.schedule('SCH_Qualtrics_CreateSurveyRecipient',CRON_EXP, new SCH_Qualtrics_CreateSurveyRecipient());
        }else{
            String jobId = System.schedule('SCH_Qualtrics_CreateSurveyRecipientV1',CRON_EXP, new SCH_Qualtrics_CreateSurveyRecipient());
        }
    }
}