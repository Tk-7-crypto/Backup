global class Sch_BCH_BatchQueue implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_BatchQueueUser b = new BCH_CSM_BatchQueueUser();
        database.executeBatch(b, 1);
    }
}