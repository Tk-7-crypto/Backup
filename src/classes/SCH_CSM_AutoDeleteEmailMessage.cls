global class SCH_CSM_AutoDeleteEmailMessage implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_AutoDeleteEmailMessage batch = new BCH_CSM_AutoDeleteEmailMessage();
        database.executeBatch(batch, 1);
    }

}