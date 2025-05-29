global class SCH_Qualtrics_CS_CreateSurveyForm implements Schedulable{
    global void execute(SchedulableContext sc){
        BCH_Qualtrics_CS_CreateSurveyForm csb = new BCH_Qualtrics_CS_CreateSurveyForm();
        Database.executeBatch(csb, 9);
    } 
    global static void scheduleBatch(){
        String CRON_EXP = '0 0 19 ? * *';
        if(!Test.isRunningTest()){
            String jobId = System.schedule('SCH_Qualtrics_CS_CreateSurveyForm',CRON_EXP, new SCH_Qualtrics_CS_CreateSurveyForm());
        }else{
            String jobId = System.schedule('SCH_Qualtrics_CS_CreateSurveyFormV1',CRON_EXP, new SCH_Qualtrics_CS_CreateSurveyForm());
        }
    }
}