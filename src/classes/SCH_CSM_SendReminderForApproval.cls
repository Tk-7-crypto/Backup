global class SCH_CSM_SendReminderForApproval implements Schedulable {
    global void execute(SchedulableContext SC) {
        BCH_CSM_SendReminderForApproval batch = new BCH_CSM_SendReminderForApproval();
        database.executeBatch(batch, 200);
    }
}