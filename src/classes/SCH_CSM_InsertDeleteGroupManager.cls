global class SCH_CSM_InsertDeleteGroupManager implements Schedulable{
 global void execute(SchedulableContext SC) {
        BCH_CSM_InsertDeleteGroupManager batch = new BCH_CSM_InsertDeleteGroupManager();
        database.executeBatch(batch, 1);
    }
}