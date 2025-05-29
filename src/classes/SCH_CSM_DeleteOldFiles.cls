global class SCH_CSM_DeleteOldFiles implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_DeleteOldFiles batch = new BCH_CSM_DeleteOldFiles();
        database.executeBatch(batch, 1);
    }
}