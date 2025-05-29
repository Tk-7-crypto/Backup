global class SCH_CSM_CaseUpdateOLAElapsed implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_CaseUpdateOLAElapsed batch = new BCH_CSM_CaseUpdateOLAElapsed();
        database.executeBatch(batch, 1);
    }
}