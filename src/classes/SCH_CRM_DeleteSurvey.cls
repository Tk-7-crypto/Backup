global class SCH_CRM_DeleteSurvey implements Schedulable {
    global void execute(SchedulableContext sc) {
        BCH_CRM_DeleteSurvey deleteSurvey = new BCH_CRM_DeleteSurvey();
        Database.executebatch(deleteSurvey); 
    }       
}