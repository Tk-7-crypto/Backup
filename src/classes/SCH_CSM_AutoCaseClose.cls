global class SCH_CSM_AutoCaseClose implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_AutoCaseClose batch = new BCH_CSM_AutoCaseClose();
        database.executeBatch(batch, 1);
    }

}