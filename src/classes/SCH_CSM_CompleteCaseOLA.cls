global class SCH_CSM_CompleteCaseOLA  implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_CompleteCaseOLA batch = new BCH_CSM_CompleteCaseOLA();
        database.executeBatch(batch, 1);
    }
}